----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
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

entity IDEX is
	Port (CLK : in STD_LOGIC;
			BUSY     : in STD_LOGIC;	
			Reg1_in : in STD_LOGIC_VECTOR(31 downto 0);
			Reg2_in : in STD_LOGIC_VECTOR(31 downto 0);
			Reg1_out : out STD_LOGIC_VECTOR(31 downto 0);
			Reg2_out : out STD_LOGIC_VECTOR(31 downto 0);
			Reset_in : in STD_LOGIC;
			Reset_out : out STD_LOGIC;
			ALUOp_in : in STD_LOGIC_VECTOR(1 downto 0);
			ALUOp_out : out STD_LOGIC_VECTOR(1 downto 0);
			Branch_in : in STD_LOGIC;
			Branch_out : out STD_LOGIC;
			Jump_in	 : in  STD_LOGIC;
			Jump_out	 : out  STD_LOGIC;
			JumpReg_in     : in  STD_LOGIC;
			JumpReg_out     : out  STD_LOGIC;
			LinkFlag_in		 : in STD_LOGIC;
			LinkFlag_out	 : out STD_LOGIC;
			JumpLink_in		 : in STD_LOGIC;
			JumpLink_out	 : out STD_LOGIC;
			Shift16_in      : in STD_LOGIC;
			Shift16_out     : out STD_LOGIC;
			ShiftFlag_in    : in STD_LOGIC;
			ShiftFlag_out   : out STD_LOGIC;
			MemRead1_in 		: in  STD_LOGIC;	
			MemRead1_out		: out  STD_LOGIC;	
			MemtoReg_in 	: in  STD_LOGIC;	
			MemtoReg_out 	: out  STD_LOGIC;	
			ALUSrc_in 		: in  STD_LOGIC;	
			ALUSrc_out 		: out  STD_LOGIC;	
			MemWrite1_in		: in  STD_LOGIC;	
			MemWrite1_out		: out  STD_LOGIC;	
			RegDst_in		: in  STD_LOGIC;
			RegDst_out		: out  STD_LOGIC;
			RegWrite_in		: in  STD_LOGIC;		
			RegWrite_out		: out  STD_LOGIC;
			PC_val_out_in   : in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			sll1_in : in STD_LOGIC_VECTOR(31 downto 0);
			sll1_out : out STD_LOGIC_VECTOR(31 downto 0);
			extension_in : in STD_LOGIC_VECTOR(31 downto 0);
			extension_out : out STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_out : out STD_LOGIC_VECTOR(31 downto 0));
end IDEX;

architecture IDEX_arch of IDEX is
begin
	process (CLK, BUSY)
	begin
		if (CLK'event and CLK='1' and BUSY = '0') then
			Reg1_out <= Reg1_in;
			Reg2_out <= Reg2_in;
			Reset_out <= Reset_in;
			ALUOp_out <= ALUOp_in;
			Branch_out <= Branch_in;
			Jump_out <= Jump_in;
			LinkFlag_out <= LinkFlag_in;
			JumpReg_out <= JumpReg_in;
			JumpLink_out <= JumpLink_in;
			Shift16_out <= Shift16_in;
			ShiftFlag_out <= ShiftFlag_in;
			MemRead1_out <= MemRead1_in;
			MemtoReg_out <= MemtoReg_in;
			ALUSrc_out <= ALUSrc_in;
			MemWrite1_out <= MemWrite1_in;
			RegDst_out <= RegDst_in;
			RegWrite_out <= RegWrite_in;
			PC_val_out_out <= PC_val_out_in;
			sll1_out <= sll1_in;
			extension_out <= extension_in;
			Instr_out_out <= Instr_out_in;
		end if;
	end process;
end IDEX_arch;
