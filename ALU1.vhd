----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:   10:39:18 13/09/2014
-- Design Name:     ALU
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: ALU template for MIPS processor
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


------------------------------------------------------------------
-- ALU Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
generic (width     : integer := 32);
Port (Clk            : in    STD_LOGIC;
        Control        : in    STD_LOGIC_VECTOR (5 downto 0);
        Operand1        : in    STD_LOGIC_VECTOR (width-1 downto 0);
        Operand2        : in    STD_LOGIC_VECTOR (width-1 downto 0);
        Result1        : out    STD_LOGIC_VECTOR (width-1 downto 0);
        Result2        : out    STD_LOGIC_VECTOR (width-1 downto 0);
        Status        : out    STD_LOGIC_VECTOR (2 downto 0)); -- busy (multicycle only), overflow (add and sub), zero (sub)
end alu;


------------------------------------------------------------------
-- ALU Architecture
------------------------------------------------------------------

architecture Behavioral of alu is

type states is (COMBINATIONAL, MULTI_CYCLE);
signal state, n_state     : states := COMBINATIONAL;


----------------------------------------------------------------------------
-- Adder instantiation
----------------------------------------------------------------------------
component adder is
generic (width : integer);
port (A         : in     std_logic_vector(width-1 downto 0);
        B         : in     std_logic_vector(width-1 downto 0);
        C_in     : in     std_logic;
        S         : out std_logic_vector(width-1 downto 0);
        C_out    : out std_logic);
end component adder;

----------------------------------------------------------------------------
-- Barrel Shifter instantiation
----------------------------------------------------------------------------
component barrelshifter is
generic (width : integer := 32);
    Port (Control: in std_logic_vector(14 downto 0);
            Input: in std_logic_vector(2*width-1 downto 0);
            Output: out std_logic_vector(2*width-1 downto 0));
end component barrelshifter;

----------------------------------------------------------------------------
-- Adder signals
----------------------------------------------------------------------------
signal A         : std_logic_vector(width-1 downto 0) := (others => '0');
signal B         : std_logic_vector(width-1 downto 0) := (others => '0');
signal C_in     : std_logic := '0';
signal S         : std_logic_vector(width-1 downto 0) := (others => '0');
signal C_out    : std_logic := '0'; --not used
----------------------------------------------------------------------------
--Barrel Shifter signals
----------------------------------------------------------------------------
signal inputshift : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal outputshift: std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal controlshift : std_logic_vector(14 downto 0) := (others=>'0');

----------------------------------------------------------------------------
-- Signals for MULTI_CYCLE_PROCESS
----------------------------------------------------------------------------
signal Result1_multi        : STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal Result2_multi        : STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal done                     : STD_LOGIC := '0';

----------------------------------------------------------------------------
-- Multiplication signals
----------------------------------------------------------------------------
signal temp_sum : std_logic_vector(2*width-1 downto 0) := (others => '0'); -- The main output of the multiplication state
signal temp_sum_inside : std_logic_vector(2*width-1 downto 0) := (others => '0');
signal controlmultiply : std_logic_vector(14 downto 0) := (others=>'0');
signal count1 : std_logic_vector(5 downto 0) := (others=>'0');
signal dont_add : std_logic := '0';
signal enable32, enable16, enable8, enable4, enable2 : std_logic := '1';
signal signed_type : std_logic_vector(1 downto 0) := "00"; -- Only for signed mult
signal A_fake : std_logic_vector(width-1 downto 0) := (others => '0');
signal B_fake : std_logic_vector(width-1 downto 0) := (others => '0');
signal tempo_sum : std_logic_vector(2*width-1 downto 0) := (others => '0');

----------------------------------------------------------------------------
-- Division signals
----------------------------------------------------------------------------

signal temp_div : std_logic_vector(2*width-1 downto 0) := (others => '0');
signal tempo_div : std_logic_vector(2*width-1 downto 0) := (others => '0');
signal temp_div_inside : std_logic_vector(2*width-1 downto 0) := (others => '0');
signal controldiv : std_logic_vector(14 downto 0) := (others=>'0');
signal starting_div : std_logic := '0';
signal init_count : std_logic_vector(5 downto 0) := (others=>'0');
signal A_div : std_logic_vector(width-1 downto 0) := (others => '0');
signal B_div : std_logic_vector(width-1 downto 0) := (others => '0');

