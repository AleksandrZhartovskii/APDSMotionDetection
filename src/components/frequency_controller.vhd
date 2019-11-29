library ieee;
use ieee.std_logic_1164.all;

entity frequency_controller is

  generic (
    gen_clk_in  : integer := 50_000_000;
    gen_clk_out : integer := 40_000
  );

  port (
    clk_in  : in  std_logic;
    clk_out : out std_logic
  );

end entity frequency_controller;

architecture rtl of frequency_controller is

  signal s_out : std_logic := '0';

begin

  process (clk_in)
    constant max_cnt : natural := (gen_clk_in / (gen_clk_out * 2)) - 1;
    variable cnt     : natural range 0 to max_cnt := 0;
  begin
    if rising_edge(clk_in) then
      if (cnt = max_cnt) then
        s_out <= not(s_out);
        cnt := 0;
      else
        cnt := cnt + 1;
      end if;
    end if;
  end process;

  clk_out <= s_out;

end architecture rtl;
