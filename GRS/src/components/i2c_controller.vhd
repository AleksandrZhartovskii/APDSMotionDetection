library ieee;
use ieee.std_logic_1164.all;

entity i2c_controller is

   port (
      clk          : in    std_logic;

      cmd_start    : in    std_logic;
      cmd_read     : in    std_logic;
      addr         : in    std_logic_vector(2 downto 0);

      SCL          : inout std_logic;
      SDA          : inout std_logic;

      cmd_ready    : out   std_logic;
      cmd_received : out   std_logic;
      data         : out   std_logic_vector(7 downto 0)
   );

end entity i2c_controller;

architecture rtl of i2c_controller is
begin



end architecture rtl;