----------------------------------------------------------------------------
-- Temp signals
----------------------------------------------------------------------------
signal temp_A : std_logic_vector(width-1 downto 0) := (others => '0');
signal temp_temp_sum : std_logic_vector(2*width-1 downto 0) := (others => '0');

begin

-- <port maps>
adder32 : adder generic map (width =>  width) port map (  A=>A, B=>B, C_in=>C_in, S=>S, C_out=>C_out );
barrelshifter64: barrelshifter generic map (width => width) port map(Input=>inputshift, Output=>outputshift, Control=>controlshift);
-- </port maps>


----------------------------------------------------------------------------
-- COMBINATIONAL PROCESS
----------------------------------------------------------------------------
COMBINATIONAL_PROCESS : process (Control, Operand1, Operand2, state, S, Result1_multi,  dont_add, b_div, Result2_multi, outputshift, signed_type, A_fake, B_fake, temp_sum, temp_sum_inside,controlmultiply,C_out, temp_div, controldiv, temp_div_inside, done)
begin

-- <default outputs>
Status(2 downto 0) <= "000"; -- both statuses '0' by default
Result1 <= (others=>'0');
Result2 <= (others=>'0');
n_state <= state;
controlshift <= (others=>'0');
inputshift <= (others=>'0');
B <= Operand2;
A_fake <= not(Operand1) + 1; -- Can be optimized
B_fake <= not(Operand2) + 1; -- Can be optimized
signed_type <= Operand1(width-1) & Operand2(width-1);
temp_sum <= (x"00000000" & Operand2);
tempo_sum <= not(temp_sum) + 1; -- Can be optimized
temp_div <= (x"00000000" & Operand1);
tempo_div <= not(temp_div) + 1; -- Can be optimized

C_in <= '0';

--Determining certain input parameters depending on the sign bit of the input 
--operands in case of signed multiplication
if ((Control(4 downto 0) = "10000") and (signed_type = "00")) then
    temp_sum <= (x"00000000" & Operand2);
    A <= Operand1;
elsif ((Control(4 downto 0) = "10000") and (signed_type = "11")) then
    temp_sum <= (x"00000000" & B_fake);
    A <= A_fake;
elsif ((Control(4 downto 0) = "10000") and (signed_type = "10")) then
    A <= A_fake;
    temp_sum <= (x"00000000" & Operand2);   
elsif ((Control(4 downto 0) = "10000") and (signed_type = "01")) then
    A <= Operand1;
    temp_sum <= (x"00000000" & B_fake);
else
    temp_sum <= (x"00000000" & Operand2);
    A <= Operand1;
end if;

--Determining certain input parameters depending on the sign bit of the input 
--operands in case of signed division
if ((Control(4 downto 0) = "10010") and (signed_type = "00")) then
    temp_div <= (x"00000000" & Operand1);
    A_div <= Operand1;
    B_div <= Operand2;
elsif ((Control(4 downto 0) = "10010") and (signed_type = "11")) then
    temp_div <= (x"00000000" & A_fake);
    A_div <= A_fake;
    B_div <= B_fake;
elsif ((Control(4 downto 0) = "10010") and (signed_type = "01")) then
    A_div <= Operand1;
    B_div <= B_fake;
    temp_div <= (x"00000000" & Operand1);   
elsif ((Control(4 downto 0) = "10010") and (signed_type = "10")) then
    A_div <= A_fake;
    B_div <= Operand2;
    temp_div <= (x"00000000" & A_fake);
else
    temp_div <= (x"00000000" & Operand1);
    A_div <= Operand1;
    B_div <= Operand2;
end if;
C_in <= '0';
-- </default outputs>

--reset
if Control(5) = '1' then
    n_state <= COMBINATIONAL;
else

