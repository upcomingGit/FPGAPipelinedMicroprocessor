----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:    08:17:28 11/02/2014 
-- Design Name: 
-- Module Name:    NewALU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity NewALU is
	Port (   CLK         : in STD_LOGIC;
				ALU_InA 		: in  STD_LOGIC_VECTOR (31 downto 0);		
				ALU_InB 		: in  STD_LOGIC_VECTOR (31 downto 0);
				ALU_Out 		: out STD_LOGIC_VECTOR (31 downto 0);
				ALU_Control	: in  STD_LOGIC_VECTOR (7 downto 0);
				Reset    : in  STD_LOGIC;
				Busy     : out STD_LOGIC;
				ALU_zero	: out STD_LOGIC);
end NewALU;

architecture Behavioral of NewALU is

component alu is
generic (width     : integer := 32);
Port (Clk            : in    STD_LOGIC;
        Control        : in    STD_LOGIC_VECTOR (5 downto 0);
        Operand1        : in    STD_LOGIC_VECTOR (width-1 downto 0);
        Operand2        : in    STD_LOGIC_VECTOR (width-1 downto 0);
        Result1        : out    STD_LOGIC_VECTOR (width-1 downto 0);
        Result2        : out    STD_LOGIC_VECTOR (width-1 downto 0);
        Status        : out    STD_LOGIC_VECTOR (2 downto 0)); -- busy (multicycle only), overflow (add and sub), zero (sub)
end component;

signal Control : std_logic_vector(5 downto 0);
signal Result1 : std_logic_vector(31 downto 0);
signal Result2 : std_logic_vector(31 downto 0);
signal Status : std_logic_vector(2 downto 0);
signal StatPrev : std_logic;
signal StatPrevPrev : std_logic;

signal HI : std_logic_vector(31 downto 0) := (others=>'0');
signal LO : std_logic_vector(31 downto 0) := (others=>'0');

begin

  ALU1 : alu port map(CLK=>CLK, Control=>Control, Operand1=>ALU_InA, Operand2=>ALU_InB,
                      Result1=>Result1, Result2=>Result2, Status=>Status);
	
	Busy <= Status(2);
	ALU_zero <= Status(0);
	process (ALU_control, Result1, Reset, HI, LO)
	begin
		Control <= "100000";
		ALU_out <= (others=>'0');
		case ALU_Control(7 downto 6) is
		when "00" => -- lw, sw, addi
			Control <= "000011";
			ALU_out <= Result1;
		when "01" => --Branch
			case ALU_Control(5 downto 0) is
			--when "000100" => --BEQ
			--	Control <= "001000";
			--when "000001" => --BGEZ, BGEZAL
			--	Control <= "000111";
		when others => NULL;
		end case;
		when "10" =>
			case ALU_Control(5 downto 0) is
			when "100000"=> --add
				Control <= "000011";
				ALU_out <= Result1;
			when "100010"=> --sub
				Control <= "001000";
				ALU_out <= Result1;
			when "100100"=> --and
				Control <= "000000";
				ALU_out <= Result1;
			when "100101"=> --or
				Control <= "000001";
				ALU_out <= Result1;
			when "100111"=> --nor
				Control <= "001100";
				ALU_out <= Result1;
			when "101010"=> --slt
				Control <= "000111";
				ALU_out <= Result1;
			when "101011" => --sltu
				Control <= "001110";
				ALU_out <= Result1;
			when "000000" => --SLL
				Control <= "000101";
				ALU_out <= Result1;
			when "000100" => --SLLV
				Control <= "010101";
				ALU_out <= Result1;
			when "000010" => --SRL
				Control <= "001101";
				ALU_out <= Result1;	
			when "000011" => --SRA	
				Control <= "001001";
				ALU_out <= Result1;
			when "011000" => --MULT
				Control <= "010000";
			when "011001" => --MULTU
				Control <= "010001";
			when "011010" => --DIV
				Control <= "010011";
			when "011011" => --DIVU
				Control <= "010010";
			when "010000" => --MFHI
				ALU_out <= HI;
			when "010010" => --MFLO
				ALU_out <= LO;
			when "001000" => --JR
				Control <= "000010";
				ALU_out <=Result1;
			when others =>	null;
			end case;
		when "11" => -- ori
				Control <= "000001";
				ALU_out <= Result1;
		when others => NULL;
		end case;
		if (Reset = '1') then
			Control <= "100000";
		end if;		
	end process;
	
	process (CLK)
	begin
--		if (CLK'event and CLK='1') then
--			StatPrev <= Status(2);
--			StatPrevPrev <= StatPrev;
--			if (StatPrev = '1' and Status(2) = '0') then
--				HI <= Result2;
--				LO <= Result1;
--			end if;
--		end if;	
		if (CLK'event and CLK='0') then
			StatPrev <= Status(2);
			StatPrevPrev <= StatPrev;
			if (StatPrev = '1' and Status(2) = '0') then
				HI <= Result2;
				LO <= Result1;
			end if;
		end if;		
	end process;
end Behavioral;