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

entity PC is
	Port(	PC_in 	: in STD_LOGIC_VECTOR (31 downto 0);
			PC_out 	: out STD_LOGIC_VECTOR (31 downto 0) := x"00400000";
			PC_ENABLE: in STD_LOGIC;
			RESET		: in STD_LOGIC;
			BUSY     : in STD_LOGIC;
			CLK		: in STD_LOGIC);
end PC;


architecture arch_PC of PC is
begin
	process(RESET, CLK, BUSY)
	begin
		if clk'event and clk = '1' then
			if (RESET = '1') then
				PC_out <= x"00400000";
			else
				if (BUSY = '0' and PC_ENABLE = '1') then
					PC_out <= PC_in;				
				end if;
			end if;
		end if;
		
--		if clk'event and clk = '0' then
--			if (RESET = '1') then
--				PC_out <= x"00400000";
--			else
--				if (BUSY ='0') then
--					PC_out <= PC_in;				
--				end if;
--			end if;
--		end if;
	end process;
end arch_PC;

