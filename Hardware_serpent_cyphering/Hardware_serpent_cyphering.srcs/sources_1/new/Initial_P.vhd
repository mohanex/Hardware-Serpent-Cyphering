----------------------------------------------------------------------------------
-- Initial permutation file
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Initial_P is
    port(
    clock : in std_logic;
    go :  in std_logic;
    ready_busy : out std_logic;
    plaintext_in : in std_logic_vector(127 downto 0);
    permutedtext_out : out std_logic_vector(127 downto 0)
    );
    
end Initial_P;

architecture Behavioral of Initial_P is

type t_array is array (0 to 127) of integer;
signal ip_table  : t_array := (
    0, 32, 64, 96, 1, 33, 65, 97, 2, 34, 66, 98, 3, 35, 67, 99,
    4, 36, 68, 100, 5, 37, 69, 101, 6, 38, 70, 102, 7, 39, 71, 103,
    8, 40, 72, 104, 9, 41, 73, 105, 10, 42, 74, 106, 11, 43, 75, 107,
    12, 44, 76, 108, 13, 45, 77, 109, 14, 46, 78, 110, 15, 47, 79, 111,
    16, 48, 80, 112, 17, 49, 81, 113, 18, 50, 82, 114, 19, 51, 83, 115,
    20, 52, 84, 116, 21, 53, 85, 117, 22, 54, 86, 118, 23, 55, 87, 119,
    24, 56, 88, 120, 25, 57, 89, 121, 26, 58, 90, 122, 27, 59, 91, 123,
    28, 60, 92, 124, 29, 61, 93, 125, 30, 62, 94, 126, 31, 63, 95, 127
    );
signal s_plaintext_in : std_logic_vector(127 downto 0);
signal s_permutedtext_out : std_logic_vector(127 downto 0);
signal temp : integer;
begin
    
    ready_busy <= '0';
    PERMUTATION : process(clock,go)
        variable compt : integer := 127;
    begin
        if(go = '1') then
            s_plaintext_in <= plaintext_in;
            for compt in 127 to 0 loop
                s_permutedtext_out(compt) <= s_plaintext_in(ip_table(compt));
            end loop;
        end if;
    end process PERMUTATION;
    

end Behavioral;
