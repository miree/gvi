library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_pkg is
	type t_uart_parallel is record
		dat   : std_logic_vector(7 downto 0);
		stb   : std_logic;
		stall : std_logic;
	end record;
	constant c_uart_parallel_init : t_uart_parallel := ((others => '0'), others => '0');
end package;

package body uart_pkg is
end package body;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	generic (
		g_clk_freq  : integer := 12000000;
		g_baud_rate : integer := 9600;
		g_bits      : integer := 8
	);
	port (
		clk_i   :  in std_logic;
		-- parallel 
		dat_i   :  in std_logic_vector(g_bits-1 downto 0);
		stb_i   :  in std_logic;
		stall_o : out std_logic;
		-- serial 
		tx_o    : out std_logic
	);	
end entity;

architecture rtl of uart_tx is
	
	subtype bit_index_t is integer range 0 to g_bits+1;
	signal bit_index : bit_index_t := 0;

	function countup_loop(index : bit_index_t) return bit_index_t is
	begin
		if index = bit_index_t'high then return 0; end if;
		return index + 1;
	end function;

	
	subtype wait_count_t is integer range 0 to g_clk_freq / g_baud_rate-1;
	signal wait_count : wait_count_t := wait_count_t'high;

	function countdown_loop(count : wait_count_t) return wait_count_t is 
	begin
		if count > 0 then return count - 1; end if;
		return wait_count_t'high;
	end function;

	type state_t is (s_idle, s_sending);
	signal state : state_t := s_idle;

	signal busy    : std_logic := '0';
	signal tx_data : std_logic_vector(bit_index_t'high downto 0) := (others => '1');

begin
	tx_o    <= tx_data(0);

	stall_o <= '0' when (bit_index = bit_index_t'high and wait_count = 0) 
	                or state = s_idle
	      else '1';

	process
	begin
		wait until rising_edge(clk_i);

		case state is

			when s_idle =>
				if stb_i = '1' then
					-- add stop('1') and start('0') bit
					tx_data <= '1' & dat_i & '0'; 
					state   <= s_sending;
				end if;

			when s_sending =>
				wait_count <= countdown_loop(wait_count);

				if wait_count = 0 then
					bit_index <= countup_loop(bit_index);

					-- right-shift tx_data
					tx_data   <= '1' & tx_data(bit_index_t'high downto 1);

					-- end of data
					if bit_index = bit_index_t'high then
						if stb_i = '1' then -- directly send next byte
							-- add stop('1') and start('0') bit
							tx_data <= '1' & dat_i & '0'; 
						else 
							-- wait for next data to come
							state <= s_idle;
						end if;
					end if;

				end if;

		end case;

	end process;
	
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
	generic (
		g_clk_freq  : integer := 12000000;
		g_baud_rate : integer := 9600;
		g_bits      : integer := 8
	);
	port (
		clk_i   :  in std_logic;
		-- parallel 
		dat_o   : out std_logic_vector(g_bits-1 downto 0);
		stb_o   : out std_logic;
		-- serial 
		rx_i    :  in std_logic
	);	
end entity;

architecture rtl of uart_rx is
	
	subtype bit_index_t is integer range 0 to g_bits-1;
	signal bit_index : bit_index_t := 0;

	function countup_loop(index : bit_index_t) return bit_index_t is
	begin
		if index = bit_index_t'high then return 0; end if;
		return index + 1;
	end function;

	
	subtype wait_count_t is integer range 0 to g_clk_freq / g_baud_rate-1;
	signal wait_count : wait_count_t := wait_count_t'high;

	function countdown_loop(count : wait_count_t) return wait_count_t is 
	begin
		if count > 0 then return count - 1; end if;
		return wait_count_t'high;
	end function;

	type state_t is (s_idle, s_align, s_receiving);
	signal state : state_t := s_idle;

	signal rx_data : std_logic_vector(bit_index_t'high downto 0) := (others => '1');
	signal stb     : std_logic := '0';
	signal rx_sync : std_logic_vector(2 downto 0) := (others => '1');
begin

	stb_o <= stb;
	dat_o <= rx_data;

	process
	begin
		wait until rising_edge(clk_i);
		rx_sync <= rx_sync(1 downto 0) & rx_i;

		stb <= '0';

		case state is

			when s_idle =>
				-- detect falling edge on rx line
				if rx_sync(2) = '1' and rx_sync(1) = '0' then
					wait_count <= wait_count_t'high/2;
					if (wait_count_t'high+1)/2 > 0 then
						state <= s_align;
					else 
						state <= s_receiving;
					end if;
				end if;

			when s_align =>
				wait_count <= countdown_loop(wait_count);
				if wait_count = 0 then
					-- we are in the center of the start bit
					state <= s_receiving;
				end if;

			when s_receiving =>
				wait_count <= countdown_loop(wait_count);
				if wait_count = 0 then
					bit_index <= countup_loop(bit_index);

					-- right-shift rx_data
					rx_data <= rx_sync(1) & rx_data(bit_index_t'high downto 1);

					-- received last bit
					if bit_index = bit_index_t'high then
						stb <= '1';
						state <= s_idle;
					end if;

				end if;

		end case;

	end process;
	
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- a wrapper for uart_rx that has a stall input
-- and buffers the last received value as long as
-- this stall input is asserted
entity uart_rx_buffer is
	generic (
		g_clk_freq  : integer := 12000000;
		g_baud_rate : integer := 9600;
		g_bits      : integer := 8
	);
	port (
		clk_i   :  in std_logic;
		-- parallel 
		dat_o   : out std_logic_vector(g_bits-1 downto 0);
		stb_o   : out std_logic;
		stall_i :  in std_logic;
		-- serial 
		rx_i    :  in std_logic
	);	
end entity;

architecture rtl of uart_rx_buffer is
	signal dat       : std_logic_vector(g_bits-1 downto 0) := (others => '0');
	signal buf       : std_logic_vector(g_bits-1 downto 0) := (others => '0');
	signal buf_valid : std_logic := '0';
	signal stb       : std_logic := '0';
begin

	wrapped_rx: entity work.uart_rx 
		generic map (g_clk_freq, g_baud_rate, g_bits)
		port map(clk_i => clk_i, 
			     dat_o => dat, 
			     stb_o => stb,
			     rx_i  => rx_i);

	dat_o <= buf;
	stb_o <= buf_valid;

	process
	begin
		wait until rising_edge(clk_i);
		if stb = '1' then
			if buf_valid = '1' and stall_i = '1' then
				assert false report "UART receiver overflow" severity failure; 
				               -- In this case one uart value is dropped
				               -- This condition should be prevented by the host
				               -- by not sending the serial bytes too fast
			end if;
			buf       <= dat;
			buf_valid <= '1';
		elsif buf_valid = '1' and stall_i = '0' then
			buf_valid <= '0';
		end if;

	end process;

end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- merge two uart sources (parallel, before serialization)
entity uart_multiplex is
	generic (
		g_bits      : integer := 8
	);
	port (
		clk_i   :  in std_logic;
		-- parallel out 
		dat_o   : out std_logic_vector(g_bits-1 downto 0);
		stb_o   : out std_logic;
		stall_i :  in std_logic;
		-- parallel in 1
		dat_1_i   :  in std_logic_vector(g_bits-1 downto 0);
		stb_1_i   :  in std_logic;
		stall_1_o : out std_logic;
		-- parallel in 2
		dat_2_i   :  in std_logic_vector(g_bits-1 downto 0);
		stb_2_i   :  in std_logic;
		stall_2_o : out std_logic
	);	
end entity;

architecture rtl of uart_multiplex is
	type t_state is (s_source_1, s_source_2);
	signal state : t_state := s_source_1;

	signal dat_out : std_logic_vector(g_bits-1 downto 0) := (others => '0');
	signal stb_out : std_logic := '0';
begin 

	dat_o <= dat_1_i when state = s_source_1 
	    else dat_2_i;

	stb_o <= stb_1_i when state = s_source_1 
	    else stb_2_i;

	stall_1_o <= stall_i when state = s_source_1 
	        else '1';

	stall_2_o <= stall_i when state = s_source_2 
	        else '1';

	process 
	begin
		wait until rising_edge(clk_i);
		case state is 
			when s_source_1 =>
				if stb_1_i = '0' and stb_2_i = '1' then
					state <= s_source_2;
				end if;

			when s_source_2 =>
				if stb_2_i = '0' and stb_1_i = '1' then
					state <= s_source_1;
				end if;
		end case;

	end process;
	
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- store parallel uart signals in registers to improve timing
entity uart_register is
	generic (
		g_bits      : integer := 8
	);
	port (
		clk_i   :  in std_logic;
		-- parallel out 
		dat_o   : out std_logic_vector(g_bits-1 downto 0);
		stb_o   : out std_logic;
		stall_i :  in std_logic;
		-- parallel in 1
		dat_i   :  in std_logic_vector(g_bits-1 downto 0);
		stb_i   :  in std_logic;
		stall_o : out std_logic
	);	
end entity;

architecture rtl of uart_register is
	signal dat_out   : std_logic_vector(g_bits-1 downto 0) := (others => '0');
	signal stb_out   : std_logic := '0';
	signal stall_out : std_logic := '0';
begin 

	dat_o   <= dat_out;
	stb_o   <= stb_out;
	stall_o <= stall_out;
	process	
	begin 
		wait until rising_edge(clk_i);
		dat_out   <= dat_i;
		stall_out <= stall_i;
		stb_out   <= stb_i;
	end process;
	
end architecture;


