library ieee;
use ieee.std_logic_1164.all;

entity APDS_master is

   port (
      clk             : in  std_logic;
      cmd_read        : in  std_logic;

      sensor_ready    : in  std_logic;
      sensor_received : in  std_logic;
      raw_data        : in  std_logic_vector(7 downto 0);
      constant_data   : in  std_logic_vector(7 downto 0);

      sensor_start    : out std_logic;
      sensor_read     : out std_logic;
      sensor_addr     : out std_logic_vector(2 downto 0);
      constant_addr   : out std_logic_vector(1 downto 0);

      data            : out std_logic_vector(7 downto 0)
   );

end entity APDS_master;

architecture rtl of APDS_master is
begin



end architecture rtl;
