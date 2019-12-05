library ieee;
use ieee.std_logic_1164.all;

entity apds_master is

  port (
    clk           : in     std_logic;

    reset_n       : in     std_logic;
    ena           : in     std_logic;
    op            : in     std_logic;

    rom_data      : in     std_logic_vector(7 downto 0);

    i2c_busy      : in     std_logic;
    i2c_data_rd   : in     std_logic_vector(7 downto 0);
    i2c_ack_error : in     std_logic;

    rom_addr      : out    std_logic_vector(5 downto 0);

    i2c_reset_n   : out    std_logic;
    i2c_ena       : out    std_logic;
    i2c_rw        : out    std_logic;
    i2c_addr      : out    std_logic_vector(6 downto 0);
    i2c_data_wr   : out    std_logic_vector(7 downto 0);

    data_u        : out    std_logic_vector(7 downto 0);
    data_r        : out    std_logic_vector(7 downto 0);
    data_d        : out    std_logic_vector(7 downto 0);
    data_l        : out    std_logic_vector(7 downto 0);

    gvalid        : out    std_logic;
    gflvl         : out    std_logic_vector(7 downto 0);

    busy          : out    std_logic;

    ack_error     : buffer std_logic
  );

end entity apds_master;

architecture rtl of apds_master is

  --rom addresses

  constant RA_APDS9960_EN        : std_logic_vector(5 downto 0) := "000000";
  constant RA_APDS9960_WTIME     : std_logic_vector(5 downto 0) := "000001";
  constant RA_APDS9960_PPULSE    : std_logic_vector(5 downto 0) := "000010";
  constant RA_APDS9960_CONTROL   : std_logic_vector(5 downto 0) := "000011";
  constant RA_APDS9960_CONFIG1   : std_logic_vector(5 downto 0) := "000100";
  constant RA_APDS9960_CONFIG2   : std_logic_vector(5 downto 0) := "000101";
  constant RA_APDS9960_CONFIG3   : std_logic_vector(5 downto 0) := "000110";

  constant RA_APDS9960_GPENTH    : std_logic_vector(5 downto 0) := "000111";
  constant RA_APDS9960_GEXTH     : std_logic_vector(5 downto 0) := "001000";
  constant RA_APDS9960_GOFFSET_U : std_logic_vector(5 downto 0) := "001001";
  constant RA_APDS9960_GOFFSET_D : std_logic_vector(5 downto 0) := "001010";
  constant RA_APDS9960_GOFFSET_L : std_logic_vector(5 downto 0) := "001011";
  constant RA_APDS9960_GOFFSET_R : std_logic_vector(5 downto 0) := "001100";
  constant RA_APDS9960_GPULSE    : std_logic_vector(5 downto 0) := "001101";
  constant RA_APDS9960_GCONFIG1  : std_logic_vector(5 downto 0) := "001110";
  constant RA_APDS9960_GCONFIG2  : std_logic_vector(5 downto 0) := "001111";
  constant RA_APDS9960_GCONFIG3  : std_logic_vector(5 downto 0) := "010000";
  constant RA_APDS9960_GCONFIG4  : std_logic_vector(5 downto 0) := "010001";

  --apds9960 address

  constant APDS9960_ADDR         : std_logic_vector(6 downto 0) := "0111001";

  --apds9960 register addresses

  constant APDS9960_R_EN         : std_logic_vector(7 downto 0) := "10000000";
  constant APDS9960_R_WTIME      : std_logic_vector(7 downto 0) := "10000011";
  constant APDS9960_R_PPULSE     : std_logic_vector(7 downto 0) := "10001110";
  constant APDS9960_R_CONTROL    : std_logic_vector(7 downto 0) := "10001111";
  constant APDS9960_R_CONFIG1    : std_logic_vector(7 downto 0) := "10001101";
  constant APDS9960_R_CONFIG2    : std_logic_vector(7 downto 0) := "10010000";
  constant APDS9960_R_CONFIG3    : std_logic_vector(7 downto 0) := "10011111";

  constant APDS9960_R_GPENTH     : std_logic_vector(7 downto 0) := "10100000";
  constant APDS9960_R_GEXTH      : std_logic_vector(7 downto 0) := "10100001";
  constant APDS9960_R_GOFFSET_U  : std_logic_vector(7 downto 0) := "10100100";
  constant APDS9960_R_GOFFSET_D  : std_logic_vector(7 downto 0) := "10100101";
  constant APDS9960_R_GOFFSET_L  : std_logic_vector(7 downto 0) := "10100111";
  constant APDS9960_R_GOFFSET_R  : std_logic_vector(7 downto 0) := "10101001";
  constant APDS9960_R_GPULSE     : std_logic_vector(7 downto 0) := "10100110";
  constant APDS9960_R_GCONFIG1   : std_logic_vector(7 downto 0) := "10100010";
  constant APDS9960_R_GCONFIG2   : std_logic_vector(7 downto 0) := "10100011";
  constant APDS9960_R_GCONFIG3   : std_logic_vector(7 downto 0) := "10101010";
  constant APDS9960_R_GCONFIG4   : std_logic_vector(7 downto 0) := "10101011";

  constant APDS9960_R_GFIFO_U    : std_logic_vector(7 downto 0) := "11111100";
  constant APDS9960_R_GFIFO_D    : std_logic_vector(7 downto 0) := "11111101";
  constant APDS9960_R_GFIFO_L    : std_logic_vector(7 downto 0) := "11111110";
  constant APDS9960_R_GFIFO_R    : std_logic_vector(7 downto 0) := "11111111";

  constant APDS9960_R_GSTATUS    : std_logic_vector(7 downto 0) := "10101111";
  constant APDS9960_R_GFLVL      : std_logic_vector(7 downto 0) := "10101110";

  type machine is (init, ready, read_fifo, read_specs, reg_init, reg_read, error);

  signal state             : machine;
  signal state_prev        : machine;

  signal i2c_busy_prev     : std_logic;

  signal reg_apds9960_addr : std_logic_vector(7 downto 0);
  signal reg_data_rom_addr : std_logic_vector(5 downto 0);

