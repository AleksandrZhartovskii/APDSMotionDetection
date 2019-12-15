library ieee;
use ieee.std_logic_1164.all;

entity indicator_controller is

  port (
    clk       : in  std_logic;

    ena       : in  std_logic;
    mode      : in  std_logic;

    gest_dt   : in  std_logic_vector(3 downto 0);
    seg_data  : out std_logic_vector(0 to 6)
  );

end entity indicator_controller;

architecture rtl of indicator_controller is

  constant SEG_DATA_OFF : std_logic_vector(0 to 6) := "1111111";
  constant SEG_DATA_UND : std_logic_vector(0 to 6) := "1111110";

  signal seg_data_num   : std_logic_vector(0 to 6);
  signal seg_data_alpha : std_logic_vector(0 to 6);
  signal t_data         : std_logic_vector(0 to 6);

begin

  num_inst : entity work.indicator_num_transformer
  generic map (
    SEG_DATA_UND => SEG_DATA_UND
  )
  port map (
    digit    => gest_dt,
    seg_data => seg_data_num
  );

  alpha_inst : entity work.indicator_alpha_transformer
  generic map (
    SEG_DATA_UND => SEG_DATA_UND
  )
  port map (
    char     => gest_dt,
    seg_data => seg_data_alpha
  );

  process (clk)
  begin
    if rising_edge(clk) then
      case mode is
        when '0' => t_data <= seg_data_num;
        when '1' => t_data <= seg_data_alpha;
      end case;
    end if;
  end process;

  seg_data <= t_data when ena = '1' else SEG_DATA_OFF;

end architecture rtl;
