----------------------------------------------------------------------------------
-- Linear transformation
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Linear_transformation is
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic;
        Bi_input : in std_logic_vector(0 to 127);
        Bi_output : in std_logic_vector(0 to 127)
    );
end Linear_transformation;

architecture Behavioral of Linear_transformation is

    signal Bi_input : std_logic_vector(0 to 127);
    signal Bi_output : std_logic_vector(0 to 127);

begin

    Linear : process(clk,go) 
    begin

    end process Linear;

end Behavioral;
