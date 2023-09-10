library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

use work.endpoint_pkg.all;
use work.wishbone_pkg.all;
use work.wrcore_pkg.all;


entity testbench is
    generic (
      g_aux_clks  : integer := 0;
      g_diag_ro_size : integer := 0;
      g_diag_rw_size : integer := 0;
      g_pcs_16bit : boolean := false
      );
end entity;

architecture simulation of testbench is

    signal clk_sys_i :  std_logic := '0';

    -- DDMTD offset clock (125.x MHz)
    signal clk_dmtd_i :  std_logic := '0';

    -- Timing reference (125 MHz)
    signal clk_ref_i :  std_logic := '0';

    -- Aux clocks (i.e. the FMC clock), which can be disciplined by the WR Core
    --signal clk_aux_i :  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

    signal clk_ext_mul_i :  std_logic := '0';
    signal clk_ext_mul_locked_i  :   std_logic := '1';
    signal clk_ext_stopped_i     :   std_logic := '0';
    signal clk_ext_rst_o         :  std_logic := '0';

    -- External 10 MHz reference (cesium, GPSDO, etc.), used in Grandmaster mode
    signal clk_ext_i :  std_logic := '0';

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    signal pps_ext_i :  std_logic := '0';

    signal rst_n_i :  std_logic := '0';

    -----------------------------------------
    --Timing system
    -----------------------------------------
    signal dac_hpll_load_p1_o :  std_logic := '0';
    signal dac_hpll_data_o    :  std_logic_vector(15 downto 0) := (others => '0');

    signal dac_dpll_load_p1_o :  std_logic := '0';
    signal dac_dpll_data_o    :  std_logic_vector(15 downto 0) := (others => '0');

    -- PHY I/f
    signal phy_ref_clk_i :  std_logic := '0';

    signal phy_tx_data_o      :  std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0) := (others => '0');
    signal phy_tx_k_o         :  std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0) := (others => '0');
    signal phy_tx_disparity_i :   std_logic := '0';
    signal phy_tx_enc_err_i   :   std_logic := '0';

    signal phy_rx_data_i     :  std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0) := (others => '0');
    signal phy_rx_rbclk_i    :  std_logic := '0';
    signal phy_rx_k_i        :  std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0) := (others => '0');
    signal phy_rx_enc_err_i  :  std_logic := '0';
    signal phy_rx_bitslide_i :  std_logic_vector(f_pcs_bts_width(g_pcs_16bit)-1 downto 0) := (others => '0');

    signal phy_rst_o            :  std_logic := '0';
    signal phy_rdy_i            :   std_logic := '1';
    signal phy_loopen_o         :  std_logic := '0';
    signal phy_loopen_vec_o     :  std_logic_vector(2 downto 0) := (others => '0');
    signal phy_tx_prbs_sel_o    :  std_logic_vector(2 downto 0) := (others => '0');
    signal phy_sfp_tx_fault_i   :  std_logic := '0';
    signal phy_sfp_los_i        :  std_logic := '0';
    signal phy_sfp_tx_disable_o :  std_logic := '0';

    signal phy_rx_rbclk_sampled_i :  std_logic := '0';
    signal phy_lpc_stat_i       :  std_logic_vector(15 downto 0) := (others => '0');
    signal phy_lpc_ctrl_o       :  std_logic_vector(15 downto 0) := (others => '0');

    
    -- PHY I/F record-based
    signal phy8_o  :  t_phy_8bits_from_wrc;
    signal phy8_i  :   t_phy_8bits_to_wrc  := c_dummy_phy8_to_wrc;
    signal phy16_o :  t_phy_16bits_from_wrc;
    signal phy16_i :   t_phy_16bits_to_wrc := c_dummy_phy16_to_wrc;

    -----------------------------------------
    --GPIO
    -----------------------------------------
    signal led_act_o  :  std_logic := '0';
    signal led_link_o :  std_logic := '0';
    signal scl_o      :  std_logic := '0';
    signal scl_i      :   std_logic := '1';
    signal sda_o      :  std_logic := '0';
    signal sda_i      :   std_logic := '1';
    signal sfp_scl_o  :  std_logic := '0';
    signal sfp_scl_i  :   std_logic := '1';
    signal sfp_sda_o  :  std_logic := '0';
    signal sfp_sda_i  :   std_logic := '1';
    signal sfp_det_i  :   std_logic := '1';
    signal btn1_i     :   std_logic := '1';
    signal btn2_i     :   std_logic := '1';
    signal spi_sclk_o :  std_logic := '0';
    signal spi_ncs_o  :  std_logic := '0';
    signal spi_mosi_o :  std_logic := '0';
    signal spi_miso_i :   std_logic := '0';

    -----------------------------------------
    --UART
    -----------------------------------------
    signal uart_rxd_i :   std_logic := '1';
    signal uart_txd_o :  std_logic := '0';

    -----------------------------------------
    -- 1-wire
    -----------------------------------------
    signal owr_pwren_o :  std_logic_vector(1 downto 0) := (others => '0');
    signal owr_en_o    :  std_logic_vector(1 downto 0) := (others => '0');
    signal owr_i       :   std_logic_vector(1 downto 0) := (others => '1');

    signal owr_wr    : std_logic_vector(1 downto 0) := (others => '1');

    -- physical 1-wire lines
    signal owr         : std_logic_vector(1 downto 0) := (others => '0');

    -- tempsense 1-wire lines 
    signal owr_tempsense_i : std_logic := '1';
    signal owr_tempsense_o : std_logic := '1';

    -----------------------------------------
    --External WB interface
    -----------------------------------------
    signal wb_adr_i   :   std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
    signal wb_dat_i   :   std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
    signal wb_dat_o   :  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    signal wb_sel_i   :   std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    signal wb_we_i    :   std_logic                                               := '0';
    signal wb_cyc_i   :   std_logic                                               := '0';
    signal wb_stb_i   :   std_logic                                               := '0';
    signal wb_ack_o   :  std_logic := '0';
    signal wb_err_o   :  std_logic := '0';
    signal wb_rty_o   :  std_logic := '0';
    signal wb_stall_o :  std_logic := '0';

    -----------------------------------------
    -- Auxillary WB master
    -----------------------------------------
    signal aux_adr_o   :  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    signal aux_dat_o   :  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    signal aux_dat_i   :   std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    signal aux_sel_o   :  std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    signal aux_we_o    :  std_logic := '0';
    signal aux_cyc_o   :  std_logic := '0';
    signal aux_stb_o   :  std_logic := '0';
    signal aux_ack_i   :   std_logic := '1';
    signal aux_stall_i :   std_logic := '0';

    -----------------------------------------
    -- External Fabric I/F
    -----------------------------------------
    signal ext_snk_adr_i   :   std_logic_vector(1 downto 0)  := "00";
    signal ext_snk_dat_i   :   std_logic_vector(15 downto 0) := x"0000";
    signal ext_snk_sel_i   :   std_logic_vector(1 downto 0)  := "00";
    signal ext_snk_cyc_i   :   std_logic                     := '0';
    signal ext_snk_we_i    :   std_logic                     := '0';
    signal ext_snk_stb_i   :   std_logic                     := '0';
    signal ext_snk_ack_o   :  std_logic := '0';
    signal ext_snk_err_o   :  std_logic := '0';
    signal ext_snk_stall_o :  std_logic := '0';

    signal ext_src_adr_o   :  std_logic_vector(1 downto 0) := (others => '0');
    signal ext_src_dat_o   :  std_logic_vector(15 downto 0) := (others => '0');
    signal ext_src_sel_o   :  std_logic_vector(1 downto 0) := (others => '0');
    signal ext_src_cyc_o   :  std_logic := '0';
    signal ext_src_stb_o   :  std_logic := '0';
    signal ext_src_we_o    :  std_logic := '0';
    signal ext_src_ack_i   :   std_logic := '1';
    signal ext_src_err_i   :   std_logic := '0';
    signal ext_src_stall_i :   std_logic := '0';

    ------------------------------------------
    -- External TX Timestamp I/F
    ------------------------------------------
    signal txtsu_port_id_o      :  std_logic_vector(4 downto 0) := (others => '0');
    signal txtsu_frame_id_o     :  std_logic_vector(15 downto 0) := (others => '0');
    signal txtsu_ts_value_o     :  std_logic_vector(31 downto 0) := (others => '0');
    signal txtsu_ts_incorrect_o :  std_logic := '0';
    signal txtsu_stb_o          :  std_logic := '0';
    signal txtsu_ack_i          :   std_logic := '1';

    -----------------------------------------
    -- Timestamp helper signals, used for Absolute Calibration
    -----------------------------------------
    signal abscal_txts_o        :  std_logic := '0';
    signal abscal_rxts_o        :  std_logic := '0';

    -----------------------------------------
    -- Pause Frame Control
    -----------------------------------------
    signal fc_tx_pause_req_i   :   std_logic                     := '0';
    signal fc_tx_pause_delay_i :   std_logic_vector(15 downto 0) := x"0000";
    signal fc_tx_pause_ready_o :  std_logic := '0';

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------

    signal tm_link_up_o         :  std_logic := '0';
    -- DAC Control
    signal tm_dac_value_o       :  std_logic_vector(23 downto 0) := (others => '0');
    --signal tm_dac_wr_o          :  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- Aux clock lock enable
    --signal tm_clk_aux_lock_en_i :   std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- Aux clock locked flag
    --signal tm_clk_aux_locked_o  :  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- Timecode output
    signal tm_time_valid_o      :  std_logic := '0';
    signal tm_tai_o             :  std_logic_vector(39 downto 0) := (others => '0');
    signal tm_cycles_o          :  std_logic_vector(27 downto 0) := (others => '0');
    -- 1PPS output
    signal pps_csync_o          :  std_logic := '0';
    signal pps_valid_o          :  std_logic := '0';
    signal pps_p_o              :  std_logic := '0';
    signal pps_led_o            :  std_logic := '0';

    signal rst_aux_n_o :  std_logic := '0';

    signal link_ok_o :  std_logic := '0';

    -------------------------------------
    -- DIAG to/from external modules
    -------------------------------------
    signal aux_diag_i :   t_generic_word_array(g_diag_ro_size-1 downto 0) := (others => (others => '0'));
    signal aux_diag_o :   t_generic_word_array(g_diag_rw_size-1 downto 0) := (others => (others => '0'));


    -- Output from UART decoder
    signal uart_parallel_o : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_stb_o      : std_logic := '0';

