library ieee;
use ieee.std_logic_1164.all;

entity indicator_controller is

  port (
    clk       : in  std_logic;

    reset_n   : in  std_logic;
    digit     : in  std_logic_vector(3 downto 0);

    seg_data  : out std_logic_vector(0 to 6)
  );

end entity indicator_controller;

architecture rtl of indicator_controller is
begin



end architecture rtl;