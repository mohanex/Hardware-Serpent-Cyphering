----------------------------------------------------------------------------------
-- S-boxes
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity S_boxes is
    Port ( 
        clk : in std_logic;
        s_box_in : in std_logic_vector(0 to 3);
        s_box_out : in std_logic_vector(0 to 3);
        go :  in std_logic;
        ready_busy : out std_logic
    );
end S_boxes;

architecture Behavioral of S_boxes is

begin


end Behavioral;
