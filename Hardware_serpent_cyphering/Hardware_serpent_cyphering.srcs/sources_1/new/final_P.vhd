----------------------------------------------------------------------------------
-- final permutation file
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity final_P is
    port(
        clk : in std_logic;
        go :  in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        plaintext_in : in std_logic_vector(0 to 127);
        permutedtext_out : out std_logic_vector(0 to 127)
    ); 
end final_P;

architecture Behavioral of final_P is

type t_array is array (0 to 127) of integer;
    signal if_table  : t_array := (
        0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60,
        64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124,
        1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61,
        65, 69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, 117, 121, 125,
        2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62,
        66, 70, 74, 78, 82, 86, 90, 94, 98, 102, 106, 110, 114, 118, 122, 126,
        3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63,
        67, 71, 75, 79, 83, 87, 91, 95, 99, 103, 107, 111, 115, 119, 123, 127
    );
    signal s_plaintext_in : std_logic_vector(0 to 127);
    signal s_permutedtext_out : std_logic_vector(0 to 127);
    signal s_ready_busy : std_logic_vector(0 to 1);
    signal debug_text_in : std_logic_vector(0 to 127);

    type state_type is(IDLE,PERMUTE,FP_FINISHED,INTERMIDIARE);
    signal state : state_type := IDLE;

    signal start_processing : std_logic;
    signal intermidaire_done : std_logic;
    signal permute_done : std_logic;
    signal finished_done : std_logic;

begin

    -- State machine process
    machine_state_control : process(clk, go)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    if start_processing = '1' and go = '1' then
                        state <= INTERMIDIARE;
                    end if;
                    
                when INTERMIDIARE =>
                    if intermidaire_done = '1' then
                        state <= PERMUTE;
                    end if;
                    
                when PERMUTE =>
                    if permute_done = '1' then
                        state <= FP_FINISHED;
                    end if;
                    
                when FP_FINISHED =>
                    if finished_done = '1' and go = '1' then
                        state <= FP_FINISHED;
                    elsif go = '0' then
                        state <= IDLE;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
    
    PERMUTATION : process(state)
        variable compt : integer := 0;
        variable temp : integer;
        variable text_out_holder : std_logic_vector(0 to 127);
        variable text_in_holder : std_logic_vector(0 to 127);
    begin
        case state is
            when IDLE =>
                report("IDLE State");
                s_ready_busy <= "00";
                start_processing <= '1';
                finished_done <= '0';
                permute_done <= '0';
                compt := 0;
                s_permutedtext_out <= (others => '1');
                
            when INTERMIDIARE =>
                text_in_holder := s_plaintext_in;
                debug_text_in <= text_in_holder;
                intermidaire_done <= '1';

            when PERMUTE =>
                s_ready_busy <= "01";
                for compt in 0 to 127 loop
                    report("Compt =")&integer'image(compt);
                    temp := if_table(compt);
                    text_out_holder(temp) := text_in_holder(compt);
                end loop;
                permute_done <= '1';

            when FP_FINISHED =>
                start_processing <= '0';
                s_ready_busy <= "11";
                s_permutedtext_out <= text_out_holder;
                finished_done <= '1';
                report("FP_FINISHED State");

            when others =>
                report("OTHERS State");
        end case;
    end process PERMUTATION;
    
    ready_busy <= s_ready_busy;
    permutedtext_out <= s_permutedtext_out;
    s_plaintext_in <= plaintext_in;

end Behavioral;
