library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbp_pkg.all;

--  S S
--  |/
--  M
entity wbp_2s1m is
	port (
		clk_i    : in  std_logic;
		slaves_i : in  t_wbp_slave_in_array(0 to 1);
		slaves_o : out t_wbp_slave_out_array(0 to 1);
		master_o : out t_wbp_master_out;
		master_i : in  t_wbp_master_in
		);
end entity;

architecture rtl of wbp_2s1m is
	type t_state is (s_cyc0, s_cyc1);
	signal state : t_state := s_cyc0;
	signal slave0_prio : boolean;
begin
	slave0_prio <= state = s_cyc0 or (state = s_cyc1 and slaves_i(1).cyc = '0');
	master_o <= slaves_i(0) when slave0_prio and slaves_i(0).cyc = '1' 
	       else slaves_i(1) when slaves_i(1).cyc = '1'
	       else (cyc=>'0',stb=>'0',we=>'-',sel=>(others=>'-'),adr=>(others=>'-'),dat=>(others=>'-'));

	slaves_o(0) <= master_i  when slave0_prio and slaves_i(0).cyc = '1'
	          else (ack=>'0',err=>'0',rty=>'0',stall=>'1',dat=>(others=>'-'));

	slaves_o(1) <= master_i  when state = s_cyc1 or (slaves_i(1).cyc = '1' and slaves_i(0).cyc = '0') 
	          else (ack=>'0',err=>'0',rty=>'0',stall=>'1',dat=>(others=>'-')); 

	process
	begin
		wait until rising_edge(clk_i);
		case state is
			when s_cyc0 =>
				if slaves_i(1).cyc = '1' and slaves_i(0).cyc = '0' then
					state <= s_cyc1;
				end if;
			when s_cyc1 =>
				if slaves_i(1).cyc = '0' then
					state <= s_cyc0;
				end if;
		end case;
	end process;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbp_pkg.all;

--   S
--  /|
-- M M
entity wbp_1s2m is
	generic (
		adr_bit : natural
		);
	port (
		clk_i     : in  std_logic;
		slave_i   : in  t_wbp_slave_in;
		slave_o   : out t_wbp_slave_out;
		masters_o : out t_wbp_master_out_array(0 to 1);
		masters_i : in  t_wbp_master_in_array(0 to 1)
		);
end entity;

architecture rtl of wbp_1s2m is 
	signal master_o : t_wbp_master_out := c_wbp_master_out_init;
begin
	master_o.cyc                     <= slave_i.cyc;
	master_o.stb                     <= slave_i.stb;
	master_o.we                      <= slave_i.we;
	master_o.adr(31 downto adr_bit ) <= (others => '0');
	master_o.adr(adr_bit-1 downto 0) <= slave_i.adr(adr_bit-1 downto 0);
	master_o.dat                     <= slave_i.dat;
	master_o.sel                     <= slave_i.sel;
	masters_o(0) <= master_o when unsigned(slave_i.adr(31 downto adr_bit)) = 0 
	             else (cyc=>'0',stb=>'0',we=>'-',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));
	masters_o(1) <= master_o when unsigned(slave_i.adr(31 downto adr_bit)) /= 0 
	             else (cyc=>'0',stb=>'0',we=>'-',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));
	slave_o <= masters_i(0) when unsigned(slave_i.adr(31 downto adr_bit)) = 0
	           else masters_i(1);
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbp_pkg.all;

-- This implementation stalls if the adressed slave changes while 
-- there are non-acked stbs on the previously adressed slave.
-- This is achieved by counting number of open stbs and costs more resources
--   S
--  /|
-- M M
entity wbp_1s2m_protected is
	generic (
		adr_bit : natural
		);
	port (
		clk_i     : in  std_logic;
		slave_i   : in  t_wbp_slave_in;
		slave_o   : out t_wbp_slave_out;
		masters_o : out t_wbp_master_out_array(0 to 1);
		masters_i : in  t_wbp_master_in_array(0 to 1)
		);
end entity;

architecture rtl of wbp_1s2m_protected is 
	type t_state is (s_idle, s_cyc0, s_cyc1);
	signal state : t_state := s_idle;
	signal sel_0, sel_1, stall: boolean := false; 
	signal inc_cnt, dec_cnt: boolean := false;
	signal cnt : integer := 0;
