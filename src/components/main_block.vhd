library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_block is

  generic (
    clk_freq : positive range 1000 to positive'high
  );

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

  --TODO: add switches (1) and (0) handlers

  subtype u_byte is natural range 0 to 255;
  subtype short is integer range -32_768 to 32_767;

  constant GESTURE_THRESHOLD_OUT  : u_byte := 10;
  constant GESTURE_SENSITIVITY_1  : u_byte := 50;
  constant GESTURE_SENSITIVITY_2  : u_byte := 20;

  constant GEST_DT_UP             : std_logic_vector(3 downto 0) := "0001";
  constant GEST_DT_DOWN           : std_logic_vector(3 downto 0) := "0010";
  constant GEST_DT_LEFT           : std_logic_vector(3 downto 0) := "0011";
  constant GEST_DT_RIGHT          : std_logic_vector(3 downto 0) := "0100";
  constant GEST_DT_NEAR           : std_logic_vector(3 downto 0) := "0101";
  constant GEST_DT_FAR            : std_logic_vector(3 downto 0) := "0110";

  constant GEST_DT_UNDEFINED      : std_logic_vector(3 downto 0) := "0000";
  constant GEST_DT_ERROR          : std_logic_vector(3 downto 0) := "0111";

  constant FIFO_DELAY_TIME        : short := 30;
  constant FIFO_DELAY_TICKS       : natural := (clk_freq / 1000) * FIFO_DELAY_TIME;

  type u_byte_array is array (natural range <>) of u_byte;
  type machine is (
    init,
    poll,
    read_data,
    process_data_size,
    find_first_appropriate_set,
    process_data_quality,
    find_last_appropriate_set,
    calculate_ratios,
    calculate_deltas,
    accumulate_deltas,
    calculate_urdl_gesture_values,
    calculate_nf_gesture_values,
    catch_nf_state,
    correct_nf_state_values,
    process_read_end,
    decode_gesture,
    reset_vars,
    delay,
    error
  );

  signal state          : machine;
  signal state_prev     : machine;

  signal reset_n        : std_logic;

  signal is_delay       : std_logic;
  signal m_busy_prev    : std_logic;

  signal fifo_level     : natural range 0 to 32;

  signal idx            : natural range 0 to 32;
  signal delay_cnt      : positive range 1 to FIFO_DELAY_TICKS;

  signal data_u_arr     : u_byte_array(0 to 31);
  signal data_r_arr     : u_byte_array(0 to 31);
  signal data_d_arr     : u_byte_array(0 to 31);
  signal data_l_arr     : u_byte_array(0 to 31);

  signal u_first        : u_byte;
  signal r_first        : u_byte;
  signal d_first        : u_byte;
  signal l_first        : u_byte;

  signal u_last         : u_byte;
  signal r_last         : u_byte;
  signal d_last         : u_byte;
  signal l_last         : u_byte;

  signal ud_ratio_first : short;
  signal lr_ratio_first : short;
  signal ud_ratio_last  : short;
  signal lr_ratio_last  : short;

  signal ud_delta       : short;
  signal lr_delta       : short;

  signal acc_ud_delta   : short := 0;
  signal acc_lr_delta   : short := 0;

  signal gest_n_count   : u_byte;
  signal gest_f_count   : u_byte;

  signal gest_ud_state  : integer range -1 to 1;
  signal gest_lr_state  : integer range -1 to 1;
  signal gest_nf_state  : integer range -1 to 1;

  procedure reset_gest_vars is
  begin
    acc_ud_delta <= 0;
    acc_lr_delta <= 0;

    gest_n_count <= 0;
    gest_f_count <= 0;

    gest_ud_state <= 0;
    gest_lr_state <= 0;
    gest_nf_state <= 0;
  end procedure;

