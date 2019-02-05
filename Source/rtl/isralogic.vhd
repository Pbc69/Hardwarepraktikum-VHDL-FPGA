---------------------------------------------------------------------------------------------------
--
-- Titel:    
-- Autor: hadesXI_13
-- Datum: 15.11.2018
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.hadescomponents.all;
	
entity isralogic is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- address input
		pcwrite		: in  std_logic;
		sisa		: in  std_logic;
		sisalvl		: in  std_logic_vector(1 downto 0);
		pcnew		: in  std_logic_vector(11 downto 0);
		
		-- address output
		selisra		: in  std_logic_vector(2 downto 0);
		isra		: out std_logic_vector(11 downto 0)
	);
end isralogic;

architecture rtl of isralogic is
	type register_type is array (0 to 3) of std_logic_vector(11 downto 0);
  	signal reg : register_type;
begin

	process (clk, reset) 
	begin
		if reset = '1' then
			for i in 0 to 3 loop
        		reg(i) <= x"FFF";
			  end loop;
		elsif rising_edge(clk) then	-- clk correct tested
			if pcwrite = '1' and sisa='1' then
				reg(to_integer(unsigned(sisalvl))) <= pcnew;		-- SISALVL is INDEX of register (from "00" to "11") ez.
			end if;
		end if;
	end process;

	-- ISRAMUX
	isra <= 	reg(0) when selisra = O"1" else
				reg(1) when selisra = O"2" else
				reg(2) when selisra = O"3" else
				reg(3) when selisra = O"4" else
				x"000";
end rtl;