begin
	masters_o(0) <= slave_i when sel_0 and not stall
				else (cyc=>'1',stb=>'0',we=>'-',adr=>(others=>'0'),dat=>(others=>'-'),sel=>(others=>'-')) when sel_0 and stall
	             else (cyc=>'0',stb=>'0',we=>'-',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));
	masters_o(1) <= slave_i when sel_1 and not stall
				else (cyc=>'1',stb=>'0',we=>'-',adr=>(others=>'0'),dat=>(others=>'-'),sel=>(others=>'-')) when sel_1 and stall
	             else (cyc=>'0',stb=>'0',we=>'-',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));

	slave_o <=  (ack=>masters_i(0).ack,err=>masters_i(0).err,rty=>masters_i(0).rty,stall=>slave_i.cyc,dat=>masters_i(0).dat) when sel_0 and stall
	       else (ack=>masters_i(1).ack,err=>masters_i(1).err,rty=>masters_i(1).rty,stall=>slave_i.cyc,dat=>masters_i(1).dat) when sel_1 and stall
	       else masters_i(0) when sel_0 
	       else masters_i(1) when sel_1
	       else (ack=>'-',err=>'-',rty=>'-',stall=>'-',dat=>(others=>'-'));


	sel_0 <= (state = s_cyc0 and slave_i.cyc = '1') or 
	         (state = s_idle and slave_i.adr(adr_bit) = '0') or 
	         (state = s_cyc1 and slave_i.adr(adr_bit) = '0' and cnt = 0);

	sel_1 <= (state = s_cyc1  and slave_i.cyc = '1') or 
	         (state = s_idle and slave_i.adr(adr_bit) = '1') or
	         (state = s_cyc0 and slave_i.adr(adr_bit) = '1' and cnt = 0);

	stall   <= (state = s_cyc0 and slave_i.adr(adr_bit) = '1' and cnt /= 0) or
	         (state = s_cyc1 and slave_i.adr(adr_bit) = '0' and cnt /= 0);

	lock: process
	begin
		wait until rising_edge(clk_i);
		case state is
			when s_idle => 
				if slave_i.cyc = '1' then
					if slave_i.adr(adr_bit) = '0' then 
						state <= s_cyc0;
					else
						state <= s_cyc1;
					end if;
				end if;
			when s_cyc0 =>
				if slave_i.cyc = '0' then
					state <= s_idle;
				elsif slave_i.adr(adr_bit) = '1' and ((cnt = 0) or (cnt = 1 and dec_cnt)) then
					state <= s_cyc1;
				end if;
			when s_cyc1 =>
				if slave_i.cyc = '0' then
					state <= s_idle;
				elsif slave_i.adr(adr_bit) = '0' and ((cnt = 0) or (cnt = 1 and dec_cnt)) then
					state <= s_cyc0;
				end if;
		end case;
		if inc_cnt then cnt <= cnt+1; end if;
		if dec_cnt then cnt <= cnt-1; end if;
	end process;

	inc_cnt <= (sel_0 and masters_i(0).ack = '0' and masters_i(0).err = '0' and masters_i(0).rty = '0' and slave_i.stb = '1') or 
	           (sel_1 and masters_i(1).ack = '0' and masters_i(1).err = '0' and masters_i(1).rty = '0' and slave_i.stb = '1');
	dec_cnt <= (sel_0 and (masters_i(0).ack = '1' or masters_i(0).err = '1' or masters_i(0).rty = '1') and (slave_i.stb = '0' or stall)) or
	           (sel_1 and (masters_i(1).ack = '1' or masters_i(1).err = '1' or masters_i(1).rty = '1') and (slave_i.stb = '0' or stall));
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbp_pkg.all;

--  S S
--  |X|
--  M M
-- 
--  is build like this from basic blocks
--      S S     
--     /| |\    
--    M M M M   
--    S S S S   
--    |  X  |  
--    | / \ |   
--    |/   \|   
--    M     M     
--
entity wbp_2s2m_crossbar is
	generic (
		adr_bit : natural
	);
	port (
		clk_i     : in  std_logic;
		slaves_i  : in  t_wbp_slave_in_array(0 to 1);
		slaves_o  : out t_wbp_slave_out_array(0 to 1);
		masters_o : out t_wbp_master_out_array(0 to 1);
		masters_i : in  t_wbp_master_in_array(0 to 1)
	);
end entity;

architecture rtl of wbp_2s2m_crossbar is
	signal intermediate : t_wbp_array(0 to 3);
begin

	spread_0: entity work.wbp_1s2m
	generic map(adr_bit=>adr_bit)
	port map(clk_i=>clk_i, 
		    slave_i=>slaves_i(0), 
		    slave_o=>slaves_o(0), 
		    masters_o(0)=>intermediate(0).mosi,
		    masters_o(1)=>intermediate(1).mosi, 
		    masters_i(0)=>intermediate(0).miso,
		    masters_i(1)=>intermediate(1).miso);
	spread_1: entity work.wbp_1s2m
	generic map(adr_bit=>adr_bit)
	port map(clk_i=>clk_i, 
		    slave_i=>slaves_i(1), 
		    slave_o=>slaves_o(1), 
		    masters_o(0)=>intermediate(2).mosi,
		    masters_o(1)=>intermediate(3).mosi, 
		    masters_i(0)=>intermediate(2).miso,
		    masters_i(1)=>intermediate(3).miso);

	combine_0: entity work.wbp_2s1m
	port map(clk_i       => clk_i,
		     slaves_i(0) => intermediate(0).mosi,
		     slaves_i(1) => intermediate(2).mosi,
		     slaves_o(0) => intermediate(0).miso,
		     slaves_o(1) => intermediate(2).miso,
		     master_o    => masters_o(0),
		     master_i    => masters_i(0));

	combine_1: entity work.wbp_2s1m
	port map(clk_i       => clk_i,
		     slaves_i(0) => intermediate(1).mosi,
		     slaves_i(1) => intermediate(3).mosi,
		     slaves_o(0) => intermediate(1).miso,
		     slaves_o(1) => intermediate(3).miso,
		     master_o    => masters_o(1),
		     master_i    => masters_i(1));

end architecture;





