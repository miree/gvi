library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal rd_clk    : std_logic := '0';
	signal wr_clk    : std_logic := '0';
	signal rd_en     : std_logic := '0';
	signal wr_en     : std_logic := '0';
	signal rst       : std_logic := '1';
	signal empty     : std_logic := '0';
	signal full      : std_logic := '0';
	signal prog_full : std_logic := '0';
	signal din       : std_logic_vector(63 downto 0) := (others => '1');
	signal dout      : std_logic_vector(63 downto 0) := (others => '0');
begin

	rd_clk <= not rd_clk after 2.1 ns;
	wr_clk <= not wr_clk after 5.0 ns;
	rst <= '0' after 20 ns;

	write: process
		variable cnt : integer := 0;
	begin
		wait until rising_edge(wr_clk);
		cnt := cnt + 1;
		din <= std_logic_vector(to_unsigned(cnt,64));
		case cnt is
			when 5 => wr_en <= '1'; 
			when 170 => wr_en <= '0';
			when others => 
		end case;
	end process;

	read: process
		variable cnt : integer := 0;
	begin
		wait until rising_edge(rd_clk);
		cnt := cnt + 1;
		case cnt is
			when 255 => rd_en <= '1';
			when 390 => rd_en <= '0';
			when others => 
		end case;
	end process;

		
	dut: entity work.clock_crossing_fifo
	port map(
		rd_clk    => rd_clk,
		wr_clk    => wr_clk,
		rd_en     => rd_en,
		wr_en     => wr_en,
		rst       => rst,
		empty     => empty,
		full      => full,
		prog_full => prog_full,
		din       => din,
		dout      => dout);

end architecture simulation;
