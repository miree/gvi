library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  


package urv_cpu_pkg is
  -- vhdl interface to the verilog module  
  component urv_cpu
  port(
    clk_i : in std_logic;
    rst_i : in std_logic;
    irq_i : in std_logic;
    fault_o : out std_logic;
    im_rd_o : out std_logic;
    im_valid_i : in std_logic;
    dm_data_select_o : out std_logic_vector(3 downto 0);
    dm_store_o : out std_logic;
    dm_load_o : out std_logic;
    dm_load_done_i : in std_logic;
    dm_store_done_i : in std_logic;
    dbg_force_i : in std_logic;
    dbg_enabled_o : out std_logic;
    dbg_insn_set_i : in std_logic;
    dbg_insn_ready_o : out std_logic;
    dbg_mbx_write_i : in std_logic;
    im_addr_o : out std_logic_vector(31 downto 0);
    im_data_i : in std_logic_vector(31 downto 0);
    dm_addr_o : out std_logic_vector(31 downto 0);
    dm_data_s_o : out std_logic_vector(31 downto 0);
    dm_data_l_i : in std_logic_vector(31 downto 0);
    dbg_insn_i : in std_logic_vector(31 downto 0);
    dbg_mbx_data_i : in std_logic_vector(31 downto 0);
    dbg_mbx_data_o : out std_logic_vector(31 downto 0));
  end component;
end package;

package body urv_cpu_pkg is
end package body;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.wbp_pkg.all;
use work.urv_cpu_pkg.all;


entity urv_cpu_wbp is
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


architecture rtl of urv_cpu_wbp is

  signal wbio         : t_wbp_master_out := c_wbp_master_out_init;
  signal wbdo         : t_wbp_master_out := c_wbp_master_out_init;


  signal fault_o          : std_logic := '0';
  signal im_rd_o          : std_logic := '0';
  signal im_valid_i       : std_logic := '0';
  signal dm_data_select_o : std_logic_vector(3 downto 0) := (others => '0');
  signal dm_store_o       : std_logic := '0';
  signal dm_load_o        : std_logic := '0';
  signal dm_load_done_i   : std_logic := '0';
  signal dm_store_done_i  : std_logic := '0';
  signal dbg_force_i      : std_logic := '0';
  signal dbg_enabled_o    : std_logic := '0';
  signal dbg_insn_set_i   : std_logic := '0';
  signal dbg_insn_ready_o : std_logic := '0';
  signal dbg_mbx_write_i  : std_logic := '0';
  signal im_addr_o        : std_logic_vector(31 downto 0) := (others => '0');
  signal im_data_i        : std_logic_vector(31 downto 0) := (others => '0');
  signal dm_addr_o        : std_logic_vector(31 downto 0) := (others => '0');
  signal dm_data_s_o      : std_logic_vector(31 downto 0) := (others => '0');
  signal dm_data_l_i      : std_logic_vector(31 downto 0) := (others => '0');
  signal dbg_insn_i       : std_logic_vector(31 downto 0) := (others => '0');
  signal dbg_mbx_data_i   : std_logic_vector(31 downto 0) := (others => '0');
  signal dbg_mbx_data_o   : std_logic_vector(31 downto 0) := (others => '0');

begin

  ---- make sure the cycle is ended when rst is asserted
  wbi_o <= wbio when rst_i = '0' 
      else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));
  wbd_o <= wbdo when rst_i = '0' 
      else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));


  -- instruction bus
  -- ?????   <= wbi_i.stall;
  im_valid_i <= wbi_i.ack;
  im_data_i  <= wbi_i.dat;
  -- ?????   <= wbi_i.err;
  wbio.stb <= wbio.cyc;
  wbio.cyc <= im_rd_o;
  wbio.sel <= "1111";          -- always select all bytes on istruction bus
  wbio.we  <= '0';             -- always read on instruction bus
  wbio.dat <= (others => '-'); -- don't care about output data bits on instruction bus
  wbio.adr <= im_addr_o;

  -- data bus
  dm_load_done_i  <= wbd_i.ack when wbdo.we = '0' else '0';
  dm_store_done_i <= wbd_i.ack when wbdo.we = '1' else '0';
  dm_data_l_i     <= wbd_i.dat;

  process
  begin
    wait until rising_edge(clk_i);   

    if dm_store_o = '1' or dm_load_o = '1' then
      wbdo.adr <= dm_addr_o;
      wbdo.cyc <= '1';
      wbdo.stb <= '1';
      wbdo.sel <= dm_data_select_o;
    elsif wbdo.cyc = '1' and wbdo.stb = '0' and wbd_i.ack = '1' then
      wbdo.cyc <= '0';
    end if;
    if dm_store_o = '1' then
      wbdo.we <= '1';
      wbdo.dat <= dm_data_s_o;
    end if;
    if dm_load_o = '1' then
      wbdo.we <= '0';
    end if;
    if wbdo.stb = '1' and wbd_i.stall = '0' then
      wbdo.stb <= '0';
    end if; 
  end process;

  cpu : urv_cpu
  port map (
    clk_i            => clk_i,
    rst_i            => rst_i,
    irq_i            => irq_i(0),
    fault_o          => fault_o,
    im_rd_o          => im_rd_o,
    im_valid_i       => im_valid_i,
    dm_data_select_o => dm_data_select_o,
    dm_store_o       => dm_store_o,
    dm_load_o        => dm_load_o,
    dm_load_done_i   => dm_load_done_i,
    dm_store_done_i  => dm_store_done_i,
    dbg_force_i      => dbg_force_i,
    dbg_enabled_o    => dbg_enabled_o,
    dbg_insn_set_i   => dbg_insn_set_i,
    dbg_insn_ready_o => dbg_insn_ready_o,
    dbg_mbx_write_i  => dbg_mbx_write_i,
    im_addr_o        => im_addr_o,
    im_data_i        => im_data_i,
    dm_addr_o        => dm_addr_o,
    dm_data_s_o      => dm_data_s_o,
    dm_data_l_i      => dm_data_l_i,
    dbg_insn_i       => dbg_insn_i,
    dbg_mbx_data_i   => dbg_mbx_data_i,
    dbg_mbx_data_o   => dbg_mbx_data_o
  );

  
end architecture;