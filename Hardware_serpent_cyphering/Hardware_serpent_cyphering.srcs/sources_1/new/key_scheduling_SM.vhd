----------------------------------------------------------------------------------
-- Key scheduling process
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_scheduling_SM is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32;
        constant full_key_size : integer :=256;
        --constant theta : std_logic_vector(31 downto 0) := "10011101100111101110110001111001";
        constant theta : std_logic_vector := X"9e3779b9";
        constant four_bits : integer := 4
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        Ki_number : in integer; --key number 
        user_key : in std_logic_vector(full_bits-1 downto 0);
        ready_busy : out std_logic_vector(0 to 1);
        Ki : out std_logic_vector(full_bits-1 downto 0);
        ready_busy_key : out std_logic_vector(0 to 1)
    );
end key_scheduling_SM;

architecture Behavioral of key_scheduling_SM is

    ----TYPES--------------------------------------------------
    type w_array is array (-8 to 131) of STD_LOGIC_VECTOR(div4_bits-1 downto 0);
    type Ki_array is array (0 to 32) of STD_LOGIC_VECTOR(full_bits-1 downto 0);
    type t_sboxes is array (0 to 15) of integer; --S_BOX
    type t_array is array (0 to 127) of integer; --IP

    constant PADDING : std_logic_vector(full_bits-2 downto 0) := (others => '0');

    ----SIGNALS--------------------------------------------------
    signal sig_Ki : std_logic_vector(full_bits-1 downto 0);
    signal sig_Ki_number : integer := 0; --key number 
    signal sig_user_key : std_logic_vector(full_bits-1 downto 0);
    signal sig_pre_keys : Ki_array;
    signal sig_ready_busy : std_logic_vector(0 to 1);
    signal sig_ready_busy_key : std_logic_vector(0 to 1);

    signal sig_expanded_Key : std_logic_vector(full_key_size-1 downto 0) := (others => '0');

    type state_type is (IDLE, PREKEY_CALCULATION, KEY_EXPEND, ASSEMBLING_KEY, FLAG_IP, MERGING);
    signal state : state_type := IDLE;

    -- Define signals to control state transitions
    signal start_processing : std_logic;
    signal prekey_calc_done : std_logic;
    signal key_expend_done : std_logic;
    signal key_assembled : std_logic;
    signal flag_ip_done : std_logic;
    signal merging_done : std_logic;

    ----S-boxes--------------------------------------------------
    function  app_s_box(
        input_bits : in std_logic_vector(four_bits-1 downto 0);
        s_box_number : in integer 
    )
    return std_logic_vector is
        variable S0 : t_sboxes :=(3,8,15,1,10,6,5,11,14,13,4,2,7,0,9,12);
        variable S1 : t_sboxes :=(15,12,2,7,9,0,5,10,1,11,14,8,6,13,3,4);
        variable S2 : t_sboxes :=(8,6,7,9,3,12,10,15,13,1,14,4,0,11,5,2);
        variable S3 : t_sboxes :=(0,15,11,8,12,9,6,3,13,1,2,4,10,7,5,14);
        variable S4 : t_sboxes :=(1,15,8,3,12,0,11,6,2,5,4,10,9,14,7,13);
        variable S5 : t_sboxes :=(15,5,2,11,4,10,9,12,0,3,14,8,13,6,7,1);
        variable S6 : t_sboxes :=(7,2,12,5,8,4,6,11,14,9,1,15,13,3,10,0);
        variable S7 : t_sboxes :=(1,13,15,0,14,8,2,11,7,4,12,10,9,3,5,6);

        variable tmp1 : std_logic_vector(four_bits-1 downto 0);
        variable read_value_in : integer;
        variable read_value_out : integer;
    begin
        read_value_in := to_integer(unsigned(input_bits));
        case s_box_number is
            when 0 =>
                read_value_out := S0(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 1 =>
                read_value_out := S1(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 2 =>
                read_value_out := S2(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 3 =>
                read_value_out := S3(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 4 =>
                read_value_out := S4(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 5 =>
                read_value_out := S5(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 6 =>
                read_value_out := S6(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when 7 =>
                read_value_out := S7(read_value_in);
                tmp1 := std_logic_vector(to_unsigned(read_value_out, tmp1'length));
            when others =>
                tmp1 := (others => '0');
        end case;
        return tmp1;
    end function  app_s_box;

    ----RV  -------------------------------------------------------
    function RV (input_vector: in std_logic_vector)
    return std_logic_vector is
        variable reversed_result: std_logic_vector(input_vector'RANGE);
        alias reversed_alias: std_logic_vector(input_vector'REVERSE_RANGE) is input_vector;
    begin
        for index in reversed_alias'RANGE loop
            reversed_result(index) := reversed_alias(index);
        end loop;
        return reversed_result;
    end;

    ----IP-------------------------------------------------------
    function  app_IP(
        input_bits : in std_logic_vector(full_bits-1 downto 0)
    )
    return std_logic_vector is
        variable ip_table  : t_array := (
            0, 32, 64, 96, 1, 33, 65, 97, 2, 34, 66, 98, 3, 35, 67, 99,
            4, 36, 68, 100, 5, 37, 69, 101, 6, 38, 70, 102, 7, 39, 71, 103,
            8, 40, 72, 104, 9, 41, 73, 105, 10, 42, 74, 106, 11, 43, 75, 107,
            12, 44, 76, 108, 13, 45, 77, 109, 14, 46, 78, 110, 15, 47, 79, 111,
            16, 48, 80, 112, 17, 49, 81, 113, 18, 50, 82, 114, 19, 51, 83, 115,
            20, 52, 84, 116, 21, 53, 85, 117, 22, 54, 86, 118, 23, 55, 87, 119,
            24, 56, 88, 120, 25, 57, 89, 121, 26, 58, 90, 122, 27, 59, 91, 123,
            28, 60, 92, 124, 29, 61, 93, 125, 30, 62, 94, 126, 31, 63, 95, 127
            );
        variable tmp1 : std_logic_vector(full_bits-1 downto 0);
        variable compt : integer := 0;
        variable temp : integer;
    begin
        for compt in full_bits-1 downto 0 loop
            temp := ip_table(compt);
            tmp1(temp) := input_bits(compt);
        end loop;
        return tmp1;
    end function  app_IP;
    
    ----SPLITTING PROCEDURE--------------------------------------
    procedure  Splitting(
        L1 : in std_logic_vector(full_key_size-1 downto 0);
        variable var_quartet_1 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_2 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_3 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_4 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_5 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_6 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_7 : out std_logic_vector(div4_bits-1 downto 0);
        variable var_quartet_8 : out std_logic_vector(div4_bits-1 downto 0)
    )
    is
    begin
        var_quartet_8 := L1(full_key_size-1 downto full_key_size-div4_bits);
        var_quartet_7 := L1(full_key_size-div4_bits-1 downto full_key_size-2*div4_bits);
        var_quartet_6 := L1(full_key_size-2*div4_bits-1 downto full_key_size-3*div4_bits);
        var_quartet_5 := L1(full_key_size-3*div4_bits-1 downto full_key_size-4*div4_bits);
        var_quartet_4 := L1(full_key_size-4*div4_bits-1 downto full_key_size-5*div4_bits);
        var_quartet_3 := L1(full_key_size-5*div4_bits-1 downto full_key_size-6*div4_bits);
        var_quartet_2 := L1(full_key_size-6*div4_bits-1 downto full_key_size-7*div4_bits);
        var_quartet_1 := L1(full_key_size-7*div4_bits-1 downto full_key_size-8*div4_bits);
    end procedure  Splitting;
    
    ----MERGING FUNCTION-----------------------------------------
    function  Merging2(
        quartet_1 : in std_logic_vector(div4_bits-1 downto 0);
        quartet_2 : in std_logic_vector(div4_bits-1 downto 0);
        quartet_4 : in std_logic_vector(div4_bits-1 downto 0);
        quartet_3 : in std_logic_vector(div4_bits-1 downto 0)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(full_bits-1 downto 0);
    begin
        tmp1((4*div4_bits)-1 downto (3*div4_bits)) := quartet_1;
        tmp1((3*div4_bits)-1 downto (2*div4_bits)) := quartet_2;
        tmp1((2*div4_bits)-1 downto div4_bits) := quartet_3;
        tmp1(div4_bits-1 downto 0) := quartet_4;
        return tmp1;
    end function  Merging2;

begin

    sig_expanded_Key <= RV(sig_user_key) & '1' & PADDING;

    process(state)
        variable w : w_array := (others => (others => '0'));
        variable k : w_array := (others => (others => '0'));
        variable temp1 : std_logic_vector(div4_bits-1 downto 0);
        variable input_s : std_logic_vector (four_bits-1 downto 0);
        variable output_s : std_logic_vector (four_bits-1 downto 0);
        variable i : integer := 0;
        variable j : integer := 0;
        variable pre_keys : Ki_array;
        variable whichS : integer;
    begin
        case state is
        when IDLE =>
            --report "IDLE State";
            start_processing <= '1';

        when PREKEY_CALCULATION =>
        Splitting(L1=>sig_expanded_Key,var_quartet_1=>w(-1),var_quartet_2=>w(-2),var_quartet_3=>w(-3),
        var_quartet_4=>w(-4),var_quartet_5=>w(-5),var_quartet_6=>w(-6),var_quartet_7=>w(-7),
        var_quartet_8=>w(-8));
        prekey_calc_done <= '1';

        when KEY_EXPEND =>
        for i in 0 to 131 loop
            temp1 := w(i-8) xor w(i-5) xor w(i-3) xor w(i-1) xor theta xor RV(std_logic_vector(to_unsigned(i,32)));
            w(i) := std_logic_vector(rotate_right(unsigned(temp1), 11));
        end loop;
        key_expend_done <='1';

        when ASSEMBLING_KEY =>
        applying_key_sbox : for i in 0 to 32 loop
            whichS := (32 + 3 - i) mod 32;
            for j in 0 to 31 loop
                -- Extract individual bits from w
                input_s := w(0 + 4 * i)(31-j) & w(1 + 4 * i)(31-j) & w(2 + 4 * i)(31-j) & w(3 + 4 * i)(31-j);
                --report "The value of 'input_s' is " & integer'image(to_integer(unsigned(input_s)));
                -- Call S box function
                output_s := app_s_box(input_bits=>input_s,s_box_number=>whichS mod 8);
                for l in 0 to 3 loop
                    --k(full_bits-l*div4_bits-1-j) := output_s(3-l);
                    k(4 * i + l) := std_logic_vector(shift_right(unsigned(k(4 * i + l)), 1));
                    k(4 * i + l)(div4_bits-1) := output_s(l);
                end loop;
            end loop;
        end loop;
        key_assembled <='1';


        when MERGING =>
            merging_ki : for i in 0 to 32 loop
                pre_keys(i) := Merging2(quartet_1=>k(4*i),quartet_2=>k(4*i+1),quartet_3=>k(4*i+2),quartet_4=>k(4*i+3));
            end loop;
            merging_done <='1';
        
        when FLAG_IP =>
            sig_pre_keys <= pre_keys;
            flag_ip_done <= '1';

        when others =>
            report "seg fault";
        end case;
    end process;



-- State machine process
process(clk, go)
begin
    if rising_edge(clk) then
            case state is
                when IDLE =>
                    if start_processing = '1' and go = '1' then
                        state <= PREKEY_CALCULATION;
                    end if;

                when PREKEY_CALCULATION =>
                    if prekey_calc_done = '1' then
                        state <= KEY_EXPEND;
                    end if;

                when KEY_EXPEND =>
                    if key_expend_done = '1' then
                        state <= ASSEMBLING_KEY;
                    end if;

                when ASSEMBLING_KEY =>
                    if key_assembled = '1' then
                        state <= MERGING;
                    end if;

                when MERGING =>
                    if merging_done = '1' then
                        state <= FLAG_IP;
                    end if;

                when FLAG_IP =>
                    if flag_ip_done = '1' and go = '1' then
                        state <= FLAG_IP;
                    elsif go = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
    end if;
end process;

    Giving_keys : process(clk,sig_Ki_number,state)
        begin
        --report "sig_ready_busy=" & integer'image(to_integer(unsigned(sig_ready_busy)));
        if rising_edge(clk) then
            if flag_ip_done = '1' then
                sig_ready_busy <= "11";
                if sig_Ki_number<0 or sig_Ki_number>32 then
                    sig_ready_busy_key <="00";
                    sig_Ki <= "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
                else
                    sig_Ki <= sig_pre_keys(sig_Ki_number);
                    sig_ready_busy_key <="01";
                end if;
            else
                sig_ready_busy <= "01";
            end if;
        end if;
    end process;

    ready_busy <= sig_ready_busy;
    ready_busy_key <= sig_ready_busy_key;
    sig_user_key <= user_key;
    sig_Ki_number <= Ki_number;
    Ki <= sig_Ki;

end Behavioral;