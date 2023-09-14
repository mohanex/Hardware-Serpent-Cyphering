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
        constant div4_bits : integer :=32
    );
    Port ( 
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic;
        Bi_input : in std_logic_vector(0 to full_bits-1);
        Bi_output : out std_logic_vector(0 to full_bits-1)
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
    signal tmp_xoring : std_logic_vector(0 to div4_bits-1);


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
        for i in 0 to 31 loop
            tmp1(i) := L1(i) xor L2(i); 
        end loop;
        for i in 0 to 31 loop
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
        variable tmp1 : std_logic_vector(0 to div4_bits-1);
        constant ZERO : std_logic_vector(0 to shift_amount-1) := (others => '0');
    begin
        if shift_amount >= 0 and shift_amount <= 31 then
            tmp1(0 to ((div4_bits-shift_amount)-1) ) := L1(shift_amount to div4_bits-1);
            tmp1((div4_bits-shift_amount) to div4_bits-1) := ZERO;
        else  
            tmp1 := (others => '1');
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
            tmp2 := L1(0 to rotating_amount-1);
            tmp1(0 to ((div4_bits-rotating_amount)-1) ) := L1(rotating_amount to div4_bits-1);
            tmp1((div4_bits-rotating_amount) to div4_bits-1) := tmp2;
        else 
            tmp1 := (others => '0');
        end if;
        return tmp1;
    end function Rotating;

    
    ----SPLITTING PROCEDURE--------------------------------------
    procedure  Splitting(
        L1 : in std_logic_vector(0 to full_bits-1);
        signal quartet1 : out std_logic_vector(0 to div4_bits-1);
        signal quartet2 : out std_logic_vector(0 to div4_bits-1);
        signal quartet3 : out std_logic_vector(0 to div4_bits-1);
        signal quartet4 : out std_logic_vector(0 to div4_bits-1)
    )
    is
    begin
        quartet1 <= L1(0 to div4_bits-1);                  -- 00 -> 31
        quartet2 <= L1(div4_bits to (2*div4_bits)-1);      -- 32 -> 63
        quartet3 <= L1((2*div4_bits) to (3*div4_bits)-1);  -- 64 -> 95
        quartet4 <= L1((3*div4_bits) to (4*div4_bits)-1);  -- 95 -> 127
    end procedure  Splitting;
    
    ----MERGING FUCNTION-----------------------------------------
    function  Merging(
        quartet1 : in std_logic_vector(0 to div4_bits-1);
        quartet2 : in std_logic_vector(0 to div4_bits-1);
        quartet3 : in std_logic_vector(0 to div4_bits-1);
        quartet4 : in std_logic_vector(0 to div4_bits-1)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to full_bits-1);
    begin
        tmp1(0 to div4_bits-1) := quartet1;
        tmp1(div4_bits to (2*div4_bits)-1) := quartet2;
        tmp1((2*div4_bits) to (3*div4_bits)-1) := quartet3;
        tmp1((3*div4_bits) to (4*div4_bits)-1) := quartet4;
        return tmp1;
    end function  Merging;

begin

    Linear : process(clk,go) 
    begin
        if rising_edge(clk) then
            if(go = '1') then
                ready_busy <= '1';
                -------Splitting to 4 quartets--------------
                Splitting(L1=>Bi_input,quartet1=>X0,quartet2=>X1,quartet3=>X2,quartet4=>X3);
                ------X0 := X0 <<< 13-----------
                --X0 <= Rotating(L1=>X0,rotating_amount=>13);
                ------X2 := X2 <<< 3 --------------
                --X2 <= Rotating(L1=>X2,rotating_amount=>3);
                ------X1 := X1 ? X0 ? X2--------
                --X1 <= Xoring(L1=>X1,L2=>X0,L3=>X2);
                ------X0 << 3---------------
                X0 <= Shifting(L1=>X0,shift_amount=>3);
                ------Assemble all 4 quartets-----------
    
                sig_Bi_output <= Merging(quartet1=>X3,quartet2=>X2,quartet3=>X1,quartet4=>X0);
            elsif (go = '0') then
                ready_busy <= '0';
                sig_Bi_output <= (others => '1');
            end if;
        end if;
    end process Linear;
    
    sig_Bi_input <= Bi_input;
    Bi_output <= sig_Bi_output;
    
end Behavioral;