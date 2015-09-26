----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	ControlUnit
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Control Unit for the basic MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The interface (entity) as well as implementation (architecture) can be modified
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ControlUnit is
    Port ( 	opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
				opcode2     : in   STD_LOGIC_VECTOR (5 downto 0);
				ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
				Branch 		: out  STD_LOGIC;		
				Jump	 		: out  STD_LOGIC;
				JumpReg     : out  STD_LOGIC;
				JumpLink		: out  STD_LOGIC;
				MemRead 		: out  STD_LOGIC;	
				MemtoReg 	: out  STD_LOGIC;	
				Shift16		: out  STD_LOGIC;
				ShiftFlag   : out  STD_LOGIC;
				MemWrite		: out  STD_LOGIC;
				ALUSrc 		: out  STD_LOGIC;	
				SignExtend 	: out  STD_LOGIC;
				RegWrite		: out  STD_LOGIC;	
				RegDst		: out  STD_LOGIC);
end ControlUnit;


architecture arch_ControlUnit of ControlUnit is  
begin   
	process (opcode, opcode2)
	begin
		ALUOp <= "00";
		Branch <= '0';		
		Jump <= '0';
		JumpReg <= '0';
		JumpLink <= '0';
		MemRead <= '0';	
		MemtoReg <= '0';	
		Shift16 <= '0';
		ShiftFlag <= '0';
		MemWrite <= '0';	
		ALUSrc <= '0';	
		SignExtend <= '0';
		RegWrite <='0';	
		RegDst <='0';
		
		case (opcode) is
		when "000000" => --R-Type instructions
			ALUOp <= "10";
			RegWrite <= '1';
			RegDst <= '1';
			case opcode2 is
			when "000000" | "000010" | "000011" => --SLL, SRL, SRA
				ShiftFlag <= '1';
				ALUSrc <= '1';
			when "000100" => --SLLV
				ShiftFlag <= '1';
			when "001000" => --JR
				RegWrite <= '0';
				JumpReg <= '1';
			when others => NULL;
			end case;
		when "100011" => --LW
			ALUOp <= "00";
			MemRead <= '1';
			MemtoReg <= '1';
			ALUSrc <= '1';
			SignExtend <= '1';
			RegWrite <= '1';
		when "101011" => --SW
			ALUOp <= "00";
			MemWrite <= '1';
			ALUSrc <= '1';
			SignExtend <= '1';
		when "001111" => --LUI
			ALUOp <= "11";
			ALUSrc <= '1';
			RegWrite <= '1';
			Shift16 <= '1';
		when "001101" => --ORI
			ALUOp <= "11";
			ALUSrc <= '1';
			RegWrite <= '1';
		when "000100" => 	--BEQ
			ALUOp <= "01";
			Branch <= '1';
		--NEWLY ADDED--
		when "000001" => --BGEZ, BGEZAL
			ALUOp <= "01";
			Branch <= '1';
			ShiftFlag <= '1';
			RegWrite <= '1';
		--NEWLY ADDED--			
		when "000010" => --Jump
			ALUOp <= "00";
			Jump <= '1';
		when "000011" => --JAL
			ALUOp <= "00";
			Jump <= '1';
			RegWrite <= '1';
			JumpLink <= '1';
		--NEWLY ADDED--			
		when "001000" => --ADDI
			ALUOp <= "00";
			ALUSrc <= '1';
			RegWrite <= '1';
			SignExtend <= '1';			
		when others => NULL;
		end case;
	end process;
end arch_ControlUnit;