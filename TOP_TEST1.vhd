--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:13:06 11/03/2014
-- Design Name:   
-- Module Name:   /home/ankur/14.7/ISE_DS/Projects/MIPS/TOP_TEST1.vhd
-- Project Name:  MIPS
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TOP_TEST1 IS
END TOP_TEST1;
 
ARCHITECTURE behavior OF TOP_TEST1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP
    PORT(
         DIP : IN  std_logic_vector(15 downto 0);
         LED : OUT  std_logic_vector(15 downto 0);
         RESET : IN  std_logic;
         CLK_undiv : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DIP : std_logic_vector(15 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal CLK_undiv : std_logic := '0';

 	--Outputs
   signal LED : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLK_undiv_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP PORT MAP (
          DIP => DIP,
          LED => LED,
          RESET => RESET,
          CLK_undiv => CLK_undiv
        );

   -- Clock process definitions
   CLK_undiv_process :process
   begin
		CLK_undiv <= '0';
		wait for CLK_undiv_period/2;
		CLK_undiv <= '1';
		wait for CLK_undiv_period/2;
   end process;
 

 -- Stimulus process
   stim_proc: process
   begin
		DIP <= X"0001";
		--wait for 4200 ns;
		--wait until rising_edge(clk_undiv);
		--DIP <= X"0060";
		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	

      --wait for CLK_undiv_period*10;

      -- insert stimulus here 
		--wait for rising_edge(clk);
		--wait for 5 ns;
		

      wait;
   end process;
END;