begin
  clk_sys_i <= not clk_sys_i after 8 ns;  -- 62.5 MHz
  clk_dmtd_i <= not clk_dmtd_i after 3.996 ns; -- approx. 125.125 MHz
  clk_ref_i  <= not clk_ref_i after 4 ns;

  --clk_aux_i <= not clk_aux_i after 8 ns;


  rst_n_i <= '1' after 50 ns;

  uart_rx: entity work.uart_rx 
  generic map (
    g_clk_freq  => 62500000,
    g_baud_rate => 115200*4,
    g_bits      => 8
  )
  port map (
    clk_i   => clk_sys_i,
    dat_o   => uart_parallel_o,
    stb_o   => uart_stb_o,
    rx_i    => uart_txd_o
  );


  -- 1-wire feed-back
  owr_wr(0) <= owr_pwren_o(0) when (owr_pwren_o(0) = '1' or owr_en_o(0) = '1') else '1';
  owr_wr(1) <= owr_pwren_o(1) when (owr_pwren_o(1) = '1' or owr_en_o(1) = '1') else '1';
  --owr(0)   <= owr_pwren_o(0) when (owr_pwren_o(0) = '1' or owr_en_o(0) = '1') else '1';
  --owr(1)   <= owr_pwren_o(1) when (owr_pwren_o(1) = '1' or owr_en_o(1) = '1') else '1';
  owr(0) <= '0' when ( owr_wr(0) = '0' or owr_tempsense_o = '0' ) else '1';
  owr(1) <= '0' when ( owr_wr(1) = '0' ) else '1';
  
  owr_i <= owr;

  tempsense: entity work.one_wire_tempsense
  port map (
      owr_i => owr(0),
      owr_o => owr_tempsense_o
    );


  dut: entity work.wr_core
  generic map( g_dpram_initf => "wrc.bram")
  port map(
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i => clk_sys_i,

    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i => clk_dmtd_i,

    -- Timing reference (125 MHz)
    clk_ref_i => clk_ref_i,

    -- Aux clocks (i.e. the FMC clock), which can be disciplined by the WR Core
    clk_aux_i => (others =>'0'),--clk_aux_i,

    clk_ext_mul_i => clk_ext_mul_i,
    clk_ext_mul_locked_i  => clk_ext_mul_locked_i ,
    clk_ext_stopped_i     => clk_ext_stopped_i    ,
    clk_ext_rst_o         => clk_ext_rst_o        ,

    -- External 10 MHz reference (cesium, GPSDO, etc.), used in Grandmaster mode
    clk_ext_i => clk_ext_i,

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    pps_ext_i => pps_ext_i,

    rst_n_i => rst_n_i,

    -----------------------------------------
    --Timing system
    -----------------------------------------
    dac_hpll_load_p1_o => dac_hpll_load_p1_o,
    dac_hpll_data_o    => dac_hpll_data_o   ,

    dac_dpll_load_p1_o => dac_dpll_load_p1_o,
    dac_dpll_data_o    => dac_dpll_data_o   ,

    -- PHY I/f
    phy_ref_clk_i => phy_ref_clk_i,

    phy_tx_data_o      => phy_tx_data_o     ,
    phy_tx_k_o         => phy_tx_k_o        ,
    phy_tx_disparity_i => phy_tx_disparity_i,
    phy_tx_enc_err_i   => phy_tx_enc_err_i  ,

    phy_rx_data_i     => phy_rx_data_i    ,
    phy_rx_rbclk_i    => phy_rx_rbclk_i   ,
    phy_rx_k_i        => phy_rx_k_i       ,
    phy_rx_enc_err_i  => phy_rx_enc_err_i ,
    phy_rx_bitslide_i => phy_rx_bitslide_i,

    phy_rst_o            => phy_rst_o           ,
    phy_rdy_i            => phy_rdy_i           ,
    phy_loopen_o         => phy_loopen_o        ,
    phy_loopen_vec_o     => phy_loopen_vec_o    ,
    phy_tx_prbs_sel_o    => phy_tx_prbs_sel_o   ,
    phy_sfp_tx_fault_i   => phy_sfp_tx_fault_i  ,
    phy_sfp_los_i        => phy_sfp_los_i       ,
    phy_sfp_tx_disable_o => phy_sfp_tx_disable_o,

    phy_rx_rbclk_sampled_i => phy_rx_rbclk_sampled_i,
    phy_lpc_stat_i       => phy_lpc_stat_i      ,
    phy_lpc_ctrl_o       => phy_lpc_ctrl_o      ,

    
    -- PHY I/F record-based
    phy8_o  => phy8_o ,
    phy8_i  => phy8_i ,
    phy16_o => phy16_o,
    phy16_i => phy16_i,

    -----------------------------------------
    --GPIO
    -----------------------------------------
    led_act_o  => led_act_o ,
    led_link_o => led_link_o,
    scl_o      => scl_o     ,
    scl_i      => scl_i     ,
    sda_o      => sda_o     ,
    sda_i      => sda_i     ,
    sfp_scl_o  => sfp_scl_o ,
    sfp_scl_i  => sfp_scl_i ,
    sfp_sda_o  => sfp_sda_o ,
    sfp_sda_i  => sfp_sda_i ,
    sfp_det_i  => sfp_det_i ,
    btn1_i     => btn1_i    ,
    btn2_i     => btn2_i    ,
    spi_sclk_o => spi_sclk_o,
    spi_ncs_o  => spi_ncs_o ,
    spi_mosi_o => spi_mosi_o,
    spi_miso_i => spi_miso_i,

    -----------------------------------------
    --UART
    -----------------------------------------
    uart_rxd_i => uart_rxd_i,
    uart_txd_o => uart_txd_o,

    -----------------------------------------
    -- 1-wire
    -----------------------------------------
    owr_pwren_o => owr_pwren_o,
    owr_en_o    => owr_en_o   ,
    owr_i       => owr_i      ,

    -----------------------------------------
    --External WB interface
    -----------------------------------------
    wb_adr_i   => wb_adr_i  ,
    wb_dat_i   => wb_dat_i  ,
    wb_dat_o   => wb_dat_o  ,
    wb_sel_i   => wb_sel_i  ,
    wb_we_i    => wb_we_i   ,
    wb_cyc_i   => wb_cyc_i  ,
    wb_stb_i   => wb_stb_i  ,
    wb_ack_o   => wb_ack_o  ,
    wb_err_o   => wb_err_o  ,
    wb_rty_o   => wb_rty_o  ,
    wb_stall_o => wb_stall_o,

    -----------------------------------------
    -- Auxillary WB master
    -----------------------------------------
    aux_adr_o   => aux_adr_o  ,
    aux_dat_o   => aux_dat_o  ,
    aux_dat_i   => aux_dat_i  ,
    aux_sel_o   => aux_sel_o  ,
    aux_we_o    => aux_we_o   ,
    aux_cyc_o   => aux_cyc_o  ,
    aux_stb_o   => aux_stb_o  ,
    aux_ack_i   => aux_ack_i  ,
    aux_stall_i => aux_stall_i,

    -----------------------------------------
    -- External Fabric I/F
    -----------------------------------------
    ext_snk_adr_i   => ext_snk_adr_i  ,
    ext_snk_dat_i   => ext_snk_dat_i  ,
    ext_snk_sel_i   => ext_snk_sel_i  ,
    ext_snk_cyc_i   => ext_snk_cyc_i  ,
    ext_snk_we_i    => ext_snk_we_i   ,
    ext_snk_stb_i   => ext_snk_stb_i  ,
    ext_snk_ack_o   => ext_snk_ack_o  ,
    ext_snk_err_o   => ext_snk_err_o  ,
    ext_snk_stall_o => ext_snk_stall_o,

    ext_src_adr_o   => ext_src_adr_o  ,
    ext_src_dat_o   => ext_src_dat_o  ,
    ext_src_sel_o   => ext_src_sel_o  ,
    ext_src_cyc_o   => ext_src_cyc_o  ,
    ext_src_stb_o   => ext_src_stb_o  ,
    ext_src_we_o    => ext_src_we_o   ,
    ext_src_ack_i   => ext_src_ack_i  ,
    ext_src_err_i   => ext_src_err_i  ,
    ext_src_stall_i => ext_src_stall_i,

    ------------------------------------------
    -- External TX Timestamp I/F
    ------------------------------------------
    txtsu_port_id_o      => txtsu_port_id_o     ,
    txtsu_frame_id_o     => txtsu_frame_id_o    ,
    txtsu_ts_value_o     => txtsu_ts_value_o    ,
    txtsu_ts_incorrect_o => txtsu_ts_incorrect_o,
    txtsu_stb_o          => txtsu_stb_o         ,
    txtsu_ack_i          => txtsu_ack_i         ,

    -----------------------------------------
    -- Timestamp helper signals, used for Absolute Calibration
    -----------------------------------------
    abscal_txts_o        => abscal_txts_o       ,
    abscal_rxts_o        => abscal_rxts_o       ,

    -----------------------------------------
    -- Pause Frame Control
    -----------------------------------------
    fc_tx_pause_req_i   => fc_tx_pause_req_i  ,
    fc_tx_pause_delay_i => fc_tx_pause_delay_i,
    fc_tx_pause_ready_o => fc_tx_pause_ready_o,

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------

    tm_link_up_o         => tm_link_up_o        ,
    -- DAC Control
    tm_dac_value_o       => tm_dac_value_o      ,
    tm_dac_wr_o          => open,--tm_dac_wr_o         ,
    -- Aux clock lock enable
    tm_clk_aux_lock_en_i => (others => '0'),--tm_clk_aux_lock_en_i,
    -- Aux clock locked flag
    tm_clk_aux_locked_o  => open,--tm_clk_aux_locked_o ,
    -- Timecode output
    tm_time_valid_o      => tm_time_valid_o     ,
    tm_tai_o             => tm_tai_o            ,
    tm_cycles_o          => tm_cycles_o         ,
    -- 1PPS output
    pps_csync_o          => pps_csync_o         ,
    pps_valid_o          => pps_valid_o         ,
    pps_p_o              => pps_p_o             ,
    pps_led_o            => pps_led_o           ,

    rst_aux_n_o => rst_aux_n_o,

    link_ok_o => link_ok_o,

    -------------------------------------
    -- DIAG to/from external modules
    -------------------------------------
    aux_diag_i => aux_diag_i,
    aux_diag_o => aux_diag_o 
    );


end architecture;



