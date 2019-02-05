-------------------------------------------------------------------------------
-- Xlcd_llctrl (LCD driver - low level control)                              --
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.xtoolbox.all;
	
entity Xlcd_llctrl is
	generic (
		FREQ		: natural
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- control
		cmd_ready	: out std_logic;
		cmd_req		: in  std_logic;
		cmd_rs		: in  std_logic;
		cmd_data	: in  std_logic_vector(7 downto 0);
		
		-- LC display
		lcd_en		: out std_logic;
		lcd_rw		: out std_logic;
		lcd_rs		: out std_logic;
		lcd_data	: out std_logic_vector(7 downto 0)
	);
end Xlcd_llctrl;

architecture rtl of Xlcd_llctrl is		

	-- timing constants
	constant DELAY_40us   : natural := integer(real(FREQ)*0.000040000);
	constant DELAY_450ns  : natural := integer(real(FREQ)*0.000000450);
	constant DELAY_40ns   : natural := integer(real(FREQ)*0.000000040);
	
	-- status
	type state_t is (IDLE,SETUP,PULSE,WAITCMD);
	signal state : state_t;
	signal count : unsigned(log2(DELAY_40us)-1 downto 0);
	
begin
	
	-- check if ready for new command
	cmd_ready <= '1' when (state=IDLE and cmd_req='0') else '0';
		
	-- do work
	process(clk,reset)
	begin
		if reset='1' then
			lcd_en   <= '0';
			lcd_rw   <= '0';
			lcd_rs   <= '0';
			lcd_data <= x"00";
			state    <= IDLE;
			count    <= to_unsigned(0, count'length);
		elsif rising_edge(clk) then
			-- decrement wait-counter by default
			count <= count-1;
			
			-- update status
			case state is
				when IDLE =>
					if cmd_req='1' then
						-- write data on bus
						lcd_rw   <= '0';
						lcd_rs   <= cmd_rs;
						lcd_data <= cmd_data;
						
						-- wait address-setup-time
						state <= SETUP;
						count <= to_unsigned(DELAY_40ns-1, count'length);
					end if;
					
				when SETUP =>
					if count=0 then
						-- pulse 'ena' for 450us
						lcd_en <= '1'; 
						state  <= PULSE;
						count  <= to_unsigned(DELAY_450ns-1, count'length);
					end if;
					
				when PULSE =>
					if count=0 then
						-- create falling edge on 'ena' and wait 40us for command to be executed
						lcd_en <= '0'; 
						state  <= WAITCMD;
						count  <= to_unsigned(DELAY_40us-1, count'length);
					end if;
					
				when WAITCMD =>
					if count=0 then
						-- done, reenter idle-state
						state <= IDLE;
					end if;
			end case;
		end if;
	end process;
end rtl;


-------------------------------------------------------------------------------
-- Xlcd_hlctrl (LCD driver - high level control)                             --
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.xtoolbox.all;
library work;
	use work.all;
	
entity Xlcd_hlctrl is
	generic (
		FREQ		: natural;
		SIM         : boolean
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- command interface
		cmd_ack     : out std_logic;
		cmd_clear   : in  std_logic;
		cmd_write   : in  std_logic;
		cmd_move    : in  std_logic;
		cmd_addr    : in  unsigned(4 downto 0);
		cmd_data    : in  std_logic_vector(7 downto 0);
		
		-- LC display
		lcd_en		: out std_logic;
		lcd_rw		: out std_logic;
		lcd_rs		: out std_logic;
		lcd_data	: out std_logic_vector(7 downto 0)
	);
end Xlcd_hlctrl;

architecture rtl of Xlcd_hlctrl is		

	--
	-- config
	--
	
	-- helper function to choose constant depeding on SIM-flag
	function simMux(a,b:natural) return natural is
	begin
		if SIM 
			then return b;
			else return a;
		end if;
	end function;
	
	-- timing constants
	constant DELAY_4100us : natural := simMux(integer(real(FREQ)*0.004100000), 100);
	constant DELAY_1700us : natural := simMux(integer(real(FREQ)*0.001700000),  50);
	constant DELAY_100us  : natural := simMux(integer(real(FREQ)*0.000100000),  10);
	
	--
	-- init sequence
	--
	
	type init_cmd_t is record
		data  : std_logic_vector(7 downto 0);
		rs    : std_logic;
		delay : natural;
	end record;
	type init_cmd_array_t is array(natural range<>) of init_cmd_t;
	
	constant init_cmd_count : natural := 17;
	constant init_cmd_info : init_cmd_array_t(0 to init_cmd_count-1) := (
		(x"30",'0',DELAY_4100us-1),		-- init #1
		(x"30",'0',DELAY_100us-1),		-- init #2
		(x"30",'0',0),					-- init #3
		(x"38",'0',0),					-- bus=8bit, lines=2, font=5x7
		(x"0C",'0',0),					-- display=on, cursor=off, blink=off
		(x"06",'0',0),					-- increment=on, shift=off
		(x"40",'0',0),					-- CG-addr = 0
		(x"01",'1',0),					-- CG0 - line0
		(x"00",'1',0),					-- CG0 - line1
		(x"00",'1',0),					-- CG0 - line2
		(x"00",'1',0),					-- CG0 - line3
		(x"00",'1',0),					-- CG0 - line4
		(x"00",'1',0),					-- CG0 - line5
		(x"00",'1',0),					-- CG0 - line6
		(x"00",'1',0),					-- CG0 - line7
		(x"80",'0',0),					-- move cursor home
		(x"01",'0',DELAY_1700us-1)		-- clear display
	);
	
	--
	-- signals
	--
	
	-- states
	type state_t is (
		SRESET,							-- start state
		INIT_CMD, INIT_WAIT,			-- init sequence
		IDLE, ACTIVE					-- worker
	);
	
	-- status
	signal state  : state_t;
	signal count  : unsigned(log2(DELAY_4100us)-1 downto 0);
	signal icount : unsigned(log2(init_cmd_count)-1 downto 0);
	
	-- low level control
	signal ll_ready	: std_logic;
	signal ll_req	: std_logic;
	signal ll_rs	: std_logic;
	signal ll_data	: std_logic_vector(7 downto 0);
	
begin
	
	-- do work
	process(clk,reset)
		variable n   : integer;
		variable tmp : unsigned(3 downto 0);
	begin
		if reset='1' then
			cmd_ack <= '0';
			ll_req	<= '0';
			ll_rs	<= '0';
			ll_data	<= x"00";
			state   <= SRESET;
			count   <= to_unsigned(0, count'length);
			icount  <= to_unsigned(0, icount'length);
		elsif rising_edge(clk) then
			-- apply default values
			count   <= count-1;
			ll_req  <= '0';
			cmd_ack <= '0';
			
			-- update status
			case state is
				when SRESET =>
					-- start executing init-sequence
					state <= INIT_CMD;
					
				when INIT_CMD =>
					if icount<init_cmd_count then
						-- issue next command
						n := to_integer(icount);
						icount  <= icount+1;
						ll_req	<= '1';
						ll_rs	<= init_cmd_info(n).rs;
						ll_data	<= init_cmd_info(n).data;
						count   <= to_unsigned(init_cmd_info(n).delay, count'length);
						state   <= INIT_WAIT;
					else
						-- init done
						state <= IDLE;
					end if;
					
				when INIT_WAIT =>
					-- wait until timer has ellapsed
					if count=0 then
						if ll_ready='1' then
							--> command done
							state <= INIT_CMD;
						else
							-- timer ellapsed, but lowlevel-ctrl is not ready yet
							count <= to_unsigned(0, count'length); -- prevent timer from underflow
						end if;
					end if;
					
				when IDLE =>
					if ll_ready='1' then
						if cmd_clear='1' then
							-- clear display 
							ll_req	<= '1';
							ll_rs	<= '0';
							ll_data	<= x"01";
							count   <= to_unsigned(DELAY_1700us-1, count'length);
							state   <= ACTIVE;
							cmd_ack <= '1';
						elsif cmd_move='1' then
							-- move cursor
							ll_req	<= '1';
							ll_rs	<= '0';
							ll_data	<= std_logic_vector("1" & cmd_addr(4) & "00" & cmd_addr(3 downto 0));
							count   <= to_unsigned(0, count'length);
							state   <= ACTIVE;
							cmd_ack <= '1';
						elsif cmd_write='1' then
							-- write char
							ll_req	<= '1';
							ll_rs	<= '1';
							ll_data <= cmd_data;
							count   <= to_unsigned(0, count'length);
							state   <= ACTIVE;
							cmd_ack <= '1';
						end if;
					end if;
					
				when ACTIVE =>
					-- wait until timer has ellapsed
					if count=0 then
						state <= IDLE;
					end if;
					
				when others =>
					null;
			end case;
		end if;
	end process;
	
	-- low level control
	i_ll: entity Xlcd_llctrl
		generic map (
			FREQ		=> FREQ
		)
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- control
			cmd_ready	=> ll_ready,
			cmd_req		=> ll_req,
			cmd_rs		=> ll_rs,
			cmd_data	=> ll_data,
			
			-- LC display
			lcd_en		=> lcd_en,
			lcd_rw		=> lcd_rw,
			lcd_rs		=> lcd_rs,
			lcd_data	=> lcd_data
		);
end rtl;



-------------------------------------------------------------------------------
-- Xlcd (LCD driver)                                                         --
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.xtoolbox.all;
library work;
	use work.all;
	
entity Xlcd is
	generic (
		FREQ		: natural;
		SIM         : boolean
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- bus interface
		adr			: in  unsigned(7 downto 0);
		datain		: in  std_logic_vector(31 downto 0);
		dataout		: out std_logic_vector(31 downto 0);
		read		: in  std_logic;
		write		: in  std_logic;
		present		: out std_logic;
		ack			: out std_logic;
		intr		: out std_logic;
		
		-- LC display
		lcd_en		: out std_logic;
		lcd_rw		: out std_logic;
		lcd_rs		: out std_logic;
		lcd_data	: out std_logic_vector(7 downto 0)
	);
end Xlcd;

architecture rtl of Xlcd is		

	-- config
	constant BASE : natural := 70;
	constant REGS : natural := 2;
	
	-- register bank
	signal reg_data	: regbank(REGS-1 downto 0);
	signal reg_re	: std_logic_vector(REGS-1 downto 0);
	signal reg_we	: std_logic_vector(REGS-1 downto 0);
	
	-- LCD commands
	signal cmd_inv   : std_logic;
	signal cmd_ack   : std_logic;
	signal cmd_clear : std_logic;
	signal cmd_write : std_logic;
	signal cmd_move  : std_logic;
	signal cmd_addr  : unsigned(4 downto 0);
	signal cmd_data  : std_logic_vector(7 downto 0);
			
begin
	
	-- connect register bank
	process(adr, read, write, reg_data, cmd_ack, cmd_inv)
		variable sel : integer;
	begin
		-- set default output
		present <= '0';
		ack     <= '0';
		reg_re  <= (others=>'0');
		reg_we  <= (others=>'0');
		dataout <= (others=>'0');
		
		-- get selection
		sel := to_integer(unsigned(adr)) - BASE;
		if (sel>=0) and (sel<REGS) then
			present     <= '1';
			ack         <= read or cmd_ack or cmd_inv;
			dataout     <= reg_data(sel);
			reg_re(sel) <= read;
			reg_we(sel) <= write;
		end if;
	end process;
	
	-- set output
	reg_data(0) <= x"00000000";
	reg_data(1) <= x"00000000";
	
	-- IRQ not used
	intr <= '0';
	
	-- handle requests
	process(clk, reset)
	begin
		if reset='1' then
			cmd_inv   <= '0';
			cmd_clear <= '0';
			cmd_write <= '0';
			cmd_move  <= '0';
			cmd_addr  <= (others=>'0');
			cmd_data  <= (others=>'0');
		elsif rising_edge(clk) then
			cmd_inv <= '0';
			if cmd_ack='1' then
				cmd_move  <= '0';
				cmd_clear <= '0';
				cmd_write <= '0';
			else
				if reg_we(0)='1' then 
					cmd_addr  <= unsigned(datain(4 downto 0));
					cmd_move  <= datain(5);
					cmd_clear <= datain(6);
					if datain(5)='0' and datain(6)='0' then 
						cmd_inv <= '1';
					end if;
				end if;
				if reg_we(1)='1' then 
					cmd_write <= '1';
					cmd_data  <= datain(7 downto 0);
				end if;
			end if;
		end if;
	end process;

	-- LCD control
	ctrl: entity Xlcd_hlctrl
		generic map (
			FREQ		=> FREQ,
			SIM			=> SIM
		)
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- command interface
			cmd_ack     => cmd_ack,
			cmd_clear   => cmd_clear,
			cmd_write   => cmd_write,
			cmd_move    => cmd_move,
			cmd_addr    => cmd_addr,
			cmd_data    => cmd_data,
			
			-- LC display
			lcd_en		=> lcd_en,
			lcd_rw		=> lcd_rw,
			lcd_rs		=> lcd_rs,
			lcd_data	=> lcd_data
		);

end rtl;
