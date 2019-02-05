---------------------------------------------------------------------------------------------------
--
-- Titel:    
-- Autor: hadesXI_13
-- Datum:    
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.hadescomponents.all;
	
entity haregs is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- write port
		regwrite	: in  std_logic;
		wopadr		: in  std_logic_vector(2 downto 0);
		wop			: in  std_logic_vector(31 downto 0);
		
		-- read port A
		aopadr		: in  std_logic_vector(2 downto 0);
		aop			: out std_logic_vector(31 downto 0);
		
		-- read port B
		bopadr		: in  std_logic_vector(2 downto 0);
		bop			: out std_logic_vector(31 downto 0)
	);
end haregs;

architecture rtl of haregs is
	type register_type is array (0 to 7) of std_logic_vector(31 downto 0);    	-- R0 bis R7 aus 32bits
	signal reg : register_type := (others=>(others=>'0'));         				-- init all register with zero's

begin

	-- process on signal: reset or clock
	process (reset, clk)
	begin 
		if reset = '1' then
			for i in 1 to 7 loop                           	-- reset register from 1 to 7
				reg(i) <= (others=>'0');
			end loop;

		elsif rising_edge(clk) and regwrite='1' then 
			if wopadr /= "000" then             				-- don't overwrite R0
				reg(to_integer(unsigned(wopadr))) <= wop;
			end if;
		end if;
	end process;

	-- process on signal: register change or aopadr or boadr
	-- asynchron to clock
	-- update Output on aop & bop
	aop <= reg(to_integer(unsigned(aopadr)));
	bop <= reg(to_integer(unsigned(bopadr)));

end rtl;