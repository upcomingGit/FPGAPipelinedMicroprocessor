----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	TOP (MIPS Wrapper)
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Top level module - wrapper for MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: See the notes below. The interface (entity) as well as implementation (architecture) can be modified
--
----------------------------------------------------------------------------------


----------------------------------------------------------------
-- NOTE : 
----------------------------------------------------------------

-- Instruction and data memory are WORD addressable (NOT byte addressable). 
-- Each can store 256 WORDs. 
-- Address Range of Instruction Memory is 0x00400000 to 0x004003FC (word addressable - only multiples of 4 are valid). This will cause warnings about 2 unused bits, but that's ok.
-- Address Range of Data Memory is 0x10010000 to 0x100103FC (word addressable - only multiples of 4 are valid).
-- LED <7> downto <0> is mapped to the word address 0x10020000. Only the least significant 8 bits written to this location are used.
-- DIP switches are mapped to the word address 0x10030000. Only the least significant 16 bits read from this location are valid.
-- You can change the above addresses to some other convenient value for simulation, and change it to their original values for synthesis / FPGA testing.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

----------------------------------------------------------------
-- TOP level module interface
----------------------------------------------------------------

entity TOP is
		Port (
			DIP 				: in  STD_LOGIC_VECTOR (15 downto 0);  -- DIP switch inputs. Not debounced.
			LED 				: out  STD_LOGIC_VECTOR (15 downto 0); -- LEDs
			-- <15> showing the divided clock, 
			-- <14> downto <8> showing Addr_Instr(22) & Addr_Instr(7 downto 2), 
			-- <7> downto <0> mapped to the address 0x10020000.
			RESET				: in  STD_LOGIC; 	-- Reset -> BTNC (Centre push button)
			CLK_undiv		: in  STD_LOGIC); -- 100MHz clock. Converted to a lower frequency using CLK_DIV_PROCESS before use.
end TOP;


architecture arch_TOP of TOP is

----------------------------------------------------------------
-- Constants
----------------------------------------------------------------
constant CLK_DIV_BITS	: integer := 25; --25 for a clock of the order of 1Hz
constant N_LEDs			: integer := 8;
constant N_DIPs			: integer := 16;

----------------------------------------------------------------
-- MIPS component declaration
----------------------------------------------------------------
component mips is
    Port ( 	
			Addr_Instr 		: out STD_LOGIC_VECTOR (31 downto 0); 	-- Input to instruction memory (normally comes from the output of PC)
			Instr 			: in STD_LOGIC_VECTOR (31 downto 0);  	-- Output from the instruction memory
			Addr_Data		: out STD_LOGIC_VECTOR (31 downto 0); 	-- Address sent to data memory / memory-mapped peripherals
			Data_In			: in STD_LOGIC_VECTOR (31 downto 0);  	-- Data read from data memory / memory-mapped peripherals
			Data_Out			: out  STD_LOGIC_VECTOR (31 downto 0); -- Data to be written to data memory / memory-mapped peripherals 
			MemRead 			: out STD_LOGIC; 	-- MemRead signal to data memory / memory-mapped peripherals 
			MemWrite 		: out STD_LOGIC; 	-- MemWrite signal to data memory / memory-mapped peripherals 
			RESET				: in STD_LOGIC; 	-- Reset signal for the processor. Should reset ALU and PC. Resetting general purpose registers is not essential (though it could be done).
			CLK				: in STD_LOGIC 	-- Divided (lower frequnency) clock for the processor.
			);
end component mips;

----------------------------------------------------------------
-- MIPS signals
----------------------------------------------------------------
signal Addr_Instr 	: STD_LOGIC_VECTOR (31 downto 0);
signal Instr 			: STD_LOGIC_VECTOR (31 downto 0);
signal Data_In			: STD_LOGIC_VECTOR (31 downto 0);
signal Addr_Data		: STD_LOGIC_VECTOR (31 downto 0);
signal Data_Out		: STD_LOGIC_VECTOR (31 downto 0);
signal MemRead 		: STD_LOGIC; 
signal MemWrite 		: STD_LOGIC; 

----------------------------------------------------------------
-- Others signals
----------------------------------------------------------------
signal dec_DATA_MEM, dec_LED, dec_DIP : std_logic;  -- data memory address decoding
signal DIP_debounced : STD_LOGIC_VECTOR (15 downto 0):=(others=>'0'); -- DIP switch debouncing
signal CLK : std_logic; --divided (low freq) clock

----------------------------------------------------------------
-- Memory type declaration
----------------------------------------------------------------
type MEM_256x32 is array (0 to 255) of std_logic_vector (31 downto 0); -- 256 words

