----------------------------------------------------------------------------------
-- State machine of permutation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity General_State_machine is
    generic(
        constant full_bits : integer :=128;
        constant div4_bits : integer :=32;
        constant full_key_size : integer :=256;
        constant four_bits : integer := 4
     );
     Port ( 
        clk : in std_logic;
        go :  in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        plain_text : in std_logic_vector(0 to full_bits-1);
        ciphered_text : out std_logic_vector(0 to full_bits-1);
        user_key : in std_logic_vector(0 to full_bits-1)
     );
end General_State_machine;

architecture Behavioral of General_State_machine is
    component Initial_P is
        port(
            clk : in std_logic;
            go :  in std_logic;
            ready_busy : out std_logic_vector(0 to 1);
            plaintext_in : in std_logic_vector(0 to 127);
            permutedtext_out : out std_logic_vector(0 to 127)
        ); 
    end component;

    component Minor_state_machine is
        Port ( 
            clk : in std_logic;
            go :  in std_logic;
            ready_busy : out std_logic_vector(0 to 1);
            text_to_compute : in std_logic_vector(0 to full_bits-1);
            computed_text : out std_logic_vector(0 to full_bits-1);
            user_key_to_calculate : in std_logic_vector(0 to full_bits-1)
         );
    end component;

    component final_P is
        port(
            clk : in std_logic;
            go :  in std_logic;
            ready_busy : out std_logic_vector(0 to 1);
            plaintext_in : in std_logic_vector(0 to 127);
            permutedtext_out : out std_logic_vector(0 to 127)
        ); 
    end component;

    -------- go signals--------------
    signal sig_go_Minor_SM : std_logic;
    signal sig_go_IP : std_logic;
    signal sig_go_FP : std_logic;

    -------- r/b signals--------------
    signal sig_ready_busy_Minor_SM : std_logic_vector(0 to 1);
    signal sig_ready_busy_IP : std_logic_vector(0 to 1);
    signal sig_ready_busy_FP : std_logic_vector(0 to 1);

    ------- Minor state machine remaining signals ------
    signal sig_text_to_compute : std_logic_vector(0 to full_bits-1);
    signal sig_computed_text : std_logic_vector(0 to full_bits-1);
    signal sig_user_key_to_calculate : std_logic_vector(0 to full_bits-1)

    ------- Initial P remaining signals ---------------
    signal sig_plaintext_in_IP : std_logic_vector(0 to 127);
    signal sig_permutedtext_out_FP : std_logic_vector(0 to 127);

    ------- Final P remaining signals -----------------
    signal sig_plaintext_in_IP : std_logic_vector(0 to 127);
    signal sig_permutedtext_out_FP : std_logic_vector(0 to 127);

    type state_type is(IDLE,IP,MINOR_ST,FP,FINISHED);
    signal state : state_type := IDLE;

    ------ General State machine Signals -----------
    signal sig_ready_busy : std_logic_vector(0 to 1);
    signal sig_plain_text : std_logic_vector(0 to full_bits-1);
    signal sig_ciphered_text : std_logic_vector(0 to full_bits-1);
    signal sig_user_key : std_logic_vector(0 to full_bits-1)

    signal start_processing : std_logic;
    signal intermidaire_done : std_logic;
    signal permute_done : std_logic;
    signal finished_done : std_logic;

begin
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
    variable B0 : std_logic_vector(0 to 127);
    variable C : std_logic_vector(0 to 127);
    begin
        case state is
            when IDLE =>
                report("IDLE State");
                sig_ready_busy <= "00";
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
    end process;

    ready_busy  <= sig_ready_busy;
    sig_plain_text <= plain_text;
    ciphered_text <= sig_ciphered_text;
    sig_user_key  <= user_key ;

end Behavioral;
