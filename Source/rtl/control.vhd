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
	
entity control is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control inputs
		inop		: in  std_logic;
		outop		: in  std_logic;
		loadop		: in  std_logic;
		storeop		: in  std_logic;
		dpma		: in  std_logic;
		epma		: in  std_logic;
		xack		: in  std_logic;
		xpresent	: in  std_logic;
		dmembusy	: in  std_logic;
		
		-- control outputs
		loadir		: out std_logic;
		regwrite	: out std_logic;
		pcwrite		: out std_logic;
		pwrite		: out std_logic;
		xread		: out std_logic;
		xwrite		: out std_logic;
		xnaintr		: out std_logic
	);
end control;

architecture rtl of control is	
  	TYPE state_type IS (IFETCH, IDECODE, ALU, IOREAD, IOWRITE, MEMREAD, MEMWRITE, XBUSNAINTR, WRITEBACK);  -- Define states
	signal state : state_type := IFETCH;    -- Create a signal that uses the different states
  	signal pma : std_logic := '1';

begin
	loadir 	<= 	'1' when state = IFETCH else
				'0';
	xread 	<= 	'1' when state = IOREAD or state = MEMREAD else
				'0';
	xwrite 	<= 	'1' when state = IOWRITE or (state = MEMWRITE and pma = '0')else
				'0';
	pwrite 	<= 	'1' when state = MEMWRITE and pma = '1' else
				'0';
	xnaintr <= 	'1' when state = XBUSNAINTR else
				'0';
	pcwrite <= 	'1' when state = XBUSNAINTR or state = WRITEBACK else
				'0';
	regwrite <= '1' when state = WRITEBACK else
				'0';
			
			
	process (clk, reset) 
		variable t_pma : std_logic := '1';
	begin 

		if reset = '1' then
			state <= IFETCH;
			t_pma := '1';                 --pma logic set 1 on reset  
		elsif rising_edge(clk) then   

			-- pma logic
			if dpma = '1' then
				t_pma := '0';         
			elsif epma = '1' then
				t_pma := '1';   
			end if;
			

			-- set next state
			case state is
				when IFETCH => 
					state <= IDECODE;

				when IDECODE => 
					state <= ALU;

				when ALU => 
					if inop = '1' then 
						state <= IOREAD;
					elsif outop = '1' then
						state <= IOWRITE;
					elsif loadop = '1' then 
						state <= MEMREAD;
					elsif storeop = '1' then
						state <= MEMWRITE;
					else
						state <= WRITEBACK;
					end if;

				when IOREAD => 
					if xpresent = '0' then
						state <= XBUSNAINTR;
					elsif xack = '1' then
						state <= WRITEBACK;
					end if;
				
				when IOWRITE => 
					if xpresent = '0' then
						state <= XBUSNAINTR;
					elsif xack = '1' then
						state <= WRITEBACK;
					end if;
				
				when MEMREAD => 
					if dmembusy = '0' then
						state <= WRITEBACK;
					end if;
				
				when MEMWRITE => 
					if dmembusy = '0' or t_pma = '1' then
						state <= WRITEBACK;
					end if;
				
				when XBUSNAINTR | WRITEBACK=> 
					state <= IFETCH;

			end case; 

			
		end if;
		pma <= t_pma;
	end process;
end rtl;
