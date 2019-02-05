-------------------------------------------------------------------------------
-- xddr2_ctrl_core (wrapper for MIG generated code) ---------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.all;
	use work.xddr2.all;

entity xddr2_ctrl_core is
	port (
		-- clock inputs
		ddr_clk		: in std_logic;
		ddr_clk90	: in std_logic;
		ddr_clk180	: in std_logic;
		ddr_clk270	: in std_logic;
		ddr_rst		: in std_logic;
		
		-- user interface - write request
		user_wreq	: in  std_logic;
		user_wstart	: out std_logic;
		user_wdone	: out std_logic;
		user_waddr	: in  unsigned(23 downto 0);
		user_wsize	: in  unsigned(9 downto 0);
		user_wen	: out std_logic;
		user_wdata	: in  std_logic_vector(31 downto 0);
			
		-- user interface - read request
		user_rreq	: in  std_logic;
		user_rstart	: out std_logic;
		user_rdone	: out std_logic;
		user_raddr	: in  unsigned(23 downto 0);
		user_rsize	: in  unsigned(9 downto 0);
		user_rvalid	: out std_logic;
		user_rdata	: out std_logic_vector(31 downto 0);
	
		-- DDR2 memory interface
		SD_BA		: out   std_logic_vector(1 downto 0);
		SD_A		: out   std_logic_vector(12 downto 0);
		SD_DQ		: inout std_logic_vector(15 downto 0);
		SD_RAS		: out   std_logic;
		SD_CAS		: out   std_logic;
		SD_CK_N		: out   std_logic_vector(0 downto 0);
		SD_CK_P		: out   std_logic_vector(0 downto 0);
		SD_CKE		: out   std_logic;
		SD_ODT		: out   std_logic;
		SD_CS		: out   std_logic;
		SD_WE		: out   std_logic;
		SD_DM		: out   std_logic_vector(1 downto 0);
		SD_DQS_N	: inout std_logic_vector(1 downto 0);
		SD_DQS_P	: inout std_logic_vector(1 downto 0);
		SD_LOOP_IN	: in    std_logic;
		SD_LOOP_OUT	: out   std_logic
	);
end xddr2_ctrl_core;

architecture rtl of xddr2_ctrl_core is

	-- commands
	constant CMD_NOP   : std_logic_vector(2 downto 0) := "000";
	constant CMD_INIT  : std_logic_vector(2 downto 0) := "010";
	constant CMD_WRITE : std_logic_vector(2 downto 0) := "100";
	constant CMD_READ  : std_logic_vector(2 downto 0) := "110";
	
	-- states
	type state_t is (
		sReset, sPreInit, sInit,					-- init states
		sIdle, sNop,								-- idle states
		sWStart1, sWStart2, sWData, sWStop,			-- write states
		sRStart1, sRStart2, sRData, sRStop, sRWait	-- read states
	);
		
	-- control logic
	signal rst_n    	: std_logic;				-- inverted reset
	signal state    	: state_t;					-- current state
	signal counter  	: unsigned(7 downto 0);		-- general counter (meaning depending on state)
	signal addr     	: unsigned(23 downto 0);	-- current address
	signal bursts   	: unsigned(8 downto 0);		-- remaining bursts
	signal counter0		: std_logic;				-- set when (counter=0)
	signal bursts1  	: std_logic;				-- set when (bursts=1)
	signal wactive      : std_logic;				-- set when in write-state
	
	-- data registers
	signal rdata_90		: std_logic_vector(31 downto 0);
	signal rdata		: std_logic_vector(31 downto 0);		
	signal rvalid_90	: std_logic;
	signal rvalid		: std_logic;
	signal rvalidl		: std_logic;
	
	-- DDR2 controller interface
	signal ddr_irst		: std_logic;
	signal ddr_irst270	: std_logic;
	signal ddr_init		: std_logic;
	signal ddr_ar_req	: std_logic;
	signal ddr_ar_done	: std_logic;
	signal ddr_cmd		: std_logic_vector(2 downto 0);
	signal ddr_ack		: std_logic;
	signal ddr_addr		: std_logic_vector(24 downto 0);
	signal ddr_done		: std_logic;
	signal ddr_wdata	: std_logic_vector(31 downto 0);
	signal ddr_wmask	: std_logic_vector(3 downto 0);
	signal ddr_rdata	: std_logic_vector(31 downto 0);
	signal ddr_rvalid	: std_logic;
	
