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
    signal sig_user_key_to_calculate : std_logic_vector(0 to full_bits-1);

    ------- Initial P remaining signals ---------------
    signal sig_plaintext_in_IP : std_logic_vector(0 to 127);
    signal sig_permutedtext_out_IP : std_logic_vector(0 to 127);

    ------- Final P remaining signals -----------------
    signal sig_plaintext_in_FP : std_logic_vector(0 to 127);
    signal sig_permutedtext_out_FP : std_logic_vector(0 to 127);

    type state_type is(IDLE,INTERMIDIARE,IP,waiting_IP,waiting_minor_SM,MINOR_SM,FP,FINISHED,waiting_FP);
    signal state : state_type := IDLE;

    ------ General State machine Signals -----------
    signal sig_ready_busy : std_logic_vector(0 to 1);
    signal sig_plain_text : std_logic_vector(0 to full_bits-1);
    signal sig_ciphered_text : std_logic_vector(0 to full_bits-1);
    signal sig_user_key : std_logic_vector(0 to full_bits-1);

    signal debug_text_in : std_logic_vector(0 to 127);

    signal start_processing : std_logic;
    signal intermidaire_done : std_logic;
    signal finished_done : std_logic;
    signal waiting_ip_done : std_logic;
    signal waiting_fp_done : std_logic;
    signal done_ip : std_logic;
    signal done_FP : std_logic;
    signal minor_st_done : std_logic;
    signal waiting_minor_SM_done : std_logic;
    
begin
    Minor_ST :  Minor_state_machine port map(
            clk => clk,
            go => sig_go_Minor_SM,
            ready_busy => sig_ready_busy_Minor_SM,
            text_to_compute => sig_text_to_compute,
            computed_text => sig_computed_text,
            user_key_to_calculate => sig_user_key_to_calculate
    );

    Initial_permutation :  Initial_P port map(
            clk => clk,
            go => sig_go_IP,
            ready_busy => sig_ready_busy_IP,
            plaintext_in => sig_plaintext_in_IP,
            permutedtext_out => sig_permutedtext_out_IP
    );

    Final_permutation :  final_P port map(
            clk => clk,
            go => sig_go_FP,
            ready_busy => sig_ready_busy_FP,
            plaintext_in => sig_plaintext_in_FP,
            permutedtext_out => sig_permutedtext_out_FP
    );

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
                        state <= IP;
                    end if;
                    
                when IP =>
                    if done_ip = '1' then
                        state <= waiting_IP;
                    end if;

                when waiting_IP =>
                    if waiting_ip_done = '1' and sig_ready_busy_IP = "11" then
                        state <= MINOR_SM;
                    end if;

                when MINOR_SM =>
                    if minor_st_done = '1' then
                        state <= waiting_minor_SM;
                    end if;

                when waiting_minor_SM =>
                    if waiting_minor_SM_done = '1' and sig_ready_busy_Minor_SM ="11" then
                        state <= FP;
                    end if;

                when FP =>
                    if done_FP = '1' then
                        state <= waiting_FP;
                    end if;

                when waiting_FP =>
                    if waiting_FP_done = '1' and sig_ready_busy_FP = "11" then
                        state <= FINISHED;
                    end if;
                    
                when FINISHED =>
                    if finished_done = '1' and go = '1' then
                        state <= FINISHED;
                    elsif go = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    PERMUTATION : process(state)
    variable temp_var : std_logic_vector(0 to 127);
    variable temp_var2 : std_logic_vector(0 to 127);
    variable B0 : std_logic_vector(0 to 127);
    variable C : std_logic_vector(0 to 127);
    begin
        case state is
            when IDLE =>
                report("IDLE State");
                sig_ready_busy <= "00";
                start_processing <= '1';
                finished_done <= '0';
                sig_ciphered_text <= (others => '1');
                
            when INTERMIDIARE =>
                B0 := sig_plain_text;
                debug_text_in <= B0;
                intermidaire_done <= '1';

            when IP =>
                sig_plaintext_in_IP <= B0;
                sig_go_IP <= '1';
                done_ip <= '1';

            when waiting_IP =>
                temp_var := sig_permutedtext_out_IP;
                waiting_ip_done <= '1';

            when MINOR_SM =>
                sig_text_to_compute <= temp_var;
                sig_user_key_to_calculate <= sig_user_key;
                sig_go_Minor_SM <= '1';
                minor_st_done <= '1';

            when waiting_minor_SM =>
                temp_var2 := sig_computed_text;
                waiting_minor_SM_done <= '1';

            when FP =>
                sig_plaintext_in_FP <= temp_var2;
                sig_go_FP <= '1';
                done_FP <= '1';

            when waiting_FP =>
                C := sig_permutedtext_out_FP;
                waiting_FP_done <= '1';

            when FINISHED =>
                start_processing <= '0';
                sig_ready_busy <= "11";
                sig_ciphered_text <= C;
                finished_done <= '1';
                report("FINISHED State");

            when others =>
                report("OTHERS State");
        end case;
    end process;

    ready_busy  <= sig_ready_busy;
    sig_plain_text <= plain_text;
    ciphered_text <= sig_ciphered_text;
    sig_user_key  <= user_key ;

end Behavioral;
