----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	MIPS
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: MIPS processor
--
-- Dependencies: PC, ALU, ControlUnit, RegFile
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: DO NOT modify the interface (entity). Implementation (architecture) can be modified.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;			

entity MIPS is -- DO NOT modify the interface (entity)
    Port ( 	
			Addr_Instr 		: out STD_LOGIC_VECTOR (31 downto 0);
			Instr 			: in STD_LOGIC_VECTOR (31 downto 0);
			Addr_Data		: out STD_LOGIC_VECTOR (31 downto 0); ----EX/MEM->MEM/WB
			Data_In			: in STD_LOGIC_VECTOR (31 downto 0);
			Data_Out			: out  STD_LOGIC_VECTOR (31 downto 0);
			MemRead 			: out STD_LOGIC; 
			MemWrite 		: out STD_LOGIC; 
			RESET				: in STD_LOGIC;
			CLK				: in STD_LOGIC);

end MIPS;


architecture arch_MIPS of MIPS is

----------------------------------------------------------------
-- Program Counter Register
----------------------------------------------------------------
component PC is
	Port(	
			PC_in 	: in STD_LOGIC_VECTOR (31 downto 0);
			PC_out 	: out STD_LOGIC_VECTOR (31 downto 0);
			PC_ENABLE: in STD_LOGIC;
			RESET		: in STD_LOGIC;
			BUSY     : in STD_LOGIC;
			CLK		: in STD_LOGIC);
end component;

----------------------------------------------------------------
-- IF/ID Register
----------------------------------------------------------------
component IFID is
	Port (CLK 			: in STD_LOGIC;
			Instr_in 	: in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_in 	: in STD_LOGIC_VECTOR(31 downto 0);
			Busy      	: in STD_LOGIC;
			IFID_Enable : in STD_LOGIC;
			Jump			: in STD_LOGIC;
			Branch 		: in STD_LOGIC;
			JumpReg 		: in STD_LOGIC;
			JumpReg_out : in STD_LOGIC;
			PC_val_out 	: out STD_LOGIC_VECTOR(31 downto 0);
			Instr_out 	: out STD_LOGIC_VECTOR(31 downto 0));
end component;

----------------------------------------------------------------
-- ID/EX Register
----------------------------------------------------------------
component IDEX is
	Port (CLK 				: in STD_LOGIC;
			BUSY				: in STD_LOGIC;
			Reg1_in 			: in STD_LOGIC_VECTOR(31 downto 0);
			Reg2_in 			: in STD_LOGIC_VECTOR(31 downto 0);
			Reg1_out 		: out STD_LOGIC_VECTOR(31 downto 0);
			Reg2_out 		: out STD_LOGIC_VECTOR(31 downto 0);
			Reset_in 		: in STD_LOGIC;
			Reset_out 		: out STD_LOGIC;
			ALUOp_in 		: in STD_LOGIC_VECTOR(1 downto 0);
			ALUOp_out 		: out STD_LOGIC_VECTOR(1 downto 0);
			Branch_in 		: in STD_LOGIC;
			Branch_out 		: out STD_LOGIC;
			Jump_in	 		: in  STD_LOGIC;
			Jump_out	 		: out  STD_LOGIC;
			JumpReg_in     : in  STD_LOGIC;
			JumpReg_out    : out  STD_LOGIC;
			LinkFlag_in		 : in STD_LOGIC;
			LinkFlag_out	 : out STD_LOGIC;
			JumpLink_in		 : in STD_LOGIC;
			JumpLink_out	 : out STD_LOGIC;			
			Shift16_in     : in STD_LOGIC;
			Shift16_out    : out STD_LOGIC;
			ShiftFlag_in   : in STD_LOGIC;
			ShiftFlag_out  : out STD_LOGIC;
			MemRead1_in 	: in  STD_LOGIC;	
			MemRead1_out	: out  STD_LOGIC;	
			MemtoReg_in 	: in  STD_LOGIC;	
			MemtoReg_out 	: out  STD_LOGIC;	
			ALUSrc_in 		: in  STD_LOGIC;	
			ALUSrc_out 		: out  STD_LOGIC;	
			MemWrite1_in	: in  STD_LOGIC;	
			MemWrite1_out	: out  STD_LOGIC;	
			RegDst_in		: in  STD_LOGIC;
			RegDst_out		: out  STD_LOGIC;
			RegWrite_in		: in  STD_LOGIC;		
			RegWrite_out	: out  STD_LOGIC;
			PC_val_out_in  : in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_out_out : out STD_LOGIC_VECTOR(31 downto 0);
			sll1_in 			: in STD_LOGIC_VECTOR(31 downto 0);
			sll1_out 		: out STD_LOGIC_VECTOR(31 downto 0);
			extension_in 	: in STD_LOGIC_VECTOR(31 downto 0);
			extension_out 	: out STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_in 	: in STD_LOGIC_VECTOR(31 downto 0);
			Instr_out_out 	: out STD_LOGIC_VECTOR(31 downto 0));
end component;

