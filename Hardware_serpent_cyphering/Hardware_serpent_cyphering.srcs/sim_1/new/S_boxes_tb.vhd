----------------------------------------------------------------------------------
-- S-Boxes testbench
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity S_boxes_tb is

end S_boxes_tb;

architecture Behavioral of S_boxes_tb is

component S_boxes
    generic(
        nb4_bits : integer := 3
    );
    Port ( 
        clk : in std_logic;
        s_box_in : in std_logic_vector(nb4_bits downto 0);
        s_box_out : out std_logic_vector(nb4_bits downto 0);
        go :  in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        sboxe_num : in integer 
    );
end component;

-- clock signals
signal clk : std_logic := '0' ;
constant clk_period : time := 20 ns;
constant nb4_bits : integer := 3; 

-- componenet signals
signal s_s_box_in : std_logic_vector(nb4_bits downto 0);
signal s_s_box_out : std_logic_vector(nb4_bits downto 0);
signal s_go :  std_logic;
signal s_ready_busy : std_logic_vector(0 to 1);
signal s_sboxe_num : integer; 

begin

u1 : S_boxes port map(
    clk => clk,
    s_box_in => s_s_box_in,
    s_box_out => s_s_box_out,
    go => s_go,
    ready_busy => s_ready_busy,
    sboxe_num => s_sboxe_num
);

clk <= not clk after clk_period/2;

stimuli : process
begin
    s_s_box_in <= "1000"; 
    s_sboxe_num <= 0;
    s_go <= '1';    --cocotb
    wait for 30 ns;

    s_go <= '0';
    wait for 30 ns;

    s_s_box_in <= "0001";
    s_sboxe_num <= 7; 
    s_go <= '1';
    wait for 30 ns;
    
    s_go <= '0';
    wait for 30 ns;
        
end process;

end Behavioral;