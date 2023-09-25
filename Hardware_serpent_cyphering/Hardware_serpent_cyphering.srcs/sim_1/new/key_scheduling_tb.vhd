----------------------------------------------------------------------------------
-- Key scheduling Testbench
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_scheduling_tb is

end key_scheduling_tb;

architecture Behavioral of key_scheduling_tb is
component key_scheduling 
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
        Ki : out std_logic_vector(0 to full_bits-1)
    );
end component;

--- constants 
constant full_bits : integer :=128;
constant div4_bits : integer :=32;
constant full_key_size : integer :=256;
constant theta : std_logic_vector := X"9e3779b9";
constant four_bits : integer := 4;

-- clock signals
signal clk : std_logic := '0';
constant clk_period : time := 20 ns; 

-- componenet signals
signal sig_go : std_logic;
signal sig_Ki_number : integer; --key number 
signal sig_user_key : std_logic_vector(0 to full_bits-1);
signal sig_ready_busy : std_logic_vector(0 to 1);
signal sig_Ki : std_logic_vector(0 to full_bits-1);

begin

key_scheduler : key_scheduling port map(
    clk => clk,
    go => sig_go,
    Ki_number => sig_Ki_number,
    user_key => sig_user_key,
    ready_busy => sig_ready_busy,
    Ki => sig_Ki 
);


clk <= not clk after clk_period/2;

stimuli : process
begin
    sig_go <= '0';

    wait for 30 ns;

    sig_user_key <= "11110011110011101000101101010010110111000110010011011111110111011000010010101010100100100110101111010110101010010110111110011111";
    sig_go <= '1';
    wait for 100 ns;

    sig_Ki_number <=3;
    wait for 30 ns;
    
    sig_Ki_number <=31;
    wait for 30 ns;
    
    sig_Ki_number <=29;
    wait for 30 ns;

end process;

end Behavioral;