----------------------------------------------------------------
-- Instruction Memory
----------------------------------------------------------------
constant INSTR_MEM : MEM_256x32 := (
-------------------------------------------------------
--Blinky Version 3 (Working)
--			x"3c090000", -- start : lui $t1, 0x0000 # constant 1 upper half word. not required if GPRs are reset when RESET is pressed
--			x"35290001", -- 			ori $t1, 0x0001 # constant 1 lower half word
--			x"3c081002", -- 			lui $t0, 0x1002 # DIP address upper half word before offset
--			x"35088001", --			ori $t0, 0x8001 # DIP address lower half word before offset
--			x"8d0c7fff", --			lw  $t4, 0x7fff($t0) # read from DIP address 0x10030000 = 0x10028001 + 0x7fff
--			x"3c081002", --			lui $t0, 0x1002 # LED address upper half word before offset
--			x"35080001", --			ori $t0, 0x0001 # LED address lower half word before offset
--			x"3400ffff", --			ori $zero, 0xffff # writing to zero. should have no effect
--			x"3c0a0000", -- loop: 	lui $t2, 0x0000 # delay counter (n) upper half word if using slow clock
--			x"354a0004", -- 			ori $t2, 0x0004 # delay counter (n) lower half word if using slow clock
--			-- x"3c0a00ff",-- 			#lui $t2, 0x00ff # delay counter (n) upper half word if using fast clock		
--			-- x"354affff",-- 			#ori $t2, 0xffff # delay counter (n) lower half word if using fast clock
--			x"01495022", -- delay: 	sub $t2, $t2, $t1 # begining of delay loop
--			x"0149582a", -- 			slt $t3, $t2, $t1
--			x"1160fffd", -- 			beq $t3, $zero, delay # end of delay loop
--			x"ad0cffff", -- 			sw  $t4, 0xffffffff($t0)	# write to LED address 0x10020000 = 0x10020001 + 0xffffffff.
--			x"01806027", --			nor $t4, $t4, $zero # flip the bits
--			x"08100008", -- 			j loop # infinite loop; # repeats every n*3 (delay instructions) + 5 (non-delay instructions).
-------------------------------------------------------------
--Random Instructions (For Lab 3b) (Working)
--			x"3c09fefe", --lui $t1, 0xfefe
--			x"3529cdcd", --ori $t1, 0xcdcd
--			x"3c081000", --lui $t0, 0x1000
--			x"35088001", --ori $t0, 0x8001
--			x"3c0e1002", --lui $t6, 0x1002
--			x"35ce0001", --ori $t6, 0x0001
--			x"8d0c7fff", --lw  $t4, 0x7fff($t0)
--			x"3c081002", --lui $t0, 0x1002
--			x"35080001", --ori $t0, 0x0001
--			x"3c0f0040", --lui $t7 0x0040
--			x"35ef004c", --ori $t7, 0x004c
--			x"01890018", --mult $t4, $t1
--			x"00005010", --mfhi $t2
--			x"00005812", --mflo $t3
--			x"adcbffff", --sw $t3, 0xffffffff($t6)
--			x"01495024", --and $t2, $t2, $t1
--			x"01495025", --or $t2, $t2, $t1
--			x"3c180000", --lui $t8 0x0000
--			x"371800ff", --ori $t8, 0x00ff
--			x"8d0c7fff", --loop: lw  $t4, 0x7fff($t0)
--			x"018a6822", --sub $t5, $t4, $t2
--			x"11a00001", --beq $t5, $zero, out
--			x"2318ffff", --add $t8, $t8, -1
--			x"13000001", --beq $t8, $zero, out
--			x"01e00008", --jr $t7
--			x"adc9ffff", --out: sw $t1, 0xffffffff($t6)
--			x"00094900", --sll $t1, $t1, 4
--			x"adc9ffff", --sw $t1, 0xffffffff($t6)
--			x"00094902", --srl $t1, $t1, 4
--			x"adc9ffff", --sw $t1, 0xffffffff($t6)
--			x"00094a00", --sll $t1, $t1, 8
--			x"adc9ffff", --sw $t1, 0xffffffff($t6)
--			x"00094a02", --srl $t1, $t1, 8
--			x"adc9ffff", --sw $t1, 0xffffffff($t6)
-------------------------------------------------------------
--Final Program ->Guessing game + dancing LEDs
			x"3c110040", --lui $17,0x00000040  
			x"36310000", --ori $17,$17,0x000000002    
			x"3c081002", --lui $8,0x00001002
			x"35088001", --ori $8,$8,0x00008001  
			x"3c091002", --lui $9,0x00001002
			x"35290001", --ori $9,$9,0x00000001
			x"8d0a7fff", --lw $10,0x00007fff($8)
			x"3c0b1001", --lui $11,0x00001001
			x"356b0000", --ori $11,$11,0x000000009
			x"016a5820", --add $11,$11,$10
			x"8d6c0000", --lw $12,0x00000000($11)
			x"3c0dfefe", --lui $13,0x0000fefe
			x"35adcdcd", --ori $13,$13,0x0000cdcd
			x"01ac0018", --mult $13,$12 
			x"00007010", --mfhi $14  
			x"00007812", --mflo $15
			x"01cf7024", --and $14,$14,$15   
			x"01cf7025", --or $14,$14,$15   
			x"3c180000", --lui $24,0x00000000 
			x"37180004", --ori $24,$24,0x00000004
			x"030e7004", --sllv $14,$14,$24  
			x"21ce000e", --addi $14,$14,0x0000000
			x"3c0f0000", --lui $15,0x00000000   
			x"35ef000f", --ori $15,$15,0x0000000f
			x"01cf7024", --and $14,$14,$15 
			x"3c18ffff", --lui $24,0x0000ffff    
			x"3718fff1", --ori $24,$24,0x0000fff1
			x"8d197fff", --lw $25,0x00007fff($8) 
			x"ad39ffff", --sw $t9, 0xffffffff($t1)
			x"ad38ffff", --sw $t8, 0xffffffff($t1)			
			x"032fc824", --and $25,$25,$15
			x"132e0003", --beq $25,$14,0x00000003
			x"23180001", --addi $24,$24,0x0000000
			x"0711001d", --bgezal $24,0x0000001d
			x"0c10001b", --jal 0x0040006c
			x"3c100000", --lui $16,0x00000000
			x"361000ff", --ori $16,$16,0x000000ff
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108100", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108103", --sra $16,$16,0x00000004
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"00108102", --srl $16,$16,0x00000004
			x"ad30ffff", --sw $16,0xffffffff($9)
			x"02200008", --jr $17  
			x"3c100000", --lui $16,0x00000000
			x"361000aa", --ori $16,$16,0x000000aa
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108080", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108083", --sra $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108082", --srl $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108100", --sll $16,$16,0x00000002
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108103", --sra $16,$16,0x00000004
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"00108102", --srl $16,$16,0x00000004
			x"ad30ffff", --sw $16,0xffffffff($9) 
			x"02200008", --jr $17
			others=> x"00000000");