----------------------------------------------------------------
-- EX/MEM Register
----------------------------------------------------------------
component EXMEM is
	Port(	CLK : in STD_LOGIC;
			BUSY : in STD_LOGIC;
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
end component;			

----------------------------------------------------------------
-- MEM/WB Register
----------------------------------------------------------------
component MEMWB is
	Port( CLK : IN STD_LOGIC;
			BUSY : in STD_LOGIC;
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
end component;

----------------------------------------------------------------
-- ALU
----------------------------------------------------------------
component NewALU is
    Port (
			CLK         : in  STD_LOGIC;
			ALU_InA 		: in  STD_LOGIC_VECTOR (31 downto 0);				
			ALU_InB 		: in  STD_LOGIC_VECTOR (31 downto 0);
			ALU_Out 		: out STD_LOGIC_VECTOR (31 downto 0);
			ALU_Control	: in  STD_LOGIC_VECTOR (7 downto 0);
			Reset       : in  STD_LOGIC;
			Busy        : out STD_LOGIC;
			ALU_zero		: out STD_LOGIC);
end component;

----------------------------------------------------------------
-- Adder
----------------------------------------------------------------
component adder is
	port (
			A 		: in STD_LOGIC_VECTOR(31 downto 0);
			B 		: in STD_LOGIC_VECTOR(31 downto 0);
			C_in 	: in STD_LOGIC;
			S 		: out STD_LOGIC_VECTOR(31 downto 0);
			C_out	: out STD_LOGIC);
end component;

----------------------------------------------------------------
-- Branch Comparator
----------------------------------------------------------------
component Comparator is
	Port (Input1 : in STD_LOGIC_VECTOR(31 downto 0);
			Input2 : in STD_LOGIC_VECTOR(31 downto 0);
			Link   : in STD_LOGIC_VECTOR(1 downto 0);
			Result : out STD_LOGIC);
end component;

----------------------------------------------------------------
-- Control Unit
----------------------------------------------------------------
component ControlUnit is
    Port ( 	
			opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
			opcode2     : in   STD_LOGIC_VECTOR (5 downto 0);
			ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
			Branch 		: out  STD_LOGIC;
			Jump	 		: out  STD_LOGIC;
			JumpReg     : out  STD_LOGIC;
			JumpLink		: out  STD_LOGIC;
			MemRead 		: out  STD_LOGIC;	
			MemtoReg 	: out  STD_LOGIC;	
			Shift16		: out  STD_LOGIC; -- true for LUI. When true, Instr(15 downto 0)&x"0000" is written to rt
			ShiftFlag   : out  STD_LOGIC; --True for SLL, SRL, SRA because of the different data input structure in the instruction
			MemWrite		: out  STD_LOGIC;	
			ALUSrc 		: out  STD_LOGIC;	
			SignExtend 	: out  STD_LOGIC; -- 
			RegWrite		: out  STD_LOGIC;	
			RegDst		: out  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Register File
----------------------------------------------------------------
component RegFile is
    Port ( 	
			ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
			ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
			WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
			WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
			RegWrite 		: in STD_LOGIC; 
			CLK 				: in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- PC Signals
----------------------------------------------------------------
	signal	PC_in 		:  STD_LOGIC_VECTOR (31 downto 0) := x"00400000";
	signal	PC_out 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal   PC_Enable   :  STD_LOGIC;

----------------------------------------------------------------
-- IF/ID Signals
----------------------------------------------------------------
	signal   Instr_out   :  STD_LOGIC_VECTOR (31 downto 0);
	signal   PC_val_out  :  STD_LOGIC_VECTOR (31 downto 0);
	signal   IFID_Enable :  STD_LOGIC;

----------------------------------------------------------------
-- ID/EX Signals
----------------------------------------------------------------	
	signal	Reg1_out : STD_LOGIC_VECTOR(31 downto 0);
	signal   Reg2_out : STD_LOGIC_VECTOR(31 downto 0);
	signal 	Reset_out : STD_LOGIC;
	signal	ALUOp_out : STD_LOGIC_VECTOR(1 downto 0);
	signal	Branch_out : STD_LOGIC;
	signal	Jump_out	 : STD_LOGIC;
	signal 	LinkFlag_out : STD_LOGIC;
	signal	JumpLink_out : STD_LOGIC;
	signal	JumpReg_out     : STD_LOGIC;
	signal   Shift16_out     : STD_LOGIC;
	signal   ShiftFlag_out     : STD_LOGIC;
	signal	MemRead1_out		: STD_LOGIC;	
	signal	MemtoReg_out 	: STD_LOGIC;	
	signal	ALUSrc_out 		: STD_LOGIC;	
	signal	MemWrite1_out		: STD_LOGIC;	
	signal	RegDst_out		: STD_LOGIC;
	signal	RegWrite_out		: STD_LOGIC;
	signal	PC_val_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal	sll1_out : STD_LOGIC_VECTOR(31 downto 0);
	signal	extension_out : STD_LOGIC_VECTOR(31 downto 0);
	signal	Instr_out_out : STD_LOGIC_VECTOR(31 downto 0);

----------------------------------------------------------------
-- EX/MEM Signals
----------------------------------------------------------------
	signal ALU_zero_out : STD_LOGIC;
	signal ALU_Out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal S_out : STD_LOGIC_VECTOR(31 downto 0);
	signal Branch_out_out : STD_LOGIC;
	signal Jump_out_out : STD_LOGIC;
	signal LinkFlag_out_out : STD_LOGIC;
	signal JumpLink_out_out : STD_LOGIC;	
	signal extension_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal Reg2_out_out  : STD_LOGIC_VECTOR(31 downto 0);	
	signal MemRead1_out_out		: STD_LOGIC;	
	signal MemtoReg_out_out 	: STD_LOGIC;
	signal MemWrite1_out_out		: STD_LOGIC;	
	signal RegWriteAddr_out  : STD_LOGIC_VECTOR (4 downto 0); 
	signal RegWrite_out_out		: STD_LOGIC;
	signal sll1_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal link_out : STD_LOGIC_VECTOR(1 downto 0);
	signal Shift16_out_out     : STD_LOGIC;
	signal ShiftFlag_out_out     : STD_LOGIC;	
	signal ALUSrc_out_out : STD_LOGIC;
	signal MFHItoDATAOUT_out : STD_LOGIC;
	signal PC_val_out_out_out :  STD_LOGIC_VECTOR(31 downto 0);
	signal Instr_out_out_out : STD_LOGIC_VECTOR(31 downto 0);
	
----------------------------------------------------------------
-- MEM/WB Signals
----------------------------------------------------------------
	signal ALU_Out_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal MemtoReg_out_out_out 	: STD_LOGIC;
	signal RegWrite_out_out_out : STD_LOGIC;	
	signal RegWriteAddr_out_out  : STD_LOGIC_VECTOR (4 downto 0);
	signal Jump_out_out_out : STD_LOGIC;
	signal link_out_out : STD_LOGIC_VECTOR(1 downto 0);
	signal Shift16_out_out_out : STD_LOGIC;
	signal Data_in_out : STD_LOGIC_VECTOR(31 downto 0);
	signal MemMapFlag_out : STD_LOGIC;
	signal MemRegFlag_out : STD_LOGIC_VECTOR(1 downto 0);
	signal PC_val_out_out_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal extension_out_out_out : STD_LOGIC_VECTOR(31 downto 0);
	signal Instr_out_out_out_out : STD_LOGIC_VECTOR(31 downto 0);
 
----------------------------------------------------------------
-- ALU Signals
----------------------------------------------------------------
	signal	ALU_InA 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_InB 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Out 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Control	:  STD_LOGIC_VECTOR (7 downto 0);
	signal   Busy        :  STD_LOGIC;
	signal	ALU_zero		:  STD_LOGIC;	
	
----------------------------------------------------------------
-- Adder Signals
----------------------------------------------------------------
	signal   A           :  STD_LOGIC_VECTOR (31 downto 0);
	signal   B           :  STD_LOGIC_VECTOR (31 downto 0);
	signal	C_in		   :  STD_LOGIC;
	signal   S           :  STD_LOGIC_VECTOR (31 downto 0);
	signal	C_out		   :  STD_LOGIC;	
	
----------------------------------------------------------------
-- BranchComparator Signals
----------------------------------------------------------------	
	signal	BranchInput1 : STD_LOGIC_VECTOR(31 downto 0);
	signal	BranchInput2 : STD_LOGIC_VECTOR(31 downto 0);
	signal	BranchLink   : STD_LOGIC_VECTOR(1 downto 0);
	signal	BranchResult : STD_LOGIC;

----------------------------------------------------------------
-- Hazard Detection Signals
----------------------------------------------------------------				
 	signal	opcode 		:  STD_LOGIC_VECTOR (5 downto 0);
	signal   opcode2     :  STD_LOGIC_VECTOR (5 downto 0);
	signal	ALUOp 		:  STD_LOGIC_VECTOR (1 downto 0);
	signal	Branch 		:  STD_LOGIC;
	signal	Jump	 		:  STD_LOGIC;
	signal   JumpReg     :  STD_LOGIC;
	signal   JumpLink    :  STD_LOGIC;
	signal	MemtoReg 	:  STD_LOGIC;
	signal 	Shift16		: 	STD_LOGIC;
	signal   ShiftFlag   :  STD_LOGIC;
	signal	ALUSrc 		:  STD_LOGIC;	
	signal	SignExtend 	: 	STD_LOGIC;
	signal	RegWrite		: 	STD_LOGIC;	
	signal	RegDst		:  STD_LOGIC;
	signal 	MemRead1    :  STD_LOGIC;
	signal   MemWrite1   :  STD_LOGIC;

----------------------------------------------------------------
-- Control Unit Signals
----------------------------------------------------------------	

	signal	ALUOp_CU 		:  STD_LOGIC_VECTOR (1 downto 0);
	signal	Branch_CU 		:  STD_LOGIC;
	signal	Jump_CU	 		:  STD_LOGIC;
	signal   JumpReg_CU     :  STD_LOGIC;
	signal   JumpLink_CU   :  STD_LOGIC;
	signal	MemtoReg_CU 	:  STD_LOGIC;
	signal 	Shift16_CU		: 	STD_LOGIC;
	signal   ShiftFlag_CU   :  STD_LOGIC;
	signal	ALUSrc_CU 		:  STD_LOGIC;	
	signal	SignExtend_CU 	: 	STD_LOGIC;
	signal	RegWrite_CU		: 	STD_LOGIC;	
	signal	RegDst_CU		:  STD_LOGIC;
	signal 	MemRead1_CU    :  STD_LOGIC;
	signal   MemWrite1_CU   :  STD_LOGIC;

----------------------------------------------------------------
-- Register File Signals
----------------------------------------------------------------
 	signal	ReadAddr1_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadAddr2_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadData1_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ReadData2_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	WriteAddr_Reg	:  STD_LOGIC_VECTOR (4 downto 0); 
	signal	WriteData_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);

----------------------------------------------------------------
-- Other Signals
----------------------------------------------------------------
	signal PC_temp 		: STD_LOGIC_VECTOR (31 downto 0); --Used with PC
	signal sll1 			: STD_LOGIC_VECTOR(31 downto 0); --Shifted signal that stores shifted address value in Jump operations 
	signal PCSrc 			: STD_LOGIC; --Output of the 'and' gate
	signal extension 		: STD_LOGIC_VECTOR (31 downto 0); --Extension signal that stores result of sign extend and shift 16 operations.
	signal link 			: STD_LOGIC_VECTOR (1 downto 0); --Originally used for linking but unused now.
	signal RegWriteAddr	: STD_LOGIC_VECTOR(4 downto 0);
	signal MemMapFlag    : STD_LOGIC;
	signal MemRegFlag    : STD_LOGIC_VECTOR(1 downto 0);
	signal Instr_withstall_out : STD_LOGIC_VECTOR(31 downto 0); 
	signal BranchStall   : STD_LOGIC;
	signal MFHItoDATAOUT : STD_LOGIC;
	signal LinkFlag		: STD_LOGIC; --Link flag for BGEZAL & BGEZ
	
----------------------------------------------------------------	
----------------------------------------------------------------
-- <MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------
begin

----------------------------------------------------------------
-- PC port map
----------------------------------------------------------------
PC1				: PC port map
						(
						PC_in 	=> PC_in, 
						PC_out 	=> PC_out,
						PC_ENABLE=> PC_Enable,
						RESET 	=> RESET,
						BUSY     => Busy,
						CLK 		=> CLK
						);
						
----------------------------------------------------------------
-- IF/ID port map
----------------------------------------------------------------
IFID1         : IFID port map
						(
						CLK       => CLK,
						Instr_in  => Instr,
						Busy      => Busy,
						Instr_out => Instr_out,
						IFID_Enable=>IFID_Enable,
						Jump => Jump_CU,
						Branch=>PCSrc,
						JumpReg => JumpReg_CU,
						JumpReg_out => JumpReg_out,
						PC_val_in => PC_temp,
						PC_val_out=> PC_val_out
						);
						
----------------------------------------------------------------
-- ID/EX port map
----------------------------------------------------------------
IDEX1				: IDEX port map
						(
						CLK => CLK,
						Busy => Busy,
						Reg1_in => ReadData1_Reg,
						Reg2_in => ReadData2_Reg,
						Reg1_out => Reg1_out,
						Reg2_out => Reg2_out,
						Reset_in => Reset,
						Reset_out => Reset_out,
						ALUOp_in => ALUOp,
						ALUOp_out => ALUOp_out,
						Branch_in => Branch,
						Branch_out => Branch_out,
						Jump_in => Jump,
						Jump_out => Jump_out,
						LinkFlag_in => LinkFlag,
						LinkFlag_out => LinkFlag_out,
						JumpLink_in => JumpLink,
						JumpLink_out => JumpLink_out,
						JumpReg_in => JumpReg,
						JumpReg_out => JumpReg_out,
						Shift16_in => Shift16,
						Shift16_out => Shift16_out,
						ShiftFlag_in => ShiftFlag,
						ShiftFlag_out => ShiftFlag_out,
						MemRead1_in => MemRead1,
						MemRead1_out => MemRead1_out,
						MemtoReg_in => MemtoReg,
						MemtoReg_out => MemtoReg_out,
						ALUSrc_in => ALUSrc,
						ALUSrc_out => ALUSrc_out,
						MemWrite1_in => MemWrite1,
						MemWrite1_out => MemWrite1_out,
						RegDst_in => RegDst,
						RegDst_out => RegDst_out,
						RegWrite_in => RegWrite,
						RegWrite_out => RegWrite_out,
						PC_val_out_in => PC_val_out,
						PC_val_out_out => PC_val_out_out,
						sll1_in => sll1,
						sll1_out => sll1_out,
						extension_in => extension,
						extension_out => extension_out,
						Instr_out_in => Instr_withstall_out,
						Instr_out_out => Instr_out_out
						);
						
----------------------------------------------------------------
-- EX/MEM port map
----------------------------------------------------------------
EXMEM1			: EXMEM port map
						(
						CLK   =>CLK,	
						Busy => Busy,						
						ALU_zero_in=>ALU_zero,
						ALU_zero_out=>ALU_zero_out,
						ALU_Out_in=>ALU_Out,
						ALU_Out_out=>ALU_Out_out,
						S_in=>S,
						S_out=>S_out,
						Branch_out_in=>Branch_out,
						Branch_out_out=>Branch_out_out,
						Jump_out_in=>Jump_out,
						Jump_out_out=>Jump_out_out,
						LinkFlag_out_in => LinkFlag_out,
						LinkFlag_out_out => LinkFlag_out_out,
						JumpLink_out_in => JumpLink_out,
						JumpLink_out_out => JumpLink_out_out,
						extension_out_in=>extension_out,
						extension_out_out=>extension_out_out,
						Reg2_out_in=>Reg2_out,
						Reg2_out_out=>Reg2_out_out,
						MemRead1_out_in=>MemRead1_out,
						MemRead1_out_out=>MemRead1_out_out,
						MemtoReg_out_in=>MemtoReg_out,	
						MemtoReg_out_out=>MemtoReg_out_out,
						MemWrite1_out_in=>MemWrite1_out,	
						MemWrite1_out_out=>MemWrite1_out_out,	
						RegWriteAddr_in=>RegWriteAddr, 
						RegWriteAddr_out=>RegWriteAddr_out,
						RegWrite_out_in=>RegWrite_out,		
						RegWrite_out_out=>RegWrite_out_out,
						sll1_out_in=>sll1_out,
						sll1_out_out=>sll1_out_out,
						link_in=>link,
						link_out=>link_out,
						Shift16_out_in=>Shift16_out,   
						Shift16_out_out=>Shift16_out_out,
						ShiftFlag_out_in=>ShiftFlag_out,   
						ShiftFlag_out_out=>ShiftFlag_out_out,
						ALUSrc_out_in=>ALUSrc_out,	
						ALUSrc_out_out=>ALUSrc_out_out,					
						PC_val_out_out_in=>PC_val_out_out,
						PC_val_out_out_out=>PC_val_out_out_out,
						MFHItoDATAOUT=>MFHItoDATAOUT,
						MFHItoDATAOUT_out=>MFHItoDATAOUT_out,
						Instr_out_out_in=>Instr_out_out,
						Instr_out_out_out=>Instr_out_out_out);

----------------------------------------------------------------
-- MEM/WB port map
----------------------------------------------------------------
MEMWB1         : MEMWB port map
						(
						CLK => CLK,
						Busy => Busy,						
						ALU_Out_out_in=>ALU_Out_out,
						ALU_Out_out_out=>ALU_Out_out_out,
						MemtoReg_out_out_in=>MemtoReg_out_out,
						MemtoReg_out_out_out=>MemtoReg_out_out_out,
						RegWrite_out_out_in=>RegWrite_out_out,
						RegWrite_out_out_out=>RegWrite_out_out_out,
						Jump_out_out_in=>Jump_out_out,
						Jump_out_out_out=>Jump_out_out_out,
						link_out_in=>link_out,
						link_out_out=>link_out_out,
						Shift16_out_out_in=>Shift16_out_out,
						Shift16_out_out_out=>Shift16_out_out_out,
						Data_in_in=>Data_in,
						Data_in_out=>Data_in_out,
						MemMapFlag_in=>MemMapFlag,
						MemMapFlag_out=>MemMapFlag_out,
						MemRegFlag_in=>MemRegFlag,
						MemRegFlag_out=>MemRegFlag_out,						
						PC_val_out_out_out_in=>PC_val_out_out_out,
						PC_val_out_out_out_out=>PC_val_out_out_out_out,
						extension_out_out_in=>extension_out_out,
						extension_out_out_out=>extension_out_out_out,
						Instr_out_out_out_in=>Instr_out_out_out,
						Instr_out_out_out_out=>Instr_out_out_out_out,
						RegWriteAddr_out_in=>RegWriteAddr_out, 
						RegWriteAddr_out_out=>RegWriteAddr_out_out);
						
----------------------------------------------------------------
-- ALU port map
----------------------------------------------------------------
ALU1 				: NewALU port map
						(
						CLK         => CLK,
						ALU_InA 		=> ALU_InA, 
						ALU_InB 		=> ALU_InB, 
						ALU_Out 		=> ALU_Out, 
						ALU_Control => ALU_Control,
						Reset       => Reset_out,
						Busy        => Busy,
						ALU_zero  	=> ALU_zero
						);
----------------------------------------------------------------
-- Adder port map
----------------------------------------------------------------
Adder1         : adder port map
						(
						A => A,
						B => B,
						C_in => C_in,
						S => S,
						C_out => C_out
						);
----------------------------------------------------------------
-- BranchComparator port map
----------------------------------------------------------------
BC1         : Comparator port map
						(
						Input1 => BranchInput1,
						Input2 => BranchInput2,
						Link => BranchLink,
						Result => BranchResult
						);						
					
----------------------------------------------------------------
-- CU port map
----------------------------------------------------------------
ControlUnit1 	: ControlUnit port map
						(
						opcode 		=> opcode,
						opcode2 		=> opcode2,
						ALUOp 		=> ALUOp_CU, 
						Branch 		=> Branch_CU, 
						Jump 			=> Jump_CU,
						JumpReg     => JumpReg_CU,
						JumpLink    => JumpLink_CU,
						MemRead 		=> MemRead1_CU, 
						MemtoReg 	=> MemtoReg_CU, 
						Shift16	 	=> Shift16_CU,
						ShiftFlag	=> ShiftFlag_CU,
						MemWrite 	=> MemWrite1_CU, 
						ALUSrc 		=> ALUSrc_CU, 
						SignExtend 	=> SignExtend_CU, 
						RegWrite 	=> RegWrite_CU, 
						RegDst 		=> RegDst_CU
						);
						
----------------------------------------------------------------
-- Register file port map
----------------------------------------------------------------
RegFile1			: RegFile port map
						(
						ReadAddr1_Reg 	=>  ReadAddr1_Reg,
						ReadAddr2_Reg 	=>  ReadAddr2_Reg,
						ReadData1_Reg 	=>  ReadData1_Reg,
						ReadData2_Reg 	=>  ReadData2_Reg,
						WriteAddr_Reg 	=>  WriteAddr_Reg,
						WriteData_Reg 	=>  WriteData_Reg,
						RegWrite 		=>  RegWrite_out_out,
						CLK 				=>  CLK				
						);

----------------------------------------------------------------
-- Processor logic
----------------------------------------------------------------
COMBINATIONAL_PROCESS:process (PC_out, PC_temp, Instr_out, PC_val_out, Shift16, Jump, 										  ShiftFlag, SignExtend, Branch, ALU_out, ALU_zero, 										 Data_in, sll1, PCSrc, S, RegDst_out, Instr_out_out, 										  PC_val_out_out, extension_out, Branch_out, ALUOp_out, 										  Reg1_out, Reg2_out, ALUSrc_out, JumpReg_out, 										  ALU_zero_out, ALU_Out_out, S_out, Branch_out_out, 										 Reg2_out_out, MemRead1_out_out, MemWrite1_out_out, 										 RegWriteAddr_out_out, Jump_out_out_out, 										  PC_val_out_out_out_out, extension_out_out_out, 										 Shift16_out_out_out, link_out_out,											RegWrite_out_out_out, sll1_out_out, 										MemtoReg_out_out_out,ALU_Out_out_out, RegWrite_out_out,ShiftFlag_out, RegWriteAddr_out, Shift16_out, MemtoReg_out_out, Jump_out_out,PC_Val_out_out_out, Shift16_out_out, extension_out_out, link_out, MemWrite1_out, Data_in_out, MemMapFlag_out, ALU_InA, MemRead1_out, MemWrite1, ShiftFlag_CU, Shift16_CU, SignExtend_CU, MemWrite1_CU, AluOp_CU, Branch_CU, Jump_CU, JumpReg_CU, MemRead1_CU, MemtoReg_CU, ALUSrc_CU, RegWrite_CU, RegDst_CU, MemRegFlag_out, Instr_out_out_out, JumpLink_CU, BranchResult, Instr, BranchStall, Instr_withstall_out, Busy, Instr_out_out_out_out, MFHItoDATAOUT, mfhitodataout_out, LinkFlag_out_out, JumpLink_out_out, JumpLink_out, LinkFlag_out)
begin
----------------------------------------------------------------
--Important note: The number of '_out' after a signal denotes the stage it is in after being CREATED. If a signal was created in the EX stage, it can't extend beyond signal_out_out!
----------------------------------------------------------------	

	MFHItoDATAOUT <= '0';
	LinkFlag <= '0'; -- For BGEZ & BGEZAL
	MemRegFlag <= "00"; --For Load-use forwarding
	MemMapFlag <= '0'; --For Load-store forwarding
	BranchStall <= '0'; --Stalling the circuit
	JumpReg <= '0'; --For JR
	PC_Enable <= '1'; --The enable signal that stalls the PC
	IFID_Enable <= '1'; --The enable signal that stalls the IF/ID register
	MemRead <= MemRead1_out_out; --EX/MEM->MEM/WB --Entity Output
	MemWrite <= MemWrite1_out_out; --EX/MEM->MEM/WB --Entity Output
	WriteAddr_Reg <= RegWriteAddr_out; ---EX/MEM->MEM/WB
	PC_temp <= PC_out + 4; --PC->IF/ID
	Addr_Instr <= PC_out; --PC->IF/ID
	link <= "00"; --ID/EX->EX/MEM --Unused now
	
----------------------------------------------------------------
--Control Unit input(Taking care of load-store hazards). The difference between Instr_out & Instr_withstall_out is that the later becomes (others=>'0') in the case of a stalled signal.
----------------------------------------------------------------	
	
	if (Instr_out(31 downto 26) = "101011" and Instr_out_out(31 downto 26) = "100011") then
		opcode <= Instr_out(31 downto 26); --IF/ID->ID/EX
		opcode2 <= Instr_out(5 downto 0); --IF/ID->ID/EX
	else
		opcode <= Instr_withstall_out(31 downto 26); --IF/ID->ID/EX
		opcode2 <= Instr_withstall_out(5 downto 0); --IF/ID->ID/EX
	end if;
	ALU_Control <= ALUOp_out & Instr_out_out(5 downto 0);	
	
----------------------------------------------------------------
--End of Control Unit Input
----------------------------------------------------------------	

	sll1 <= PC_val_out(31 downto 28) & Instr_out(25 downto 0) & "00"; -- For Jump addresses 
----------------------------------------------------------------
--ShiftFlag for SLL/SLLV Operations --Because the inputs and register addresses are different from the rest of the signals
----------------------------------------------------------------	
	if (ShiftFlag_CU = '1') then -- For SLL etc. --IF/ID->ID/EX
		if (Instr_out(31 downto 26) = "000001") then
			ReadAddr1_Reg <= "00000";
			ReadAddr2_Reg <= Instr_out(25 downto 21);			
		else
			ReadAddr1_Reg <= Instr_out(20 downto 16);
			ReadAddr2_Reg <= Instr_out(25 downto 21);
		end if;
	else
		ReadAddr1_Reg <= Instr_out(25 downto 21);
		ReadAddr2_Reg <= Instr_out(20 downto 16);
	end if;

----------------------------------------------------------------
--16-bit shifter and sign extender
----------------------------------------------------------------	
	if (Shift16_CU = '1') then --IF/ID->ID/EX
		extension <= Instr_out(15 downto 0) & x"0000"; -- After 16-bit shifting
	elsif (SignExtend_CU = '0' and Branch_CU /= '1') then
		extension <= x"0000" & Instr_out(15 downto 0);
	else
		extension <= Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15) & 						  Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15) & 						Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15) & 						 Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15) & 						  Instr_out(15 downto 0);
	end if;
		
