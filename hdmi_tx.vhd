----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2020 11:42:26 PM
-- Design Name: 
-- Module Name: hdmi_tx - Behavioral
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

entity hdmi_tx is
	Port ( 
		SYSCLK		: in std_logic;
		TMDS_P		: out std_logic_vector(2 downto 0);
		TMDS_N		: out std_logic_vector(2 downto 0);
		TMDS_CLK_P	: out std_logic;
		TMDS_CLK_N	: out std_logic
	);
end hdmi_tx;

architecture Behavioral of hdmi_tx is

component video_timing_generator is
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
end component video_timing_generator;

component video_pattern_generator is
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
end component video_pattern_generator;

component tmds_tx is
	Port ( 
		PIX_CLK		: in std_logic;
		SERIAL_CLK	: in std_logic;
		RSTn		: in std_logic;
		D_IN		: in std_logic_vector(23 downto 0);
		HSYNC		: in std_logic;
		VSYNC		: in std_logic;
		DISP_ENA	: in std_logic;
		TMDS_P		: out std_logic_vector(2 downto 0);
		TMDS_N		: out std_logic_vector(2 downto 0);
		TMDS_CLK_P	: out std_logic;
		TMDS_CLK_N	: out std_logic
	);
end component tmds_tx;

component clk_wiz_0
port
	(
		PIXCLK		: out std_logic;
		SERIAL_CLK	: out std_logic;
		LOCKED 		: out std_logic;
		CLK_IN1		: in std_logic
	);
end component;

signal   PIX_CLK    : std_logic;
signal   SERIAL_CLK : std_logic;
signal   RSTn       : std_logic;
signal   RGB       	: std_logic_vector(23 downto 0);
signal   HSYNC      : std_logic;
signal   VSYNC      : std_logic;
signal   DISP_ENA   : std_logic;
signal   VTG_CE   	: std_logic;
signal   xCnt   	: std_logic_vector(9 downto 0);
signal   yCnt   	: std_logic_vector(9 downto 0);
signal   CLKEN   	: std_logic;

begin

	comp_video_timing_generator : video_timing_generator
	port map (
		PIX_CLK     => PIX_CLK,
		RSTn        => RSTn,
		CLKEN       => CLKEN,
		xCnt        => xCnt,
		yCnt        => yCnt,
		HSYNC       => HSYNC,
		VSYNC       => VSYNC,
		ACTIVE_AREA => DISP_ENA
	);

	comp_video_pattern_generator : video_pattern_generator
	port map (
		PIX_CLK  	=> PIX_CLK,
		RSTn     	=> RSTn,
		HSYNC    	=> HSYNC,
		VSYNC    	=> VSYNC,
		DISP_ENA 	=> DISP_ENA,
		xCnt     	=> xCnt,
		yCnt     	=> yCnt,
		VTG_CE   	=> VTG_CE,
		RGB      	=> RGB
	);

	comp_tmds_tx : tmds_tx
	port map (
		PIX_CLK    	=> PIX_CLK,
		SERIAL_CLK 	=> SERIAL_CLK,
		RSTn       	=> RSTn,
		D_IN       	=> RGB,
		HSYNC      	=> HSYNC,
		VSYNC      	=> VSYNC,
		DISP_ENA   	=> DISP_ENA,
		TMDS_P     	=> TMDS_P,
		TMDS_N     	=> TMDS_N,
		TMDS_CLK_P 	=> TMDS_CLK_P,
		TMDS_CLK_N 	=> TMDS_CLK_N
	);

	comp_clock_generator: clk_wiz_0
	port map ( 
		-- Clock out ports 
		PIXCLK 		=> PIX_CLK,		-- 25 MHz
		SERIAL_CLK 	=> SERIAL_CLK,	-- 250 MHz
		-- Status and control signals                
		LOCKED 		=> RSTn,
		-- Clock in ports 
		CLK_IN1 	=> SYSCLK		-- (On-board) 125 MHz oscillator
	);
end Behavioral;
