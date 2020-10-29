----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2020 08:50:11 PM
-- Design Name: 
-- Module Name: tmds_tx - Behavioral
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

library UNISIM;
use UNISIM.VComponents.all;

entity tmds_tx is
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
end tmds_tx;

architecture Behavioral of tmds_tx is

component tmds_encoder IS
	port(  
		clk      	: in  std_logic;                     
		disp_ena 	: in  std_logic;                     
		control  	: in  std_logic_vector(1 downto 0);  
		d_in     	: in  std_logic_vector(7 downto 0);  
		q_out    	: out std_logic_vector(9 downto 0)
	); 
end component tmds_encoder;

signal	tmds_red		: std_logic_vector(9 downto 0);
signal	tmds_green		: std_logic_vector(9 downto 0);
signal	tmds_blue		: std_logic_vector(9 downto 0);

signal	tmds_mod10		: integer range 0 to 10;
	
signal	tmds_sload		: std_logic;
signal	tmds_sred		: std_logic_vector(9 downto 0);
signal	tmds_sgreen		: std_logic_vector(9 downto 0);
signal	tmds_sblue		: std_logic_vector(9 downto 0);

begin

	MOD_10_CNT_P : process (SERIAL_CLK)
	begin
		if rising_edge(SERIAL_CLK) then
			if (RSTn = '0') then
				tmds_mod10		<= 0;
			else
				if (TMDS_mod10 = 9) then
					tmds_mod10		<= 0;
				else
					tmds_mod10		<= tmds_mod10 + 1;
				end if;
			end if;
		end if;
	end process;
	
	TMDS_SHIFTL_P : process (SERIAL_CLK)
	begin
		if rising_edge(SERIAL_CLK) then
			if (RSTn = '0') then
				tmds_sload		<= '0';
			else
				if (TMDS_mod10 = 9) then
					tmds_sload		<= '1';
				else
					tmds_sload		<= '0';
				end if;			
			end if;			
		end if;
	end process;
	
	TMDS_SHIFTD_P : process (SERIAL_CLK)
	begin
		if rising_edge(SERIAL_CLK) then
			if (RSTn = '0') then
				tmds_sred		<= (others => '0');
				tmds_sgreen		<= (others => '0');
				tmds_sblue		<= (others => '0');
			else
				if (tmds_sload = '1') then
					tmds_sred		<= tmds_red;
					tmds_sgreen		<= tmds_green;
					tmds_sblue		<= tmds_blue;
				else	
					tmds_sred		<= tmds_sred(0) & tmds_sred(9 downto 1);
					tmds_sgreen		<= tmds_sgreen(0) & tmds_sgreen(9 downto 1);
					tmds_sblue		<= tmds_sblue(0) & tmds_sblue(9 downto 1);
				end if;			
			end if;			
		end if;
	end process;

	tmds_encoder_r : tmds_encoder
	port map (
		clk      	=> PIX_CLK,
		disp_ena 	=> DISP_ENA,
		control  	=> "00",
		d_in     	=> D_IN(23 downto 16),
		q_out    	=> tmds_red
	);

	tmds_encoder_g : tmds_encoder
	port map (
		clk      	=> PIX_CLK,
		disp_ena 	=> DISP_ENA,
		control  	=> "00",
		d_in     	=> D_IN(15 downto 8),
		q_out    	=> tmds_green
	);

	tmds_encoder_b : tmds_encoder
	port map (
		clk      	=> PIX_CLK,
		disp_ena 	=> DISP_ENA,
		control  	=> VSYNC & HSYNC,
		d_in     	=> D_IN(7 downto 0),
		q_out    	=> tmds_blue
	);
	
	OBUFDS_red : OBUFDS
	generic map (
		IOSTANDARD 	=> "TMDS_33", 	--Specify the output I/O standard
		SLEW 		=> "SLOW"		--Specify the output slew rate
	)				 
	port map (
		O 	=> TMDS_P(2),		--Diff_poutput (connect directly to top-level port)
		OB 	=> TMDS_N(2),		--Diff_noutput (connect directly to top-level port)
		I	=> tmds_sred(0)		--Bufferinput
	);
	
	OBUFDS_green : OBUFDS
	generic map (
		IOSTANDARD 	=> "TMDS_33", 	--Specify the output I/O standard
		SLEW 		=> "SLOW"		--Specify the output slew rate
	)				 
	port map (
		O 	=> TMDS_P(1),		--Diff_poutput (connect directly to top-level port)
		OB 	=> TMDS_N(1),		--Diff_noutput (connect directly to top-level port)
		I	=> tmds_sgreen(0)	--Bufferinput
	);
	
	OBUFDS_blue : OBUFDS
	generic map (
		IOSTANDARD 	=> "TMDS_33", 	--Specify the output I/O standard
		SLEW 		=> "SLOW"		--Specify the output slew rate
	)				 
	port map (
		O 	=> TMDS_P(0),		--Diff_poutput (connect directly to top-level port)
		OB 	=> TMDS_N(0),		--Diff_noutput (connect directly to top-level port)
		I	=> tmds_sblue(0)	--Bufferinput
	);
	
	OBUFDS_clock : OBUFDS
	generic map (
		IOSTANDARD 	=> "TMDS_33", 	--Specify the output I/O standard
		SLEW 		=> "SLOW"		--Specify the output slew rate
	)				 
	port map (
		O 	=> TMDS_CLK_P,		--Diff_poutput (connect directly to top-level port)
		OB 	=> TMDS_CLK_N,		--Diff_noutput (connect directly to top-level port)
		I	=> PIX_CLK		--Bufferinput
	);
	

end Behavioral;
