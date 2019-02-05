---------------------------------------------------------------------------------------------------
--
-- Titel: Program Counter
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
	
entity pcblock is
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- interrupt inputs
		xperintr	: in  std_logic;
		xnaintr		: in  std_logic;
		xmemintr	: in  std_logic;
		
		-- ALU flags
		ov			: in  std_logic;
		zero		: in  std_logic;
		
		-- control input
		pcwrite		: in  std_logic;
		pccontr		: in  std_logic_vector(10 downto 0);
		pcnew		: in  std_logic_vector(11 downto 0);
		sisalvl     : in  std_logic_vector(1 downto 0);

		-- control output
		pcakt		: out std_logic_vector(11 downto 0);
		pcinc		: out std_logic_vector(11 downto 0)
	);
end pcblock;

architecture rtl of pcblock is
	signal pccontr_irq	: std_logic_vector(4 downto 0) := (others => '0');
	signal pccontr_pc	: std_logic_vector(5 downto 0) := (others => '0');

	-- connection from IRQ to PC component
	signal intr		: std_logic := '0';
	signal isra		: std_logic_vector(11 downto 0) := (others => '0');
	signal isrr		: std_logic_vector(11 downto 0) := (others => '0');

	-- connection from PC to IRQ component
	signal pcnext	: std_logic_vector(11 downto 0) := (others => '0');
begin

	-- IRQ-Logic
	irqlogic1 : entity irqlogic
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- interrupt inputs
			xperintr	=> xperintr,
			xnaintr		=> xnaintr,
			xmemintr	=> xmemintr,
			
			-- control input
			pcwrite		=> pcwrite,
			pccontr		=> pccontr_irq,
			pcnext		=> pcnext,
			pcnew		=> pcnew,
			sisalvl	 	=> sisalvl,
			
			-- control output
			intr		=> intr,
			isra		=> isra,
			isrr		=> isrr
		);
	
	-- PC-Logic
	pclogic1 : entity pclogic
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,

			-- control flags			
			pcwrite		=> pcwrite,
			pccontr		=> pccontr_pc,
			ov			=> ov,
			zero		=> zero,
			intr		=> intr,
			
			-- program counter inputs
			pcnew		=> pcnew,
			isra		=> isra,
			isrr		=> isrr,
	
			-- program counter outputs
			pcakt		=> pcakt,
			pcinc		=> pcinc,
			pcnext		=> pcnext
		);

	-- Setze PCCONTROL für die jeweiligen Componenten
	process (pccontr) 
	begin

		-- IRC 
		pccontr_irq(4) 			<= pccontr(9); 			-- SWI
		pccontr_irq(3 downto 0) <= pccontr(6 downto 3); -- RETI, ENI, DEI, SISA

		-- PC
		pccontr_pc(5 downto 3) <= pccontr(8 downto 6) ; -- JAL, JREG, RETI
		pccontr_pc(2 downto 0) <= pccontr(2 downto 0) ; -- BOV, BEQZ, BNEZ

	end process;
end rtl;
