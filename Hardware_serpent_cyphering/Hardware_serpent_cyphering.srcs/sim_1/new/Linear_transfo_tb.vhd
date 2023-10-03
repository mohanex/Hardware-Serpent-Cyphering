library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Linear_transformation_tb is
end entity Linear_transformation_tb;

architecture sim of Linear_transformation_tb is
    constant full_bits : integer := 128;
    constant div4_bits : integer := 32;
    signal i_X : std_logic_vector(full_bits-1 downto 0);
    signal o_X : std_logic_vector(full_bits-1 downto 0);
    
    component Linear_transformation
        generic (
            full_bits : integer := 128;
            div4_bits : integer := 32
        );
        port (
            Bi_input : in std_logic_vector(full_bits-1 downto 0);
            Bi_output : out std_logic_vector(full_bits-1 downto 0)
        );
    end component Linear_transformation;
    
begin
    uut : Linear_transformation
        generic map (
            full_bits => full_bits,
            div4_bits => div4_bits
        )
        port map (
            Bi_input => i_X,
            Bi_output => o_X
        );
        
    process
    variable tmp : std_logic_vector(full_bits-1 downto 0);
    begin
        i_X <= (others => '0');
        wait for 10 ns;
                               
        tmp := "11100110001111001100100111101001" & "11111111001001101000100111010001" & "10010111111001111011011001001010" & "00001101110111110000001101111010";
        i_X <= tmp;
        wait for 100 ns;
    end process;
    
end architecture sim;