----------------------------------------------------------------
--Destination Register
----------------------------------------------------------------
	if (JumpLink_out = '0' and LinkFlag_out = '0') then
		if (RegDst_out = '0') then --ID/EX->EX/MEM
			RegWriteAddr <= Instr_out_out(20 downto 16);
		else
			RegWriteAddr <= Instr_out_out(15 downto 11);
		end if;
	else
		RegWriteAddr <= "00000";
	end if;
----------------------------------------------------------------
--ALU Input Multiplexor
----------------------------------------------------------------	
	ALU_InA <= Reg1_out; --ID/EX->EX/MEM
	if (ALUSrc_out = '0') then --ID/EX->EX/MEM
		ALU_InB <= Reg2_out;
	else
		ALU_InB <= extension_out;
	end if;
----------------------------------------------------------------
--Writing to Register File in the final pipeline stage
----------------------------------------------------------------
	Addr_Data <= ALU_Out_out; --EX/MEM->MEM/WB
	if (RegWrite_out_out = '1') then --EX/MEM->MEM/WB 
		if (MemtoReg_out_out = '1') then --EX/MEM->MEM/WB
				WriteData_Reg <= Data_in;
		else
			if (Shift16_out_out = '1') then -- mux fix for LUI 
				WriteData_Reg <= extension_out_out;
			else	
				WriteData_Reg <=  ALU_Out_out;
			end if;
		end if;
	else
		WriteData_Reg <= x"00000000";
	end if;
	if (LinkFlag_out = '1' or JumpLink_out = '1') then --When a BGEZAL or JAL is used
			WriteAddr_Reg <= "11111";
			WriteData_Reg <= PC_val_out_out_out;
	end if;

