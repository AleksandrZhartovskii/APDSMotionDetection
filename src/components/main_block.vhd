library ieee;
use ieee.std_logic_1164.all;

entity main_block is

  port (
    clk         : in  std_logic;

    checked_sw  : in  std_logic_vector(2 downto 0);

    data_u      : in  std_logic_vector(7 downto 0);
    data_r      : in  std_logic_vector(7 downto 0);
    data_d      : in  std_logic_vector(7 downto 0);
    data_l      : in  std_logic_vector(7 downto 0);

    gvalid      : in  std_logic;
    gflvl       : in  std_logic_vector(7 downto 0);

    m_busy      : in  std_logic;
    m_ack_error : in  std_logic;

    m_reset_n   : out std_logic;
    m_ena       : out std_logic;
    m_op        : out std_logic;

    gest_dt     : out std_logic_vector(3 downto 0)
  );

end entity main_block;

architecture rtl of main_block is
begin



end architecture rtl;