begin

  process (clk, reset_n, ack_error)
    variable stage_init       : natural range 0 to 18;
    variable stage_read_fifo  : natural range 0 to 5;
    variable stage_read_specs : natural range 0 to 3;
    variable stage_reg_init   : natural range 0 to 3;
    variable stage_reg_read   : natural range 0 to 3;
  begin
    if (reset_n = '0') then
      stage_init := 0;
      stage_read_fifo := 0;
      stage_read_specs := 0;
      stage_reg_init := 0;
      stage_reg_read := 0;

      state <= init;
      i2c_busy_prev <= '0';

      i2c_ena <= '0';
      busy <= '1';

      gvalid <= '0';
      gflvl <= "00000000";

      data_u <= "00000000";
      data_r <= "00000000";
      data_d <= "00000000";
      data_l <= "00000000";
    elsif ((ack_error = '1') and (state /= error)) then
      i2c_ena <= '0';
      state <= error;
    elsif rising_edge(clk) then
      case state is
        when init =>
          if (ena = '1') then
            busy <= '1';

            case stage_init is
              when 0 =>
                reg_apds9960_addr <= APDS9960_R_WTIME;
                reg_data_rom_addr <= RA_APDS9960_WTIME;
              when 1 =>
                reg_apds9960_addr <= APDS9960_R_PPULSE;
                reg_data_rom_addr <= RA_APDS9960_PPULSE;
              when 2 =>
                reg_apds9960_addr <= APDS9960_R_CONTROL;
                reg_data_rom_addr <= RA_APDS9960_CONTROL;
              when 3 =>
                reg_apds9960_addr <= APDS9960_R_CONFIG1;
                reg_data_rom_addr <= RA_APDS9960_CONFIG1;
              when 4 =>
                reg_apds9960_addr <= APDS9960_R_CONFIG2;
                reg_data_rom_addr <= RA_APDS9960_CONFIG2;
              when 5 =>
                reg_apds9960_addr <= APDS9960_R_CONFIG3;
                reg_data_rom_addr <= RA_APDS9960_CONFIG3;
              when 6 =>
                reg_apds9960_addr <= APDS9960_R_GPENTH;
                reg_data_rom_addr <= RA_APDS9960_GPENTH;
              when 7 =>
                reg_apds9960_addr <= APDS9960_R_GEXTH;
                reg_data_rom_addr <= RA_APDS9960_GEXTH;
              when 8 =>
                reg_apds9960_addr <= APDS9960_R_GOFFSET_U;
                reg_data_rom_addr <= RA_APDS9960_GOFFSET_U;
              when 9 =>
                reg_apds9960_addr <= APDS9960_R_GOFFSET_D;
                reg_data_rom_addr <= RA_APDS9960_GOFFSET_D;
              when 10 =>
                reg_apds9960_addr <= APDS9960_R_GOFFSET_L;
                reg_data_rom_addr <= RA_APDS9960_GOFFSET_L;
              when 11 =>
                reg_apds9960_addr <= APDS9960_R_GOFFSET_R;
                reg_data_rom_addr <= RA_APDS9960_GOFFSET_R;
              when 12 =>
                reg_apds9960_addr <= APDS9960_R_GPULSE;
                reg_data_rom_addr <= RA_APDS9960_GPULSE;
              when 13 =>
                reg_apds9960_addr <= APDS9960_R_GCONFIG1;
                reg_data_rom_addr <= RA_APDS9960_GCONFIG1;
              when 14 =>
                reg_apds9960_addr <= APDS9960_R_GCONFIG2;
                reg_data_rom_addr <= RA_APDS9960_GCONFIG2;
              when 15 =>
                reg_apds9960_addr <= APDS9960_R_GCONFIG3;
                reg_data_rom_addr <= RA_APDS9960_GCONFIG3;
              when 16 =>
                reg_apds9960_addr <= APDS9960_R_GCONFIG4;
                reg_data_rom_addr <= RA_APDS9960_GCONFIG4;
              when 17 =>
                reg_apds9960_addr <= APDS9960_R_EN;
                reg_data_rom_addr <= RA_APDS9960_EN;
              when others =>
                null;
            end case;

            if (stage_init <= 17) then
              state <= reg_init;
              stage_init := stage_init + 1;
            else
              busy <= '0';
              state <= ready;
              stage_init := 0;
            end if;
          end if;
        when ready =>
          if (ena = '1') then
            case op is
              when '0' =>
                busy <= '1';
                state <= read_specs;
              when '1' =>
                busy <= '1';
                state <= read_fifo;
              when others =>
                null;
            end case;
          end if;
        when read_specs =>
          case stage_read_specs is
            when 0 =>
              reg_apds9960_addr <= APDS9960_R_GSTATUS;
            when 1 =>
              gvalid <= i2c_data_rd(0);
              reg_apds9960_addr <= APDS9960_R_GFLVL;
            when 2 =>
              gflvl <= i2c_data_rd;
            when others =>
              null;

            if (stage_read_specs <= 2) then
              stage_read_specs := stage_read_specs + 1;

              if (stage_read_specs <= 1) then
                state <= reg_read;
                state_prev <= read_specs;
              end if;
            else
              busy <= '0';
              state <= ready;
              stage_read_specs := 0;
            end if;
          end case;
        when read_fifo =>
          case stage_read_fifo is
            when 0 =>
              reg_apds9960_addr <= APDS9960_R_GFIFO_U;
            when 1 =>
              data_u <= i2c_data_rd;
              reg_apds9960_addr <= APDS9960_R_GFIFO_R;
            when 2 =>
              data_r <= i2c_data_rd;
              reg_apds9960_addr <= APDS9960_R_GFIFO_D;
            when 3 =>
              data_d <= i2c_data_rd;
              reg_apds9960_addr <= APDS9960_R_GFIFO_L;
            when 4 =>
              data_l <= i2c_data_rd;
            when others =>
              null;
          end case;

          if (stage_read_fifo <= 4) then
            stage_read_fifo := stage_read_fifo + 1;

            if (stage_read_fifo <= 3) then
              state <= reg_read;
              state_prev <= read_fifo;
            end if;
          else
            busy <= '0';
            state <= ready;
            stage_read_fifo := 0;
          end if;
        when reg_init =>
          i2c_rw <= '0';
          i2c_busy_prev <= i2c_busy;

          if (
            (i2c_busy_prev = '0' and i2c_busy = '1') or
            (i2c_busy = '0' and stage_reg_init = 2)
          ) then
            stage_reg_init := stage_reg_init + 1;
          end if;

          case stage_reg_init is
            when 0 =>
              i2c_data_wr <= reg_apds9960_addr;
              i2c_ena <= '1';

              rom_addr <= reg_data_rom_addr;
            when 1 =>
              i2c_data_wr <= rom_data;
            when 2 =>
              i2c_ena <= '0';
            when 3 =>
              state <= init;
              stage_reg_init := 0;
          end case;
        when reg_read =>
          i2c_rw <= '0';
          i2c_busy_prev <= i2c_busy;

          if (
            (i2c_busy_prev = '0' and i2c_busy = '1') or
            (i2c_busy = '0' and stage_reg_read = 2)
          ) then
            stage_reg_read := stage_reg_read + 1;
          end if;

          case stage_reg_read is
            when 0 =>
              i2c_data_wr <= reg_apds9960_addr;
              i2c_ena <= '1';
            when 1 =>
              i2c_rw <= '1';
            when 2 =>
              i2c_ena <= '0';
            when 3 =>
              state <= state_prev;
              stage_reg_read := 0;
          end case;
        when error =>
          null;
      end case;
    end if;
  end process;

  i2c_addr <= APDS9960_ADDR;

  i2c_reset_n <= reset_n;
  ack_error <= i2c_ack_error;

end architecture rtl;
