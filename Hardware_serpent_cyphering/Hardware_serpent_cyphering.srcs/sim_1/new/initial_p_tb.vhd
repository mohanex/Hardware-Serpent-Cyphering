----------------------------------------------------------------------------------
-- TestBENCH of the initial permutation file
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity initial_p_tb is
--  Port ( );
end initial_p_tb;

architecture Behavioral of initial_p_tb is
component Initial_P
    port(
        clk : in std_logic;
        go :  in std_logic;
        ready_busy : out std_logic;
        plaintext_in : in std_logic_vector(127 downto 0);
        permutedtext_out : out std_logic_vector(127 downto 0)
    ); 
end component;
-- clock signals
signal clk : std_logic := '0' ;
constant clk_period : time := 20 ns; 

-- componenet signals
signal s_go : std_logic;
signal s_ready_busy : std_logic;
signal s_plaintext_in : std_logic_vector(127 downto 0);
signal s_permutedtext_out : std_logic_vector(127 downto 0);

begin
u1 : Initial_P port map (

    clk => clk,
    go => s_go,
    ready_busy => s_ready_busy,
    plaintext_in => s_plaintext_in,
    permutedtext_out => s_permutedtext_out

);

clk <= not clk after clk_period/2;

stimuli : process
begin
    s_go <= '0';
    s_plaintext_in <= (others => '0');
    
    wait for 20 ns;
    
    s_go <= '1';
    s_plaintext_in <= "01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101";

    wait for 1000 ns;
    
    s_go <= '0';
    wait;

end process;

end Behavioral;