----------------------------------------------------------------
--Branch Comparison
----------------------------------------------------------------	
	if(Instr_out(31 downto 26) = "000001") then --BGEZ and BGEZAL
		if ((Instr_out_out(31 downto 26) = "000000") and (Instr_out_out(15 downto 11) = Instr_out(25 downto 21)) and (Instr_out(25 downto 21) /= "00000")) then
			BranchStall <= '1';
		elsif (Instr_out_out(20 downto 16) = Instr_out(25 downto 21) and (Instr_out(25 downto 21) /= "00000")) then
			BranchStall <= '1';
		else
			BranchStall <= '0';
		end if;
		BranchLink <= Instr_out(26) & Instr_out(20); --Is signal BGEZ or BGEZAL?
		if (Instr_out(26) = '1' and Instr_out(20) = '1' and BranchResult = '1') then
			LinkFlag <= '1'; --Branch is taken. Store value.
		end if;
		BranchInput1 <= (others=>'0'); --Input into comparator in ID stage
		BranchInput2 <= Reg2_out; --Input into comparator in ID stage
		
	elsif (Instr_out(31 downto 26) = "000100") then --BEQ
		if ((Instr_out_out(31 downto 26) = "000000") and ((Instr_out_out(15 downto 11) = Instr_out(25 downto 21) and (Instr_out(25 downto 21) /= "00000")) or (Instr_out_out(15 downto 11) = Instr_out(20 downto 16) and (Instr_out(20 downto 16) /= "00000")))) then
			BranchStall <= '1';
		elsif ((Instr_out_out(20 downto 16) = Instr_out(25 downto 21) and (Instr_out(25 downto 21) /= "00000"))  or (Instr_out_out(20 downto 16) = Instr_out(20 downto 16)and (Instr_out(20 downto 16) /= "00000")))  then
			BranchStall <= '1';
		else
			BranchStall <= '0';
		end if;	
		BranchLink <= "00";
		BranchInput1 <= Reg1_out; --Input into comparator in ID stage		
		BranchInput2 <= Reg2_out; --Input into comparator in ID stage
	else
		BranchLink <= "01"; --None of the above instructions!
		BranchInput1 <= (others=>'0'); --Input into comparator in ID stage		
		BranchInput2 <= (others=>'0'); --Input into comparator in ID stage		
	end if;

	PCSrc <= Branch_CU and BranchResult; --ID/EX->EX/MEM
	--The adder below calculates the address to branch too using the instruction
	A <= PC_val_out; --ID/EX->EX/MEM
	B <= Instr_out(15) & Instr_out(15) & Instr_out(15) &Instr_out(15) & Instr_out(15) & 		 Instr_out(15) & Instr_out(15) & Instr_out(15) &Instr_out(15) & Instr_out(15) & 			Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15) & Instr_out(15 downto 0) & "00";
	C_in <= '0'; --ID/EX->EX/MEM
	
