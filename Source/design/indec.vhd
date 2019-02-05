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
	
entity indec is
	port (
		-- instruction word input
		iword		: in  std_logic_vector(31 downto 0);
		
		-- register addresses
		aopadr		: out std_logic_vector(2 downto 0);
		bopadr		: out std_logic_vector(2 downto 0);
		wopadr		: out std_logic_vector(2 downto 0);
		
		-- immediate value
		ivalid		: out std_logic;
		iop			: out std_logic_vector(15 downto 0);
		
		-- control flags
		opc			: out std_logic_vector(4 downto 0);
		pccontr		: out std_logic_vector(10 downto 0);
		inop		: out std_logic;
		outop		: out std_logic;
		loadop		: out std_logic;
		storeop		: out std_logic;
		dmemop		: out std_logic;
		selxres		: out std_logic;
		dpma		: out std_logic;
		epma		: out std_logic
		
	);

	
end indec;

-- Update 19.12.2018. Habe cpu5 mit hades emulator verglichen. Dabei habe ich festgestellt, dass der Befehl
-- SWI => 000B: 017F00C8;          SWI r7, 200
-- den HexCode: 0000 00010 111 111 1 0000 0000 1100 1000 erzeugt.
-- Laut Angabe muessen allerdings die bits 22 bis 20 0 sein und nicht wie im Assembler 111
-- Dadurch wird bei uns das Register welches zuvor gesetzt war, geloescht! Evtl ist das egal, vlt auch ncht!


architecture rtl of indec is
begin

	-- update all directly mappable values
	-- process (iword) is
	process (iword) 
	begin
	
		opc 	<= iword(27 downto 23);     -- command for the alu
		ivalid 	<= iword(16);            	-- immediate command or not
		iop 	<= iword(15 downto 0);      -- immediate value
		aopadr 	<= iword(19 downto 17);  	-- which register used for operand A
		bopadr 	<= "000";
		--bopadr 	<= iword(15 downto 13);  	-- with register used for operand B
											-- with exception OUT and STORE
											-- in that case bopadr will be overwritten 
											-- with correct value
		wopadr <= "000";
		--wopadr <= iword(22 downto 20);  	-- register which the solution of operation should be stored in
											-- if it should not be stored - zero register r0
											-- exception for command OUT and STORE
											-- will be overwritten in that case
		pccontr <= "00000000000";							
		
		-- set initial value to these values
		-- value will be overwritten later if needed
		inop    <= '0';
		outop	<= '0';
		loadop	<= '0';
		storeop	<= '0';
		dmemop	<= '0';
		selxres	<= '0';
		dpma	<= '0';
		epma	<= '0';
			
		case iword(31 downto 28) is
			when x"0" =>
				if iword(16) = '1' then --is Immidiate Command

					if iword(27 downto 23) = "00010" then  		-- SWI
						pccontr <= "01000000000";
						
					elsif iword(27 downto 23) = "00011" then   	-- GETSWI
						wopadr <= iword(22 downto 20);

					else 										-- then ALUI
						wopadr <= iword(22 downto 20);
					end if;

				else  --is not immidiate
					
					if iword(27 downto 23) = "00000" then
						-- is NOP instruction
					
					else
						-- is ALU instruction
						bopadr 	<= iword(15 downto 13);
						wopadr <= iword(22 downto 20);
					end if;
				
				end if;
				
			when x"1" =>						-- is ENI instruction
				pccontr <= "00000100000";
			
			when x"2" =>						-- is IN instruction
				inop 	<= '1';
				selxres <= '1';
				wopadr <= iword(22 downto 20);
				
			when x"3" =>						-- is OUT instruction
				outop 	<= '1';
				selxres <= '1';
				bopadr 	<= iword(22 downto 20);
				--wopadr 	<= "000";
			
			when x"4" =>						-- is DEI instruction
				pccontr <= "00000010000";
			
			when x"5" =>						-- is BNEZ instruction
				pccontr <= "10000000001";
			
			when x"6" =>						-- is BEQZ instruction
				pccontr <= "10000000010";
			
			when x"7" =>						-- is BOV instruction
				pccontr <= "10000000100";
			
			when x"8" =>						-- is LOAD instruction
				loadop 	<= '1';
				dmemop 	<= '1';
				selxres <= '1';
				wopadr <= iword(22 downto 20);
				
			when x"9" =>						-- is STORE instruction
				storeop 	<= '1';
				dmemop 		<= '1';
				selxres 	<= '1';
				bopadr 		<= iword(22 downto 20);
				--wopadr 		<= "000";
			
			when x"A" =>						-- is JAL instruction
				pccontr <= "10100000000";
				wopadr <= iword(22 downto 20);
			
			when x"B" =>						-- is JREG instruction
				pccontr <= "00010000000";
			
			when x"C" =>						-- is RETI instruction
				pccontr <= "00001000000";
			
			when x"D" =>						-- is SISA instruction
				pccontr <= "10000001000";
			
			when x"E" =>						-- is DPMA instruction
				dpma <= '1';

			when others => -- 0xF				-- is EPMA
				epma <= '1';

		end case;
				
	end process;
	
	end rtl;
