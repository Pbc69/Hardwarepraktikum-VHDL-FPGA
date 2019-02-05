---------------------------------------------------------------------------------------------------
--
-- Titel:    
-- Autor: hadesXI_13   
-- Datum: 18.11.2018
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.all;
	use work.hadescomponents.all;
	
entity irqlogic is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- interrupt inputs
		xperintr	: in  std_logic;
		xnaintr		: in  std_logic;
		xmemintr	: in  std_logic;
		
		-- control input
		pcwrite		: in  std_logic;
		pccontr		: in  std_logic_vector(4 downto 0); -- SWI, RETI, ENI,  DEI, SISA
		pcnext		: in  std_logic_vector(11 downto 0);
		pcnew		: in  std_logic_vector(11 downto 0);
		sisalvl		: in  std_logic_vector(1 downto 0);
		
		-- control output
		intr		: out std_logic;
		isra		: out std_logic_vector(11 downto 0);
		isrr		: out std_logic_vector(11 downto 0)
	);
end irqlogic;

architecture rtl of irqlogic is
	signal selisra : std_logic_vector(2 downto 0) := (others => '0');
	signal curlvl, retilvl : std_logic_vector(2 downto 0) := (others => '0');
	signal swintr 		: std_logic := '0'; 
	signal intr_pipe 	: std_logic := '0'; -- signal from checkirq to isrr
begin

	ISRA_logic: entity isralogic
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- address input
			pcwrite		=> pcwrite,
			sisa		=> pccontr(0),	-- SISA
			sisalvl		=> sisalvl,
			pcnew		=> pcnew,
			
			-- address output
			selisra		=> selisra,
			isra		=> isra
		);

	ISRR_logic: entity isrrlogic
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- control & address input
			pcwrite		=> pcwrite,
			intr		=> intr_pipe,  		-- from CheckIRQ
			reti		=> pccontr(3), 		-- RETI
			pcnext		=> pcnext,
			curlvl		=> curlvl,			-- from CheckIRQ
			
			-- address output
			retilvl		=> retilvl,
			isrr		=> isrr
		);

	checkirq1:	entity checkirq
		port map(
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- interrupt inputs
			xperintr	=> xperintr,
			xnaintr		=> xnaintr,
			xmemintr	=> xmemintr,
			
			-- control input
			swintr		=> swintr, 		-- SWI & PCWRITE
			pcwrite		=> pcwrite,
			eni			=> pccontr(2),	-- ENI (enable interrupt)
			dei			=> pccontr(1),	-- DEI (dissable interrupt)
			reti		=> pccontr(3),	-- RETI
			retilvl		=> retilvl, 	-- from ISRR-Logic
			
			-- control output
			curlvl		=> curlvl,
			selisra		=> selisra,
			intr		=> intr_pipe
		);

	swintr 	<= pccontr(4) when pcwrite = '1' else '0';
	intr 	<= intr_pipe;

end rtl;
