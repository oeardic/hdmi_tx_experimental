----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2020 07:34:20 PM
-- Design Name: 
-- Module Name: video_timing_generator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity video_timing_generator is
	Port ( 
		PIX_CLK		: in std_logic;
		RSTn		: in std_logic;
		CLKEN		: in std_logic;
		xCnt		: out std_logic_vector(9 downto 0);
		yCnt		: out std_logic_vector(9 downto 0);
		HSYNC		: out std_logic;
		VSYNC		: out std_logic;
		ACTIVE_AREA	: out std_logic
	);
end video_timing_generator;

architecture Behavioral of video_timing_generator is

signal	xCounter		: unsigned(9 downto 0);
signal	yCounter		: unsigned(9 downto 0);

begin

	xCnt	<= std_logic_vector(xCounter);
	yCnt	<= std_logic_vector(yCounter);

	HSYNC_GEN_P : process (PIX_CLK)
	begin
		if rising_edge(PIX_CLK) then
			if (RSTn = '0') then
				HSYNC		<= '0';
			else
				if ((xCounter >= 656) and (xCounter < 752)) then
					HSYNC		<= '1';
				else
					HSYNC		<= '0';
				end if;
			end if;
		end if;
	end process;
	
	VSYNC_GEN_P : process (PIX_CLK)
	begin
		if rising_edge(PIX_CLK) then
			if (RSTn = '0') then
				VSYNC		<= '0';
			else
				if ((yCounter >= 490) and (yCounter < 492)) then
					VSYNC		<= '1';
				else
					VSYNC		<= '0';
				end if;
			end if;
		end if;
	end process;
	
	DISP_EN_GEN_P : process (PIX_CLK)
	begin
		if rising_edge(PIX_CLK) then
			if (RSTn = '0') then
				ACTIVE_AREA		<= '0';
			else
				if ((xCounter < 640) and (yCounter < 480)) then
					ACTIVE_AREA		<= '1';
				else
					ACTIVE_AREA		<= '0';
				end if;
			end if;
		end if;
	end process;

	X_AXIS_CNT_P : process (PIX_CLK)
	begin
		if rising_edge(PIX_CLK) then
			if (RSTn = '0') then
				xCounter	<= (others => '0');
			else
				if (xCounter = 799) then
					xCounter	<= (others => '0');
				else
					xCounter	<= xCounter + 1;
				end if;
			end if;
		end if;
	end process;

	Y_AXIS_CNT_P : process (PIX_CLK)
	begin
		if rising_edge(PIX_CLK) then
			if (RSTn = '0') then
				yCounter	<= (others => '0');
			else
				if (xCounter = 799) then
					if (yCounter = 524) then
						yCounter	<= (others => '0');
					else
						yCounter	<= yCounter + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;