-- The Blinky program reads the DIP switches in the begining. Let the value read be VAL
-- It will then keep alternating between VAL(7 downto 0) , not(VAL(7 downto 0)), 
-- essentially blinking LED(7 downto 0) according to the initial pattern read from the DIP switches 	

----------------------------------------------------------------
-- Data Memory
----------------------------------------------------------------
--signal DATA_MEM : MEM_256x32 := (others=> x"00000000");
signal DATA_MEM : MEM_256x32 := (
	-- blk 0
	x"deeddeed",
	x"abdbabdb",
	x"12341232",
	x"12332457",

	-- blk 1
	x"54623563",
	x"34523452",
	x"12341245",
	x"35464675",
	-- blk 2
	x"56675776",
	x"67674565",
	x"34534535",
	x"77688667",
	-- blk 3
	x"23434234",
	x"34534543",
	x"43543534",
	x"35345345",
	-- blk 4
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	-- blk 5
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	-- blk 6
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	-- blk 7
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	
	others => x"00000000");

----------------------------------------------------------------	
----------------------------------------------------------------
-- <Wrapper architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
		
begin

----------------------------------------------------------------
-- MIPS port map
----------------------------------------------------------------
MIPS1 : MIPS port map ( 
			Addr_Instr 		=>  Addr_Instr,
			Instr 			=>  Instr, 		
			Data_In			=>  Data_In,	
			Addr_Data		=>  Addr_Data,		
			Data_Out			=>  Data_Out,	
			MemRead 			=>  MemRead,		
			MemWrite 		=>  MemWrite,
			RESET				=>	 RESET,
			CLK				=>  CLK				
			);

----------------------------------------------------------------
-- Data memory address decoding
----------------------------------------------------------------
dec_DATA_MEM <= '1' 	when Addr_Data>=x"10010000" and Addr_Data<=x"100103FC" else '0'; --assuming 256 word memory
dec_LED 		<= '1'	when Addr_Data=x"10020000" else '0';
dec_DIP 		<= '1' 	when Addr_Data=x"10030000" else '0';

