library ieee;
use ieee.std_logic_1164.all;

entity indicator_controller is

  port (
    clk  : in  std_logic;
    bcd  : in  std_logic_vector(3 downto 0);

    code : out std_logic_vector(6 downto 0)
  );

end entity indicator_controller;

architecture rtl of indicator_controller is
begin



end architecture rtl;
