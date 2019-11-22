library ieee;
use ieee.std_logic_1164.all;

entity APDS_master is

  port (
    clk           : in std_logic;

    reset_n       : in std_logic;
    init          : in std_logic;
    ena           : in std_logic;

    rom_data      : in std_logic_vector(7 downto 0);

    i2c_busy      : in std_logic;
    i2c_data_rd   : in std_logic_vector(7 downto 0);
    i2c_ack_error : in std_logic;

    rom_addr      : out std_logic_vector(5 downto 0);

    i2c_reset_n   : out std_logic;
    i2c_ena       : out std_logic;
    i2c_rw        : out std_logic;
    i2c_addr      : out std_logic_vector(6 downto 0);
    i2c_data_wr   : out std_logic_vector(7 downto 0);

    data_u        : out std_logic_vector(7 downto 0);
    data_r        : out std_logic_vector(7 downto 0);
    data_d        : out std_logic_vector(7 downto 0);
    data_l        : out std_logic_vector(7 downto 0);

    busy          : out std_logic;
    init_done     : out std_logic;

    ack_error     : buffer std_logic
  );

end entity APDS_master;

architecture rtl of APDS_master is
begin



end architecture rtl;
