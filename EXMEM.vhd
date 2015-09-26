----------------------------------------------------------------------------------
-- Engineer:Ankur Gupta
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	PC
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: PC for the basic MIPS processor
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

entity EXMEM is
	Port(	CLK : in STD_LOGIC;
			Busy : in STD_LOGIC;
			ALU_zero_in : in STD_LOGIC;
			ALU_zero_out : out STD_LOGIC;
			ALU_Out_in : in STD_LOGIC_VECTOR(31 downto 0);
			ALU_Out_out : out STD_LOGIC_VECTOR(31 downto 0);
			S_in : in STD_LOGIC_VECTOR(31 downto 0);
			S_out : out STD_LOGIC_VECTOR(31 downto 0);
			Branch_out_in : in STD_LOGIC;
			Branch_out_out : out STD_LOGIC;
			Jump_out_in : in STD_LOGIC;
			Jump_out_out : out STD_LOGIC;
			JumpLink_out_in : in STD_LOGIC;
			JumpLink_out_out : out STD_LOGIC;
			LinkFlag_out_in : in STD_LOGIC;
			LinkFlag_out_out : out STD_LOGIC;
			extension_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			extension_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			Reg2_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			Reg2_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			MemRead1_out_in 		: in  STD_LOGIC;	
			MemRead1_out_out		: out  STD_LOGIC;	
			MemtoReg_out_in 	: in  STD_LOGIC;	
			MemtoReg_out_out 	: out  STD_LOGIC;
			MemWrite1_out_in		: in  STD_LOGIC;	
			MemWrite1_out_out		: out  STD_LOGIC;	
			RegWriteAddr_in  : in STD_LOGIC_VECTOR (4 downto 0); 
			RegWriteAddr_out  : out STD_LOGIC_VECTOR (4 downto 0); 
			RegWrite_out_in		: in  STD_LOGIC;		
			RegWrite_out_out		: out  STD_LOGIC;
			sll1_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			sll1_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			link_in : in STD_LOGIC_VECTOR(1 downto 0);
			link_out : out STD_LOGIC_VECTOR(1 downto 0);
			Shift16_out_in      : in STD_LOGIC;
			Shift16_out_out     : out STD_LOGIC;
			ShiftFlag_out_in      : in STD_LOGIC;
			ShiftFlag_out_out     : out STD_LOGIC;	
			ALUSrc_out_in 		: in  STD_LOGIC;	
			ALUSrc_out_out 		: out  STD_LOGIC;				
			PC_val_out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_out_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			MFHItoDATAOUT : in STD_LOGIC;
			MFHItoDATAOUT_out : out STD_LOGIC;
			Instr_out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_out_out : out STD_LOGIC_VECTOR(31 downto 0));
end EXMEM;

architecture arch_EXMEM of EXMEM is
begin
	process(CLK, BUSY)
	begin
		if (CLK'event and CLK='1' and BUSY = '0') then
			ALU_zero_out <= ALU_zero_in;
			ALU_Out_out <= ALU_Out_in;
			S_out <= S_in;
			Branch_out_out <= Branch_out_in;
			Jump_out_out <= Jump_out_in;
			JumpLink_out_out <= JumpLink_out_in;
			LinkFlag_out_out <= LinkFlag_out_in;
			extension_out_out <= extension_out_in;
			Reg2_out_out <= Reg2_out_in;
			MemRead1_out_out <= MemRead1_out_in;
			MemtoReg_out_out <= MemtoReg_out_in;
			MemWrite1_out_out	<= MemWrite1_out_in;
			RegWriteAddr_out <= RegWriteAddr_in;
			RegWrite_out_out <= RegWrite_out_in;
			sll1_out_out <= sll1_out_in;
			link_out <= link_in;
			Shift16_out_out <= Shift16_out_in;
			ShiftFlag_out_out <= ShiftFlag_out_in;			
			PC_val_out_out_out <= PC_val_out_out_in;
			Instr_out_out_out <= Instr_out_out_in;
			MFHItoDATAOUT_out <= MFHItoDATAOUT;
		end if;
	end process;
end arch_EXMEM;