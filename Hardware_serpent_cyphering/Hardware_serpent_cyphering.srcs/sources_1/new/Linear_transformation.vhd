----------------------------------------------------------------------------------
-- Linear transformation
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Linear_transformation is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32;
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic;
        Bi_input : in std_logic_vector(0 to full_bits-1);
        Bi_output : in std_logic_vector(0 to full_bits-1)
    );
end Linear_transformation;

architecture Behavioral of Linear_transformation is
    ----signals--------------------------------------
    signal sig_Bi_input : std_logic_vector(0 to full_bits-1);
    signal sig_Bi_output : std_logic_vector(0 to full_bits-1);
    signal X0 : std_logic_vector(0 to div4_bits-1);
    signal X1 : std_logic_vector(0 to div4_bits-1);
    signal X2 : std_logic_vector(0 to div4_bits-1);
    signal X3 : std_logic_vector(0 to div4_bits-1);


    ----XORING FUNCTION--------------------------------------
    function Xoring(
        L1 : in std_logic_vector(0 to div4_bits-1);
        L2 : in std_logic_vector(0 to div4_bits-1);
        L3 : in std_logic_vector(0 to div4_bits-1)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to div4_bits-1);
        variable tmp2 : std_logic_vector(0 to div4_bits-1);
    begin
        for i in 0 to 32 loop
            tmp1(i) := L1(i) xor L2(i); 
        end loop;
        for i in 0 to 32 loop
            tmp2(i) := tmp1(i) xor L3(i);    --does these two run in the same time?
        end loop;
        return tmp2;
    end function Xoring;



    ----SHIFTING FUNCTION--------------------------------------
    function Shifting(
        L1 : in std_logic_vector(0 to div4_bits-1);
        shift_amount : in integer
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to full_bits-1);
    begin
        if shift_amount >= 0 and shift_amount <= 31 then
            tmp1 <= L1(shift_amount to full_bits-1) & (others => '0');
        else 
            tmp1 <= (others => '0');
        end if;
        return tmp1;
    end function Shifting;



    ----ROTATING FUCNTION--------------------------------------
    function Rotating(
        L1 : in std_logic_vector(0 to div4_bits-1);
        rotating_amount : in integer
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to div4_bits-1);
        variable tmp2 : std_logic_vector(0 to rotating_amount-1);
    begin
        if rotating_amount >= 0 and rotating_amount <= 31 then
            tmp2 <= L1(0 to rotating_amount-1);
            tmp1(0 to rotating_amount-1) <= L1(rotating_amount to full_bits-1);
            tmp1(rotating_amount to full_bits-1) <= tmp2;
        else 
            tmp1 <= (others => '0');
        end if;
        return tmp1;
    end function Rotating;

    
    ----SPLITTING PROCEDURE--------------------------------------
    procedure  Splitting(
        L1 : in std_logic_vector(0 to full_bits-1);
        quartet1 : out std_logic_vector(0 to div4_bits-1);
        quartet2 : out std_logic_vector(0 to div4_bits-1);
        quartet3 : out std_logic_vector(0 to div4_bits-1);
        quartet4 : out std_logic_vector(0 to div4_bits-1)
    )
    is
    begin
        quartet1 := L1(0 to div4_bits-1);                  -- 00 -> 31
        quartet2 := L1(div4_bits to (2*div4_bits)-1);      -- 32 -> 63
        quartet3 := L1((2*div4_bits) to (3*div4_bits)-1);  -- 64 -> 95
        quartet4 := L1((3*div4_bits) to (4*div4_bits)-1);  -- 95 -> 127
    end procedure  Splitting;

begin

    Linear : process(clk,go) 
    begin

    end process Linear;

end Behavioral;
