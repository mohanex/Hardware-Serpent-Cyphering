----------------------------------------------------------------------------------
-- General state machine Testbench File
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity General_SM_tb is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32;
        constant full_key_size : integer :=256;
        constant four_bits : integer := 4
    );
end General_SM_tb;

architecture Behavioral of General_SM_tb is
    component General_State_machine is 
        Port ( 
            clk : in std_logic;
            go :  in std_logic;
            ready_busy : out std_logic_vector(0 to 1);
            plain_text : in std_logic_vector(0 to full_bits-1);
            ciphered_text : out std_logic_vector(0 to full_bits-1);
            user_key : in std_logic_vector(0 to full_bits-1)
        );
    end component;

    -- clock signals
    signal clk : std_logic := '0' ;
    constant clk_period : time := 20 ns;

    signal sig_go : std_logic;
    signal sig_ready_busy : std_logic_vector(0 to 1);
    signal sig_plain_text : std_logic_vector(0 to full_bits-1);
    signal sig_ciphered_text : std_logic_vector(0 to full_bits-1);
    signal sig_user_key : std_logic_vector(0 to full_bits-1);

begin

    GSM : component General_State_machine port map(
        clk => clk,
        go => sig_go,
        ready_busy => sig_ready_busy,
        plain_text => sig_plain_text,
        ciphered_text => sig_ciphered_text,
        user_key => sig_user_key
    );

    clk <= not clk after clk_period/2;

    stimuli : process
    begin    
        sig_user_key <="00001011110101111000100100011010011101110110000011100000101000110101101011111000101111011010111101000001001010111100101111010011";
        sig_plain_text <= "11101011001111001000110000011001011010111000100110110101000111010000101110010011101110010110110011010111101101100001001101111101";
        sig_go <= '1';
        
    wait for 120000ns;
    end process;
end Behavioral;
