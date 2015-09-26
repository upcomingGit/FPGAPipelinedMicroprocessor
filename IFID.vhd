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

entity IFID is 
	Port (CLK : in STD_LOGIC;
			Instr_in : in STD_LOGIC_VECTOR(31 downto 0);
			PC_val_in : in STD_LOGIC_VECTOR(31 downto 0);
			Busy      : in STD_LOGIC;
			IFID_Enable : in STD_LOGIC;
			Jump : in STD_LOGIC;
			Branch : in STD_LOGIC;
			JumpReg : in STD_LOGIC;
			JumpReg_out : in STD_LOGIC;
			PC_val_out : out STD_LOGIC_VECTOR(31 downto 0);
			Instr_out : out STD_LOGIC_VECTOR(31 downto 0));
end IFID;

architecture IFID_arch of IFID is
begin
	process (CLK, Busy, Branch)
	begin
		if (CLK'event and CLK = '1') then
			if (Busy = '0' and IFID_Enable = '1') then
				PC_val_out <= PC_val_in;
				Instr_out <= Instr_in;
			end if;
			if ((Jump = '1') or (JumpReg = '1') or (JumpReg_out = '1') or (Branch = '1')) then
				Instr_out <= (others=>'0');
			end if;
		end if;
	end process;
end IFID_arch;
