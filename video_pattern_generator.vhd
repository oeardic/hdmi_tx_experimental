----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2020 11:32:28 PM
-- Design Name: 
-- Module Name: video_pattern_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity video_pattern_generator is
	Port ( 
		PIX_CLK		: in std_logic;
		RSTn		: in std_logic;
		HSYNC		: in std_logic;
		VSYNC		: in std_logic;
		DISP_ENA	: in std_logic;
		xCnt		: in std_logic_vector(9 downto 0);
		yCnt		: in std_logic_vector(9 downto 0);
		VTG_CE		: out std_logic;
		RGB			: out std_logic_vector(23 downto 0)
	);
end video_pattern_generator;

architecture Behavioral of video_pattern_generator is

signal	xCounter		: unsigned(9 downto 0);
signal	yCounter		: unsigned(9 downto 0);

begin

	xCounter	<= unsigned(xCnt);
	yCounter	<= unsigned(yCnt);

	RGB(23 downto 16)	<= 	std_logic_vector((xCounter(5 downto 0) and "111111") & "00") when (yCounter(4 downto 3) = (not xCounter(4 downto 3))) else
							std_logic_vector((xCounter(5 downto 0) and "000000") & "00");
	
	RGB(15 downto 8)	<=	std_logic_vector(xCounter(7 downto 0) and (yCounter(6) & yCounter(6) & yCounter(6) & yCounter(6) & yCounter(6) & yCounter(6) & yCounter(6) & yCounter(6)));
	
	RGB(7 downto 0)		<=	std_logic_vector(yCounter(7 downto 0));

	VTG_CE	<= '1';

end Behavioral;
