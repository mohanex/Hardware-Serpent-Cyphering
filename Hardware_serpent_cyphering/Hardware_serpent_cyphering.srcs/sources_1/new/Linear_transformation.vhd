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
        clk : in std_logic;
        go : in std_logic;
        ready_busy : out std_logic_vector(0 to 1);
        Bi_input : in std_logic_vector(full_bits-1 downto 0);
        Bi_output : out std_logic_vector(full_bits-1 downto 0)
    );
end Linear_transformation;

architecture Behavioral of Linear_transformation is
    ----signals--------------------------------------
    signal sig_Bi_input : std_logic_vector(full_bits-1 downto 0);
    signal sig_Bi_output : std_logic_vector(full_bits-1 downto 0);
    type state_type is(IDLE,SPLITTING,LT_FINISHED);
    signal state : state_type := IDLE;
    signal start_processing : std_logic;
    signal INTERMEDIATE_done : std_logic;
    signal SPLITTING_done : std_logic;
    signal subs_done : std_logic;
    signal finished_done : std_logic;
    signal merging_done : std_logic;

begin

    machine_state_control : process(clk, go)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    if start_processing = '1' and go = '1' then
                        state <= SPLITTING;
                    end if;
                    
                when SPLITTING =>
                    if merging_done = '1' then
                        state <= LT_FINISHED;
                    end if;

                when LT_FINISHED =>
                    if finished_done = '1' and go = '1' then
                        state <= LT_FINISHED;
                    elsif go = '0' then
                        state <= IDLE;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    Linear : process(state) 
        variable X0 : std_logic_vector(div4_bits-1 downto 0);
        variable X1 : std_logic_vector(div4_bits-1 downto 0);
        variable X2 : std_logic_vector(div4_bits-1 downto 0);
        variable X3 : std_logic_vector(div4_bits-1 downto 0);
        variable tmp_xoring : std_logic_vector(div4_bits-1 downto 0);
        variable tmp_function : std_logic_vector(div4_bits-1 downto 0);
        variable tmp1 : std_logic_vector(div4_bits-1 downto 0);
        variable tmp2 : std_logic_vector(full_bits-1 downto 0);
    begin
        case state is
            when IDLE =>
                report("IDLE State");
                ready_busy <= "00";
                start_processing <= '1';
                
            when SPLITTING =>
                report "Bi_input: " & integer'image(to_integer(unsigned(sig_Bi_input)));
                x0 := sig_Bi_input((4*div4_bits)-1 downto (3*div4_bits));                  -- 127 -> 96
                x1 := sig_Bi_input((3*div4_bits)-1 downto (2*div4_bits));                  -- 95 -> 64
                x2 := sig_Bi_input((2*div4_bits)-1 downto div4_bits);                      -- 63 -> 32
                x3 := sig_Bi_input(div4_bits-1 downto 0);
                
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
                tmp2 := X0 & X1 & X2 & X3;
                merging_done <= '1';

            when LT_FINISHED =>
                report "Bi_output: " & integer'image(to_integer(unsigned(tmp2)));
                sig_Bi_output <= tmp2;
                ready_busy <= "11";
                finished_done <= '1';

            when others =>
                report"LT OTHERS";
        end case;
        
    end process Linear;
    
    sig_Bi_input <= Bi_input;
    Bi_output <= sig_Bi_output;
    
end Behavioral;