----------------------------------------------------------------
--Hazard detection
----------------------------------------------------------------	
if (((MemRead1_out = '1') and ((Instr_out_out(20 downto 16) = Instr_out(20 downto 16)) or (Instr_out_out(20 downto 16) = Instr_out(25 downto 21))) and (MemWrite1_CU = '0')) or (BranchStall = '1')) then
-- 	or (Jump_CU = '1') or (JumpReg_CU = '1') or (JumpReg_out = '1') ) then
		--Passing in all '0's for stalling and flushing.
		Instr_withstall_out <= (others=>'0');
		PC_Enable <= '0';
		IFID_Enable <= '0';
		ALUOp<="00"; 
		Branch<='0'; 
		Jump<='0';
		JumpLink<='0';		
		JumpReg<='0';
		MemRead1<='0';
		MemtoReg<='0'; 
		Shift16<='0';
		ShiftFlag<='0';
		MemWrite1<='0'; 
		ALUSrc<='0';
		SignExtend<='0'; 
		RegWrite<='0';
		RegDst<='0';
else
		--Pass in control signals as normal
		Instr_withstall_out <= Instr_out;
		PC_Enable <= '1';
		IFID_Enable <= '1';
		ALUOp<=ALUOp_CU; 
		Branch<=Branch_CU; 
		Jump<=Jump_CU;
		JumpLink<=JumpLink_CU;
		JumpReg<=JumpReg_CU;
		MemRead1<=MemRead1_CU; 
		MemtoReg<=MemtoReg_CU; 
		Shift16<=Shift16_CU;
		ShiftFlag<=ShiftFlag_CU;
		MemWrite1<=MemWrite1_CU; 
		ALUSrc<=ALUSrc_CU; 
		SignExtend<=SignExtend_CU; 
		RegWrite<=RegWrite_CU; 
		RegDst<=RegDst_CU;
