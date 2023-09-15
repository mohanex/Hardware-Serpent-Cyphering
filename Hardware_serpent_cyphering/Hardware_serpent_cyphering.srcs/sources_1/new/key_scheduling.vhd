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
        constant theta : std_logic_vector := X"9e3779b9"
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic;
        user_key : in std_logic_vector(0 to 4*full_bits-1);
        Ki : out std_logic_vector(0 to div4_bits-1)
    );
end key_scheduling;

architecture Behavioral of key_scheduling is

begin


end Behavioral;
