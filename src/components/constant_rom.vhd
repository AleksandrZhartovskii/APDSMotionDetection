library ieee;
use ieee.std_logic_1164.all;

entity constant_rom is

   port (
      clk  : in  std_logic;
      addr : in  std_logic_vector(5 downto 0);

      data : out std_logic_vector(7 downto 0)
   );

end entity constant_rom;

architecture rtl of constant_rom is

  --rom addresses

  constant RA_APDS9960_EN           : std_logic_vector(5 downto 0) := "000000";
  constant RA_APDS9960_WTIME        : std_logic_vector(5 downto 0) := "000001";
  constant RA_APDS9960_PPULSE       : std_logic_vector(5 downto 0) := "000010";
  constant RA_APDS9960_CONTROL      : std_logic_vector(5 downto 0) := "000011";
  constant RA_APDS9960_CONFIG1      : std_logic_vector(5 downto 0) := "000100";
  constant RA_APDS9960_CONFIG2      : std_logic_vector(5 downto 0) := "000101";
  constant RA_APDS9960_CONFIG3      : std_logic_vector(5 downto 0) := "000110";

  constant RA_APDS9960_GPENTH       : std_logic_vector(5 downto 0) := "000111";
  constant RA_APDS9960_GEXTH        : std_logic_vector(5 downto 0) := "001000";
  constant RA_APDS9960_GOFFSET_U    : std_logic_vector(5 downto 0) := "001001";
  constant RA_APDS9960_GOFFSET_D    : std_logic_vector(5 downto 0) := "001010";
  constant RA_APDS9960_GOFFSET_L    : std_logic_vector(5 downto 0) := "001011";
  constant RA_APDS9960_GOFFSET_R    : std_logic_vector(5 downto 0) := "001100";
  constant RA_APDS9960_GPULSE       : std_logic_vector(5 downto 0) := "001101";
  constant RA_APDS9960_GCONFIG1     : std_logic_vector(5 downto 0) := "001110";
  constant RA_APDS9960_GCONFIG2     : std_logic_vector(5 downto 0) := "001111";
  constant RA_APDS9960_GCONFIG3     : std_logic_vector(5 downto 0) := "010000";
  constant RA_APDS9960_GCONFIG4     : std_logic_vector(5 downto 0) := "010001";

  --values

  constant V_APDS9960_EN            : std_logic_vector(7 downto 0) := "01001101";
  constant V_APDS9960_WTIME         : std_logic_vector(7 downto 0) := "11111111";
  constant V_APDS9960_PPULSE        : std_logic_vector(7 downto 0) := "10001001";
  constant V_APDS9960_CONTROL       : std_logic_vector(7 downto 0) := "00001000";
  constant V_APDS9960_CONFIG1       : std_logic_vector(7 downto 0) := "01100000";
  constant V_APDS9960_CONFIG2       : std_logic_vector(7 downto 0) := "00110001";
  constant V_APDS9960_CONFIG3       : std_logic_vector(7 downto 0) := "00000000";

  constant V_APDS9960_GPENTH        : std_logic_vector(7 downto 0) := "00101000";
  constant V_APDS9960_GEXTH         : std_logic_vector(7 downto 0) := "00011110";
  constant V_APDS9960_GOFFSET_U     : std_logic_vector(7 downto 0) := "00000000";
  constant V_APDS9960_GOFFSET_D     : std_logic_vector(7 downto 0) := "00000000";
  constant V_APDS9960_GOFFSET_L     : std_logic_vector(7 downto 0) := "00000000";
  constant V_APDS9960_GOFFSET_R     : std_logic_vector(7 downto 0) := "00000000";
  constant V_APDS9960_GPULSE        : std_logic_vector(7 downto 0) := "11001001";
  constant V_APDS9960_GCONFIG1      : std_logic_vector(7 downto 0) := "01000000";
  constant V_APDS9960_GCONFIG2      : std_logic_vector(7 downto 0) := "01000001";
  constant V_APDS9960_GCONFIG3      : std_logic_vector(7 downto 0) := "00000000";
  constant V_APDS9960_GCONFIG4      : std_logic_vector(7 downto 0) := "00000000";

begin

  process (clk)
  begin
    if rising_edge(clk) then
      case addr is
        when RA_APDS9960_EN           => data <= V_APDS9960_EN;
        when RA_APDS9960_WTIME        => data <= V_APDS9960_WTIME;
        when RA_APDS9960_PPULSE       => data <= V_APDS9960_PPULSE;
        when RA_APDS9960_CONTROL      => data <= V_APDS9960_CONTROL;
        when RA_APDS9960_CONFIG1      => data <= V_APDS9960_CONFIG1;
        when RA_APDS9960_CONFIG2      => data <= V_APDS9960_CONFIG2;
        when RA_APDS9960_CONFIG3      => data <= V_APDS9960_CONFIG3;
        when RA_APDS9960_GPENTH       => data <= V_APDS9960_GPENTH;
        when RA_APDS9960_GEXTH        => data <= V_APDS9960_GEXTH;
        when RA_APDS9960_GOFFSET_U    => data <= V_APDS9960_GOFFSET_U;
        when RA_APDS9960_GOFFSET_D    => data <= V_APDS9960_GOFFSET_D;
        when RA_APDS9960_GOFFSET_L    => data <= V_APDS9960_GOFFSET_L;
        when RA_APDS9960_GOFFSET_R    => data <= V_APDS9960_GOFFSET_R;
        when RA_APDS9960_GPULSE       => data <= V_APDS9960_GPULSE;
        when RA_APDS9960_GCONFIG1     => data <= V_APDS9960_GCONFIG1;
        when RA_APDS9960_GCONFIG2     => data <= V_APDS9960_GCONFIG2;
        when RA_APDS9960_GCONFIG3     => data <= V_APDS9960_GCONFIG3;
        when RA_APDS9960_GCONFIG4     => data <= V_APDS9960_GCONFIG4;
        when others                   => null;
      end case;
    end if;
  end process;

end architecture rtl;
