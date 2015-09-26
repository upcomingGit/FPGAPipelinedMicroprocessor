------------------------------------------------------------------
-- Adder Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
generic (width : integer := 32);
port (A 		: in std_logic_vector(width-1 downto 0);
		B 		: in std_logic_vector(width-1 downto 0);
		C_in 	: in std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end adder;

------------------------------------------------------------------
-- Adder Architecture
------------------------------------------------------------------

architecture adder_arch of adder is
signal S_wider : std_logic_vector(width downto 0);
begin
	S_wider <= ('0'& A) + ('0'& B) + C_in;
	S <= S_wider(width-1 downto 0);
	C_out <= S_wider(width);
end adder_arch;