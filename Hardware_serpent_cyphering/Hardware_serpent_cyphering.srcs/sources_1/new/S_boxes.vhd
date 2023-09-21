----------------------------------------------------------------------------------
-- S-boxes
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity S_boxes is
    Port ( 
        clk : in std_logic;
        s_box_in : in std_logic_vector(0 to 3);
        s_box_out : out std_logic_vector(0 to 3);
        go :  in std_logic;
        ready_busy : out std_logic
        --mode : in std_logic;   -----if 1 then will take sboxe_num as sbox number else itll start on 0 finish at 7 and reiterate
        --sboxe_num : in integer 
    );
end S_boxes;

architecture Behavioral of S_boxes is

    type t_sboxes is array (0 to 15) of integer;
    signal S0 : t_sboxes :=(3,8,15,1,10,6,5,11,14,13,4,2,7,0,9,12);
    signal S1 : t_sboxes :=(15,12,2,7,9,0,5,10,1,11,14,8,6,13,3,4);
    signal S2 : t_sboxes :=(8,6,7,9,3,12,10,15,13,1,14,4,0,11,5,2);
    signal S3 : t_sboxes :=(0,15,11,8,12,9,6,3,13,1,2,4,10,7,5,14);
    signal S4 : t_sboxes :=(1,15,8,3,12,0,11,6,2,5,4,10,9,14,7,13);
    signal S5 : t_sboxes :=(15,5,2,11,4,10,9,12,0,3,14,8,13,6,7,1);
    signal S6 : t_sboxes :=(7,2,12,5,8,4,6,11,14,9,1,15,13,3,10,0);
    signal S7 : t_sboxes :=(1,13,15,0,14,8,2,11,7,4,12,10,9,3,5,6);

    signal signal_s_box_in : std_logic_vector(0 to 3);
    signal signal_s_box_out : std_logic_vector(0 to 3);
    --signal signal_mode : in std_logic;
    --signal signal_sboxe_num : in integer;

begin

    subsitution : process(go,clk)
        variable sboxes_compt : integer := 0;
        variable read_value_in : integer;
        variable read_value_out : integer;
        variable converted_read_value_out : std_logic_vector(0 to 3);
    begin

        if rising_edge(clk) then
            if(go = '1') then
                ready_busy <= '1';
                read_value_in := to_integer(unsigned(signal_s_box_in));
                case sboxes_compt is
                    when 0 =>
                        read_value_out := S0(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 1 =>
                        read_value_out := S1(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 2 =>
                        read_value_out := S2(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 3 =>
                        read_value_out := S3(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 4 =>
                        read_value_out := S4(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 5 =>
                        read_value_out := S5(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 6 =>
                        read_value_out := S6(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := sboxes_compt+1;
                    when 7 =>
                        read_value_out := S7(read_value_in);
                        converted_read_value_out := std_logic_vector(to_unsigned(read_value_out, converted_read_value_out'length));
                        sboxes_compt := 0;
                    when others =>
                        ready_busy <= '0';
                end case;
                signal_s_box_out <= converted_read_value_out;
            elsif (go = '0') then
                ready_busy <= '0';
            end if;
        end if;

    end process subsitution;
    s_box_out <= signal_s_box_out;
    signal_s_box_in <= s_box_in;
end Behavioral;