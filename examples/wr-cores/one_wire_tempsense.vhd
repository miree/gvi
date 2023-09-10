library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_wire_tempsense is
	port (
		owr_i : in  std_logic;
		owr_o : out std_logic
	);
end entity;

architecture simulation of one_wire_tempsense is
	signal clk : std_logic := '1';
	signal owr, owr_old : std_logic := '1';
	signal owr_out : std_logic := '1';
	type state_t is (s_idle, 
		             s_reset, 
		             s_wait_end_reset, -- wait until rising edge of owr
		             s_wait_present,   -- wait 30 us then to to s_signal_presence
		             s_signal_presence -- pull owr_out down for 60 us
		             );
	signal state : state_t := s_idle;
begin

	clk <= not clk after 500 ns; -- 1 MHz clock , 1 us period

	owr_o <= owr_out;

	process
		variable counter : integer := 0;
	begin
		wait until rising_edge(clk);
		owr <= owr_i;
		owr_old <= owr;
		if counter > 0 then counter := counter - 1; end if;
		case state is 
			when s_idle =>
				if owr_old = '1' and owr = '0' then
					counter := 300;
					state <= s_reset;
				end if;
			when s_reset => 
				if owr = '1' then 
					counter := 0;
					state <= s_idle;
				else 
					if counter = 0 then 
						state <= s_wait_end_reset;
					end if;
				end if;
			when s_wait_end_reset =>
				if owr = '1' then 
					state <= s_wait_present;
					counter := 30;
				end if;
			when s_wait_present =>
				if counter = 0 then 
					state <= s_signal_presence;
					counter := 60;
					owr_out <= '0';
				end if;
			when s_signal_presence =>
				if counter = 0 then 
					owr_out <= '1';
				end if;
		end case;
	end process;


end architecture simulation;