case state is
    when COMBINATIONAL =>
        case Control(4 downto 0) is
        --and
        when "00000" =>   -- takes 0 cycles to execute
            Result1 <= Operand1 and Operand2;
        --or
        when "00001" =>
            Result1 <= Operand1 or Operand2;
        --xor
        when "00100" =>
            Result1 <= Operand1 xor Operand2;
        --nor
        when "01100" =>
            Result1 <= Operand1 nor Operand2;
        --add
        when "00010" => --Unsigned Addition
            Result1 <= S;
            -- overflow
            Status(1) <= ( Operand1(width-1) xnor  Operand2(width-1) )  and (Operand2(                                width-1) xor S(width-1) );
        when "00011" => --Signed Addition (Using 2's complement)
            if ((Operand1(width-1) xnor Operand2(width-1)) = '1') then
                if (Operand1(width-1) = '0') then
                    Result1 <= S;
                    Status(1) <= S(width-1);
                else
                    Result1 <= S;
                    Status(1) <= not S(width-1);                   
                end if;
            else
                Result1 <= S;
                Status(1) <= '0'; --There can never be an overflow in this case
            end if;
        when "00110" => --Unsigned Subtraction
            A <= Operand1;
            B <= not(Operand2);
            C_in <= '1';
            Result1 <= S;
            -- overflow
             Status(1) <= not C_out;
            --zero
            if S = x"00000000" then
                Status(0) <= '1';
            else
                Status(0) <= '0';
            end if;
        when "01000" => --Signed Subtraction (Using 2's complement)
            if ((Operand1(width-1) xnor (not(Operand2(width-1)))) = '1') then
                if (Operand1(width-1) = '0') then
                    A <= Operand1;
                    B <= not(Operand2);
                    C_in <= '1';
                    Result1 <= S;
                    Status(1) <= S(width-1);
                else
                    A <= Operand1;
                    B <= not(Operand2);
                    C_in <= '1';
                    Result1 <= S;
                    Status(1) <= not S(width-1);
                end if;
            else
                A <= Operand1;
                B <= not(Operand2);
                C_in <= '1';
                Result1 <= S;
                -- overflow
                Status(1) <= '0'; -- There can't be an overflow in this case
            end if;
            if S = x"00000000" then
                Status(0) <= '1';
            else
                Status(0) <= '0';
            end if;
        when "01110" => --Unsigned SLT
            if (((Operand1(width-1) xor (Operand2(width-1)))) = '1') then
                if ((Operand1(width-1) = '1') and (Operand2(width-1) = '0')) then
                    Result1 <= x"00000000";
                else
                    Result1 <= x"00000001";
                end if;
            else
                B <= not (Operand2);
                C_in <= '1';
                if (S(width-1) = '1') then
                    Result1 <= x"00000001";
                else
                    Result1 <= x"00000000";
                end if;   
            end if;                   
        when "00111" => --Signed SLT
            if (((Operand1(width-1) xor (Operand2(width-1)))) = '1') then
                if ((Operand1(width-1) = '1') and (Operand2(width-1) = '0')) then
                    Result1 <= x"00000001";
                else
                    Result1 <= x"00000000";
                end if;
            else
                A <= Operand1;
                B <= not (Operand2);
                C_in <= '1';
                if (S(width-1) = '1') then
                    Result1 <= x"00000001";
						  Status(0) <= '1';
                else
                    Result1 <= x"00000000";
						  Status(0) <= '0';
                end if;   
            end if;
        when "00101" => --SLL
            inputshift <= x"00000000" & Operand1;               
            controlshift(2 downto 0) <= ("00" & Operand2(6));
            controlshift(5 downto 3) <= ("00" & Operand2(7));
            controlshift(8 downto 6) <= ("00" & Operand2(8));
            controlshift(11 downto 9) <= ("00" & Operand2(9));
            controlshift(14 downto 12) <= ("00" & Operand2(10));       
            Result1 <= outputshift(31 downto 0);
            Result2 <= outputshift(2*width-1 downto width);
		  when "10101" => --SLLV
            inputshift <= x"00000000" & Operand1;               
            controlshift(2 downto 0) <= ("00" & Operand2(0));
            controlshift(5 downto 3) <= ("00" & Operand2(1));
            controlshift(8 downto 6) <= ("00" & Operand2(2));
            controlshift(11 downto 9) <= ("00" & Operand2(3));
            controlshift(14 downto 12) <= ("00" & Operand2(4));       
            Result1 <= outputshift(31 downto 0);
            Result2 <= outputshift(2*width-1 downto width);
        when "01101" => --SRL
            inputshift <= x"00000000" & Operand1;               
            controlshift(2 downto 0) <= ('0' & Operand2(6) & '0');
            controlshift(5 downto 3) <= ('0' & Operand2(7) & '0');
            controlshift(8 downto 6) <= ('0' & Operand2(8) & '0');
            controlshift(11 downto 9) <= ('0' & Operand2(9) & '0');
            controlshift(14 downto 12) <= ('0' & Operand2(10) & '0');                   
            Result1 <= outputshift(31 downto 0);
            Result2 <= outputshift(2*width-1 downto width);
        when "01001" => --SRA
            inputshift <= x"00000000" & Operand1;               
            controlshift(2 downto 0) <= (Operand2(6) & "00");
            controlshift(5 downto 3) <= (Operand2(7) & "00");
            controlshift(8 downto 6) <= (Operand2(8) & "00");
            controlshift(11 downto 9) <= (Operand2(9) & "00");
            controlshift(14 downto 12) <= (Operand2(10) & "00");                   
            Result1 <= outputshift (31 downto 0);
            Result2 <= outputshift(2*width-1 downto width);
        -- multi-cycle operations   
        when "10001" | "10000" | "10011" | "10010" => -- Signed div adding
            n_state <= MULTI_CYCLE;
            Status(2) <= '1';
        -- default cases (already covered)
        when others=> null;
        end case;
    when MULTI_CYCLE =>
        case Control(4 downto 0) is
            when "10001" | "10000" =>
                if (Control(4 downto 0) = "10000") then
                    signed_type <= Operand1(width-1) & Operand2(width-1); 
						  -- useful for signed multiplication
                end if;
                    inputshift <= temp_sum_inside; --Input to barrel shifter
                    controlshift <= controlmultiply; --Control input to barrel shifter
                    if dont_add = '0' then 
						  -- This condition adds operand to the register after it is shifted
								--A <= Operand1;
                        B <= outputshift(2*width-2 downto width-1);
                        temp_sum <= C_out & S & outputshift(width-2 downto 0);
                    else
						  --This condition only shifts the operand and doesn't add anything
								A <= (others=>'0');
                        B <= outputshift(2*width-2 downto width-1);		
                        temp_sum <= C_out & S & outputshift(width-2 downto 0);	
                     --   temp_sum <= '0' & outputshift(2*width-2 downto 0);
                    end if;
                    if done = '1' then                           
                        Result1 <= Result1_multi; -- Number of '0's should vary
                        Result2 <= Result2_multi;
                        n_state <= COMBINATIONAL;
                        Status(2) <= '0';
                    else
                        Status(2) <= '1';
                        n_state <= MULTI_CYCLE;
                    end if;
        when "10011" | "10010" =>
            inputshift <= temp_div_inside; -- Input to barrelshifter
            controlshift <= controldiv; -- Control input to barrelshifter
            temp_div <= outputshift;
            A <= outputshift(2*width-1 downto width); -- Input to Adder
            --According to the sign of the sign bit, assign operands. If Operand2 is 
				--negative, then pass it into the adder as is, otherwise pass in the 2's 
				--complement for subtraction
				if (signed_type(0) = '0') then
                B <= not (Operand2);
                C_in <= '1';
            else
                B <= Operand2;
                C_in <= '0';
            end if;
				--If the result of subtraction is negative, then a '1' is not added to 
				--the quotient and the register is shifted further to the left. If the 
				--result of the subtraction is positive, a '1' is added to the quotient 
				--(last bit of the register)
				--B_div is the original Operand2 in DIVU and 2's complement in DIV
            if (((outputshift(2*width-1) xor (B_div(width-1)))) = '1') then
				--This condition is an attempt to assign the quotient bits by first comparing the input operand, B_div, and the shifed result. If B_div is bigger, add a '0' to the quotient
                if ((outputshift(2*width-1) = '1') and (B_div(width-1) = '0')) then
                    temp_div(0) <= '1';
                    temp_div(2*width-1 downto width) <= S;                   
                else
                    temp_div(0) <= '0';
                end if;
            else
					--Compare output results
                if (S(width-1) = '1') then
                    temp_div(0) <= '0';
                else
                    temp_div(0) <= '1';
                    temp_div(2*width-1 downto width) <= S;                                       
                end if;   
            end if;
            if done = '1' then                           
                Result1 <= Result1_multi; -- Number of '0's should vary
                Result2 <= Result2_multi;
                n_state <= COMBINATIONAL;
                Status(2) <= '0';
            else
                Status(2) <= '1';
                n_state <= MULTI_CYCLE;
            end if;           
        when others => NULL;
        end case;
    when others => NULL;
    end case;
end if;   
end process;


----------------------------------------------------------------------------
-- STATE UPDATE PROCESS
----------------------------------------------------------------------------

STATE_UPDATE_PROCESS : process (Clk) -- state updating
begin 
   if (Clk'event and Clk = '1') then
        state <= n_state;
   end if;
end process;

----------------------------------------------------------------------------
-- MULTI CYCLE PROCESS
----------------------------------------------------------------------------
MULTI_CYCLE_PROCESS : process (Clk) -- multi-cycle operations done here
-- assume that Operand1 and Operand 2 do not change while multi-cycle operations are being performed


--BASIC LOGIC
--The function of the barrelshifter was to shift by a variable 
--number of zeroes in each cycle. Instead of blinding shifting 32 times, 
--the shifter would match the pattern of the input to certain pre-set 
--patterns and determine how much to shift by. The 'enable' signals are simply 
--switches for the various bit-shifters. Depending on the number of bits left in the 
--operand, they are switched on and off.For example, if 20 bits have been shifted, the 
--enable32 and enable16 signals will be off.
begin
   if (Clk'event and Clk = '1') then
        if Control(5) = '1' then
            count1 <= "000000";
        end if;
        temp_sum_inside <= temp_sum;                   
        done <= '0';
        if n_state = MULTI_CYCLE then
            case Control(4 downto 0) is
            when "10001" | "10000" =>
                if state = COMBINATIONAL then
                    count1 <= "000000";                   
                end if;
                if (count1 = "000000") then
                    enable32 <= '1';
                else
                    enable32 <= '0';
                end if;               
                if (count1(4) or count1(5)) = '1' then
                    enable16 <= '0';
                else
                    enable16 <= '1';
                end if;
                if ((count1(4) and count1(3)) or count1(5)) = '1' then
                    enable8 <= '0';
                else
                    enable8 <= '1';
                end if;
                if ((count1(4) and count1(3) and count1(2)) or count1(5)) = '1' then
                    enable4 <= '0';
                else
                    enable4 <= '1';
                end if;
                if (((not count1(5)) and (not count1(0))) or count1(5)) = '1' then
                    enable2 <= '0';
                else
                    enable2 <= '1';
                end if;               
                    dont_add <= '1';--This value means only shift and don't add.
						  
						  --Pattern matching for the barrelshifter				
                    if (temp_sum(0) = '0') then
                        if (temp_sum(1 downto 0) = "00" and enable2 = '1') then
                            if (temp_sum(3 downto 0) = "0000" and enable4 = '1') then
                                if (temp_sum(7 downto 0) = "00000000" and enable8 = '1') then
                                    if (temp_sum(15 downto 0) = x"0000" and enable16 = '1') then
                                        if (temp_sum(31 downto 0) = x"00000000" and enable32 = '1') then
                                            controlmultiply <= "010010010010010";
                                            count1 <= count1 + 32;
                                        else
                                            controlmultiply <= "010000000000000";
                                            count1 <= count1 + 16;
                                        end if;
                                    else   
                                        controlmultiply <= "000010000000000";
                                        count1 <= count1 + 8;
                                    end if;
                                else
                                    controlmultiply <= "000000010000000";
                                    count1 <= count1 + 4;
                                end if;
                            else
                                controlmultiply <= "000000000010000";
                                count1 <= count1 + 2;
                            end if;
                        else
                            controlmultiply <= "000000000000010";
                            count1 <= count1 + 1;
                        end if;
                    else
                        controlmultiply <= "000000000000010";
                        count1 <= count1 + 1;
                        dont_add <= '0';
                    end if;
                if count1 = "100000" then
                    if ((Control(4 downto 0) = "10000") and ((signed_type = "10") or(                        signed_type = "01"))) then
                        Result1_multi <= tempo_sum(31 downto 0);
                        Result2_multi <= tempo_sum(2*width-1 downto width);                       
                    else
                        Result1_multi <= temp_sum(31 downto 0);
                        Result2_multi <= temp_sum(2*width-1 downto width);
                    end if;
                    controlmultiply <= (others=>'0');
                    done <= '1';
                    count1 <= "000000";
                end if;
            when "10011" | "10010" =>
                if state = COMBINATIONAL then
                    count1 <= "000000";                   
                    starting_div <= '0';                   
                end if;
                init_count <= "000000";
                temp_div_inside <= temp_div;
					 
--Pattern matching for the barrelshifter (only happens in the 
--first cycle, hence the variable 'starting_div' which indicates this first 
--cycle 					 
                if (A_div(width-1) = '0' and (state = COMBINATIONAL or starting_div = '0'                    ))then
                    if (A_div(width-1 downto width-2) = "00") then
                        if (A_div(width-1 downto width-4) = "0000") then
                            if (A_div(width-1 downto width-8) = "00000000") then
                                if (A_div(width-1 downto width-16) = x"0000") then
                                    if (A_div(width-1 downto 0) = x"00000000") then
                                        controldiv <= "001001001001001";
                                        init_count <= init_count + 32;
                                        count1 <= count1 + 32;
                                        starting_div <= '1';
                                    else
                                        controldiv <= "001000000000000";
                                        init_count <= init_count + 16;
                                        count1 <= count1 + 16;
                                        starting_div <= '1';
                                    end if;
                                else   
                                    controldiv <= "000001000000000";
                                    init_count <= init_count + 8;
                                    count1 <= count1 + 8;
                                    starting_div <= '1';
                                end if;
                            else
                                controldiv <= "000000001000000";
                                init_count <= init_count + 4;
                                count1 <= count1 + 4;
                                starting_div <= '1';
                            end if;
                        else
                            controldiv <= "000000000001000";
                            init_count <= init_count + 2;
                            count1 <= count1 + 2;
                            starting_div <= '1';
                        end if;
                    else
                        controldiv <= "000000000001000";
                        init_count <= init_count + 1;
                        count1 <= count1 + 2;
                        starting_div <= '1';
                    end if;
                else
                    controldiv <= "000000000000001";
                    count1 <= count1 + 1;
                end if;
                if count1 = "100000" then
					 --Depending on DIV and DIVU, the output will be different
                    if ((Control(4 downto 0) = "10010") and (signed_type = "01")) then
                        Result1_multi <= not (temp_div(31 downto 0)) + 1; --Quotient
                        Result2_multi <= temp_div(2*width-1 downto width); --Remainder
                    elsif ((Control(4 downto 0) = "10010") and (signed_type = "10")) then
                        Result1_multi <= not (temp_div(31 downto 0)) + 1; --Quotient
                        Result2_multi <= not (temp_div(2*width-1 downto width))+1; --Remainder
                    elsif ((Control(4 downto 0) = "10010") and (signed_type = "11")) then
                        Result1_multi <= temp_div(31 downto 0); --Quotient
                        Result2_multi <= not (temp_div(2*width-1 downto width))+1; --Remainder
                    else
                        Result1_multi <= temp_div(31 downto 0); --Quotient
                        Result2_multi <= temp_div(2*width-1 downto width); --Remainder
                    end if;
                    controldiv <= (others=>'0');
                    done <= '1';
                    count1 <= "000000";
                    starting_div <= '0';
                end if;               
            when others=> null;
            end case;
        end if;
    end if;
end process;
end Behavioral;
