----------------------------------------------------------------------------------
-- Testbench for the linear_transformation module
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Linear_transfo_tb is
end Linear_transfo_tb;

architecture Behavioral of Linear_transfo_tb is

component Linear_transformation is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic;
        Bi_input : in std_logic_vector(0 to full_bits-1);
        Bi_output : out std_logic_vector(0 to full_bits-1)
    );
end component;

-- constants
constant const_full_bits : integer :=128;
constant const_div4_bits : integer :=32;

-- clock signals
signal clk : std_logic := '0' ;
constant clk_period : time := 20 ns; 

-- componenet signals
signal s_Bi_input : std_logic_vector(0 to const_full_bits-1);
signal s_Bi_output : std_logic_vector(0 to const_full_bits-1);
signal s_go :  std_logic;
signal s_ready_busy : std_logic;

begin
    u1 : Linear_transformation 
    generic map(
        full_bits => const_full_bits,
        div4_bits => const_div4_bits
    )
    port map(
        Bi_input => s_Bi_input,
        Bi_output => s_Bi_output,
        clk => clk,
        go => s_go,
        ready_busy => s_ready_busy
    );
    clk <= not clk after clk_period/2;

    stimuli : process
    begin
        s_go <= '0';
        s_Bi_input <= (others => '0');
        
        wait for 30 ns;

        s_Bi_input <= "01100110011001100110011001100110010101010101010101010101010101011010101010101010101010101010101001000100010001000100010001000100"; -- should give us 5
        --s_Bi_input <= ""; -- should give us 5
       -- s_Bi_input <= "10101010101010101010101010101010"; -- should give us 5
        --s_Bi_input <= "01000100010001000100010001000100"; -- should give us 5
        s_go <= '1';
        
        wait for 3000 ns;
    end process;
    
end Behavioral;