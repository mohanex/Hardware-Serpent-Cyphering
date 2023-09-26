----------------------------------------------------------------------------------
-- State machine of Xoring s-boxing and linear transformation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Minor_state_machine is
   generic(
      constant full_bits : integer :=128;
      constant div4_bits : integer :=32;
      constant full_key_size : integer :=256;
      constant four_bits : integer := 4
   );
   Port ( 
      clk : in std_logic;
      go :  in std_logic;
      ready_busy : out std_logic;
      text_to_compute : in std_logic_vector(0 to full_bits-1);
      computed_text : out std_logic_vector(0 to full_bits-1)
   );
end Minor_state_machine;

architecture Behavioral of Minor_state_machine is

-------- component SBOXES ----------
component S_boxes is
   port(
      clk : in std_logic;
      s_box_in : in std_logic_vector(0 to 3);
      s_box_out : out std_logic_vector(0 to 3);
      go :  in std_logic;
      ready_busy : out std_logic
   );
end component S_boxes;

--------- component KEY_SCHEDULING -----------
component key_scheduling is
   generic(
      constant full_bits : integer :=128;
      constant div4_bits : integer :=32;
      constant full_key_size : integer :=256;
      constant theta : std_logic_vector := X"9e3779b9";
      constant four_bits : integer := 4
  );
  Port ( 
      clk : in std_logic;
      go : in std_logic;
      Ki_number : in integer; --key number 
      user_key : in std_logic_vector(0 to full_bits-1);
      ready_busy : inout std_logic_vector(0 to 1);
      Ki : out std_logic_vector(0 to full_bits-1)
  );
end component key_scheduling;

---------- component LINEAR TRANSFORMATION ---------
component Linear_transformation is
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
end component Linear_transformation;

-------- go signals--------------
signal sig_go_sboxes : std_logic;
signal sig_go_key : std_logic;
signal sig_go_linear : std_logic;

-------- r/b signals--------------
signal sig_ready_busy_sboxes : std_logic;
signal sig_ready_busy_key : std_logic_vector(0 to 1);
signal sig_ready_busy_linear : std_logic;

------- s-boxes remaining signals -------
signal sig_box_in : std_logic_vector(0 to 3);
signal sig_box_out : std_logic_vector(0 to 3);

------- key_scheduling remaining signals -------
signal sig_Ki : std_logic_vector(0 to full_bits-1);
signal sig_Ki_number : integer; --key number;
signal sig_user_key : std_logic_vector(0 to full_bits-1);

------- linear transformation remaining signals ---------
signal sig_Bi_input : std_logic_vector(0 to full_bits-1);
signal sig_Bi_output : std_logic_vector(0 to full_bits-1);


------- Machine state variable -------------------------
type t_State is (IDLE, state_SB, state_KS, state_LT, finished);
signal State : t_State := IDLE;
signal Next_State : t_State;

begin

   SB : S_boxes port map(
      clk => clk;
      s_box_in => sig_box_in;
      s_box_out => sig_box_out;
      go => sig_go_sboxes;
      ready_busy => sig_ready_busy_sboxes
   );
   KS : key_scheduling port map(
      clk => clk,
      go => sig_go_key,
      Ki_number => sig_Ki_number,
      user_key => sig_user_key,
      ready_busy => sig_ready_busy_key,
      Ki => sig_Ki
   );
   LT : Linear_transformation port map(
      clk => clk,
      go => sig_go_linear,
      ready_busy => sig_ready_busy_linear,
      Bi_input => sig_Bi_input,
      Bi_output => sig_Bi_output
   );

   process(Clk) is
      variable iteration : integer := 0;
      variable text_holder : std_logic_vector(0 to full_bits-1);
      variable Ki_holder : std_logic_vector(0 to full_bits-1);
      variable i : integer := 0;
      begin
         if rising_edge(Clk) then
            case state is 
               when IDLE =>
                  if(go = '1') then
                     ready_busy <= '1';
                     state <= state_SB;
                  elsif (go = '0') then
                     ready_busy <= '0';
                  end if;
               when state_SB =>
                     
               when state_KS =>
               when state_LT =>
               when finished =>
            end case;
         end if;
   end process;


end Behavioral;