begin

	--
	-- DDR2 controller wrapper
	--
	
	-- control logic
	process(ddr_clk, ddr_irst)
	begin
		if ddr_irst='1' then
			state       <= sReset;
			counter     <= (others=>'0');
			addr        <= (others=>'0');
			bursts      <= (others=>'0');
			counter0    <= '0';
			bursts1     <= '0';
			wactive     <= '0';
			user_wstart <= '0';
			user_rstart <= '0';
			user_wdone  <= '0';
			user_rdone  <= '0';
			ddr_cmd     <= CMD_NOP;
			ddr_done    <= '0';
		elsif rising_edge(ddr_clk) then
			
			-- assign default values
			counter     <= counter-1;
			user_wstart <= '0';
			user_rstart <= '0';
			user_wdone  <= '0';
			user_rdone  <= '0';
			ddr_done    <= '0';
			ddr_cmd     <= CMD_NOP;

			-- checck if counters will reach special value in next cycle
			if bursts=1
				then bursts1 <= '1';
				else bursts1 <= '0';
			end if;
			if counter=1
				then counter0 <= '1';
				else counter0 <= '0';
			end if;
			
			-- update status
			case state is
				--
				-- init states
				--
				when sReset =>
					-- wait some cycles before issuing INIT-command
					state    <= sPreInit;
					counter  <= to_unsigned(16, counter'length);
					counter0 <= '0';
					
				when sPreInit =>
					if counter0='1' then
						-- issue INIT-command
						state   <= sInit;
						ddr_cmd <= CMD_INIT;
					end if;
				
				when sInit =>
					-- wait until init is done
					if ddr_init='1' then
						state <= sIdle;
					end if;


				--
				-- idle states
				--
				when sNop => 
					state <= sIdle;
				
				when sIdle =>
					-- check if ready for new command
					if ddr_ack='0' then
						if user_wreq='1' then
							--> handle write-request
							state       <= sWStart1;
							user_wstart <= '1';
							wactive     <= '1';
						elsif user_rreq='1' then
							--> handle read-request
							state       <= sRStart1;
							user_rstart <= '1';
						end if;
					end if;
				
				--
				-- write states
				--
				when sWStart1 | sWStart2 =>
					-- issue write-command
					ddr_cmd <= CMD_WRITE;
				
					-- latch infos after first cycle in start-state
					if state=sWStart1 then
						state  <= sWStart2;
						addr   <= user_waddr;
						bursts <= user_wsize(9 downto 1);
					end if;
					
					-- wait until write command gets ACKed
					if ddr_ack='1' then
						--> start writing data
						state    <= sWData;
						counter  <= to_unsigned(2-1, counter'length);
						counter0 <= '0';
					end if;
					
				when sWData =>
					ddr_cmd <= CMD_WRITE;
					if counter0='1' then
						if bursts=1 then
							--> was last burst, stop writing
							state      <= sWStop;
							counter    <= to_unsigned(2-1, counter'length);
							counter0   <= '0';
							wactive    <= '0';
							ddr_done   <= '1';
							user_wdone <= '1';
						else
							--> write next burst
							state    <= sWData;
							counter  <= to_unsigned(2-1, counter'length);
							counter0 <= '0';
							bursts   <= bursts - 1;
							addr     <= addr + 2;
						end if;
					end if;
					
				when sWStop =>
					if counter0='1'
						then state    <= sIdle; -- done
						else ddr_done <= '1';   -- still aborting
					end if;
				
				--
				-- read states
				--
				when sRStart1 | sRStart2 =>
					-- issue read-command
					ddr_cmd <= CMD_READ;
					
					-- latch infos after first cycle in start-state
					if state=sRStart1 then
						state  <= sRStart2;
						addr   <= user_raddr;
						bursts <= user_rsize(9 downto 1);
					end if;
					
					-- wait until read command gets ACKed
					if ddr_ack='1' then
						--> start reading data
						state    <= sRData;
						counter  <= to_unsigned(2-1, counter'length);
						counter0 <= '0';
					end if;
					
				when sRData =>
					ddr_cmd <= CMD_READ;
					if counter0='1' then
						if bursts=1 then
							--> was last burst, stop reading
							state    <= sRStop;
							counter  <= to_unsigned(2-1, counter'length);
							counter0 <= '0';
							ddr_done <= '1';
						else
							--> read next burst
							state    <= sRData;
							counter  <= to_unsigned(2-1, counter'length);
							counter0 <= '0';
							bursts   <= bursts - 1;
							addr     <= addr + 2;
						end if;
					end if;
					
				when sRStop =>
					if counter0='1' then
						--> done, now wait until all data was received
						state    <= sRWait;
						counter  <= to_unsigned(63, counter'length);
						counter0 <= '0';
					else
						-- still aborting
						ddr_done <= '1';
					end if;
					
				when sRWait =>
					-- wait for falling-edge on read-data-valid (or timeout)
					if (rvalidl='1' and rvalid='0') or counter0='1' then
						user_rdone <= '1';
						state      <= sNop;
					end if;

				when others =>
					null;
			end case;
		end if;
	end process;
	
	-- output address
	ddr_addr <= std_logic_vector(addr(21 downto 0) & addr(23 downto 22) & "0");
	
	-- create user-write-enable
	user_wen <= wactive and ddr_ack and ((not bursts1) or (not counter0));
	
	-- bring write-data into 'clk270'-domain
	process(ddr_clk270, ddr_irst270)
	begin
		if ddr_irst270='1' then
			ddr_wdata <= (others=>'0');
		elsif rising_edge(ddr_clk270) then
			ddr_wdata <= user_wdata;
		end if;
	end process;
	
	-- write-mask is unused
	ddr_wmask <= (others=>'0');
	
	-- bring read-data into 'clk'-domain
	process(ddr_clk270, ddr_irst270)
	begin
		if ddr_irst270='1' then
			rdata_90  <= (others=>'0');
			rvalid_90 <= '0';
		elsif falling_edge(ddr_clk270) then
			rdata_90  <= ddr_rdata;
			rvalid_90 <= ddr_rvalid;
		end if;
	end process;
	process(ddr_clk, ddr_irst)
	begin
		if ddr_irst='1' then
			rdata   <= (others=>'0');
			rvalid  <= '0';
			rvalidl <= '0';
		elsif rising_edge(ddr_clk) then
			rdata   <= rdata_90;
			rvalid  <= rvalid_90;
			rvalidl <= rvalid;
		end if;
	end process;
	
	-- set read-data-output
	user_rvalid	<= rvalid;
	user_rdata	<= rdata;

	
	--
	-- DDR2 controller
	--
	
	-- generate inverted reset
	rst_n <= not ddr_rst;

	-- instantiate controller (use inverted clocks so that control signals are in 'clk'-domain)
	i_mig: entity xddr2_mig
		port map (
			-- input clocks
			clk_int					=> ddr_clk180,
			clk90_int				=> ddr_clk270,
			reset_in_n				=> rst_n, 
			dcm_lock				=> rst_n,
			
			-- output clocks
			cntrl0_clk_tb			=> open,
			cntrl0_clk90_tb			=> open,
			cntrl0_sys_rst_tb		=> open,
			cntrl0_sys_rst90_tb		=> ddr_irst270,
			cntrl0_sys_rst180_tb	=> ddr_irst,
	
			-- status/control
			cntrl0_burst_done				=> ddr_done,
			cntrl0_init_done 				=> ddr_init,
			cntrl0_ar_done					=> ddr_ar_done,
			cntrl0_user_data_valid			=> ddr_rvalid,
			cntrl0_auto_ref_req				=> ddr_ar_req,
			cntrl0_user_cmd_ack				=> ddr_ack,
			cntrl0_user_command_register	=> ddr_cmd,
			cntrl0_user_data_mask			=> ddr_wmask,
			cntrl0_user_output_data			=> ddr_rdata,
			cntrl0_user_input_data			=> ddr_wdata,
			cntrl0_user_input_address		=> ddr_addr,
	
			-- DDR2 signals
			cntrl0_ddr2_dq			=> SD_DQ,
			cntrl0_ddr2_a			=> SD_A,
			cntrl0_ddr2_ba			=> SD_BA,
			cntrl0_ddr2_cke			=> SD_CKE,
			cntrl0_ddr2_cs_n		=> SD_CS,
			cntrl0_ddr2_ras_n		=> SD_RAS,
			cntrl0_ddr2_cas_n		=> SD_CAS,
			cntrl0_ddr2_we_n 		=> SD_WE,
			cntrl0_ddr2_odt			=> SD_ODT,
			cntrl0_ddr2_dm			=> SD_DM,
			cntrl0_ddr2_dqs			=> SD_DQS_P,
			cntrl0_ddr2_dqs_n		=> SD_DQS_N,
			cntrl0_ddr2_ck			=> SD_CK_P,
			cntrl0_ddr2_ck_n 		=> SD_CK_N,
			cntrl0_rst_dqs_div_in	=> SD_LOOP_IN,
			cntrl0_rst_dqs_div_out	=> SD_LOOP_OUT
		);	
	
end rtl;


-------------------------------------------------------------------------------
-- xddr2_ctrl_clkgen (generate clocks needed by DDR2 controller) --------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library unisim;
	use unisim.vcomponents.all;	
library xbus_common;
	use xbus_common.all;

entity xddr2_ctrl_clkgen is
	port (
		-- clock input
		clk 			: in  std_logic;
		reset			: in  std_logic;
		
		-- generated clocks
		ddr_clk			: out std_logic;
		ddr_clk90		: out std_logic;
		ddr_clk180		: out std_logic;
		ddr_clk270		: out std_logic;
		ddr_rst			: out std_logic
	);
end xddr2_ctrl_clkgen;

architecture rtl of xddr2_ctrl_clkgen is

	-- reset generation
	signal dcm_reset1		: std_logic;
	signal dcm_rst1_del		: std_logic_vector(7 downto 0);
	signal dcm_lock			: std_logic_vector(1 downto 0);
	
	-- 133MHz clock generation
	signal clk_fb0			: std_logic;
	signal clk_dcm0			: std_logic;
	signal clk_ub			: std_logic;
	signal clk90_ub			: std_logic;
	signal clk180_ub		: std_logic;
	signal clk270_ub		: std_logic;
	signal clk_buf			: std_logic;
	signal clk90_buf		: std_logic;
	signal clk180_buf		: std_logic;
	signal clk270_buf		: std_logic;
	signal reset_i 			: std_logic;

	-- eunsure that clock names are kept
	attribute syn_keep : boolean;
	attribute syn_keep of clk_buf    : signal is true;
	attribute syn_keep of clk90_buf  : signal is true;
	attribute syn_keep of clk180_buf : signal is true;
	attribute syn_keep of clk270_buf : signal is true;
	attribute syn_keep of reset_i    : signal is true;
  
begin
	
	-- create DCM1 reset (wait until DCM0 has locked)
	process(clk_dcm0, reset)
	begin
		if reset='1' then
			dcm_rst1_del <= (others=>'1');
			dcm_reset1   <= '1';
		elsif rising_edge(clk_dcm0) then
			dcm_rst1_del <= (not dcm_lock(0)) & dcm_rst1_del(dcm_rst1_del'high downto 1);
			dcm_reset1   <= dcm_rst1_del(0);
		end if;
	end process;
	
	-- sync reset to clock-domains
	i_rst: entity xbus_common.reset_sync
		port map (
			clk     => clk_buf,
			rst_in  => reset, 
			rst_out => reset_i
		);
	ddr_rst <= reset_i;
		
	-- DCM0 (50MHZ -> 133Mhz)
	i_dcm0 : DCM
		generic map (
			CLKIN_PERIOD   => 20.000,
			CLKFX_MULTIPLY => 8,
			CLKFX_DIVIDE   => 3
		)
		port map(
			CLKIN    => clk,
			CLKFB    => clk_fb0,
			DSSEN    => '0',
			PSINCDEC => '0',
			PSEN     => '0',
			PSCLK    => '0',
			RST      => reset,
			CLK0     => clk_fb0,
			CLK90    => open,
			CLK180   => open,
			CLK270   => open,
			CLK2X    => open,
			CLK2X180 => open,
			CLKDV    => open,
			CLKFX    => clk_dcm0,
			CLKFX180 => open,
			LOCKED   => dcm_lock(0),
			PSDONE   => open,
			STATUS   => open
		);
		
	-- DCM1 (create phase-shifted clocks)
	i_dcm1 : DCM
		generic map (
			CLKIN_PERIOD => 7.519
		)
		port map(
			CLKIN    => clk_dcm0,
			CLKFB    => clk_buf,
			DSSEN    => '0',
			PSINCDEC => '0',
			PSEN     => '0',
			PSCLK    => '0',
			RST      => dcm_reset1,
			CLK0     => clk_ub,
			CLK90    => clk90_ub,
			CLK180   => clk180_ub,
			CLK270   => clk270_ub,
			CLK2X    => open,
			CLK2X180 => open,
			CLKDV    => open,
			CLKFX    => open,
			CLKFX180 => open,
			LOCKED   => dcm_lock(1),
			PSDONE   => open,
			STATUS   => open
		);

	-- buffer clocks
	i_buf: BUFG
		port map (
			I => clk_ub,
			O => clk_buf
		);
	i_buf90: BUFG
		port map (
			I => clk90_ub,
			O => clk90_buf
		);
	i_buf180: BUFG
		port map (
			I => clk180_ub,
			O => clk180_buf
		);
	i_buf270: BUFG
		port map (
			I => clk270_ub,
			O => clk270_buf
		);
		
	-- output clocks
	ddr_clk    <= clk_buf;
	ddr_clk90  <= clk90_buf;
	ddr_clk180 <= clk180_buf;
	ddr_clk270 <= clk270_buf;

end rtl;


-------------------------------------------------------------------------------
-- xddr2_ctrl (DDR2 controller toplevel component) ----------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
library work;
	use work.all;
	use work.xddr2.all;

entity xddr2_ctrl is
	port (
		-- clocks
		sys_clk 	: in std_logic;
		sys_rst		: in std_logic;

		-- user interface
		user_dclk	: out std_logic;
		user_wri	: in  xddr2_wr_p2c;
		user_wro	: out xddr2_wr_c2p;
		user_rdi	: in  xddr2_rd_p2c;
		user_rdo	: out xddr2_rd_c2p;
		
		-- DDR2 memory interface
		SD_BA		: out   std_logic_vector(1 downto 0);
		SD_A		: out   std_logic_vector(12 downto 0);
		SD_DQ		: inout std_logic_vector(15 downto 0);
		SD_RAS		: out   std_logic;
		SD_CAS		: out   std_logic;
		SD_CK_N		: out   std_logic_vector(0 downto 0);
		SD_CK_P		: out   std_logic_vector(0 downto 0);
		SD_CKE		: out   std_logic;
		SD_ODT		: out   std_logic;
		SD_CS		: out   std_logic;
		SD_WE		: out   std_logic;
		SD_DM		: out   std_logic_vector(1 downto 0);
		SD_DQS_N	: inout std_logic_vector(1 downto 0);
		SD_DQS_P	: inout std_logic_vector(1 downto 0);
		SD_LOOP_IN	: in    std_logic;
		SD_LOOP_OUT	: out   std_logic
	);
end xddr2_ctrl;

architecture rtl of xddr2_ctrl is

	-- user interface - write request
	signal user_wreq	: std_logic;
	signal user_wstart	: std_logic;
	signal user_wdone	: std_logic;
	signal user_waddr	: unsigned(23 downto 0);
	signal user_wsize	: unsigned(9 downto 0);
	signal user_wen		: std_logic;
	signal user_wdata	: std_logic_vector(31 downto 0);

	-- user interface - read request
	signal user_rreq	: std_logic;
	signal user_rstart	: std_logic;
	signal user_rdone	: std_logic;
	signal user_raddr	: unsigned(23 downto 0);
	signal user_rsize	: unsigned(9 downto 0);
	signal user_rvalid	: std_logic;
	signal user_rdata	: std_logic_vector(31 downto 0);
	
	-- internal clocks
	signal ddr_clk		: std_logic;
	signal ddr_clk90	: std_logic;
	signal ddr_clk180	: std_logic;
	signal ddr_clk270	: std_logic;
	signal ddr_rst		: std_logic;

	-- synchronized control flags 
	signal sync_wreq	: std_logic;
	signal sync_wstart	: std_logic;
	signal sync_wdone	: std_logic;
	signal sync_rreq	: std_logic;
	signal sync_rstart	: std_logic;
	signal sync_rdone	: std_logic;
	
begin
	
	-- user interface - write request
	user_waddr     <= user_wri.addr;
	user_wsize     <= user_wri.size;
	user_wdata     <= user_wri.data;
	user_wro.start <= user_wstart;
	user_wro.done  <= user_wdone;
	user_wro.wen   <= user_wen;

	-- user interface - read request
	user_raddr	   <= user_rdi.addr;
	user_rsize	   <= user_rdi.size;
	user_rdo.start <= user_rstart;
	user_rdo.done  <= user_rdone;
	user_rdo.valid <= user_rvalid;
	user_rdo.data  <= user_rdata;
	
	-- DDR2 clock generation
	i_clkgen: entity xddr2_ctrl_clkgen
		port map (
			-- clock input
			clk 		=> sys_clk,
			reset		=> sys_rst,
			
			-- generated clocks
			ddr_clk		=> ddr_clk,
			ddr_clk90	=> ddr_clk90,
			ddr_clk180	=> ddr_clk180,
			ddr_clk270	=> ddr_clk270,
			ddr_rst		=> ddr_rst
		);
		
	-- output clock
	user_dclk <= ddr_clk;
	
	-- register request-flags to ensure non-combinatorial input to synchronizers
	process(sys_clk,sys_rst)
	begin
		if sys_rst='1' then
			user_wreq <= '0';
			user_rreq <= '0';
		elsif rising_edge(sys_clk) then
			user_wreq <= user_wri.req;
			user_rreq <= user_rdi.req;
		end if;		
	end process;
	
	-- synchronizer
	i_sync_wr: entity xbus_common.sync_dualff
		port map (
			o_clk  => ddr_clk,
			i_data => user_wreq,
			o_data => sync_wreq
		);
	i_sync_rr: entity xbus_common.sync_dualff
		port map (
			o_clk  => ddr_clk,
			i_data => user_rreq,
			o_data => sync_rreq
		);
	i_sync_ws: entity xbus_common.sync_feedback
		port map (
			i_clk  => ddr_clk,
			o_clk  => sys_clk,
			i_data => sync_wstart,
			o_data => user_wstart
		);
	i_sync_rs: entity xbus_common.sync_feedback
		port map (
			i_clk  => ddr_clk,
			o_clk  => sys_clk,
			i_data => sync_rstart,
			o_data => user_rstart
		);
	i_sync_wd: entity xbus_common.sync_feedback
		port map (
			i_clk  => ddr_clk,
			o_clk  => sys_clk,
			i_data => sync_wdone,
			o_data => user_wdone
		);
	i_sync_rd: entity xbus_common.sync_feedback
		port map (
			i_clk  => ddr_clk,
			o_clk  => sys_clk,
			i_data => sync_rdone,
			o_data => user_rdone
		);

	-- DDR2 controller core
	i_core: entity xddr2_ctrl_core
		port map (
			-- clock inputs
			ddr_clk		=> ddr_clk,
			ddr_clk90	=> ddr_clk90,
			ddr_clk180	=> ddr_clk180,
			ddr_clk270	=> ddr_clk270,
			ddr_rst		=> ddr_rst,
			
			-- user interface - write request
			user_wreq	=> sync_wreq,
			user_wstart	=> sync_wstart,
			user_wdone	=> sync_wdone,
			user_waddr	=> user_waddr,
			user_wsize	=> user_wsize,
			user_wen	=> user_wen,
			user_wdata	=> user_wdata,
				
			-- user interface - read request
			user_rreq	=> sync_rreq,
			user_rstart	=> sync_rstart,
			user_rdone	=> sync_rdone,
			user_raddr	=> user_raddr,
			user_rsize	=> user_rsize,
			user_rvalid	=> user_rvalid,
			user_rdata	=> user_rdata,
		
			-- DDR2 memory interface
			SD_BA		=> SD_BA,
			SD_A		=> SD_A,
			SD_DQ		=> SD_DQ,
			SD_RAS		=> SD_RAS,
			SD_CAS		=> SD_CAS,
			SD_CK_N		=> SD_CK_N,
			SD_CK_P		=> SD_CK_P,
			SD_CKE		=> SD_CKE,
			SD_ODT		=> SD_ODT,
			SD_CS		=> SD_CS,
			SD_WE		=> SD_WE,
			SD_DM		=> SD_DM,
			SD_DQS_N	=> SD_DQS_N,
			SD_DQS_P	=> SD_DQS_P,
			SD_LOOP_IN	=> SD_LOOP_IN,
			SD_LOOP_OUT	=> SD_LOOP_OUT
		);
		
end rtl;