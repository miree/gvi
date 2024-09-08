library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk : std_logic := '0';
	signal clk_always_on : std_logic := '0';
	signal rst_n : std_logic := '0';
	signal pwrup_req : std_logic := '0';
	signal pwrup_ack : std_logic := '0';
	signal clk_en : std_logic := '0';
	signal unblock_out : std_logic := '0';
	signal unblock_in : std_logic := '0';
	signal bus_aph_req_i : std_logic := '0';
	signal bus_aph_panic_i : std_logic := '0';
	signal bus_aph_ready_i : std_logic := '0';
	signal bus_dph_ready_i : std_logic := '0';
	signal bus_dph_err_i : std_logic := '0';
	signal bus_hsize_i : std_logic_vector(2 downto 0) := (others => '0');
	signal bus_priv_i : std_logic := '0';
	signal bus_aph_req_d : std_logic := '0';
	signal bus_aph_excl_d : std_logic := '0';
	signal bus_aph_ready_d : std_logic := '0';
	signal bus_dph_ready_d : std_logic := '0';
	signal bus_dph_err_d : std_logic := '0';
	signal bus_dph_exokay_d : std_logic := '0';
	signal bus_hsize_d : std_logic_vector(2 downto 0) := (others => '0');
	signal bus_priv_d : std_logic := '0';
	signal bus_hwrite_d : std_logic := '0';
	signal dbg_req_halt : std_logic := '0';
	signal dbg_req_halt_on_reset : std_logic := '0';
	signal dbg_req_resume : std_logic := '0';
	signal dbg_halted : std_logic := '0';
	signal dbg_running : std_logic := '0';
	signal dbg_data0_wen : std_logic := '0';
	signal dbg_instr_data_vld : std_logic := '0';
	signal dbg_instr_data_rdy : std_logic := '0';
	signal dbg_instr_caught_exception : std_logic := '0';
	signal dbg_instr_caught_ebreak : std_logic := '0';
	signal irq : std_logic_vector(0 to 0) := (others => '0');
	signal soft_irq : std_logic := '0';
	signal timer_irq : std_logic := '0';
	signal bus_haddr_i : std_logic_vector(31 downto 0) := (others => '0');
	signal bus_rdata_i : std_logic_vector(31 downto 0) := (others => '0');
	signal bus_haddr_d : std_logic_vector(31 downto 0) := (others => '0');
	signal bus_wdata_d : std_logic_vector(31 downto 0) := (others => '0');
	signal bus_rdata_d : std_logic_vector(31 downto 0) := (others => '0');
	signal dbg_data0_rdata : std_logic_vector(31 downto 0) := (others => '0');
	signal dbg_data0_wdata : std_logic_vector(31 downto 0) := (others => '0');
	signal dbg_instr_data : std_logic_vector(31 downto 0) := (others => '0');

	signal r_variable   : std_logic_vector(31 downto 0) := (others => '0');

begin
	-- drive clock and reset pins
	clk_always_on <= clk;

	clk   <= not clk after 5 ns;
	rst_n <= '1' after 20 ns;


	pwrup_ack <= pwrup_req;

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

	bus_aph_ready_i <= '1';
	bus_dph_ready_i <= bus_aph_req_i;
 	bus_rdata_i <= x"000007b7" when bus_haddr_i = x"00000000" and bus_aph_req_i = '1' --        lui  a5,0x0
  	         else  x"0007a783" when bus_haddr_i = x"00000004" and bus_aph_req_i = '1' --        lw   a5,0(a5) 
 	         else  x"00000737" when bus_haddr_i = x"00000008" and bus_aph_req_i = '1' --        lui  a4,0x0
	         else  x"00178793" when bus_haddr_i = x"0000000c" and bus_aph_req_i = '1' -- <.L2>: addi	a5,a5,1
	         else  x"00f72023" when bus_haddr_i = x"00000010" and bus_aph_req_i = '1' --        sw   a5,0(a4)
	         else  x"ff9ff06f" when bus_haddr_i = x"00000014" and bus_aph_req_i = '1';--        j    c <.L2>

	-- handle data bus
	-- only one single register can be accessed (don't even look at o_dbus_adr)
	bus_aph_ready_d <= '1';
	bus_dph_ready_d <= '1';
	bus_rdata_d <= r_variable;
	r_variable <= bus_wdata_d when bus_hwrite_d = '1' and bus_aph_req_d = '1' and bus_haddr_d = x"00000000";

	cpu : entity work.hazard3_core
	port map (
		clk                        => clk, 
		clk_always_on              => clk_always_on, 
		rst_n                      => rst_n, 
		pwrup_req                  => pwrup_req, 
		pwrup_ack                  => pwrup_ack, 
		clk_en                     => clk_en, 
		unblock_out                => unblock_out, 
		unblock_in                 => unblock_in, 
		bus_aph_req_i              => bus_aph_req_i, 
		bus_aph_panic_i            => bus_aph_panic_i, 
		bus_aph_ready_i            => bus_aph_ready_i, 
		bus_dph_ready_i            => bus_dph_ready_i, 
		bus_dph_err_i              => bus_dph_err_i, 
		bus_hsize_i                => bus_hsize_i, 
		bus_priv_i                 => bus_priv_i, 
		bus_aph_req_d              => bus_aph_req_d, 
		bus_aph_excl_d             => bus_aph_excl_d, 
		bus_aph_ready_d            => bus_aph_ready_d, 
		bus_dph_ready_d            => bus_dph_ready_d, 
		bus_dph_err_d              => bus_dph_err_d, 
		bus_dph_exokay_d           => bus_dph_exokay_d, 
		bus_hsize_d                => bus_hsize_d, 
		bus_priv_d                 => bus_priv_d, 
		bus_hwrite_d               => bus_hwrite_d, 
		dbg_req_halt               => dbg_req_halt, 
		dbg_req_halt_on_reset      => dbg_req_halt_on_reset, 
		dbg_req_resume             => dbg_req_resume, 
		dbg_halted                 => dbg_halted, 
		dbg_running                => dbg_running, 
		dbg_data0_wen              => dbg_data0_wen, 
		dbg_instr_data_vld         => dbg_instr_data_vld, 
		dbg_instr_data_rdy         => dbg_instr_data_rdy, 
		dbg_instr_caught_exception => dbg_instr_caught_exception, 
		dbg_instr_caught_ebreak    => dbg_instr_caught_ebreak, 
		irq                        => irq, 
		soft_irq                   => soft_irq, 
		timer_irq                  => timer_irq, 
		bus_haddr_i                => bus_haddr_i, 
		bus_rdata_i                => bus_rdata_i, 
		bus_haddr_d                => bus_haddr_d, 
		bus_wdata_d                => bus_wdata_d, 
		bus_rdata_d                => bus_rdata_d, 
		dbg_data0_rdata            => dbg_data0_rdata, 
		dbg_data0_wdata            => dbg_data0_wdata, 
		dbg_instr_data             => dbg_instr_data
	);

end architecture simulation;
