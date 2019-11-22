library ieee;
use ieee.std_logic_1164.all;

entity main_block is

  port (
    clk           : in  std_logic;

    checked_sw    : in  std_logic_vector(2 downto 0);
    rom_data      : in  std_logic_vector(7 downto 0);

    data_u        : in  std_logic_vector(7 downto 0);
    data_r        : in  std_logic_vector(7 downto 0);
    data_d        : in  std_logic_vector(7 downto 0);
    data_l        : in  std_logic_vector(7 downto 0);

    i2c_busy      : in  std_logic;
    i2c_init_done : in  std_logic;
    i2c_ack_error : in  std_logic;

    rom_addr      : out std_logic_vector(5 downto 0);

    i2c_reset_n   : out std_logic;
    i2c_init      : out std_logic;
    i2c_ena       : out std_logic;

    gesture_bcd   : out std_logic_vector(3 downto 0)
  );

end entity main_block;

architecture rtl of main_block is
begin



end architecture rtl;
