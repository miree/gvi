library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  


package serv_rf_pkg is
	component serv_rf_top is
	port (
		clk          :  in std_logic;
		i_rst        :  in std_logic;
		i_timer_irq  :  in std_logic;
		o_ibus_adr   : out std_logic_vector(31 downto 0);
		o_ibus_cyc   : out std_logic;
		i_ibus_rdt   :  in std_logic_vector(31 downto 0);
		i_ibus_ack   :  in std_logic;
		o_dbus_adr   : out std_logic_vector(31 downto 0);
		o_dbus_dat   : out std_logic_vector(31 downto 0);
		o_dbus_sel   : out std_logic_vector(3 downto 0);
		o_dbus_we    : out std_logic;
		o_dbus_cyc   : out std_logic;
		i_dbus_rdt   :  in std_logic_vector(31 downto 0);
		i_dbus_ack   :  in std_logic;
		o_ext_rs1    : out std_logic_vector(31 downto 0);
		o_ext_rs2    : out std_logic_vector(31 downto 0);
		o_ext_funct3 : out std_logic_vector(2 downto 0);
		i_ext_rd     :  in std_logic_vector(31 downto 0);
		i_ext_ready  :  in std_logic;
		o_mdu_valid  : out std_logic
	);
	end component;

	component mdu_top
	port(
		i_clk       :  in std_logic;
		i_rst       :  in std_logic;
		i_mdu_op    :  in std_logic_vector(2 downto 0);
		i_mdu_valid :  in std_logic;
		o_mdu_ready : out std_logic;
		i_mdu_rs1   :  in std_logic_vector(31 downto 0);
		i_mdu_rs2   :  in std_logic_vector(31 downto 0);
		o_mdu_rd    : out std_logic_vector(31 downto 0));
	end component;

end package;

package body serv_rf_pkg is
end package body;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.wbp_pkg.all;
use work.serv_rf_pkg.all;


entity serv_rf_wbp is
port(
	clk_i : in  std_logic;
	rst_i : in  std_logic;
	irq_i : in  std_logic_vector(31 downto 0);
	-- instruction interface
	wbi_o : out t_wbp_master_out;
	wbi_i : in  t_wbp_master_in;
	-- data interface
	wbd_o : out t_wbp_master_out;
	wbd_i : in  t_wbp_master_in
);
end entity;

architecture rtl of serv_rf_wbp is
	--signal trap    : std_logic := '0';
	signal wbio         : t_wbp_master_out := c_wbp_master_out_init;
	signal wbdo         : t_wbp_master_out := c_wbp_master_out_init;

	signal o_ext_rs1    : std_logic_vector(31 downto 0) := (others => '0');
	signal o_ext_rs2    : std_logic_vector(31 downto 0) := (others => '0');
	signal o_ext_funct3 : std_logic_vector(2 downto 0)  := (others => '0');
	signal i_ext_rd     : std_logic_vector(31 downto 0) := (others => '0');
	signal i_ext_ready  : std_logic := '0';
	signal o_mdu_valid  : std_logic := '0';

	signal wbdo_stb, wbio_stb : std_logic;
	type state_t is (s_idle, s_wait_for_ack);
	signal state_d, state_i : state_t := s_idle;

	procedure wb_classic_to_pipeline(signal state : inout state_t; signal wb_i : in t_wbp_master_in; signal wb_o : in t_wbp_master_out) is
	begin
		-- state management
		case state is 
				when s_idle => 
					if wb_o.stb = '1' and wb_i.stall = '0' and wb_i.ack = '0' then
						state <= s_wait_for_ack;
					end if;
				when s_wait_for_ack => 
					if wb_i.ack = '1' then 
						state <= s_idle;
					end if;
		end case;
	end procedure;

begin
	-- conversion from classical_wb to pipelined_wb
	process
	begin
		wait until rising_edge(clk_i);
		wb_classic_to_pipeline(state_i, wbi_i, wbio);
		wb_classic_to_pipeline(state_d, wbd_i, wbdo);
		--assert trap='0'  report "cpu trapped" severity failure;
	end process;

	-- stb line control
	wbio_stb <= wbio.stb when state_i = s_idle else '0';
	wbdo_stb <= wbdo.stb when state_d = s_idle else '0';

	---- make sure the cycle is ended when rst is asserted
	wbi_o <= (wbio.cyc, wbio_stb, wbio.adr, wbio.sel, wbio.we, wbio.dat) when rst_i = '0' 
			else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));
	wbd_o <= (wbdo.cyc, wbdo_stb, wbdo.adr, wbdo.sel, wbdo.we, wbdo.dat) when rst_i = '0' 
			else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));

	-- cycle and stb assume the same value
	wbdo.stb <= wbdo.cyc;
	wbio.stb <= wbio.cyc;

	wbio.sel <= "1111"; -- always select all bytes on istruction bus
	wbio.we  <= '0';    -- always read on instruction bus
	wbio.dat <= (others => '-'); -- don't care about output data bits on instruction bus

	--wbi_o <= wbio;
	--wbd_o <= wbdo;

	cpu : serv_rf_top
	port map (
		clk          => clk_i,
		i_rst        => rst_i,
		i_timer_irq  => irq_i(0),
		o_ibus_adr   => wbio.adr,
		o_ibus_cyc   => wbio.cyc,
		i_ibus_rdt   => wbi_i.dat,
		i_ibus_ack   => wbi_i.ack,
		o_dbus_adr   => wbdo.adr,
		o_dbus_dat   => wbdo.dat,
		o_dbus_sel   => wbdo.sel,
		o_dbus_we    => wbdo.we,
		o_dbus_cyc   => wbdo.cyc,
		i_dbus_rdt   => wbd_i.dat,
		i_dbus_ack   => wbd_i.ack,
		o_ext_rs1    => o_ext_rs1,
		o_ext_rs2    => o_ext_rs2,
		o_ext_funct3 => o_ext_funct3,
		i_ext_rd     => i_ext_rd,
		i_ext_ready  => i_ext_ready,
		o_mdu_valid  => o_mdu_valid
	);

	mdu: mdu_top
	port map (
		i_clk       => clk_i,
		i_rst       => rst_i,
		i_mdu_op    => o_ext_funct3,
		i_mdu_valid => o_mdu_valid,
		o_mdu_ready => i_ext_ready,
		i_mdu_rs1   => o_ext_rs1,
		i_mdu_rs2   => o_ext_rs2,
		o_mdu_rd    => i_ext_rd
	);
	
end architecture;

