---------------------------------------------------------------------------------
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

entity Comparator is
	Port (Input1 : in STD_LOGIC_VECTOR(31 downto 0);
			Input2 : in STD_LOGIC_VECTOR(31 downto 0);
			Link   : in STD_LOGIC_VECTOR(1 downto 0);
			Result : out STD_LOGIC);
end comparator;

architecture arch of Comparator is
	
component adder is
	port (
			A 		: in STD_LOGIC_VECTOR(31 downto 0);
			B 		: in STD_LOGIC_VECTOR(31 downto 0);
			C_in 	: in STD_LOGIC;
			S 		: out STD_LOGIC_VECTOR(31 downto 0);
			C_out	: out STD_LOGIC);
end component;

	signal   A1          :  STD_LOGIC_VECTOR (31 downto 0);
	signal   B1          :  STD_LOGIC_VECTOR (31 downto 0);
	signal	C_in1		   :  STD_LOGIC;
	signal   S1          :  STD_LOGIC_VECTOR (31 downto 0);
	signal	C_out1		:  STD_LOGIC;
	
	signal Result1       :  STD_LOGIC_VECTOR(31 downto 0);
	
begin

Adder1         : adder port map
						(
						A => A1,
						B => B1,
						C_in => C_in1,
						S => S1,
						C_out => C_out1
						);
process (Input1, Input2, S1, link)
begin

	A1 <= (others=>'0'); 
	B1 <= (others=>'0'); 
   C_in1 <= '0';
	Result <= '0';
	if (Link = "00") then --BEQ
		if ((Input1(31) xnor (not(Input2(31)))) = '1') then
			if (Input1(31) = '0') then
				A1 <= Input1;
				B1 <= not(Input2);
				C_in1 <= '1';
				Result1 <= S1;
			else
				A1 <= Input1;
				B1 <= not(Input2);
				C_in1 <= '1';
				Result1 <= S1;
			end if;
		else
			A1 <= Input1;
			B1 <= not(Input2);
			C_in1 <= '1';
			Result1 <= S1;
		end if;
		
		if S1 = x"00000000" then
			Result <= '1';
		else
			Result <= '0';
		end if;
	elsif (Link = "10" or Link = "11") then
		if (((Input1(31) xor (Input2(31)))) = '1') then
			 if ((Input1(31) = '0') and (Input2(31) = '1')) then
				  Result <= '0';
			 else
				  Result <= '1';
			 end if;
		else
			 A1 <= Input1;
			 B1 <= not (Input2);
			 C_in1 <= '1';
			 if (S1(31) = '1' or (S1 = Input1)) then
				  Result <= '1';
			 else
				  Result <= '0';
			 end if;   
		end if;
	else
		Result <= '0';
	end if;
end process;
end arch;

	
	