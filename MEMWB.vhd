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

entity MEMWB is
	Port( CLK : IN STD_LOGIC;
			BUSY : IN STD_LOGIC;
			ALU_Out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			ALU_Out_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			MemtoReg_out_out_in 	: in  STD_LOGIC;	
			MemtoReg_out_out_out 	: out  STD_LOGIC;
			RegWrite_out_out_in : in STD_LOGIC;
			RegWrite_out_out_out : out STD_LOGIC;
			Jump_out_out_in : in STD_LOGIC;
			Jump_out_out_out : out STD_LOGIC;
			link_out_in : in STD_LOGIC_VECTOR(1 downto 0);
			link_out_out : out STD_LOGIC_VECTOR(1 downto 0);
			Shift16_out_out_in      : in STD_LOGIC;
			Shift16_out_out_out     : out STD_LOGIC;
			Data_in_in : in STD_LOGIC_VECTOR(31 downto 0);
			Data_in_out : out STD_LOGIC_VECTOR(31 downto 0);
			MemMapFlag_in : in STD_LOGIC;
			MemMapFlag_out : out STD_LOGIC;
			MemRegFlag_in : in STD_LOGIC_VECTOR(1 downto 0);
			MemRegFlag_out : out STD_LOGIC_VECTOR(1 downto 0);
			PC_val_out_out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_out_out_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			extension_out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			extension_out_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_out_out_in : in STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_out_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			RegWriteAddr_out_in  : in STD_LOGIC_VECTOR (4 downto 0); 
			RegWriteAddr_out_out  : out STD_LOGIC_VECTOR (4 downto 0)); 	
end MEMWB;

architecture arch_MEMWB of MEMWB is
begin
	process(CLK, BUSY)
	begin
		if (CLK'event and CLK='1' and BUSY='0') then
			ALU_Out_out_out <= ALU_Out_out_in;
			MemtoReg_out_out_out <= MemtoReg_out_out_in;
			RegWrite_out_out_out <= RegWrite_out_out_in;
			RegWriteAddr_out_out <= RegWriteAddr_out_in;
			Jump_out_out_out <= Jump_out_out_in;
			link_out_out <= link_out_in;
			Shift16_out_out_out  <= Shift16_out_out_in;
			Data_in_out <= Data_in_in;
			MemMapFlag_out<=MemMapFlag_in;
			MemRegFlag_out <= MemRegFlag_in;
			PC_val_out_out_out_out <= PC_val_out_out_out_in;
			extension_out_out_out <= extension_out_out_in;
			Instr_out_out_out_out <= Instr_out_out_out_in;
		end if;
	end process;
end arch_MEMWB;
			