library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk_i : std_logic := '0';
	signal rst_i : std_logic := '1';
	signal interrupt : std_logic_vector(31 downto 0) := (others => '0');
	signal I_DAT_I : std_logic_vector(31 downto 0) := (others => '0');
	signal I_ACK_I : std_logic := '0';
	signal I_ERR_I : std_logic := '0';
	signal I_RTY_I : std_logic := '0';
	signal D_DAT_I : std_logic_vector(31 downto 0) := (others => '0');
	signal D_ACK_I : std_logic := '0';
	signal D_ERR_I : std_logic := '0';
	signal D_RTY_I : std_logic := '0';
	signal ext_break : std_logic := '0';
	signal I_DAT_O : std_logic_vector(31 downto 0) := (others => '0');
	signal I_ADR_O : std_logic_vector(31 downto 0) := (others => '0');
	signal I_CYC_O : std_logic := '0';
	signal I_SEL_O : std_logic_vector(3 downto 0) := (others => '0');
	signal I_STB_O : std_logic := '0';
	signal I_WE_O : std_logic := '0';
	signal I_CTI_O : std_logic_vector(2 downto 0) := (others => '0');
	signal I_LOCK_O : std_logic := '0';
	signal I_BTE_O : std_logic_vector(1 downto 0) := (others => '0');
	signal D_DAT_O : std_logic_vector(31 downto 0) := (others => '0');
	signal D_ADR_O : std_logic_vector(31 downto 0) := (others => '0');
	signal D_CYC_O : std_logic := '0';
	signal D_SEL_O : std_logic_vector(3 downto 0) := (others => '0');
	signal D_STB_O : std_logic := '0';
	signal D_WE_O : std_logic := '0';
	signal D_CTI_O : std_logic_vector(2 downto 0) := (others => '0');
	signal D_LOCK_O : std_logic := '0';
	signal D_BTE_O : std_logic_vector(1 downto 0) := (others => '0');
begin

	clk_i <= not clk_i after 5 ns;
	rst_i <= '0' after 20 ns;

-- some instructions
	I_DAT_I <= x"34210000" when I_ADR_O = x"00000000" 
	      else x"34210000" when I_ADR_O = x"00000004" 
	      else x"34210000" when I_ADR_O = x"00000008" 
	      else x"34210000" when I_ADR_O = x"0000000C" 
	      else x"e3fffffc"; -- the last instruction jumps back 4 instructions

-- 111000************************** -4
-- 1110 0011 1111 1111 1111 1111 1111 1100
--    e    3    f    f    f    f    f    c

	process
	begin
		wait until rising_edge(clk_i);
		I_ACK_I <= I_STB_O;
	end process;


	cpu : entity work.lm32_top
	port map (
		clk_i     => clk_i,
		rst_i     => rst_i,
		interrupt => interrupt,
		I_DAT_I   => I_DAT_I,
		I_ACK_I   => I_ACK_I,
		I_ERR_I   => I_ERR_I,
		I_RTY_I   => I_RTY_I,
		D_DAT_I   => D_DAT_I,
		D_ACK_I   => D_ACK_I,
		D_ERR_I   => D_ERR_I,
		D_RTY_I   => D_RTY_I,
		ext_break => ext_break,
		I_DAT_O   => I_DAT_O,
		I_ADR_O   => I_ADR_O,
		I_CYC_O   => I_CYC_O,
		I_SEL_O   => I_SEL_O,
		I_STB_O   => I_STB_O,
		I_WE_O    => I_WE_O,
		I_CTI_O   => I_CTI_O,
		I_LOCK_O  => I_LOCK_O,
		I_BTE_O   => I_BTE_O,
		D_DAT_O   => D_DAT_O,
		D_ADR_O   => D_ADR_O,
		D_CYC_O   => D_CYC_O,
		D_SEL_O   => D_SEL_O,
		D_STB_O   => D_STB_O,
		D_WE_O    => D_WE_O,
		D_CTI_O   => D_CTI_O,
		D_LOCK_O  => D_LOCK_O,
		D_BTE_O   => D_BTE_O
	);

end architecture simulation;
