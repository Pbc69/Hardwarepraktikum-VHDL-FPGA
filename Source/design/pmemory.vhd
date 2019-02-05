---------------------------------------------------------------------------------------------------
--
-- Titel:    
-- Autor:    
-- Datum:    
--
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
  use work.hadescomponents.all;

entity pmemory is
	generic (
		INIT		: string := "UNUSED"
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- write port
		pwrite		: in  std_logic;						--Write signal
		wadr		: in  std_logic_vector(11 downto 0);	--Address for next instruction to be written
		datain		: in  std_logic_vector(31 downto 0);	--Write value to address WADR(11..0)
		
		-- read port
		loadir		: in  std_logic;						--Read signal
		radr		: in  std_logic_vector(11 downto 0);	--Address for next instruction to be read
		dataout		: out std_logic_vector(31 downto 0)		--Instruction code on address RADR(11..0)
	);
end pmemory;

architecture rtl of pmemory is	
	

begin
	hadesram : entity work.hades_ram32_dp(rtl) 
		generic map(
			WIDTH_ADDR	=> 	12,
			INIT_FILE	=>	INIT,
			INIT_DATA	=> hades_bootloader
		)
		port map( 
			--common ports
			clk 	    => clk,
			reset  	  	=> reset,				
			-- write port
			wena        => pwrite,
			waddr       => wadr,
			wdata       => datain,
			--read Ports
			rena        => loadir,
			raddr       => radr,
			rdata       => dataout
		);
end rtl;
