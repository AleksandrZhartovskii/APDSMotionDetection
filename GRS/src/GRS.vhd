library ieee;
use ieee.std_logic_1164.all;

entity GRS is

   port (
      clk            : in    std_logic;
      checked_sw     : in    std_logic_vector(2 downto 0);

      SCL            : inout std_logic;
      SDA            : inout std_logic;

      indicator_code : out   std_logic_vector(6 downto 0)
   );

   signal so_frequency_controller        : std_logic;
   signal so_switches_controller         : std_logic_vector(2 downto 0);
   signal so_constant_ROM                : std_logic_vector(7 downto 0);
    
   signal so_APDS_master_sensor_start    : std_logic;
   signal so_APDS_master_sensor_read     : std_logic;
   signal so_APDS_master_sensor_addr     : std_logic_vector(2 downto 0);
   signal so_APDS_master_constant_addr   : std_logic_vector(1 downto 0);
   signal so_APDS_master_data            : std_logic_vector(7 downto 0);
    
   signal so_i2c_controller_cmd_ready    : std_logic;
   signal so_i2c_controller_cmd_received : std_logic;
   signal so_i2c_controller_data         : std_logic_vector(7 downto 0);
    
   signal so_main_block_sensor_read      : std_logic;
   signal so_main_block_gesture_bcd      : std_logic_vector(3 downto 0);

end entity GRS;

architecture rtl of GRS is
begin

   frequency_controller_instance : entity work.frequency_controller
   port map (
      clk_in  => clk,
      clk_out => so_frequency_controller
   );

   switches_controller_instance : entity work.switches_controller
   port map (
      clk            => so_frequency_controller,
      checked_sw_in  => checked_sw,
      checked_sw_out => so_switches_controller
   );
    
    indicator_controller_instance : entity work.indicator_controller
   port map (
      clk  => so_frequency_controller,
      bcd  => so_main_block_gesture_bcd,
      code => indicator_code
   );

   constant_ROM_instance : entity work.constant_ROM
   port map (
      clk  => so_frequency_controller,
      addr => so_APDS_master_constant_addr,
      data => so_constant_ROM
   );

   i2c_controller_instance : entity work.i2c_controller
   port map (
      clk          => so_frequency_controller,
      cmd_start    => so_APDS_master_sensor_start,
      cmd_read     => so_APDS_master_sensor_read,
      addr         => so_APDS_master_sensor_addr,
      SCL          => SCL,
      SDA          => SDA,
      cmd_ready    => so_i2c_controller_cmd_ready,
      cmd_received => so_i2c_controller_cmd_received,
      data         => so_i2c_controller_data
   );
    
   APDS_master_instance : entity work.APDS_master
   port map (
      clk             => so_frequency_controller,
      cmd_read        => so_main_block_sensor_read,
      sensor_ready    => so_i2c_controller_cmd_ready,
      sensor_received => so_i2c_controller_cmd_received,
      raw_data        => so_i2c_controller_data,
      constant_data   => so_constant_ROM,
      sensor_start    => so_APDS_master_sensor_start,
      sensor_read     => so_APDS_master_sensor_read,
      sensor_addr     => so_APDS_master_sensor_addr,
      constant_addr   => so_APDS_master_constant_addr,
      data            => so_APDS_master_data
   );

   main_block_instance : entity work.main_block
   port map (
      clk         => so_frequency_controller,
      checked_sw  => so_switches_controller,
      sensor_data => so_APDS_master_data,
      sensor_read => so_main_block_sensor_read,
      gesture_bcd => so_main_block_gesture_bcd
   );

end architecture rtl;
