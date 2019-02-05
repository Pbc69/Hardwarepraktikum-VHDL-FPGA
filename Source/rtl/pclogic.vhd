---------------------------------------------------------------------------------------------------
--
-- Titel: Program Counter Logic   
-- Autor: HadesXI_13   
-- Datum: 15.11.2018   
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.all;
	use work.hadescomponents.all;
	
entity pclogic is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control flags
		pcwrite		: in  std_logic;
		pccontr		: in  std_logic_vector(5 downto 0); -- 6bits: JAL, JREG, RETI, BOV, BEQZ, BNEZ
		ov			: in  std_logic;
		zero		: in  std_logic;
		intr		: in  std_logic;
		
		-- program counter inputs
		pcnew		: in  std_logic_vector(11 downto 0);
		isra		: in  std_logic_vector(11 downto 0);
		isrr		: in  std_logic_vector(11 downto 0);

		-- program counter outputs
		pcakt		: out std_logic_vector(11 downto 0);	-- Aktiver PC
		pcinc		: out std_logic_vector(11 downto 0);
		pcnext		: out std_logic_vector(11 downto 0)		-- Nächster
	);
end pclogic;

architecture rtl of pclogic is

	signal inc : std_logic_vector(11 downto 0) := (others => '0');
	signal pcreg : std_logic_vector(11 downto 0) 	:= (others => '0');
	signal selpc : std_logic_vector(1 downto 0) 	:= "00"; -- from MUXSEL
begin

	-- Nur bei aktivem REGWRITE und Rising Clock wird der aktuelle PC durchgereicht.
	-- Zuweisung von "INC" setzt alle weiteren Signale
	process (clk, reset) 
	begin
		if reset = '1' then
			pcakt 	<= (others => '0');
			inc 	<= (others => '0');
			inc(0) 	<= '1'; 					-- PC+1; => fires pcinc & pcmux and fires everything else

		elsif rising_edge(clk) and pcwrite='1' then

			pcakt 	<= pcreg; -- LAST STATE!!!! = PC
			inc 	<= std_logic_vector(unsigned(pcreg) + 1); -- PC+1; => fires pcinc & pcmux and fires everything else

		end if;
	end process; 

	-- Setzte PCREG sobald sich was ändert
	process (selpc, pcwrite, intr, isra, isrr, pcnew, inc)
	begin
		-- IRQMUX
		if intr = '1' then
			pcreg <= isra;
		else
			-- PCMUX
			if selpc = "10" then
				pcreg <= isrr;
			elsif selpc = "01" then
				pcreg <= pcnew;
			else
				pcreg <= inc;
			end if;
		end if;
	end process;

	-- MUXSEL
	--			5	  4     3     2    1     0	
	-- pccontr: JAL, JREG, RETI, BOV, BEQZ, BNEZ
	selpc 	<= "10" when pccontr(3)='1' else 	-- RETI is set
				"01" when 						-- JUMP or BRANCH
					(pccontr(2)='1' and ov='1') or 
					(pccontr(1)='1' and zero='1') or 
					(pccontr(0)='1' and zero='0') or 
					(pccontr(5 downto 4) /= "00") 
				else 
				"00"; 


	pcinc 	<= inc;

	-- PCMUX set pcnext output
	pcnext  <= 	isrr when selpc = "10" else
				pcnew when selpc = "01" else
				inc;


	-- OLD
	--inc 	<= std_logic_vector(unsigned(pcreg) + 1); 	-- PC+1;
	--pcakt 	<= pcreg;

end rtl;