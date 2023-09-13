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

    signal sig_Bi_input : std_logic_vector(0 to 127);
    signal sig_Bi_output : std_logic_vector(0 to 127);
    signal X0 : std_logic_vector(0 to 31);
    signal X1 : std_logic_vector(0 to 31);
    signal X2 : std_logic_vector(0 to 31);
    signal X3 : std_logic_vector(0 to 31);

    function Xoring(
        L1 : std_logic_vector(0 to 31),
        L2 : std_logic_vector(0 to 31),
        L3 : std_logic_vector(0 to 31)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to 31);
        variable tmp2 : std_logic_vector(0 to 31);
    begin
        for i in 0 to 32 loop
            tmp1(i) := L1(i) xor L2(i);
        end loop;
        for i in 0 to 32 loop
            tmp2(i) := tmp1(i) xor L3(i);    --does these two run in the same time?
        end loop;
        return tmp2;
    end function Xoring;

begin

    Linear : process(clk,go) 
    begin

    end process Linear;

end Behavioral;
