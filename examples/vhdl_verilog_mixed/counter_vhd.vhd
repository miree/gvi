library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_vhd is
port (
	clk_i, rst_i : in std_logic;
	cnt_o        : out std_logic_vector(31 downto 0));
end entity;
architecture rtl of counter_vhd is
	signal cnt : unsigned(31 downto 0) := (others => '0');
begin
	process
	begin
		wait until rising_edge(clk_i);
		if rst_i = '1' then 
			cnt <= (others => '0');
		else 
			cnt <= cnt + 1;
		end if;
	end process;
	cnt_o <= std_logic_vector(cnt);
end architecture;

