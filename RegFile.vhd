----------------------------------------------------------------------------------
-- Engineer: Ankur Gupta
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	RegFile
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Register File for the MIPS processor
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
use ieee.numeric_std.all;

entity RegFile is
    Port ( 	ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
				ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
				ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
				ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
				WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
				WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
				RegWrite 		: in STD_LOGIC; 
				CLK 				: in  STD_LOGIC);
end RegFile;


architecture arch_RegFile of RegFile is
	constant REGISTER_SIZE : natural := 32;
	type registerFileType is array((REGISTER_SIZE - 1) downto 0) of std_logic_vector(31 downto 0);
	signal registers : registerfileType := (others => (others => '0'));
	-- <force VHDL to use block RAM>
	attribute ram_style: string;
	attribute ram_style of registers : signal is "block";
	-- </force VHDL to use block RAM>
begin
--	ReadData1_Reg <= registers(to_integer(unsigned(ReadAddr1_Reg)));
--	ReadData2_Reg <= registers(to_integer(unsigned(ReadAddr2_Reg)));
	
	process (CLK)
		variable regIdx : integer := 0;
	begin
		if (CLK'event and CLK='1') then
			if (RegWrite = '1') then
				regIdx := to_integer(unsigned(WriteAddr_Reg));
				if (regIdx > 0) and (regIdx <=(REGISTER_SIZE - 1)) then 
					registers(regIdx) <= WriteData_Reg;
				elsif regIdx = 0 then
					registers(0) <= (others => '0'); -- zero register
				else -- NOP for other cases
				end if;
			end if;
		end if;
		if (CLK'event and CLK='0') then
			ReadData1_Reg <= registers(to_integer(unsigned(ReadAddr1_Reg)));
			ReadData2_Reg <= registers(to_integer(unsigned(ReadAddr2_Reg)));
		end if;
	end process;
end arch_RegFile;