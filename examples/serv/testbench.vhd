library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk          : std_logic := '1';
	signal i_rst        : std_logic := '1';
	signal i_timer_irq  : std_logic := '0';
	signal o_ibus_adr   : std_logic_vector(31 downto 0) := (others => '0');
	signal o_ibus_cyc   : std_logic := '0';
	signal i_ibus_rdt   : std_logic_vector(31 downto 0) := (others => '0');
	signal i_ibus_ack   : std_logic := '0';
	signal o_dbus_adr   : std_logic_vector(31 downto 0) := (others => '0');
	signal o_dbus_dat   : std_logic_vector(31 downto 0) := (others => '0');
	signal o_dbus_sel   : std_logic_vector(3 downto 0)  := (others => '0');
	signal o_dbus_we    : std_logic := '0';
	signal o_dbus_cyc   : std_logic := '0';
	signal i_dbus_rdt   : std_logic_vector(31 downto 0) := (others => '0');
	signal i_dbus_ack   : std_logic := '0';
	signal o_ext_rs1    : std_logic_vector(31 downto 0) := (others => '0');
	signal o_ext_rs2    : std_logic_vector(31 downto 0) := (others => '0');
	signal o_ext_funct3 : std_logic_vector(2 downto 0)  := (others => '0');
	signal i_ext_rd     : std_logic_vector(31 downto 0) := (others => '0');
	signal i_ext_ready  : std_logic := '0';
	signal o_mdu_valid  : std_logic := '0';

	signal r_variable   : std_logic_vector(31 downto 0) := (others => '0');

begin
	-- drive clock and reset pins
	clk   <= not clk after 5 ns;
	i_rst <= '0' after 20 ns;

	-- handle instruction requests
	-- provide hard coded riscv instructions that increment r_variable 
	-- by one and jump back to the beginning of the porgram
	-- the program was generated from this c-source (prog.c):
	--	volatile int i;
	--	void fun() {
	--		int j = i;
	--		for(;;)i=++j;
	--	}
	-- compile it:     riscv32-elf-gcc -mabi=ilp32 -march=rv32i -c prog.c -O
	-- disassemble it: riscv32-elf-objdump -d prog.o 
	i_ibus_ack <= o_ibus_cyc;
 	i_ibus_rdt <= x"000007b7" when o_ibus_adr = x"00000000" and o_ibus_cyc = '1' --        lui  a5,0x0
  			else  x"0007a783" when o_ibus_adr = x"00000004" and o_ibus_cyc = '1' --        lw   a5,0(a5) 
 			else  x"00000737" when o_ibus_adr = x"00000008" and o_ibus_cyc = '1' --        lui  a4,0x0
			else  x"00178793" when o_ibus_adr = x"0000000c" and o_ibus_cyc = '1' -- <.L2>: addi	a5,a5,1
			else  x"00f72023" when o_ibus_adr = x"00000010" and o_ibus_cyc = '1' --        sw   a5,0(a4)
			else  x"ff9ff06f" when o_ibus_adr = x"00000014" and o_ibus_cyc = '1';--        j    c <.L2>

	-- handle data bus
	-- only one register can be accessed (don't even look at o_dbus_adr)
	i_dbus_ack <= o_dbus_cyc;
	i_dbus_rdt <= r_variable;
	r_variable <= o_dbus_dat when o_dbus_we = '1' and o_dbus_cyc = '1';

	cpu : entity work.serv_rf_top
	port map (
		clk          => clk,
		i_rst        => i_rst,
		i_timer_irq  => i_timer_irq,
		o_ibus_adr   => o_ibus_adr,
		o_ibus_cyc   => o_ibus_cyc,
		i_ibus_rdt   => i_ibus_rdt,
		i_ibus_ack   => i_ibus_ack,
		o_dbus_adr   => o_dbus_adr,
		o_dbus_dat   => o_dbus_dat,
		o_dbus_sel   => o_dbus_sel,
		o_dbus_we    => o_dbus_we,
		o_dbus_cyc   => o_dbus_cyc,
		i_dbus_rdt   => i_dbus_rdt,
		i_dbus_ack   => i_dbus_ack,
		o_ext_rs1    => o_ext_rs1,
		o_ext_rs2    => o_ext_rs2,
		o_ext_funct3 => o_ext_funct3,
		i_ext_rd     => i_ext_rd,
		i_ext_ready  => i_ext_ready,
		o_mdu_valid  => o_mdu_valid
	);

end architecture simulation;
