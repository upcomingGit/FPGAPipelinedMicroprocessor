----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:54 11/10/2014 
-- Design Name: 
-- Module Name:    ExceptionUnit - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- The Exception unit is a LUT for a series of inputs, mapping them to
-- The correct Cause value.
-- The EPC should be wired directly, and is not handled here.

entity ExceptionUnit is
    Port ( ALU_Overflow 			: in  STD_LOGIC;
			  Instr		 				: in 	STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
           ExceptionReg_Cause 	: out  STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
			  ExceptionReg_EPC		: out  STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
			  PC_out						: out  STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
			  ExceptionUnit_Trigger : out STD_LOGIC;
			  ExceptionMode 			: out STD_LOGIC);
end ExceptionUnit;

architecture Behavioral of ExceptionUnit is
begin
	ExceptionUnit_Trigger <= ALU_Overflow; -- trigger HIGH for 1 clock cycle
	
	CauseProc : process (ALU_Overflow, Instr)
	begin
		--ExceptionMode <= '0';
		if (ALU_Overflow = '1') then
			ExceptionReg_Cause <= x"0000ff13";
			ExceptionReg_EPC <= Instr;
			PC_out <= x"80000000";
			ExceptionMode <= '1';
		end if;
	end process;
	
end Behavioral;

