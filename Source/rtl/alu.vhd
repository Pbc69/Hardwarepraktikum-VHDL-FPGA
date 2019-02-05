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
	use work.all;
	use work.hadescomponents.all;
	
entity alu is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control inputs
		opcode		: in  std_logic_vector(4 downto 0);
		regwrite	: in  std_logic;
		
		-- data input
		achannel	: in  std_logic_vector(31 downto 0);
		bchannel	: in  std_logic_vector(31 downto 0);
		
		-- result
		result		: out std_logic_vector(31 downto 0);
		zero		: out std_logic;
		overflow	: out std_logic
	);
end alu;

architecture rtl of alu is

	signal shift_opt : std_logic_vector(1 downto 0) := "00"; -- hades shift options. 1.bit left=0, right=1, 0.bit cycle=1
	signal sub_opt, lt,eq,gt : std_logic := '0';

	-- result outputs of hades components
	-- depending on opcode, this will be assigned to final result output
	signal result_addsub, result_shift, result_mul : std_logic_vector(31 downto 0) := (others => '0');

	-- overflow outputs of hades components
	-- depending on opcode, this will be assigned to final overflow output and cvff
	signal ov_addsub, ov_shift, ov_mul : std_logic := '0';
	

	-- register for SWI
	signal swiaff, swibff : std_logic_vector(31 downto 0) := x"00000000";

	-- overflow flipflop
	signal ovff 		: std_logic := '0'; -- overflow flipflop
	--signal next_ovff 	: std_logic := '0';
begin

	---------------
	-- Create instances of Hades components
	haddsub: entity work.hades_addsub(rtl)
	generic map (N => 32)
	port map (
		sub => sub_opt, -- 1=sub, 0=add
		a => achannel,
		b => bchannel,
		r => result_addsub,
		ov => ov_addsub
	);     
	
	hshift: entity work.hades_shift(rtl)
	generic map (N => 32)
	port map (
		cyclic => shift_opt(0), -- 0.bit cycle=1
		right => shift_opt(1),  -- 1.bit left=0, right=1
		a => achannel,
		b => bchannel(4 downto 0),  -- log(32)-1 = 4 : how many shifts
		r => result_shift,
		ov => ov_shift
	);     

	hmul: entity work.hades_mul(rtl)
	generic map (N => 32)
	port map (
		clk => clk,
		a => achannel,
		b => bchannel,
		r => result_mul,
		ov => ov_mul
	);     

	hcompare: entity work.hades_compare(rtl)
	generic map (N => 32)
	port map (
		a => achannel, 
		b => bchannel,
		lt => lt,
		eq => eq,
		gt => gt 
	);
	---------------


	-- Handle SWI Register writes
	process (regwrite, reset) 
	begin
		if reset = '1' then
			swiaff 	<= (others => '0');
			swibff 	<= (others => '0');
		else
			if opcode = opc_SWI and regwrite = '1' then
				swiaff <= achannel;
				swibff <= bchannel;
			end if;
		end if;
	end process;


	-- Handle result, instant write on any change
	process (opcode, result_mul, result_addsub, result_shift)
	begin  
		
		result 	<= (others => '0'); 	-- clear and overwrite on need

		case opcode is
			-- handled in other processes
			--when opc_SWI =>
			--when opc_SETOV =>

			when opc_GETSWI =>
				if bchannel(0) = '0' then
					result <= swibff;
				else
					result <= swiaff;
				end if;


			-- Shift
			when opc_SHL | opc_SHR | opc_CSHL | opc_CSHR =>
				result <= result_shift;

			-- basic commands
			when opc_AND =>
				for i in 0 to 31 loop
					result(i) <= achannel(i) and bchannel(i);
				end loop;

			when opc_OR =>
				for i in 0 to 31 loop
					result(i) <= achannel(i) or bchannel(i);
				end loop;

			when opc_XOR =>
				for i in 0 to 31 loop
					result(i) <= achannel(i) xor bchannel(i);
				end loop;

			when opc_XNOR =>
				for i in 0 to 31 loop
					result(i) <= achannel(i) xnor bchannel(i);
				end loop;


			-- Branches and Pass
			when opc_BNEZ | opc_BEQZ | opc_PASS =>
				result(15 downto 0) <= bchannel(15 downto 0);


			-- Add or Sub
			when opc_SUB | opc_ADD =>
				result <= result_addsub;


			when opc_GETOV =>
				result(0) <= ovff; -- MSB cleared and LSB is ovff
	

			-- Multiplication
			when opc_MUL =>
				result <= result_mul;

			-- COMPARE commands
			when opc_SNE => -- a != b
				result(0) <= NOT(eq);

			when opc_SEQ => -- a = b
				result(0) <= eq;

			when opc_SGT => -- a > b
				result(0) <= gt;

			when opc_SGE => -- a >= b
				result(0) <= gt or eq;

			when opc_SLT => -- a < b
				result(0) <= lt;

			when opc_SLE => -- a <= b
				result(0) <= lt or eq;
			
			when others =>
		end case;
	end process;



	-- Overflow Process only on clk
	-- Wirte overflow 1 cycle after regwrite swtiched from 1 to 0
	process (clk, reset)
		variable store_ov 	: std_logic := '0';
	begin  

		if reset = '1' then
			ovff 		<= '0';
			store_ov 	:= '0';
		else
			
			if regwrite = '1' then
				store_ov := '1';
			elsif rising_edge(clk) and store_ov = '1' then 
				store_ov := '0';

				case opcode is
					when opc_SHL | opc_SHR | opc_CSHL | opc_CSHR =>
						ovff <= ov_shift;

					when opc_SUB | opc_ADD =>
						ovff <= ov_addsub;

					when opc_SETOV =>
						ovff <= bchannel(0); -- LSB from bchannel

					when opc_MUL =>
						ovff <= ov_mul;

					when others =>
				end case;
			end if;
		end if;
	end process;


	
	sub_opt 	<= 	'1' when opcode = opc_SUB else
					'0';

	shift_opt 	<= 	"11" when opcode = opc_CSHR else
					"10" when opcode = opc_SHR else
					"01" when opcode = opc_CSHL else
					"00"; --when opcode = opc_SHL else
	
	zero 		<= 	'1' when (opcode = opc_BNEZ or opcode = opc_BEQZ) and achannel = (achannel'range => '0') else
					'0';

	overflow 	<= ovff;

end rtl;
