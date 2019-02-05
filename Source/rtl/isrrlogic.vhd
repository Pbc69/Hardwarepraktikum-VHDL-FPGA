---------------------------------------------------------------------------------------------------
--
-- Titel: ISRR Logic
-- Autor: hadesXI_13   
-- Datum: 15.11.2018
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.hadescomponents.all;
	
entity isrrlogic is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control & address input
		pcwrite		: in  std_logic;
		intr		: in  std_logic;
		reti		: in  std_logic;
		pcnext		: in  std_logic_vector(11 downto 0);
		curlvl		: in  std_logic_vector(2 downto 0);
		
		-- address output
		retilvl		: out std_logic_vector(2 downto 0);
		isrr		: out std_logic_vector(11 downto 0)
	);
end isrrlogic;

architecture rtl of isrrlogic is
	type register_type is array (0 to 3) of std_logic_vector(14 downto 0); --15bits for return adress = LVL & ISRR
	signal reg : register_type;
begin

	process (clk,reset) 
	begin
		if reset='1' then
			for i in 0 to 3 loop
        		reg(i) <= O"0" & x"FFE";
			end loop;
		
		elsif rising_edge(clk) then --or falling_edge(clk) then
			if pcwrite='1' then
				if intr='1' and reti='0' then	
					-- shift all 
					reg(1) <= reg(0);
					reg(2) <= reg(1);
					reg(3) <= reg(2);

					-- save current input
					reg(0) <= curlvl & pcnext; 				-- ISRR1

				elsif intr='0' and reti='1' then
					-- shift back (pop command)
					reg(0) <= reg(1);
					reg(1) <= reg(2);
					reg(2) <= reg(3);
					reg(3) <= O"0" & x"FFE"; --default
				end if;
			end if;
		end if;
	end process;

	retilvl <= reg(0)(14 downto 12);
	isrr 	<= reg(0)(11 downto 0);
end rtl;
