library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
	generic (portsize : integer := 61);
end entity;

architecture simulation of testbench is
	signal clk_a_i                         : std_logic := '1';
	signal clk_b_i                         : std_logic := '1';
	signal rst_i                         : std_logic := '1';
	signal value_i_old, value_i, value_o : std_logic_vector(portsize-1 downto 0) := ('1', others => '0');
begin

	clk_a_i <= not clk_a_i after 5 ns;
	clk_b_i <= not clk_b_i after 20.1 ns;
	
	check : process
		variable i : integer := 3;
	begin
		wait until rising_edge(clk_a_i);
		if i > 0 then 
			i := i-1;
		else 
			rst_i       <= '0';
			value_i_old <= value_i;
			value_i     <= value_i(0) & value_i(value_i'left downto 1);
			--assert(value_i_old = value_o);
		end if;
	end process;


	dut : entity work.test_v
	port map (
		clk_a_i => clk_a_i,
		clk_b_i => clk_b_i,
		rst_i   => rst_i,
		value_o => value_o,
		value_i => value_i,
		cnt_a_o => open,
		cnt_b_o => open
	);
	dut2 : entity work.test2_v
	port map (
		clk_a_i => clk_a_i,
		clk_b_i => clk_b_i,
		rst_i   => rst_i,
		value_o => open,
		value_i => value_i,
		cnt_a_o => open,
		cnt_b_o => open
	);

end architecture simulation;
