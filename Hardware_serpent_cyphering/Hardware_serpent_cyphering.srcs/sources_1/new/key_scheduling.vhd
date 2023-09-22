----------------------------------------------------------------------------------
-- Key scheduling process
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_scheduling is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32;
        constant full_key_size : integer :=256;
        constant theta : std_logic_vector := X"9e3779b9";
        constant four_bits : integer := 4
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        Ki_number : in integer; --key number 
        user_key : in std_logic_vector(0 to full_bits-1);
        ready_busy : inout std_logic_vector(0 to 1);
        Ki : out std_logic_vector(0 to div4_bits-1)
    );
end key_scheduling;

architecture Behavioral of key_scheduling is

    ----TYPES--------------------------------------------------
    type w_array is array (-8 to 131) of STD_LOGIC_VECTOR(0 to div4_bits-1);
    type Ki_array is array (0 to 32) of STD_LOGIC_VECTOR(0 to div4_bits-1);
    type t_sboxes is array (0 to 15) of integer; --S_BOX
    type t_array is array (0 to 127) of integer; --IP

    ----SIGNALS--------------------------------------------------
    signal sig_Ki : std_logic_vector(0 to div4_bits-1);
    signal sig_Ki_number : integer; --key number 
    signal sig_user_key : std_logic_vector(0 to full_bits-1);
    signal sig_pre_keys : Ki_array;
    signal sig_ready_busy : std_logic_vector(0 to 1);
    ----S-boxes--------------------------------------------------
    function  app_s_box(
        input_bits : in std_logic_vector(0 to four_bits-1);
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

        variable tmp1 : std_logic_vector(0 to four_bits-1);
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


    ----IP-------------------------------------------------------
    function  app_IP(
        input_bits : in std_logic_vector(0 to full_bits-1)
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
        variable tmp1 : std_logic_vector(0 to full_bits-1);
        variable compt : integer := 0;
        variable temp : integer;
    begin
        for compt in 0 to full_bits-1 loop
            temp := ip_table(compt);
            tmp1(temp) := input_bits(compt);
        end loop;
        return tmp1;
    end function  app_IP;
    
    ----SPLITTING PROCEDURE--------------------------------------
    procedure  Splitting(
        L1 : in std_logic_vector(0 to full_key_size-1);
        variable var_quartet_1 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_2 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_3 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_4 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_5 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_6 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_7 : out std_logic_vector(0 to div4_bits-1);
        variable var_quartet_8 : out std_logic_vector(0 to div4_bits-1)
    )
    is
    begin
        var_quartet_1 := L1(0 to div4_bits-1);                  -- 00 -> 31
        var_quartet_2 := L1((div4_bits) to (2*div4_bits)-1);    -- 32 -> 63
        var_quartet_3 := L1((2*div4_bits) to (3*div4_bits)-1);  -- 64 -> 95
        var_quartet_4 := L1((3*div4_bits) to (4*div4_bits)-1);  -- 95 -> 127
        var_quartet_5 := L1((4*div4_bits) to (5*div4_bits)-1);  -- 128 -> 159
        var_quartet_6 := L1((5*div4_bits) to (6*div4_bits)-1);  -- 160 -> 191
        var_quartet_7 := L1((6*div4_bits) to (7*div4_bits)-1);  -- 192 -> 223
        var_quartet_8 := L1((7*div4_bits) to (8*div4_bits)-1);  -- 224 -> 255
    end procedure  Splitting;
    
    ----MERGING FUNCTION-----------------------------------------
    function  Merging(
        quartet_1 : in std_logic_vector(0 to div4_bits-1);
        quartet_2 : in std_logic_vector(0 to div4_bits-1);
        quartet_4 : in std_logic_vector(0 to div4_bits-1);
        quartet_3 : in std_logic_vector(0 to div4_bits-1)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to full_bits-1);
    begin
        tmp1(0 to div4_bits-1) := quartet_1;
        tmp1(div4_bits to (2*div4_bits)-1) := quartet_2;
        tmp1((2*div4_bits) to (3*div4_bits)-1) := quartet_3;
        tmp1((3*div4_bits) to (4*div4_bits)-1) := quartet_4;
        return tmp1;
    end function  Merging;
    
    ----ROTATING FUNCTION--------------------------------------
    function Rotating(
        L1 : in std_logic_vector(0 to div4_bits-1);
        rotating_amount : in integer
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to div4_bits-1);
        variable tmp2 : std_logic_vector(0 to rotating_amount-1);
    begin
        if rotating_amount >= 0 and rotating_amount <= 31 then
            tmp2 := L1(0 to rotating_amount-1);
            tmp1(0 to ((div4_bits-rotating_amount)-1) ) := L1(rotating_amount to div4_bits-1);
            tmp1((div4_bits-rotating_amount) to div4_bits-1) := tmp2;
        else 
            tmp1 := (others => '0');
        end if;
        return tmp1;
    end function Rotating;

begin
    Scheduling : process(clk,go)
    variable key_to_256 : std_logic_vector(0 to full_key_size-1);
    variable padding_zeros : std_logic_vector(0 to 126);
    variable temp_calc : std_logic_vector (0 to div4_bits-1);
    variable input_s : std_logic_vector (0 to four_bits-1);
    variable output_s : std_logic_vector (0 to four_bits-1);

    variable w : w_array;
    variable k : w_array;
    variable pre_keys : Ki_array;

    variable whichS : integer;
    variable i : integer := 0;
    variable padding_number : integer := 0;
        begin
            if rising_edge(clk) then
                if(go='1') then
                    ready_busy <= "01";
                    -----------Key padding to 256 for one time-----------
                    if(padding_number = 0) then
                        padding_zeros := (others => '0');
                        key_to_256(full_key_size-1) := '1';
                        key_to_256(127 to 254) := sig_user_key;
                        key_to_256(0 to 126) := padding_zeros;
                        padding_number := 1;
                    end if;
                    
                    -----------Finish Padding----------------------------

                    Splitting(L1=>key_to_256,var_quartet_1=>w(-1),var_quartet_2=>w(-2),var_quartet_3=>w(-3),
                    var_quartet_4=>w(-4),var_quartet_5=>w(-5),var_quartet_6=>w(-6),var_quartet_7=>w(-7),
                    var_quartet_8=>w(-8));
                    prekey : for i in 0 to 131 loop
                        temp_calc := w(i-8) xor w(i-5) xor w(i-3) xor w(i-1) xor theta xor 
                        std_logic_vector(to_unsigned(i,32));
                        w(i) := Rotating(L1=>temp_calc,rotating_amount=>11);
                    end loop;
                    
                    applying_key_sbox : for i in 0 to 32 loop
                        whichS := (32 + 3 - i) mod 32;
                        for j in 0 to 31 loop
                            -- Extract individual bits from w
                            input_s := w(0 + 4 * i)(j) & w(1 + 4 * i)(j) & w(2 + 4 * i)(j) & w(3 + 4 * i)(j);
                            -- Call the S function here (you need to define it separately)
                            output_s := app_s_box(input_bits=>input_s,s_box_number=>whichS);
                            for l in 0 to 3 loop
                                k(4 * i + l) := k(4 * i + l) & output_s(l);
                            end loop;
                        end loop;
                    end loop;
                    
                    assembling_key : for i in 0 to 32 loop
                        pre_keys(i) := Merging(quartet_1=>k(4*i),quartet_2=>k(4*i+1),quartet_3=>k(4*i+2),quartet_4=>k(4*i+3));
                    end loop;

                    applying_ip : for i in 0 to 32 loop
                        pre_keys(i) := app_IP(input_bits=>pre_keys(i));
                        sig_pre_keys(i) <= pre_keys(i);
                    end loop;
                    
                    ready_busy <= "11";

                elsif (go = '0') then
                    ready_busy <= "10";
                    padding_number := 0;
                end if;
            end if;
    end process Scheduling;

    Giving_keys : process(clk,sig_Ki_number,ready_busy)
        begin
        if rising_edge(clk) and ready_busy = "11" then
            sig_Ki <= sig_pre_keys(sig_Ki_number);
        end if;
    end process;

    sig_user_key <= user_key;
    sig_Ki_number <= Ki_number;
    Ki <= sig_Ki;
end Behavioral;
