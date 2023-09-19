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
        Ki_number : in std_logic; --key number 
        user_key : in std_logic_vector(0 to full_bits-1);
        ready_busy : out std_logic;
        Ki : out std_logic_vector(0 to div4_bits-1)
    );
end key_scheduling;

architecture Behavioral of key_scheduling is

    ----SIGNALS--------------------------------------------------
    type w_array is array (-8 to 131) of STD_LOGIC_VECTOR(31 downto 0);
    signal w : w_array;
    
    
    ----SPLITTING PROCEDURE--------------------------------------
    procedure  Splitting(
        L1 : in std_logic_vector(0 to full_bits-1);
        variable quartet_1 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_2 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_3 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_4 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_5 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_6 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_7 : out std_logic_vector(0 to div4_bits-1);
        variable quartet_8 : out std_logic_vector(0 to div4_bits-1)
    )
    is
    begin
        quartet_1 := L1(0 to div4_bits-1);                  -- 00 -> 31
        quartet_2 := L1((div4_bits) to (2*div4_bits)-1);    -- 32 -> 63
        quartet_3 := L1((2*div4_bits) to (3*div4_bits)-1);  -- 64 -> 95
        quartet_4 := L1((3*div4_bits) to (4*div4_bits)-1);  -- 95 -> 127
        quartet_5 := L1((4*div4_bits) to (5*div4_bits)-1);  -- 128 -> 159
        quartet_6 := L1((5*div4_bits) to (6*div4_bits)-1);  -- 160 -> 191
        quartet_7 := L1((6*div4_bits) to (7*div4_bits)-1);  -- 192 -> 223
        quartet_8 := L1((7*div4_bits) to (8*div4_bits)-1);  -- 224 -> 255
    end procedure  Splitting;
    
    ----MERGING FUCNTION-----------------------------------------
    function  Merging(
        quartet_1 : in std_logic_vector(0 to div4_bits-1);
        quartet_2 : in std_logic_vector(0 to div4_bits-1);
        quartet_3 : in std_logic_vector(0 to div4_bits-1);
        quartet_4 : in std_logic_vector(0 to div4_bits-1);
        quartet_5 : in std_logic_vector(0 to div4_bits-1);
        quartet_6 : in std_logic_vector(0 to div4_bits-1);
        quartet_7 : in std_logic_vector(0 to div4_bits-1);
        quartet_8 : in std_logic_vector(0 to div4_bits-1)
    )
    return std_logic_vector is
        variable tmp1 : std_logic_vector(0 to full_bits-1);
    begin
        tmp1(0 to div4_bits-1) := quartet_1;
        tmp1(div4_bits to (2*div4_bits)-1) := quartet_2;
        tmp1((2*div4_bits) to (3*div4_bits)-1) := quartet_3;
        tmp1((3*div4_bits) to (4*div4_bits)-1) := quartet_4;
        tmp1((4*div4_bits) to (5*div4_bits)-1) := quartet_5;
        tmp1((5*div4_bits) to (6*div4_bits)-1) := quartet_6;
        tmp1((6*div4_bits) to (7*div4_bits)-1) := quartet_7;
        tmp1((7*div4_bits) to (8*div4_bits)-1) := quartet_8;
        return tmp1;
    end function  Merging;
    
        ----ROTATING FUNCTION--------------------------------------
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
begin

    Scheduling : process(go)
    variable i : integer := -8;
        begin
            if(go='1') then
                ready_busy <= '1';
                for i := 0 to 131 loop
                
                end loop;
            elsif (go = '0') then
                ready_busy <= '0';
            end if;
    end process Scheduling;

end Behavioral;
