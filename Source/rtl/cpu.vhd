---------------------------------------------------------------------------------------------------
--
-- Titel:    
-- Autor: Hades_XI13
-- Datum:    
--
-- cpu 1, tested, checked waveform, xbus mem & reg all correct 17.12
-- cpu 2, tested, checked waveform, xbus mem all correct 17.12
-- cpu 3, tested, checked waveform, all correct 17.12
-- cpu 4, tested, checked waveform, all correct 17.12
-- cpu 5, tested IRSA 2 and 3 wrong afte 440ns!!! BUG 17.12.
---------------------------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.all;
	use work.hadescomponents.all;
	
entity cpu is
	generic (
		INIT		: string := "UNUSED"
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- XBus
		xread		: out std_logic;
		xwrite		: out std_logic;
		xadr		: out std_logic_vector(12 downto 0);
		xdatain		: in  std_logic_vector(31 downto 0);
		xdataout	: out std_logic_vector(31 downto 0);
		xpresent	: in  std_logic;
		xack		: in  std_logic;
		dmemop		: out std_logic;
		dmembusy	: in  std_logic;
		xperintr	: in  std_logic;
		xmemintr	: in  std_logic
	);
end cpu;

architecture rtl of cpu is

	-- Pmemory
	signal iword 	: std_logic_vector(31 downto 0); 		--> Control 


	-- Haregs
	signal aop 		: std_logic_vector(31 downto 0);	-- Datapath
	signal bop 		: std_logic_vector(31 downto 0);	-- Datapath
	
	
	-- Indec Outouts
	signal aopadr 	: std_logic_vector(2 downto 0);		--> Haregs
	signal bopadr 	: std_logic_vector(2 downto 0);		--> Haregs
	signal wopadr 	: std_logic_vector(2 downto 0);		--> Haregs
	signal iop		: std_logic_vector(15 downto 0);	--> Datapath
	signal ivalid	: std_logic;						--> Datapath
	signal opc		: std_logic_vector(4 downto 0);		--> Datapath
	signal pccontr	: std_logic_vector(10 downto 0);	--> Datapath Jal & Rela & Pcblock
	signal inop		: std_logic;		--> Control
	signal outop	: std_logic;		--> Control
	signal loadop	: std_logic;		--> Control
	signal storeop	: std_logic;		--> Control
	--signal dmemop	: std_logic;		--> Control
	signal selxres	: std_logic;		--> Datapath
	signal dpma		: std_logic;		--> Control
	signal epma		: std_logic;		--> Control
	
	
	-- Control Output 
	signal loadir		: std_logic;	--> Pmemory
	signal regwrite		: std_logic;	--> Haregs & Datapath
	signal pcwrite		: std_logic;
	signal pwrite		: std_logic;
	--signal xread		: std_logic;
	--signal xwrite		: std_logic;
	signal xnaintr		: std_logic;


	-- DatapathOutput
	signal wop	: std_logic_vector(31 downto 0);	--> Haregs
	signal pipe_xadr: std_logic_vector(12 downto 0);	--> Pmemory & Xadr
	--output signal xdataout
	signal pcnew	: std_logic_vector(11 downto 0);
	signal sisalvl	: std_logic_vector(1 downto 0);
	signal ov		: std_logic;
	signal zero		: std_logic;


	-- PC Block Output
	signal pcakt	: std_logic_vector(11 downto 0);	--> PMEMORY (radr)
	signal pcinc	: std_logic_vector(11 downto 0);	--> Datapath

begin
	pmemory1: entity pmemory
		generic map (
			INIT 		=> INIT		-- for loading an assembler program
		)
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- write port
			pwrite		=> pwrite,
			wadr		=> pipe_xadr(11 downto 0),
			datain		=> bop,
			
			-- read port
			loadir		=> loadir,
			radr		=> pcakt,
			dataout		=> iword
		);

	indec1: entity indec
		port map (
			-- instruction word input
			iword		=> iword,
			
			-- register addresses
			aopadr		=> aopadr,
			bopadr		=> bopadr,
			wopadr		=> wopadr,
			
			-- immediate value
			ivalid		=> ivalid,
			iop			=> iop,
			
			-- control flags
			opc			=> opc,
			pccontr		=> pccontr,
			inop		=> inop,
			outop		=> outop,
			loadop		=> loadop,
			storeop		=> storeop,
			dmemop		=> dmemop,
			selxres		=> selxres,
			dpma		=> dpma,
			epma		=> epma
		);
		
	haregs1: entity haregs
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- write port
			regwrite	=> regwrite,
			wopadr		=> wopadr,
			wop			=> wop,
			
			-- read port A
			aopadr		=> aopadr,
			aop			=> aop,
			
			-- read port B
			bopadr		=> bopadr,
			bop			=> bop
		);

	control1: entity control
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- control inputs
			inop		=> inop,
			outop		=> outop,
			loadop		=> loadop,
			storeop		=> storeop,
			dpma		=> dpma,
			epma		=> epma,
			xack		=> xack,
			xpresent	=> xpresent,
			dmembusy	=> dmembusy,
			
			-- control outputs
			loadir		=> loadir,
			regwrite	=> regwrite,
			pcwrite		=> pcwrite,
			pwrite		=> pwrite,
			xread		=> xread,
			xwrite		=> xwrite,
			xnaintr		=> xnaintr
		);

	datapath1: entity datapath
		port map (
			-- common
		  	clk 		=> clk,
			reset		=> reset,
			
			-- control
			opc			=> opc,
			regwrite	=> regwrite,
			
			-- input data
			aop			=> aop,
			bop			=> bop,
			iop			=> iop,
			ivalid		=> ivalid,
			
			-- output data
			wop			=> wop,
			
			-- XBus
			selxres		=> selxres,
			xdatain		=> xdatain,
			xdataout	=> xdataout,
			xadr		=> pipe_xadr,
			
			-- status flags
			zero		=> zero,
			ov			=> ov,
			
			-- program counter
			jal			=> pccontr(8),
			rela		=> pccontr(10),
			pcinc		=> pcinc,
			pcnew		=> pcnew,
			sisalvl     => sisalvl
		);

	pcblock1: entity pcblock
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- interrupt inputs
			xperintr	=> xperintr,
			xnaintr		=> xnaintr,
			xmemintr	=> xmemintr,
			
			-- ALU flags
			ov			=> ov,
			zero		=> zero,
			
			-- control input
			pcwrite		=> pcwrite,
			pccontr		=> pccontr,
			pcnew		=> pcnew,
			sisalvl     => sisalvl,
	
			-- control output
			pcakt		=> pcakt,
			pcinc		=> pcinc
		);

	xadr <= pipe_xadr;
end rtl;