----------------------------------------------------------------
-- Data memory read
----------------------------------------------------------------
Data_In 	<= (N_DIPs-1 downto 0 => '0') & DIP	when MemRead = '1' and dec_DIP = '1' 
				else DATA_MEM(conv_integer(Addr_Data(9 downto 2)))	when MemRead = '1' and dec_DATA_MEM = '1'
				else (others=>'0');
				
----------------------------------------------------------------
-- Instruction memory read
----------------------------------------------------------------
Instr <= INSTR_MEM(conv_integer(Addr_Instr(9 downto 2))) 
			when ( Addr_Instr(31 downto 10) & Addr_Instr(1 downto 0) )=x"004000" -- To check if address is in the valid range. Also helps minimize warnings
			else x"00000000";

----------------------------------------------------------------
-- Debug LEDs
----------------------------------------------------------------			
--LED(13 downto 8) <= Addr_Instr(22) & Addr_Instr(7 downto 2); -- debug showing PC
LED(15) <= CLK; -- debug showing clock
LED(10 downto 8) <= "000";

----------------------------------------------------------------
-- Data Memory-mapped LED write
----------------------------------------------------------------
write_LED: process (CLK)
begin
	if (CLK'event and CLK = '1') then
				LED(14 downto 11) <= "0000"; 
				case ADDR_INSTR(8 downto 0) is
				when "000111000" | "000111100" => --Busy LED
					LED(13) <= '1';
				when "000000000" => --Program Restart LED
					LED(14) <= '1';
				when "001111100" | "010000100" | "010001000" => --Branching LED
					LED(12) <= '1';
				when "010001100" | "101101000" => --Jumping LED
					LED(11) <= '1';
				when others=> NULL;
				end case;
		if (MemWrite = '1') and  (dec_LED = '1') then
            LED(7 downto 4) <= Data_Out(3 downto 0); --Counter LED
				if (ADDR_INSTR(8 downto 0) = "001111100") then
					LED (3 downto 0) <= Data_Out(3 downto 0); --User Input LED
				end if;
				if (ADDR_INSTR(8) = '1' or (ADDR_INSTR(7) = '1' and (ADDR_INSTR(6) = '1' or ADDR_INSTR(5) = '1' or ADDR_INSTR(4) = '1'))) then
					LED(7 downto 0) <= Data_Out(7 downto 0); --LED to display the dancing LEDs
				end if;
		end if;
	end if;
end process;

----------------------------------------------------------------
-- Data Memory write
----------------------------------------------------------------
write_DATA_MEM: process (CLK)
begin
    if (CLK'event and CLK = '1') then
        if (MemWrite = '1' and dec_DATA_MEM = '1') then
            DATA_MEM(conv_integer(Addr_Data(9 downto 2))) <= Data_Out;
        end if;
    end if;
end process;

----------------------------------------------------------------
-- Clock divider
----------------------------------------------------------------

----------------------------------------------------------------
-- <DEPLOYMENT: REMOVE IN DEVELOPMENT>
----------------------------------------

--CLK_DIV_PROCESS : process(CLK_undiv)
--variable clk_counter : std_logic_vector(CLK_DIV_BITS downto 0) := (others => '0');
--begin
--	if CLK_undiv'event and CLK_undiv = '1' then
--		clk_counter := clk_counter+1;
--		CLK <= clk_counter(CLK_DIV_BITS);
--	end if;
--end process;

---------------------------------------
-- </DEPLOYMENT: REMOVE IN DEVELOPMENT>
----------------------------------------------------------------




----------------------------------------------------------------
-- <DEVELOPMENT: REMOVE IN DEPLOYMENT>
---------------------------------------
clk <= clk_undiv;
---------------------------------------
-- </DEVELOPMENT: REMOVE IN DEPLOYMENT>
----------------------------------------------------------------

end arch_TOP;



----------------------------------------------------------------	
----------------------------------------------------------------
-- </Wrapper architecture>
----------------------------------------------------------------
----------------------------------------------------------------	



----------------------------------------------------------------
-- Blinky Program
----------------------------------------------------------------
--ori $t1, 0x0001 # constant 1
--#lui $t0, 0x1001 # DIP pointer, for MIPS simulation
--lui $t0, 0x1003 # DIP pointer, for VHDL
--lw  $t4, 0($t0)
--lui $t0, 0x1002 # LED pointer, for VHDL
--loop:
--lui $t2, 0x0000
--ori $t2, 0x0004 # delay counter (n). Change according to the clock
--delay:
--sub $t2, $t2, $t1 
--slt $t3, $t2, $t1
--beq $t3, $zero, delay
--sw  $t4, 0($t0)
--nor $t4, $t4, $zero
--j loop
--# n*3 (delay instructions) + 5 (non-delay instructions).