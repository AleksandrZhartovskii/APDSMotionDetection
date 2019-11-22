library ieee;
use ieee.std_logic_1164.all;

entity GRS is

  port (
    clk            : in    std_logic;
    checked_sw     : in    std_logic_vector(2 downto 0);

    sda            : inout std_logic;
    scl            : inout std_logic;

    indicator_code : out   std_logic_vector(6 downto 0)
  );

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

  signal APDS_master_reset_n    : std_logic;
  signal APDS_master_init       : std_logic;
  signal APDS_master_ena        : std_logic;
  signal APDS_master_busy       : std_logic;
  signal APDS_master_init_done  : std_logic;
  signal APDS_master_ack_error  : std_logic;

  signal data_u                 : std_logic_vector(7 downto 0);
  signal data_r                 : std_logic_vector(7 downto 0);
  signal data_d                 : std_logic_vector(7 downto 0);
  signal data_l                 : std_logic_vector(7 downto 0);

  signal gesture_bcd            : std_logic_vector(3 downto 0);

end entity GRS;

architecture rtl of GRS is
begin

  frequency_controller_inst : entity work.frequency_controller
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
    clk  => ci_clk,
    bcd  => gesture_bcd,
    code => indicator_code
  );

  constant_ROM_inst : entity work.constant_ROM
  port map (
    clk  => ci_clk,
    addr => rom_addr,
    data => rom_data
  );

  i2c_controller_inst : entity work.i2c_controller
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

  APDS_master_inst : entity work.APDS_master
  port map (
    clk           => ci_clk,
    reset_n       => APDS_master_reset_n,
    init          => APDS_master_init,
    ena           => APDS_master_ena,
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
    busy          => APDS_master_busy,
    init_done     => APDS_master_init_done,
    ack_error     => APDS_master_ack_error
  );

  main_block_inst : entity work.main_block
  port map (
    clk           => ci_clk,
    checked_sw    => ci_checked_sw,
    rom_data      => rom_data,
    data_u        => data_u,
    data_r        => data_r,
    data_d        => data_d,
    data_l        => data_l,
    i2c_busy      => APDS_master_busy,
    i2c_init_done => APDS_master_init_done,
    i2c_ack_error => APDS_master_ack_error,
    rom_addr      => rom_addr,
    i2c_reset_n   => APDS_master_reset_n,
    i2c_init      => APDS_master_init,
    i2c_ena       => APDS_master_ena,
    gesture_bcd   => gesture_bcd
  );

end architecture rtl;
