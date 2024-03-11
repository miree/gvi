library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk_i                  : std_logic := '0';
	signal rst_ni                 : std_logic := '0';
	signal test_en_i              : std_logic := '0';
	signal instr_req_o            : std_logic := '0';
	signal instr_gnt_i            : std_logic := '0';
	signal instr_rvalid_i         : std_logic := '0';
	signal instr_rdata_intg_i     : std_logic_vector(6 downto 0) := (others => '0');
	signal instr_err_i            : std_logic := '0';
	signal data_req_o             : std_logic := '0';
	signal data_gnt_i             : std_logic := '0';
	signal data_rvalid_i          : std_logic := '0';
	signal data_we_o              : std_logic := '0';
	signal data_be_o              : std_logic_vector(3 downto 0) := (others => '0');
	signal data_wdata_intg_o      : std_logic_vector(6 downto 0) := (others => '0');
	signal data_rdata_intg_i      : std_logic_vector(6 downto 0) := (others => '0');
	signal data_err_i             : std_logic := '0';
	signal irq_software_i         : std_logic := '0';
	signal irq_timer_i            : std_logic := '0';
	signal irq_external_i         : std_logic := '0';
	signal irq_nm_i               : std_logic := '0';
	signal scramble_key_valid_i   : std_logic := '0';
	signal scramble_req_o         : std_logic := '0';
	signal debug_req_i            : std_logic := '0';
	signal double_fault_seen_o    : std_logic := '0';
	signal fetch_enable_i         : std_logic_vector(3 downto 0) := (others => '1');
	signal alert_minor_o          : std_logic := '0';
	signal alert_major_internal_o : std_logic := '0';
	signal alert_major_bus_o      : std_logic := '0';
	signal core_sleep_o           : std_logic := '0';
	signal scan_rst_ni            : std_logic := '0';
	signal ram_cfg_i              : std_logic_vector(9 downto 0)  := (others => '0');
	signal irq_fast_i             : std_logic_vector(14 downto 0) := (others => '0');
	signal hart_id_i              : std_logic_vector(31 downto 0) := (others => '0');
	signal boot_addr_i            : std_logic_vector(31 downto 0) := (others => '0');
	signal instr_addr_o           : std_logic_vector(31 downto 0) := (others => '0');
	signal instr_rdata_i          : std_logic_vector(31 downto 0) := (others => '0');
	signal data_addr_o            : std_logic_vector(31 downto 0) := (others => '0');
	signal data_wdata_o           : std_logic_vector(31 downto 0) := (others => '0');
	signal data_rdata_i           : std_logic_vector(31 downto 0) := (others => '0');
	signal scramble_key_i         : std_logic_vector(127 downto 0) := (others => '0');
	signal scramble_nonce_i       : std_logic_vector(63 downto 0) := (others => '0');
	signal crash_dump_o           : std_logic_vector(159 downto 0) := (others => '0');

	signal reg : std_logic_vector(31 downto 0) := (others => '0');

begin

	clk_i <= not clk_i after 8 ns;
	rst_ni <= '1' after 80 ns;

	instr_gnt_i <= '1';   -- is like inverse of stall from pipelined WB
	instr_rvalid_i <= instr_req_o;

--00000000 <f>:
--   0:	ff010113          	addi	sp,sp,-16
--   4:	00812623          	sw	s0,12(sp)
--   8:	01010413          	addi	s0,sp,16
--   c:	00000793          	li	a5,0
--  10:	0007a023          	sw	zero,0(a5)

--00000014 <.L2>:
--  14:	00000793          	li	a5,0
--  18:	0007a783          	lw	a5,0(a5)
--  1c:	00000713          	li	a4,0
--  20:	00178793          	addi	a5,a5,1
--  24:	00f72023          	sw	a5,0(a4)
--  28:	fedff06f          	j	14 <.L2>
	instr_rdata_i <=
		x"ff010113" when instr_addr_o = x"00000080" else 
		x"00812623" when instr_addr_o = x"00000084" else 
		x"01010413" when instr_addr_o = x"00000088" else 
		x"00000793" when instr_addr_o = x"0000008c" else 
		x"0007a023" when instr_addr_o = x"00000090" else 
		x"00000793" when instr_addr_o = x"00000094" else 
		x"0007a783" when instr_addr_o = x"00000098" else 
		x"00000713" when instr_addr_o = x"0000009c" else 
		x"00178793" when instr_addr_o = x"000000a0" else 
		x"00f72023" when instr_addr_o = x"000000a4" else 
		x"fedff06f" when instr_addr_o = x"000000a8" else 
		x"00000713";

   	data_gnt_i <= '1';
   	process
   	begin
   		wait until rising_edge(clk_i);
		data_rdata_i <= reg;
		if data_we_o = '1' then 
			reg <= data_wdata_o;
		end if;
		data_rdata_i <= reg;		
		data_rvalid_i <= data_req_o;
	end process;

	cpu : entity work.ibex_top 
	port map(
		clk_i                  => clk_i,
		rst_ni                 => rst_ni,
		test_en_i              => test_en_i,
		instr_req_o            => instr_req_o,
		instr_gnt_i            => instr_gnt_i,
		instr_rvalid_i         => instr_rvalid_i,
		instr_rdata_intg_i     => instr_rdata_intg_i,
		instr_err_i            => instr_err_i,
		data_req_o             => data_req_o,
		data_gnt_i             => data_gnt_i,
		data_rvalid_i          => data_rvalid_i,
		data_we_o              => data_we_o,
		data_be_o              => data_be_o,
		data_wdata_intg_o      => data_wdata_intg_o,
		data_rdata_intg_i      => data_rdata_intg_i,
		data_err_i             => data_err_i,
		irq_software_i         => irq_software_i,
		irq_timer_i            => irq_timer_i,
		irq_external_i         => irq_external_i,
		irq_nm_i               => irq_nm_i,
		scramble_key_valid_i   => scramble_key_valid_i,
		scramble_req_o         => scramble_req_o,
		debug_req_i            => debug_req_i,
		double_fault_seen_o    => double_fault_seen_o,
		fetch_enable_i         => fetch_enable_i,
		alert_minor_o          => alert_minor_o,
		alert_major_internal_o => alert_major_internal_o,
		alert_major_bus_o      => alert_major_bus_o,
		core_sleep_o           => core_sleep_o,
		scan_rst_ni            => scan_rst_ni,
		ram_cfg_i              => ram_cfg_i,
		irq_fast_i             => irq_fast_i,
		hart_id_i              => hart_id_i,
		boot_addr_i            => boot_addr_i,
		instr_addr_o           => instr_addr_o,
		instr_rdata_i          => instr_rdata_i,
		data_addr_o            => data_addr_o,
		data_wdata_o           => data_wdata_o,
		data_rdata_i           => data_rdata_i,
		scramble_key_i         => scramble_key_i,
		scramble_nonce_i       => scramble_nonce_i,
		crash_dump_o           => crash_dump_o
		);

end architecture simulation;
