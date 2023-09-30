----------------------------------------------------------------------------------
-- Initial permutation file
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Initial_P is
    port(
        clk : in std_logic;
        go :  in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        plaintext_in : in std_logic_vector(0 to 127);
        permutedtext_out : out std_logic_vector(0 to 127)
    ); 
end Initial_P;

architecture Behavioral of Initial_P is

type t_array is array (0 to 127) of integer;
    signal ip_table  : t_array := (
        0, 32, 64, 96, 1, 33, 65, 97, 2, 34, 66, 98, 3, 35, 67, 99,
        4, 36, 68, 100, 5, 37, 69, 101, 6, 38, 70, 102, 7, 39, 71, 103,
        8, 40, 72, 104, 9, 41, 73, 105, 10, 42, 74, 106, 11, 43, 75, 107,
        12, 44, 76, 108, 13, 45, 77, 109, 14, 46, 78, 110, 15, 47, 79, 111,
        16, 48, 80, 112, 17, 49, 81, 113, 18, 50, 82, 114, 19, 51, 83, 115,
        20, 52, 84, 116, 21, 53, 85, 117, 22, 54, 86, 118, 23, 55, 87, 119,
        24, 56, 88, 120, 25, 57, 89, 121, 26, 58, 90, 122, 27, 59, 91, 123,
        28, 60, 92, 124, 29, 61, 93, 125, 30, 62, 94, 126, 31, 63, 95, 127
        );
    signal s_plaintext_in : std_logic_vector(0 to 127);
    signal s_permutedtext_out : std_logic_vector(0 to 127);
    signal s_ready_busy : std_logic_vector(0 to 1);
    signal debug_text_in : std_logic_vector(0 to 127);

    type state_type is(IDLE,PERMUTE,IP_FINISHED,INTERMIDIARE);
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
                        state <= IP_FINISHED;
                    end if;
                    
                when IP_FINISHED =>
                    if finished_done = '1' and go = '1' then
                        state <= IP_FINISHED;
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
                    temp := ip_table(compt);
                    text_out_holder(temp) := text_in_holder(compt);
                end loop;
                permute_done <= '1';

            when IP_FINISHED =>
                start_processing <= '0';
                s_ready_busy <= "11";
                s_permutedtext_out <= text_out_holder;
                finished_done <= '1';
                report("IP_FINISHED State");

            when others =>
                report("OTHERS State");
        end case;
    end process PERMUTATION;
    
    ready_busy <= s_ready_busy;
    permutedtext_out <= s_permutedtext_out;
    s_plaintext_in <= plaintext_in;

end Behavioral;
