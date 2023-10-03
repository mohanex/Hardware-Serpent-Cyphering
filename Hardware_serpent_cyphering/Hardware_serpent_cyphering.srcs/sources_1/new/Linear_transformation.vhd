----------------------------------------------------------------------------------
-- Linear transformation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Linear_transformation is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32
    );
    Port ( 
        Bi_input : in std_logic_vector(full_bits-1 downto 0);
        Bi_output : out std_logic_vector(full_bits-1 downto 0)
    );
end Linear_transformation;

architecture Behavioral of Linear_transformation is
begin

    Linear : process(Bi_input) 
        variable X0 : std_logic_vector(div4_bits-1 downto 0) := (others => '0');
        variable X1 : std_logic_vector(div4_bits-1 downto 0) := (others => '0');
        variable X2 : std_logic_vector(div4_bits-1 downto 0) := (others => '0');
        variable X3 : std_logic_vector(div4_bits-1 downto 0) := (others => '0');
    begin
        x0 := Bi_input((4*div4_bits)-1 downto (3*div4_bits));                  -- 127 -> 96
        x1 := Bi_input((3*div4_bits)-1 downto (2*div4_bits));                  -- 95 -> 64
        x2 := Bi_input((2*div4_bits)-1 downto div4_bits);                      -- 63 -> 32
        x3 := Bi_input(div4_bits-1 downto 0);
                
        X0 := std_logic_vector(rotate_right(unsigned(X0), 13));
        X2 := std_logic_vector(rotate_right(unsigned(X2), 3));
        X1 := X1 xor X0 xor X2;
        X3 := X3 xor X2 xor std_logic_vector(shift_right(unsigned(X0), 3));
        X1 := std_logic_vector(rotate_right(unsigned(X1), 1));
        X3 := std_logic_vector(rotate_right(unsigned(X3), 7));
        X0 := X0 xor X1 xor X3;
        X2 := X2 xor X3 xor std_logic_vector(shift_right(unsigned(X1), 7));
        X0 := std_logic_vector(rotate_right(unsigned(X0), 5));
        X2 := std_logic_vector(rotate_right(unsigned(X2), 22));

        Bi_output <= X0 & X1 & X2 & X3;
        
    end process Linear;
    
end Behavioral;