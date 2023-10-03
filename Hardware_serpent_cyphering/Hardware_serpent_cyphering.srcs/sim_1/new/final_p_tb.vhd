----------------------------------------------------------------------------------
-- TestBENCH of the final permutation file
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity final_p_tb is
--  Port ( );
end final_p_tb;

architecture Behavioral of final_p_tb is
component final_P
    port(
        clk : in std_logic;
        go :  in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        plaintext_in : in std_logic_vector(0 to 127);
        permutedtext_out : out std_logic_vector(0 to 127)
    ); 
end component;
-- clock signals
signal clk : std_logic := '0' ;
constant clk_period : time := 20 ns; 

-- componenet signals
signal s_go : std_logic;
signal s_ready_busy : std_logic_vector(0 to 1);
signal s_plaintext_in : std_logic_vector(0 to 127);
signal s_permutedtext_out : std_logic_vector(0 to 127);

begin
u1 : final_P port map (

    clk => clk,
    go => s_go,
    ready_busy => s_ready_busy,
    plaintext_in => s_plaintext_in,
    permutedtext_out => s_permutedtext_out

);

clk <= not clk after clk_period/2;

stimuli : process
begin
    --s_go <= '0';
    --s_plaintext_in <= (others => '0');
    
    --wait for 300 ns;
    --general test
    s_plaintext_in <= "10001100011001011101101011011110101000010110001011110011001011110101011100110101001011011101010001101010110100111000100011110010";
    s_go <= '1';

    wait for 300 ns;
    
    s_go <= '0';
    
    wait for 100 ns;
    s_go <= '1';
    s_plaintext_in <= "00010000001001010001011000101100101011100001010110110011110001100000001011110111101101110000111001010110101110001001101110100101";

    wait for 300 ns;
    s_go <= '0';
    wait for 100 ns;

    s_go <= '1';
    s_plaintext_in <= "00000110110010010011011001111000111010010100101011100100111111010110111010111010010111110110111111011010000010001000011010111100";

    wait for 300 ns;
    s_go <= '0';
    wait for 100 ns;
    
    s_go <= '1';
    s_plaintext_in <= "01101100000001000111100011000011111001010000111100011011000101000100010001001110100101111000001110001000110000000100010000010111";

    wait;

end process;

end Behavioral;