end if;
----------------------------------------------------------------
--End of hazard detection
----------------------------------------------------------------
	
----------------------------------------------------------------
--Forwarding circuitry below!!!
----------------------------------------------------------------

	--Memory Forwarding (including MFHI and MFLO as well)
	--Load->use, use->store
	if (MemMapFlag_out = '1') then
		Data_Out <= Data_In_out;
	else
		Data_Out <= Reg2_out_out; --EX/MEM->MEM/WB
	end if;
	if (MFHItoDATAOUT_out = '1') then --Only for use->store
		Data_Out <= ALU_Out_out_out;
	end if;

--Forwarding from MEM to EX
	if ((RegWrite_out_out = '1') and (RegWriteAddr_out /= "00000")) then
		if (ShiftFlag_out = '1') then -- For SLL etc. --IF/ID->ID/EX
			if (Instr_out_out(31 downto 26) = "000001") then
				if (Instr_out_out(25 downto 21) = RegWriteAddr_out) then
					if (Shift16_out = '0') then -- LUI 
						if (ALUSrc_out = '1') then
							ALU_InB <=  extension_out;
						else
							ALU_InB <=  ALU_Out_out;
						end if;
					end if;
				end if;
			else
				if (Instr_out_out(25 downto 21) = RegWriteAddr_out) then
					if (Shift16_out = '0') then -- LUI 
						if (ALUSrc_out = '1') then
							ALU_InB <=  extension_out;
						else
							ALU_InB <=  ALU_Out_out;
						end if;
					end if;
				end if;
				if (Instr_out_out(20 downto 16) = RegWriteAddr_out) then
					ALU_InA <= ALU_Out_out;
				end if;
			end if;
		else
			if (Instr_out_out(20 downto 16) = RegWriteAddr_out) then
				if (Shift16_out = '0') then -- LUI 
					if (ALUSrc_out = '1') then
						ALU_InB <=  extension_out;
					else
						ALU_InB <=  ALU_Out_out;
					end if;
				end if;
				if (MemWrite1_out = '1') then
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
						MFHItoDATAOUT <= '1';
					end if;
				end if;
			end if;
			if (Instr_out_out(25 downto 21) = RegWriteAddr_out) then
					ALU_InA <= ALU_Out_out;
					if (MemWrite1_out = '1') then
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
							MFHItoDATAOUT <= '1';
						end if;
					end if;
			end if;
		end if;		
	end if;

	--Forwarding from WB to EX
	if ((RegWrite_out_out_out = '1') and (RegWriteAddr_out_out /= "00000")) then
		if (ShiftFlag_out = '1') then -- For SLL etc. --IF/ID->ID/EX
			if (Instr_out_out(31 downto 26) = "000001") then
				if (Instr_out_out(25 downto 21) = RegWriteAddr_out_out and Instr_out_out(25 downto 21)/= RegWriteAddr_out) then
					if (Shift16_out = '0') then -- LUI 
						if (ALUSrc_out = '1') then
							if (MemtoReg_out_out_out = '1') then
								ALU_InB <= Data_In;
							else
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
									MFHItoDATAOUT <= '1';
								else
									ALU_InB <=  extension_out;
								end if;	
							end if;
						else
							if (MemtoReg_out_out_out = '1') then
								ALU_InB <= Data_In;
							else
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
									MFHItoDATAOUT <= '1';
								else
									ALU_InB <= ALU_Out_out_out;
								end if;	
							end if;
						end if;
					end if;
				end if;
			else
				if ((Instr_out_out(25 downto 21) = RegWriteAddr_out_out) and (Instr_out_out(25 downto 21) /= RegWriteAddr_out)) then 
					if (MemWrite1_out = '0') then
						if (Shift16_out = '0') then -- LUI 
							if (ALUSrc_out = '1') then
								if (MemtoReg_out_out_out = '1') then
									ALU_InB <= Data_In;
								else
							if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
										MFHItoDATAOUT <= '1';
									else
										ALU_InB <=  extension_out;
									end if;	
								end if;
							else
								if (MemtoReg_out_out_out = '1') then
									ALU_InB <= Data_In;
								else
							if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
										MFHItoDATAOUT <= '1';
										ALU_InB <= ALU_Out_out_out;									
									else
										ALU_InB <= ALU_Out_out_out;
									end if;	
								end if;
							end if;
						end if;
					end if;
				end if;
				if ((Instr_out_out(20 downto 16) = RegWriteAddr_out_out) and (Instr_out_out(20 downto 16) /= RegWriteAddr_out or MemWrite1_out = '0')) then
					if (MemtoReg_out_out_out = '1') then
						ALU_InA <= Data_In;
					else
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
							MFHItoDATAOUT <= '1';
						else
							ALU_InA <= ALU_Out_out_out;
						end if;	
					end if;
				end if;
			end if;
		else
			if ((Instr_out_out(20 downto 16) = RegWriteAddr_out_out) and (Instr_out_out(20 downto 16) /= RegWriteAddr_out)) then
				if (Shift16_out = '0') then -- LUI 
					if (ALUSrc_out = '1') then
						if (MemtoReg_out_out_out = '1') then
							ALU_InB <= Data_In;
						else
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
								MFHItoDATAOUT <= '1';
							else
								ALU_InB <=  extension_out;
							end if;				
						end if;
					else
						if (MemtoReg_out_out_out = '1') then
							ALU_InB <= Data_In;
						else
						if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
								MFHItoDATAOUT <= '1';
								ALU_InB <= ALU_Out_out_out;
								
							else
								ALU_InB <= ALU_Out_out_out;
							end if;							
						end if;
					end if;
				end if;
			end if;
			if ((Instr_out_out(25 downto 21) = RegWriteAddr_out_out) and (Instr_out_out(25 downto 21) /= RegWriteAddr_out)) then			
				if (MemtoReg_out_out_out = '1') then
					ALU_InA <= Data_In;
				else
					if ((Instr_out_out_out_out(31 downto 24) = "00000000") and (Instr_out_out_out_out(4) = '1'))  then --Only for MFLO and MFHI!!!
						MFHItoDATAOUT <= '1';
						ALU_InA <= ALU_Out_out_out;						
					else
						ALU_InA <= ALU_Out_out_out;
					end if;
				end if;
			end if;
		end if;
	end if;

	--Load-store forwarding
	if ((MemtoReg_out_out = '1') and (MemWrite1_out = '1')) then
		if (Instr_out_out_out(20 downto 16) = Instr_out_out(20 downto 16)) then
			MemMapFlag <= '1';
		end if;
	end if;
	
	--Load-use forwarding(after a compulsory stall)
	if (MemtoReg_out_out = '1') then
		if (Instr_out(25 downto 21) = Instr_out_out_out(20 downto 16)) then
			MemRegFlag <= "01";
		elsif (Instr_out(20 downto 16) = Instr_out_out_out(20 downto 16)) then
			MemRegFlag <= "10";
		elsif ((Instr_out(25 downto 21) = Instr_out_out_out(20 downto 16)) and (Instr_out(20 downto 16) = Instr_out_out_out(20 downto 16))) then
			MemRegFlag <= "11";
		else
			MemRegFlag <= "00";
		end if;
	end if;
	
	--Forwarding from MEM/WB to ID/EX for branching
	
	if (Branch_CU = '1') then
		if (Instr_out_out_out(31 downto 26) = "000000") then --R-Type
			if (Instr_out_out_out(15 downto 11) /= "00000") then
				if (Instr_withstall_out(31 downto 26) = "000001") then --BGEZ, BGEZAL
					if (Instr_out_out_out(15 downto 11) = Instr_out(25 downto 21)) then
						BranchInput2 <= ALU_Out_out;
					end if;
				elsif (Instr_out(31 downto 26) = "000100") then
					if ((Instr_out_out_out(15 downto 11) = Instr_out(25 downto 21)) and Instr_withstall_out(25 downto 21) /= "00000") then
						BranchInput2 <= ALU_Out_out;
					end if;
					if ((Instr_out_out_out(15 downto 11) = Instr_out(20 downto 16)) and Instr_withstall_out(20 downto 16) /= "00000") then
						BranchInput1 <= ALU_Out_out;
					end if;
				end if;
			end if;
		else
			if (Instr_out_out_out(20 downto 16) /= "00000") then
				if (Instr_out(31 downto 26) = "000001") then --BGEZ, BGEZAL
					if (Instr_out_out_out(20 downto 16) = Instr_out(25 downto 21)) then
						if (Shift16_out_out = '1') then
							BranchInput2 <= extension_out_out;
						else
							BranchInput2 <= ALU_Out_out;
						end if;
					end if;
				elsif (Instr_withstall_out(31 downto 26) = "000100") then
					if ((Instr_out_out_out(20 downto 16) = Instr_out(25 downto 21)) and Instr_withstall_out(25 downto 21) /= "00000") then
						if (Shift16_out_out = '1') then
							BranchInput2 <= extension_out_out;
						else
							BranchInput2 <= ALU_Out_out;
						end if;
					end if;
					if ((Instr_out_out_out(20 downto 16) = Instr_out(20 downto 16)) and Instr_withstall_out(20 downto 16) /= "00000") then
						if (Shift16_out_out = '1') then
							BranchInput1 <= extension_out_out;
						else
							BranchInput1 <= ALU_Out_out;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;

	--Fulfilling the Load->use condition checked above by assigning values to the ALU
	case MemRegFlag_out is
	when "01" =>
		ALU_InA <= Data_In_out;
	when "10" =>
		ALU_InB <= Data_In_out;
	when "11" =>
		ALU_InA <= Data_In_out;
		ALU_InB <= Data_In_out;
	when others => NULL;
	end case;

----------------------------------------------------------------
-- End of forwarding circuitry
----------------------------------------------------------------

----------------------------------------------------------------
-- Input to PC
----------------------------------------------------------------	
	if (Jump_CU = '1') then --IF/ID->ID/EX
		PC_in <= sll1;
		PC_Enable <= '1';
		IFID_Enable <= '1';
	elsif ((Branch_CU = '1') and (BranchResult = '1')) then 
		PC_Enable <= '1';
		IFID_Enable <= '1';		
		PC_in <= S; --ID/EX->EX/MEM
	elsif (JumpReg_out = '1') then --ID/EX->EX/MEM 
		PC_in <= ALU_Out;	
	else --PC->IF/ID 
		PC_in <= PC_temp;
	end if;
	if (JumpReg_out = '1' or JumpReg_CU = '1') then
		PC_Enable <= '1';
		IFID_Enable <= '1';
		JumpReg <= JumpReg_CU;
	end if;
end process;
end arch_MIPS;
----------------------------------------------------------------
-- End of input to PC
----------------------------------------------------------------

----------------------------------------------------------------	
----------------------------------------------------------------
-- </MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
