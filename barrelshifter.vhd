library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity barrelshifter is
generic (width : integer := 32);
	Port (Control: in std_logic_vector(14 downto 0);
			Input: in std_logic_vector(2*width-1 downto 0);
			Output: out std_logic_vector(2*width-1 downto 0));
end barrelshifter;

architecture arch of barrelshifter is
--Shift Mapping 
component slr1 is
generic (width : integer);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end component slr1;

component slr2 is
generic (width : integer);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end component slr2;

component slr4 is
generic (width : integer);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end component slr4;

component slr8 is
generic (width : integer);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end component slr8;

component slr16 is
generic (width : integer);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end component slr16;

signal out1 : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal out2 : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal out4 : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal out8 : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal controlshift1 : std_logic_vector(2 downto 0) := "000";
signal controlshift2 : std_logic_vector(2 downto 0) := "000";
signal controlshift4 : std_logic_vector(2 downto 0) := "000";
signal controlshift8 : std_logic_vector(2 downto 0) := "000";
signal controlshift16 : std_logic_vector(2 downto 0) := "000";
signal inputshift : std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal outputshift: std_logic_vector(2*width-1 downto 0) := (others=>'0');
signal controller : std_logic_vector(5 downto 0) := (others=>'0');

begin

slr11: slr1 generic map (width=>width) port map(Control(2 downto 0), Input, out1);
slr21: slr2 generic map (width=>width) port map(Control(5 downto 3), out1, out2);
slr41: slr4 generic map (width=>width) port map(Control(8 downto 6), out2, out4);
slr81: slr8 generic map (width=>width) port map(Control(11 downto 9), out4, out8);
slr161: slr16 generic map (width=>width) port map(Control(14 downto 12), out8, Output);

end arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slr1 is
generic (width : integer := 32);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end slr1;

architecture slr1_arch of slr1 is
begin
	output <= (input(2*width-2 downto 0) & '0') when control = "001" else
				('0' & input(2*width-1 downto 1)) when control = "010" else
				(x"00000000" & input(width-1) & input(width-1 downto 1)) when control = "100" else
				input;
end slr1_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slr2 is
generic (width : integer := 32);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end slr2;

architecture slr2_arch of slr2 is
begin
	output <= (input(2*width-3 downto 0) & "00") when control = "001" else
				("00" & input(2*width-1 downto 2)) when control = "010" else
				(x"00000000" & input(width-1) & input(width-1) & input(width-1 downto 2)) when 					control = "100" else
				input;
end slr2_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slr4 is
generic (width : integer := 32);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end slr4;

architecture slr4_arch of slr4 is
begin
	output <= (input(2*width-5 downto 0) & "0000") when control = "001" else
				("0000" & input(2*width-1 downto 4)) when control = "010" else
				(x"00000000" & input(width-1) & input(width-1) & input(width-1) & input(width-1) & input					(width-1 downto 4)) when control = "100" else
				input;
end slr4_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slr8 is
generic (width : integer := 32);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end slr8;

architecture slr8_arch of slr8 is
begin
	output <= (input(2*width-9 downto 0) & "00000000") when control = "001" else
				("00000000" & input(2*width-1 downto 8)) when control = "010" else
				(x"00000000" & input(width-1) & input(width-1) & input(width-1) & input(width-1) 				& input(width-1) & input(width-1) & input(width-1) & input(width-1) & 				input(width-1 downto 8)) when control = "100" else	
					input;
end slr8_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slr16 is
generic (width : integer := 32);
	Port (control: in std_logic_vector(2 downto 0);
			input: in std_logic_vector(2*width-1 downto 0);
			output: out std_logic_vector(2*width-1 downto 0));
end slr16;

architecture slr16_arch of slr16 is
begin
	output <= (input(2*width-17 downto 0) & x"0000") when control = "001" else
				(x"0000" & input(2*width-1 downto 16)) when control = "010" else
				(x"00000000" & input(width-1) & input(width-1) & input(width-1) & input(width-1) 				& input(width-1) & input(width-1) & input(width-1) & input(width-1) & 				input(width-1) & input(width-1) & input(width-1) & input(width-1) & input				(width-1) & input(width-1) & input(width-1)& input(width-1) & input				(width-1 downto 16)) when control = "100" 	else	
				input;
end slr16_arch;