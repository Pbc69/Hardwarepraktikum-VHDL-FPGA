---------------------------------------------------------------------------------------------------
--
-- Titel: CheckIRQ
-- Autor: HadesXI_13   
-- Datum: 23.01.2019   
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.hadescomponents.all;

entity checkirq is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- interrupt inputs
		xperintr	: in  std_logic;
		xnaintr		: in  std_logic;
		xmemintr	: in  std_logic;
		
		-- control input
		swintr		: in  std_logic;
		pcwrite		: in  std_logic;
		eni			: in  std_logic;
		dei			: in  std_logic;
		reti		: in  std_logic;
		retilvl		: in  std_logic_vector(2 downto 0);
		
		-- control output
		curlvl		: out std_logic_vector(2 downto 0);
		selisra		: out std_logic_vector(2 downto 0);
		intr		: out std_logic
	);
end checkirq;

architecture rtl of checkirq is
	constant IRL_XMEM: 	std_logic_vector(2 downto 0) 	:= "100";
	constant IRL_XNA: 	std_logic_vector(2 downto 0) 	:= "011";
	constant IRL_XPER: 	std_logic_vector(2 downto 0) 	:= "010";
	constant IRL_SW: 	std_logic_vector(2 downto 0) 	:= "001";
	constant IRL_NONE: 	std_logic_vector(2 downto 0) 	:= "000";

	-- IRQ Receiver Signals
	signal buf_xmemir, buf_xnair, buf_swir: std_logic;	-- Outputs: Buffers
	signal xmem_ack, xna_ack, sw_ack: std_logic := '0'; -- Inputs: Set to 1 if value has been used

	
	signal enabled 		: std_logic := '1';		-- Interrupts completly enabled or disabled
	signal higherIrl 	: std_logic := '0';		-- es liegt ein höheres IRL vor
	signal fireIntr		: std_logic := '0';		-- ein interrupt soll ausgelöst werden
	signal intr_pipe 	: std_logic := '0'; 	-- interrupt ausgelöst > verbunden zu intr, dient auch zum reset der buffer

	signal reqlvl, tcurlvl, newlvl 		: std_logic_vector(2 downto 0) := "000";
begin
	
	irq_XMEM: entity work.irqreceiver
		port map(
			CLK 	=> clk,
			RESET 	=> reset,
			IACK	=> xmem_ack,
			ISIGNAL => xmemintr,
			Q 		=> buf_xmemir
			);

	irq_XNA: entity work.irqreceiver
		port map(
			CLK 	=> clk,
			RESET 	=> reset,
			IACK	=> xna_ack,
			ISIGNAL => xnaintr,
			Q 		=> buf_xnair
			);

	irq_SW: entity work.irqreceiver
		port map(
			CLK 	=> clk,
			RESET 	=> reset,
			IACK	=> sw_ack,
			ISIGNAL => swintr,
			Q 		=> buf_swir
			);


	-- fire interrupt logic
	process(reti, retilvl, reqlvl, tcurlvl)
	begin
		fireIntr <= '0';
		if reti = '1' then
			if reqlvl > retilvl then
				fireIntr <= '1';
			end if;
		else	
			if reqlvl > tcurlvl then
				fireIntr <= '1';
			end if;	
		end if;
	end process;

	
	-- interrupt lvl logic
	process (higherIrl, retilvl, reqlvl)
	begin
		if higherIrl='1' then
			newlvl <= reqlvl;
		else
			newlvl <= retilvl;
		end if;
	end process;


	-- update curlvl on clock
	process (clk, reset)
	begin
		if reset = '1' then
			tcurlvl <= IRL_NONE;
		elsif rising_edge(clk) and pcwrite='1' then
			if reti = '1' or newLvl > tcurlvl then
				tcurlvl <= newlvl;
			end if;
		end if;
	end process;

	-- Raise interrupt only when enabled
	higherIrl 	<= '1' when fireIntr='1' and enabled='1' else '0';
	intr_pipe 	<= '1' when higherIrl='1' and pcwrite='1' else '0';	-- Fire Interrupt
	intr 		<= intr_pipe;
	
	
	selisra 	<= 	newlvl; 
	curlvl 		<=  tcurlvl;

	-- der aktuell höchste interrupt
	reqlvl 	<= 	IRL_XMEM when xmemintr='1' or buf_xmemir='1' else	-- XMEM Interrupt Lvl 4
			  	IRL_XNA when xnaintr='1' or buf_xnair='1' else		-- XNA Interrupt Lvl 3
			  	IRL_XPER when xperintr='1' else						-- XPER Interrupt Lvl 2
			  	IRL_SW when swintr='1' or buf_swir='1' else			-- SW Interrupt Lvl 1
				IRL_NONE; 	-- no interrupt


	-- wenn interrupt behandelt wurde, dann reset den jeweiligen buffer
	xmem_ack 	<= '1' when (intr_pipe = '1' and reqlvl = IRL_XMEM) or reset='1' else '0';
	xna_ack 	<= '1' when (intr_pipe = '1' and reqlvl = IRL_XNA) or reset='1' else '0';
	sw_ack 		<= '1' when (intr_pipe = '1' and reqlvl = IRL_SW ) or reset='1' else '0';

	-- Interrupts enabled
	enabled <= 	'1' when eni='1' or reset='1' else
				'0' when dei='1' else
				enabled;

end rtl;
