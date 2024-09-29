library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  


package picorv32_pkg is
  -- vhdl interface to the verilog module  
  component picorv32
  port(
    clk : in std_logic;
    resetn : in std_logic;
    trap : out std_logic;
    mem_valid : out std_logic;
    mem_instr : out std_logic;
    mem_ready : in std_logic;
    mem_addr : out std_logic_vector(31 downto 0);
    mem_wdata : out std_logic_vector(31 downto 0);
    mem_wstrb : out std_logic_vector(3 downto 0);
    mem_rdata : in std_logic_vector(31 downto 0);
    mem_la_read : out std_logic;
    mem_la_write : out std_logic;
    mem_la_addr : out std_logic_vector(31 downto 0);
    mem_la_wdata : out std_logic_vector(31 downto 0);
    mem_la_wstrb : out std_logic_vector(3 downto 0);
    pcpi_valid : out std_logic;
    pcpi_insn : out std_logic_vector(31 downto 0);
    pcpi_rs1 : out std_logic_vector(31 downto 0);
    pcpi_rs2 : out std_logic_vector(31 downto 0);
    pcpi_wr : in std_logic;
    pcpi_rd : in std_logic_vector(31 downto 0);
    pcpi_wait : in std_logic;
    pcpi_ready : in std_logic;
    irq : in std_logic_vector(31 downto 0);
    eoi : out std_logic_vector(31 downto 0);
    trace_valid : out std_logic;
    trace_data : out std_logic_vector(35 downto 0));
  end component;
end package;

package body picorv32_pkg is
end package body;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.wbp_pkg.all;
use work.picorv32_pkg.all;


entity picorv32_wbp2 is
port(
	clk_i : in  std_logic;
	rst_i : in  std_logic;
	irq_i : in  std_logic_vector(31 downto 0);
  wbi_o : out t_wbp_master_out;
  wbi_i : in  t_wbp_master_in;
  wbd_o : out t_wbp_master_out;
  wbd_i : in  t_wbp_master_in
);
end entity;

architecture rtl of picorv32_wbp2 is
  signal resetn  : std_logic := '0';
  signal trap    : std_logic := '0';

  signal mem_valid    : std_logic := '0';
  signal mem_instr    : std_logic := '0';
  signal mem_ready    : std_logic := '0';
  signal mem_addr     : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_wdata    : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_wstrb    : std_logic_vector( 3 downto 0) := (others => '0');
  signal mem_rdata    : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_la_read  : std_logic := '0';
  signal mem_la_write : std_logic := '0';
  signal mem_la_addr  : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_la_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_la_wstrb : std_logic_vector( 3 downto 0) := (others => '0');
  signal pcpi_valid   : std_logic := '0';
  signal pcpi_insn    : std_logic_vector(31 downto 0) := (others => '0');
  signal pcpi_rs1     : std_logic_vector(31 downto 0) := (others => '0');
  signal pcpi_rs2     : std_logic_vector(31 downto 0) := (others => '0');
  signal pcpi_wr      : std_logic := '0';
  signal pcpi_rd      : std_logic_vector(31 downto 0) := (others => '0');
  signal pcpi_wait    : std_logic := '0';
  signal pcpi_ready   : std_logic := '0';
  signal eoi          : std_logic_vector(31 downto 0) := (others => '0');

  signal wbi     : t_wbp_master_in  := c_wbp_master_in_init;
  signal wbo     : t_wbp_master_out := c_wbp_master_out_init;
  signal wbo_stb : std_logic;
  type state_t is (s_idle, s_wait_for_ack);
  signal state : state_t := s_idle;

  procedure wb_classic_to_pipeline(signal rst : in std_logic; signal pstate : inout state_t; signal wb_i : in t_wbp_master_in; signal wb_o : in t_wbp_master_out) is
  begin
    if rst = '1' then
      pstate <= s_idle;
    else
      -- state management
      case pstate is 
          when s_idle => 
            if wb_o.stb = '1' and wb_i.stall = '0' and wb_i.ack = '0' then
              pstate <= s_wait_for_ack;
            end if;
          when s_wait_for_ack => 
            if wb_i.ack = '1' then 
              pstate <= s_idle;
            end if;
      end case;
    end if;
  end procedure;

begin

  wbo.cyc   <= mem_valid;
  wbo.stb   <= mem_valid;
  wbo.adr   <= mem_addr;
  wbo.dat   <= mem_wdata;
  wbo.sel   <= "1111" when wbo.we = '0' else mem_wstrb;
  wbo.we    <= '0' when mem_wstrb = "0000" else '1';
  mem_ready <= wbi.ack;
  mem_rdata <= wbi.dat;

  process
  begin
    wait until rising_edge(clk_i);
    wb_classic_to_pipeline(rst_i, state, wbi, wbo);
    assert trap='0'  report "cpu trapped" severity failure;
  end process;

  resetn <= not rst_i;

  -- stb line control (converting wishbone classic to pipelined)
  wbo_stb <= wbo.stb when state = s_idle else '0';

  -- wishbone instr./data multiplexing
  wbi <= wbi_i when mem_instr = '1' else wbd_i;

  wbi_o <= (wbo.cyc, wbo_stb, wbo.adr, wbo.sel, wbo.we, wbo.dat) when rst_i = '0' and mem_instr = '1'
      else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));
  wbd_o <= (wbo.cyc, wbo_stb, wbo.adr, wbo.sel, wbo.we, wbo.dat) when rst_i = '0' and mem_instr = '0'
      else ( '0', '0', (others=>'0'), (others=>'0'), '0', (others=>'0'));

  cpu: picorv32
  port map (
    clk          => clk_i,
    resetn       => resetn,
    trap         => trap,
    mem_valid    => mem_valid,
    mem_instr    => mem_instr,
    mem_ready    => mem_ready,
    mem_addr     => mem_addr,
    mem_wdata    => mem_wdata,
    mem_wstrb    => mem_wstrb,
    mem_rdata    => mem_rdata,
    mem_la_read  => mem_la_read,
    mem_la_write => mem_la_write,
    mem_la_addr  => mem_la_addr,
    mem_la_wdata => mem_la_wdata,
    mem_la_wstrb => mem_la_wstrb,
    pcpi_valid   => pcpi_valid,
    pcpi_insn    => pcpi_insn,
    pcpi_rs1     => pcpi_rs1,
    pcpi_rs2     => pcpi_rs2,
    pcpi_wr      => pcpi_wr,
    pcpi_rd      => pcpi_rd,
    pcpi_wait    => pcpi_wait,
    pcpi_ready   => pcpi_ready,
    irq          => irq_i,
    eoi          => eoi,
    trace_valid  => open,
    trace_data   => open
  );
	
end architecture;


