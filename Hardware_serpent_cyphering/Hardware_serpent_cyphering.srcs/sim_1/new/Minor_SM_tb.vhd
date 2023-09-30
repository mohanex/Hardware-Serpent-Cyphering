----------------------------------------------------------------------------------
-- Testbench of minor state machine
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Minor_SM_tb is
        generic(
           constant full_bits : integer :=128;
           constant div4_bits : integer :=32;
           constant full_key_size : integer :=256;
           constant four_bits : integer := 4
        );
end Minor_SM_tb;

architecture Behavioral of Minor_SM_tb is
    component Minor_state_machine is
        Port ( 
           clk : in std_logic;
           go :  in std_logic;
           ready_busy : out std_logic_vector(0 to 1);
           text_to_compute : in std_logic_vector(0 to full_bits-1);
           computed_text : out std_logic_vector(0 to full_bits-1);
           user_key_to_calculate : in std_logic_vector(0 to full_bits-1)
        );
     end component;

    -- clock signals
    signal clk : std_logic := '0' ;
    constant clk_period : time := 20 ns; 

    signal sig_go : std_logic;
    signal sig_ready_busy : std_logic_vector(0 to 1);
    signal sig_text_to_compute : std_logic_vector(0 to full_bits-1);
    signal sig_computed_text : std_logic_vector(0 to full_bits-1);
    signal sig_user_key_to_calculate : std_logic_vector(0 to full_bits-1);
    
begin

    MSM : component Minor_state_machine port map(
        clk => clk,
        go => sig_go,
        ready_busy => sig_ready_busy,
        text_to_compute => sig_text_to_compute,
        computed_text => sig_computed_text,
        user_key_to_calculate => sig_user_key_to_calculate
    );

    clk <= not clk after clk_period/2;

    stimuli : process
    begin    
        sig_user_key_to_calculate <="00001011110101111000100100011010011101110110000011100000101000110101101011111000101111011010111101000001001010111100101111010011";
        sig_text_to_compute <= "11101011001111001000110000011001011010111000100110110101000111010000101110010011101110010110110011010111101101100001001101111101";
        sig_go <= '1';
        
        wait for 100ms;
    end process;
end Behavioral;
