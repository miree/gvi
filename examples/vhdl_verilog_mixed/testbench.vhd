library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk_i        : std_logic := '1';
	signal rst_i        : std_logic := '1';
	signal vhdl_o, verilog_o, mixed_o: std_logic_vector(31 downto 0) := (others => '0');
begin

	clk_i <= not clk_i after 5 ns;
	
	check : process
		variable i : integer := 3;
	begin
		wait until rising_edge(clk_i);
		if i > 0 then i := i-1;
		else rst_i <= '0';
		end if;
		-- check if output of verilog implementation (dut)
		--  is equal to vhdl implementation (ref)
		assert(vhdl_o = verilog_o); 
		assert(vhdl_o = mixed_o);
	end process;


	vhdl : entity work.counter_vhd
	port map (
		clk_i => clk_i,
		rst_i => rst_i,
		cnt_o => vhdl_o
	);
	verilog : entity work.counter_v
	port map (
		clk_i => clk_i,
		rst_i => rst_i,
		cnt_o => verilog_o
	);
	mixed : entity work.counter_mixed
	port map (
		clk_i => clk_i,
		rst_i => rst_i,
		cnt_o => mixed_o
	);


end architecture simulation;