begin

  process (clk, reset_n, m_ack_error)
  begin
    if (reset_n = '0') then
      m_ena <= '0';
      m_op <= '0';

      idx <= 0;
      delay_cnt <= 1;
      m_busy_prev <= '0';

      reset_gest_vars;

      state <= init;
    elsif (m_ack_error = '1') then
      m_ena <= '0';
      state <= error;
    elsif rising_edge(clk) then
      case state is
        when init =>
          gest_dt <= GEST_DT_UNDEFINED;

          m_ena <= '1';
          m_busy_prev <= m_busy;

          if (m_busy_prev = '1') then
            m_ena <= '0';

            if (m_busy = '0') then
              state <= poll;
              is_delay <= '1';
            end if;
          end if;
        when poll =>
          if (is_delay = '1') then
            state <= delay;
            state_prev <= poll;
          else
            m_op <= '0';
            m_ena <= '1';

            m_busy_prev <= m_busy;

            if (m_busy_prev = '1') then
              m_ena <= '0';

              if (m_busy = '0') then
                if (gvalid = '1') then
                  fifo_level <= to_integer(unsigned(gflvl));
                  state <= read_data;
                else
                  is_delay <= '1';
                end if;
              end if;
            end if;
          end if;
        when read_data =>
          m_op <= '1';
          m_ena <= '1';

          m_busy_prev <= m_busy;

          if (m_busy_prev = '1') then
            if (idx = fifo_level - 1) then
              m_ena <= '0';
            end if;

            if (m_busy = '0') then
              data_u_arr(idx) <= to_integer(unsigned(data_u));
              data_r_arr(idx) <= to_integer(unsigned(data_r));
              data_d_arr(idx) <= to_integer(unsigned(data_d));
              data_l_arr(idx) <= to_integer(unsigned(data_l));

              if (idx = fifo_level - 1) then
                idx <= 0;
                state <= process_data_size;
              else
                idx <= idx + 1;
              end if;
            end if;
          end if;
        when process_data_size =>
          if (fifo_level > 4) then
            state <= find_first_appropriate_set;
          else
            state <= process_read_end;
            is_delay <= '1';
          end if;
        when find_first_appropriate_set =>
          if ((idx = fifo_level - 1) or (
              (data_u_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_r_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_d_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_l_arr(idx) > GESTURE_THRESHOLD_OUT)
          )) then
            u_first <= data_u_arr(idx);
            r_first <= data_r_arr(idx);
            d_first <= data_d_arr(idx);
            l_first <= data_l_arr(idx);

            idx <= 0;
            state <= process_data_quality;
          else
            idx <= idx + 1;
          end if;
        when process_data_quality =>
          if (
            (u_first /= 0) and
            (r_first /= 0) and
            (d_first /= 0) and
            (l_first /= 0)
          ) then
            state <= find_last_appropriate_set;
            idx <= fifo_level - 1;
          else
            state <= process_read_end;
            is_delay <= '1';
          end if;
        when find_last_appropriate_set =>
          if ((idx = 0) or (
              (data_u_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_r_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_d_arr(idx) > GESTURE_THRESHOLD_OUT) and
              (data_l_arr(idx) > GESTURE_THRESHOLD_OUT)
          )) then
            u_last <= data_u_arr(idx);
            r_last <= data_r_arr(idx);
            d_last <= data_d_arr(idx);
            l_last <= data_l_arr(idx);

            idx <= 0;
            state <= calculate_ratios;
          else
            idx <= idx - 1;
          end if;
        when calculate_ratios =>
          ud_ratio_first <= ((u_first - d_first) * 100) / (u_first + d_first);
          lr_ratio_first <= ((l_first - r_first) * 100) / (l_first + r_first);
          ud_ratio_last <= ((u_last - d_last) * 100) / (u_last + d_last);
          lr_ratio_last <= ((l_last - r_last) * 100) / (l_last + r_last);

          state <= calculate_deltas;
        when calculate_deltas =>
          ud_delta <= ud_ratio_last - ud_ratio_first;
          lr_delta <= lr_ratio_last - lr_ratio_first;

          state <= accumulate_deltas;
        when accumulate_deltas =>
          acc_ud_delta <= acc_ud_delta + ud_delta;
          acc_lr_delta <= acc_lr_delta + lr_delta;

          state <= calculate_urdl_gesture_values;
        when calculate_urdl_gesture_values =>
          if (acc_ud_delta >= GESTURE_SENSITIVITY_1) then
            gest_ud_state <= 1;
          elsif (acc_ud_delta <= -GESTURE_SENSITIVITY_1) then
            gest_ud_state <= -1;
          end if;

          if (acc_lr_delta >= GESTURE_SENSITIVITY_1) then
            gest_lr_state <= 1;
          elsif (acc_lr_delta <= -GESTURE_SENSITIVITY_1) then
            gest_lr_state <= -1;
          end if;

          state <= calculate_nf_gesture_values;
        when calculate_nf_gesture_values =>
          if (
            (abs(ud_delta) < GESTURE_SENSITIVITY_2) and
            (abs(lr_delta) < GESTURE_SENSITIVITY_2)
          ) then
            if ((gest_ud_state = 0) and (gest_lr_state = 0)) then
              if ((ud_delta = 0) and (lr_delta = 0)) then
                gest_n_count <= gest_n_count + 1;
              elsif ((ud_delta /= 0) or (lr_delta /= 0)) then
                gest_f_count <= gest_f_count + 1;
              end if;

              state <= catch_nf_state;
            else
              if ((ud_delta = 0) and (lr_delta = 0)) then
                gest_n_count <= gest_n_count + 1;
              end if;

              state <= correct_nf_state_values;
            end if;
          else
            state <= process_read_end;
            is_delay <= '1';
          end if;
        when catch_nf_state =>
          if ((gest_n_count >= 10) and (gest_f_count >= 2)) then
            if ((ud_delta = 0) and (lr_delta = 0)) then
              gest_nf_state <= -1;
            elsif ((ud_delta /= 0) and (lr_delta /= 0)) then
              gest_nf_state <= 1;
            end if;
          end if;

          state <= process_read_end;
          is_delay <= '1';
        when correct_nf_state_values =>
          if (gest_n_count >= 10) then
            acc_ud_delta <= 0;
            acc_lr_delta <= 0;

            gest_ud_state <= 0;
            gest_lr_state <= 0;
          end if;

          state <= process_read_end;
          is_delay <= '1';
        when process_read_end =>
          if (is_delay = '1') then
            state <= delay;
            state_prev <= process_read_end;
          else
            m_op <= '0';
            m_ena <= '1';

            m_busy_prev <= m_busy;

            if (m_busy_prev = '1') then
              m_ena <= '0';

              if (m_busy = '0') then
                if (gvalid = '1') then
                  fifo_level <= to_integer(unsigned(gflvl));
                  state <= read_data;
                else
                  state <= decode_gesture;
                end if;
              end if;
            end if;
          end if;
        when decode_gesture =>
          if (gest_nf_state = -1) then
            gest_dt <= GEST_DT_NEAR;
          elsif (gest_nf_state = 1) then
            gest_dt <= GEST_DT_FAR;
          elsif ((gest_ud_state = -1) and (gest_lr_state = 0)) then
            gest_dt <= GEST_DT_UP;
          elsif ((gest_ud_state = 1) and (gest_lr_state = 0)) then
            gest_dt <= GEST_DT_DOWN;
          elsif ((gest_ud_state = 0) and (gest_lr_state = 1)) then
            gest_dt <= GEST_DT_RIGHT;
          elsif ((gest_ud_state = 0) and (gest_lr_state = -1)) then
            gest_dt <= GEST_DT_LEFT;
          elsif ((gest_ud_state = -1) and (gest_lr_state = 1)) then
            if (abs(acc_ud_delta) > abs(acc_lr_delta)) then
              gest_dt <= GEST_DT_UP;
            else
              gest_dt <= GEST_DT_RIGHT;
            end if;
          elsif ((gest_ud_state = 1) and (gest_lr_state = -1)) then
            if (abs(acc_ud_delta) > abs(acc_lr_delta)) then
              gest_dt <= GEST_DT_DOWN;
            else
              gest_dt <= GEST_DT_LEFT;
            end if;
          elsif ((gest_ud_state = -1) and (gest_lr_state = -1)) then
            if (abs(acc_ud_delta) > abs(acc_lr_delta)) then
              gest_dt <= GEST_DT_UP;
            else
              gest_dt <= GEST_DT_LEFT;
            end if;
          elsif ((gest_ud_state = 1) and (gest_lr_state = 1)) then
            if (abs(acc_ud_delta) > abs(acc_lr_delta)) then
              gest_dt <= GEST_DT_DOWN;
            else
              gest_dt <= GEST_DT_RIGHT;
            end if;
          else
            gest_dt <= GEST_DT_UNDEFINED;
          end if;

          state <= reset_vars;
        when reset_vars =>
          reset_gest_vars;

          state <= poll;
          is_delay <= '1';
        when delay =>
          if (delay_cnt = FIFO_DELAY_TICKS) then
            state <= state_prev;
            is_delay <= '0';

            delay_cnt <= 1;
          else
            delay_cnt <= delay_cnt + 1;
          end if;
        when error =>
          gest_dt <= GEST_DT_ERROR;
      end case;
    end if;
  end process;

  reset_n <= not(checked_sw(2));
  m_reset_n <= reset_n;

end architecture rtl;
