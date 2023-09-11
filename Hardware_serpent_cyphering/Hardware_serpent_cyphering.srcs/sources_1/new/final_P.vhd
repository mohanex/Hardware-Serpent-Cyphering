----------------------------------------------------------------------------------
-- Final permutation file
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Final_P is
    port(
    clk : in std_logic;
    go :  in std_logic;
    ready_busy : out std_logic;
    plaintext_in : in std_logic_vector(0 to 127);
    permutedtext_out : out std_logic_vector(0 to 127)
    ); 
end Final_P;

architecture Behavioral of Final_P is

type t_array is array (0 to 127) of integer;
signal if_table  : t_array := (
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60,
    64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124,
    1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61,
    65, 69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, 117, 121, 125,
    2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62,
    66, 70, 74, 78, 82, 86, 90, 94, 98, 102, 106, 110, 114, 118, 122, 126,
    3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63,
    67, 71, 75, 79, 83, 87, 91, 95, 99, 103, 107, 111, 115, 119, 123, 127
    );
signal s_plaintext_in : std_logic_vector(0 to 127);
signal s_permutedtext_out : std_logic_vector(0 to 127);
signal temp2 : integer;

begin
    
    PERMUTATION : process(clk,go)
        variable compt : integer := 0;
        variable temp : integer;
    begin
    
        if rising_edge(clk) then
            if(go = '1') then
                ready_busy <= '1';
                for compt in 0 to 127 loop
                    --s_permutedtext_out(compt) <= s_plaintext_in(if_table(compt));
                    temp := if_table(compt);
                    temp2 <= temp;
                    s_permutedtext_out(temp) <= s_plaintext_in(compt);
                    --s_permutedtext_out <= compt;
                end loop;
                --permutedtext_out <= s_permutedtext_out;
            elsif (go = '0') then
                ready_busy <= '0';
                s_permutedtext_out <= (others => '1');
            end if;
        end if;
        
    end process PERMUTATION;
    permutedtext_out <= s_permutedtext_out;
    s_plaintext_in <= plaintext_in;

end Behavioral;