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
      ready_busy : out std_logic_vector(0 to 1);
      text_to_compute : in std_logic_vector(full_bits-1 downto 0);
      computed_text : out std_logic_vector(full_bits-1 downto 0);
      user_key_to_calculate : in std_logic_vector(full_bits-1 downto 0)
   );
end Minor_state_machine;

architecture Behavioral of Minor_state_machine is
------------ Reverse Function ----------
function RV (input_vector: in std_logic_vector)
   return std_logic_vector is
       variable reversed_result: std_logic_vector(input_vector'RANGE);
       alias reversed_alias: std_logic_vector(input_vector'REVERSE_RANGE) is input_vector;
   begin
       for index in reversed_alias'RANGE loop
           reversed_result(index) := reversed_alias(index);
       end loop;
       return reversed_result;
   end;

-------- component SBOXES ----------
component S_boxes is
   port(
      clk : in std_logic;
      s_box_in : in std_logic_vector(0 to 3);
      s_box_out : out std_logic_vector(0 to 3);
      go :  in std_logic;
      ready_busy : out std_logic_vector(0 to 1);
      sboxe_num : in integer 
   );
end component S_boxes;

--------- component KEY_SCHEDULING -----------
component key_scheduling_SM is
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
      user_key : in std_logic_vector(full_bits-1 downto 0);
      ready_busy : out std_logic_vector(0 to 1);
      Ki : out std_logic_vector(full_bits-1 downto 0);
      ready_busy_key : out std_logic_vector(0 to 1)
  );
end component key_scheduling_SM;

---------- component LINEAR TRANSFORMATION ---------
component Linear_transformation is
   generic(
      constant full_bits : integer :=128;
      constant div4_bits : integer :=32
  );
  Port ( 
      Bi_input : in std_logic_vector(full_bits-1 downto 0);
      Bi_output : out std_logic_vector(full_bits-1 downto 0)
  );
end component Linear_transformation;

-------- go signals--------------
signal sig_go_sboxes : std_logic;
signal sig_go_key : std_logic;

-------- r/b signals--------------
signal sig_ready_busy_sboxes : std_logic_vector(0 to 1);
signal sig_ready_busy_key : std_logic_vector(0 to 1);

------- s-boxes remaining signals -------
signal sig_box_in : std_logic_vector(0 to 3);
signal sig_box_out : std_logic_vector(0 to 3);
signal sig_sboxe_num : integer; 

------- key_scheduling remaining signals -------
signal sig_Ki : std_logic_vector(full_bits-1 downto 0);
signal sig_Ki_number : integer; --key number;
signal sig_user_key : std_logic_vector(full_bits-1 downto 0);
signal sig_ready_busy_key_give : std_logic_vector(0 to 1);

------- linear transformation remaining signals ---------
signal sig_Bi_input : std_logic_vector(full_bits-1 downto 0);
signal sig_Bi_output : std_logic_vector(full_bits-1 downto 0);

------- Machine state variable and signlas-------------------------
type t_State is (IDLE, state_SB, state_KS, state_LT, final_permutation, finished, ALL_FINISHED, speciaal,generating_subkeys,searching_ki32,state_xoring,wait_for_ki,loop_control,final_xor,waiting_for_Sbox,waiting_for_Linear_Transformation);
signal State : t_State := IDLE;
signal Minor_ready_busy : std_logic_vector(0 to 1);
signal sig_computed_text : std_logic_vector(0 to full_bits-1);

begin
   SB : S_boxes port map(
      clk => clk,
      s_box_in => sig_box_in,
      s_box_out => sig_box_out,
      go => sig_go_sboxes,
      ready_busy => sig_ready_busy_sboxes,
      sboxe_num => sig_sboxe_num
   );
   KS : key_scheduling_SM port map(
      clk => clk,
      go => sig_go_key,
      Ki_number => sig_Ki_number,
      user_key => sig_user_key,
      ready_busy => sig_ready_busy_key,
      Ki => sig_Ki,
      ready_busy_key => sig_ready_busy_key_give
   );
   LT : Linear_transformation port map(
      Bi_input => sig_Bi_input,
      Bi_output => sig_Bi_output
   );

   SM : process(Clk,go) is
      variable iteration : integer := 0;
      variable text_holder : std_logic_vector(0 to full_bits-1);
      variable Bi : std_logic_vector(0 to full_bits-1);
      variable Ki_holder : std_logic_vector(0 to full_bits-1);
      variable temp1,temp2,temp3 : std_logic_vector(0 to full_bits-1);
      variable input_s : std_logic_vector (0 to four_bits-1);
      variable i,j,l : integer;
      variable special_var : integer := 0;
      begin
         if rising_edge(Clk) then
            case state is 
               when IDLE =>
                report "IDLE State";
                --report "sig_ready_busy_key =" & integer'image(to_integer(unsigned(sig_ready_busy_key)));
                  if(go = '1') then
                     sig_go_key <= '1';
                     text_holder := text_to_compute;
                     i := 0;
                     state <= generating_subkeys;
                     sig_computed_text <= (others => '0');
                     Minor_ready_busy <= "01";
                  elsif (go = '0') then
                     Minor_ready_busy <= "00";
                  end if;

               when generating_subkeys => --waiting for flag then stopping subkey generation
                  Minor_ready_busy <= "10";
                  report "generating_subkeys State";
                  --report "sig_ready_busy_key =" & integer'image(to_integer(unsigned(sig_ready_busy_key)));
                  if(sig_ready_busy_key = "11") then 
                     sig_go_key <= '0';
                     state <= state_KS;
                  else 
                     state <= generating_subkeys;
                  end if;

               when state_KS => --asking for the subkey 
                  report " KS State";
                  sig_Ki_number <= i;
                  Ki_holder := sig_Ki;
                  state <= wait_for_ki;


               when wait_for_ki =>
                  report " wait_for_ki State";
                  --report "sig_ready_busy_key =" & integer'image(to_integer(unsigned(sig_ready_busy_key_give)));
                  if(sig_ready_busy_key_give = "01") then 
                     if i = 32 then
                        state <= final_xor;
                     else
                        state <= state_xoring;
                     end if;
                  else 
                     state <= wait_for_ki;
                  end if;
                  

               when state_xoring =>
                  report " xoring State";
                  temp1 := text_holder xor Ki_holder;
                  report "Ki :" & integer'image(to_integer(unsigned(Ki_holder)));
                  report "text_holder :" & integer'image(to_integer(unsigned(text_holder)));
                  report "value xored :" & integer'image(to_integer(unsigned(temp1)));
                  j := 0;
                  state <= state_SB;

               when state_SB =>
               report " SB State and i is at " & integer'image(i) & "Iteration";
               --report "Value of xoring before Sboxe :" & integer'image(to_integer(unsigned(temp1)));
                  input_s := temp1(0 + 4 * j) & temp1(1 + 4 * j) & temp1(2 + 4 * j) & temp1(3 + 4 * j);
                  sig_box_in <= input_s;
                  sig_go_sboxes <= '1';
                  state <= waiting_for_Sbox;
                  
              when waiting_for_Sbox =>
                  if sig_ready_busy_sboxes = "11" then
                        temp2((0+4*j) to (3+4*j)) := sig_box_out;
                        sig_go_sboxes <= '0';
                        state <= loop_control;
                        report "Out_of_sbox_value =" & integer'image(to_integer(unsigned(sig_box_out)));
                  else
                        state <= waiting_for_Sbox;
                  end if;
               --report "Value of xoring after Sboxe :" & integer'image(to_integer(unsigned(temp2)));
              
               when loop_control =>
                  report " loop_control State";
                  if j = 31 then
                    if i < 31 then
                        state <= state_LT;
                    elsif i = 31 then
                        state <= searching_ki32;
                    end if;
                  else
                        j := j+1;
                        state <= state_SB;
                  end if;

               when state_LT =>
                  report " LT State";
                  sig_Bi_input <= temp2;
                  state <= waiting_for_Linear_Transformation;
                  
               when waiting_for_Linear_Transformation =>
                  temp3 := sig_Bi_output;
                  state <= finished;
                  --end loop;
                  
               when finished =>
                  report " FINISHED State";
                  report "Value of i :" & integer'image(i);
                  bi := temp3;
                  if i<31 then
                     i := i+1;
                     text_holder := bi;
                     state <= state_KS;
                  else
                     state <= speciaal;
                  end if;

               when speciaal =>
                  report " SPECIAAL State";
                  i := 31;
                  state <= state_KS;
                  text_holder := bi;
                  
                  
               when searching_ki32 =>
                  report " searching_ki32 State";
                  i := 32;
                  state <= state_KS;

               when final_xor =>
                  report " final_xor State";
                  bi := temp2 xor Ki_holder;
                  state <= ALL_FINISHED;

               when ALL_FINISHED =>
                  report " ALL_FINISHED State";
                  if(go = '0') then
                     state <= IDLE;
                  elsif (go = '1') then
                     state <= ALL_FINISHED;
                     Minor_ready_busy <= "11";
                     sig_computed_text <= bi;
                  end if;
                  
               when others =>
                    report"Going to others state";

            end case;
         end if;
   end process;
   sig_user_key <= user_key_to_calculate;
   ready_busy <= Minor_ready_busy;
   computed_text <= sig_computed_text;
   
end Behavioral;
