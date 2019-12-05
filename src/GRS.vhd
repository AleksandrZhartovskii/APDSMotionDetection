library ieee;
use ieee.std_logic_1164.all;

entity GRS is

  port (
    clk         : in    std_logic;
    checked_sw  : in    std_logic_vector(2 downto 0);

    sda         : inout std_logic;
    scl         : inout std_logic;

    seg_data    : out   std_logic_vector(0 to 6)
  );

  constant BOARD_FREQ   : positive := 50_000_000;
  constant SYSTEM_FREQ  : positive := 12_500_000;
  constant I2C_BUS_FREQ : positive := 400_000;

  signal ci_clk                 : std_logic;
  signal ci_checked_sw          : std_logic_vector(2 downto 0);

  signal rom_addr               : std_logic_vector(5 downto 0);
  signal rom_data               : std_logic_vector(7 downto 0);

  signal i2c_reset_n            : std_logic;
  signal i2c_ena                : std_logic;
  signal i2c_addr               : std_logic_vector(6 downto 0);
  signal i2c_rw                 : std_logic;
  signal i2c_data_wr            : std_logic_vector(7 downto 0);

  signal i2c_data_rd            : std_logic_vector(7 downto 0);
  signal i2c_busy               : std_logic;
  signal i2c_ack_error          : std_logic;

  signal apds_master_reset_n    : std_logic;
  signal apds_master_ena        : std_logic;
  signal apds_master_op         : std_logic;
  signal apds_master_busy       : std_logic;
  signal apds_master_ack_error  : std_logic;

  signal data_u                 : std_logic_vector(7 downto 0);
  signal data_r                 : std_logic_vector(7 downto 0);
  signal data_d                 : std_logic_vector(7 downto 0);
  signal data_l                 : std_logic_vector(7 downto 0);

  signal gvalid                 : std_logic;
  signal gflvl                  : std_logic_vector(7 downto 0);

  signal gest_dt                : std_logic_vector(3 downto 0);

end entity GRS;

architecture rtl of GRS is
begin

  frequency_controller_inst : entity work.frequency_controller
  generic map (
    clk_in_freq   => BOARD_FREQ,
    clk_out_freq  => SYSTEM_FREQ
  )
  port map (
    clk_in  => clk,
    clk_out => ci_clk
  );

  switches_controller_inst : entity work.switches_controller
  port map (
    clk            => ci_clk,
    checked_sw_in  => checked_sw,
    checked_sw_out => ci_checked_sw
  );

  indicator_controller_inst : entity work.indicator_controller
  port map (
    clk       => ci_clk,
    digit     => gest_dt,
    seg_data  => seg_data
  );

  constant_rom_inst : entity work.constant_rom
  port map (
    clk  => ci_clk,
    addr => rom_addr,
    data => rom_data
  );

  i2c_controller_inst : entity work.i2c_controller
  generic map (
    input_clk_freq  => BOARD_FREQ,
    bus_clk_freq    => I2C_BUS_FREQ
  )
  port map (
    clk       => clk,
    reset_n   => i2c_reset_n,
    ena       => i2c_ena,
    addr      => i2c_addr,
    rw        => i2c_rw,
    data_wr   => i2c_data_wr,
    busy      => i2c_busy,
    data_rd   => i2c_data_rd,
    ack_error => i2c_ack_error,
    sda       => sda,
    scl       => scl
  );

  apds_master_inst : entity work.apds_master
  port map (
    clk           => ci_clk,
    reset_n       => apds_master_reset_n,
    ena           => apds_master_ena,
    op            => apds_master_op,
    rom_data      => rom_data,
    i2c_busy      => i2c_busy,
    i2c_data_rd   => i2c_data_rd,
    i2c_ack_error => i2c_ack_error,
    rom_addr      => rom_addr,
    i2c_reset_n   => i2c_reset_n,
    i2c_ena       => i2c_ena,
    i2c_rw        => i2c_rw,
    i2c_addr      => i2c_addr,
    i2c_data_wr   => i2c_data_wr,
    data_u        => data_u,
    data_r        => data_r,
    data_d        => data_d,
    data_l        => data_l,
    gvalid        => gvalid,
    gflvl         => gflvl,
    busy          => apds_master_busy,
    ack_error     => apds_master_ack_error
  );

  main_block_inst : entity work.main_block
  generic map (
    clk_freq => SYSTEM_FREQ
  )
  port map (
    clk           => ci_clk,
    checked_sw    => ci_checked_sw,
    data_u        => data_u,
    data_r        => data_r,
    data_d        => data_d,
    data_l        => data_l,
    gvalid        => gvalid,
    gflvl         => gflvl,
    m_busy        => apds_master_busy,
    m_ack_error   => apds_master_ack_error,
    m_reset_n     => apds_master_reset_n,
    m_ena         => apds_master_ena,
    m_op          => apds_master_op,
    gest_dt       => gest_dt
  );

end architecture rtl;
