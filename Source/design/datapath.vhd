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
library xbus_common;
	use xbus_common.xtoolbox.all;
library work;
	use work.all;
	use work.hadescomponents.all;
	
entity datapath is
	port (
		-- common
	  	clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control
		opc			: in  std_logic_vector(4 downto 0);
		regwrite	: in  std_logic;
		
		-- input data
		aop			: in  std_logic_vector(31 downto 0);
		bop			: in  std_logic_vector(31 downto 0);
		iop			: in  std_logic_vector(15 downto 0);
		ivalid		: in  std_logic;
		
		-- output data
		wop			: out std_logic_vector(31 downto 0);
		
		-- XBus
		selxres		: in  std_logic;
		xdatain		: in  std_logic_vector(31 downto 0);
		xdataout	: out std_logic_vector(31 downto 0);
		xadr		: out std_logic_vector(12 downto 0); -- war ein fehler!!! das muss 12 sein nicht 18!!
		
		-- status flags
		zero		: out std_logic;
		ov			: out std_logic;
		
		-- program counter
		jal			: in  std_logic;
		rela		: in  std_logic;
		pcinc		: in  std_logic_vector(11 downto 0);
		pcnew		: out std_logic_vector(11 downto 0);
		sisalvl     : out std_logic_vector(1 downto 0)
	);
end datapath;

architecture rtl of datapath is		

	-- Buffer registers
	signal zff : std_logic := '0';
	signal opreg : std_logic_vector(4 downto 0) := (others => '0');
	signal areg, bcreg, rreg, breg, xreg : std_logic_vector(31 downto 0) := (others => '0');

	-- connections between components
	signal pipe_zff : std_logic := '0';
	signal pipe_rreg : std_logic_vector(31 downto 0) := (others => '0');

begin 

	-- alu is clock asynchron!
	alu1 : entity alu
	port map(
		-- common
		clk 		=> clk,
    	reset	 	=> reset,
    		
		-- control inputs
		opcode		=> opreg,
		regwrite 	=> regwrite,
		
		-- data input
		achannel	=> areg,
		bchannel	=> bcreg,
		
		-- outputs
		result		=> pipe_rreg,
		zero		=> pipe_zff, 
		overflow	=> ov
	);
  
	process (clk, reset)
	begin

      -- async reset, zustands gesteuerte flipflops
    	if reset = '1' then

			xdataout <= (others => '0');
			areg 	<= (others => '0');
			opreg 	<= (others => '0');
			
			bcreg 	<= (others => '0');
			xreg 	<= (others => '0');
			rreg 	<= (others => '0');
			zff 	<= '0';

		elsif rising_edge(clk) then

			-- FlipFlops set on rising clock
			-- before alu
			opreg 	<= opc;
			areg 	<= aop;
			xdataout <= bop;

			-- after alu
			rreg 	<= pipe_rreg;
			zff 	<= pipe_zff;
			xreg 	<= xdatain;

			
			if ivalid = '0' then
				bcreg <= bop;
			else
				-- For some OPcodes the immediate value has to be converted to signed
				case opc is
					when opc_SUB | opc_ADD | opc_MUL => 	-- SIGNED
						--report "B: " & to_hex(std_logic_vector(to_signed(to_integer(signed(iop)), 32))) &"; " &integer'image(to_integer(signed(iop)));

						-- extend to 32 bits and keep sign!
						-- convert 16bit vector to a signed integer, e.g. 0xFFFF = -1
						-- convert to a 32bit signed vector => 0xFFFFFFFF
						bcreg <= std_logic_vector(to_signed(to_integer(signed(iop)), 32));

					when others => 					--UNSIGNED
						bcreg <= (others => '0');
						bcreg(15 downto 0) <= iop; -- 16 bits
				end case;
			end if; 

		end if;
	end process;


	process (rreg) begin
		sisalvl <= rreg(15 downto 14); --15 and 14 bit
		
        xadr(11 downto 0) <= rreg(11 downto 0);   -- XADR = LSB of alu result : 13 bit = OR comination of other 20 bits of alu result
        if rreg(31 downto 12) /= "00000000000000000000" then -- 20bits
          xadr(12) <= '1';
        else
          xadr(12) <= '0';
        end if;
	end process;

	
	-- DMUS & PCMUX unabhängig von clock
	-- wenn sich was ändert muss wop neu gesetzt werden
    wop <=  xreg when selxres = '1' else
            rreg when jal = '0' else
            x"00000" & pcinc;

  	pcnew 	<=  rreg(11 downto 0) when rela = '0' else
				std_logic_vector(unsigned(rreg(11 downto 0)) + unsigned(pcinc));
				
	zero <= zff;

end rtl;
