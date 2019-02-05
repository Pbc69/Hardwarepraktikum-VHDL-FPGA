-------------------------------------------------------------------------------
-- xvga_wcache_ddr2if ---------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
	use xbus_common.xtoolbox.all;
library work;
	use work.xddr2.all;
	
entity xvga_wcache_ddr2if is
	generic (
		BASE_ADDR	: natural
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- user interface
		addr		: in  unsigned(22 downto 0);
		rreq		: in  std_logic;
		rack		: out std_logic;
		rdata		: out std_logic_vector(63 downto 0);
		wreq		: in  std_logic;
		wack		: out std_logic;
		wdata		: in  std_logic_vector(63 downto 0); 
		
		-- DDR2 interface
		ddr2_dclk	: in  std_logic;
		ddr2_rdi	: in  xddr2_rd_c2p;
		ddr2_rdo	: out xddr2_rd_p2c;
		ddr2_wri	: in  xddr2_wr_c2p;
		ddr2_wro	: out xddr2_wr_p2c
	);
end xvga_wcache_ddr2if;

architecture rtl of xvga_wcache_ddr2if is	

	-- status flags
	signal rlatch    : std_logic;
	signal wlatch    : std_logic;
	signal rreq_sync : std_logic;
	signal wreq_sync : std_logic;
	signal rlow      : std_logic;
	signal wword     : std_logic_vector(31 downto 0);
	
begin
	
	-- glue busses
	ddr2_wro.req  <= wreq or wlatch;
	ddr2_rdo.req  <= rreq or rlatch;
	ddr2_wro.addr <= to_unsigned(BASE_ADDR,24) + (addr&"0");
	ddr2_rdo.addr <= to_unsigned(BASE_ADDR,24) + (addr&"0");
	ddr2_wro.size <= to_unsigned(2,10);
	ddr2_rdo.size <= to_unsigned(2,10);
	ddr2_wro.data <= wword;
	wack <= ddr2_wri.done;
	rack <= ddr2_rdi.done;
	
	-- latch read/write-requests
	process(clk,reset)
	begin
		if reset='1' then
			wlatch <= '0';
			rlatch <= '0';
		elsif rising_edge(clk) then
			if wreq='1' then
				wlatch <= '1';
			elsif ddr2_wri.start='1' then
				wlatch <= '0';
			end if;
			if rreq='1' then
				rlatch <= '1';
			elsif ddr2_rdi.start='1' then
				rlatch <= '0';
			end if;
		end if;
	end process;
	
	-- bring start-flags into ddr-clock-domain
	ssr: entity xbus_common.sync_feedback
		port map (
			i_clk  => clk,
			o_clk  => ddr2_dclk,
			i_data => rreq,
			o_data => rreq_sync
		);
	ssw: entity xbus_common.sync_feedback
		port map (
			i_clk  => clk,
			o_clk  => ddr2_dclk,
			i_data => wreq,
			o_data => wreq_sync
		);
		
	-- handle ram-accesses
	process(ddr2_dclk)
	begin
		if rising_edge(ddr2_dclk) then
			-- handle read
			if rreq_sync='1' then
				rlow <= '1';
			elsif ddr2_rdi.valid='1' then
				if rlow='1'
					then rdata(31 downto  0) <= ddr2_rdi.data;
					else rdata(63 downto 32) <= ddr2_rdi.data;
				end if;
				rlow <= '0';
			end if;
			
			-- handle write
			if wreq_sync='1' then
				wword <= wdata(31 downto  0);
			elsif ddr2_wri.wen='1' then
				wword <= wdata(63 downto 32);
			end if;
		end if;
	end process;
end rtl;


-------------------------------------------------------------------------------
-- xvga_wcache ----------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.xtoolbox.all;
library work;
	use work.all;
	use work.xddr2.all;
	
entity xvga_wcache is
	generic (
		BASE_ADDR	: natural
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- user interface
		addr		: in  unsigned(18 downto 0);
		rreq		: in  std_logic;
		rack		: out std_logic;
		rdatal		: out std_logic_vector(31 downto 0);
		rdatas		: out std_logic_vector(15 downto 0);
		wreql		: in  std_logic;
		wreqs		: in  std_logic;
		wack		: out std_logic;
		wdatal		: in  std_logic_vector(31 downto 0); 
		wdatas		: in  std_logic_vector(15 downto 0); 
		
		-- special control
		vsync		: in  std_logic;
		
		-- DDR2 interface
		ddr2_dclk	: in  std_logic;
		ddr2_rdi	: in  xddr2_rd_c2p;
		ddr2_rdo	: out xddr2_rd_p2c;
		ddr2_wri	: in  xddr2_wr_c2p;
		ddr2_wro	: out xddr2_wr_p2c
	);
end xvga_wcache;

architecture rtl of xvga_wcache is	

	-- states
	type state_t is (SIDLE, SFETCH, SEVICT);
	
	-- main status
	signal state       : state_t;
	signal rlatch      : std_logic;
	signal wlatchl     : std_logic;
	signal wlatchs     : std_logic;
	
	-- cache
	signal cache_valid : std_logic;
	signal cache_dirty : std_logic;
	signal cache_addr  : unsigned(16 downto 0);
	signal cache_data  : std_logic_vector(63 downto 0);
	
	-- memory interface
	signal mem_addr    : unsigned(22 downto 0);
	signal mem_rreq	   : std_logic;
	signal mem_rack    : std_logic;
	signal mem_rdata   : std_logic_vector(63 downto 0);
	signal mem_wreq    : std_logic;
	signal mem_wack	   : std_logic;
	signal mem_wdata   : std_logic_vector(63 downto 0); 
	
begin
	
	-- update status
	process(clk, reset)
		variable offs : integer range 0 to 3;
		variable offl : integer range 0 to 1;
	begin
		if reset='1' then
			state       <= SIDLE;
			rlatch      <= '0';
			wlatchl     <= '0';
			wlatchs     <= '0';
			wack        <= '0';
			rack        <= '0';
			mem_rreq    <= '0';
			mem_wreq    <= '0';
			cache_valid <= '0';
			cache_dirty <= '0';
			cache_addr  <= (others=>'0');
			cache_data  <= (others=>'0');
			rdatal		<= (others=>'0');
			rdatas		<= (others=>'0');
		elsif rising_edge(clk) then
			-- clear control-flags by default
			mem_rreq <= '0';
			mem_wreq <= '0';
			wack     <= '0';
			rack     <= '0';

			-- latch requests
			rlatch  <= rlatch  or rreq;
			wlatchl <= wlatchl or wreql;
			wlatchs <= wlatchs or wreqs;
			
			-- get data-offset for current address
			offs := to_integer(addr(1 downto 0));
			offl := to_integer(addr(1 downto 1));
		
			-- update status
			case state is
				when SIDLE =>
					-- update cache if:
					--  + cache is empty
					--  + wrong word is c
					--  + cache is dirty an vsync is set
					if cache_valid='0' or addr(18 downto 2)/=cache_addr or (vsync='1' and cache_dirty='1') then
						--> wrong word in cache, update
						if cache_valid='1' and cache_dirty='1' then
							--> need to evict old word first
							mem_wreq   <= '1';
							state      <= SEVICT;
						else
							--> fetch new word
							cache_valid <= '0';
							cache_dirty <= '0';
							cache_addr  <= addr(18 downto 2);
							mem_rreq    <= '1';
							state       <= SFETCH;
						end if;
					elsif rreq='1' or rlatch='1' then
						--> read request done, ack request, clear flag & output correct slices
						rack    <= '1';
						rlatch  <= '0';
						rdatal  <= cache_data(((offl+1)*32)-1 downto offl*32);
						rdatas  <= cache_data(((offs+1)*16)-1 downto offs*16);
					elsif wreql='1' or wlatchl='1' then
						--> long write request done, ack request, clear flag & update cached word
						wack    <= '1';
						wlatchl <= '0';
						cache_dirty <= '1';
						cache_data(((offl+1)*32)-1 downto offl*32) <= wdatal;
					elsif wreqs='1' or wlatchs='1' then
						--> short write request done, ack request, clear flag & update cached word
						wack    <= '1';
						wlatchs <= '0';
						cache_dirty <= '1';
						cache_data(((offs+1)*16)-1 downto offs*16) <= wdatas;
					end if;
					
				when SFETCH =>
					-- wait until request has completed
					if mem_rack='1' then
						--> data read, update cache and return to idle state
						cache_valid <= '1';
						cache_dirty <= '0';
						cache_data  <= mem_rdata;
						state       <= SIDLE;
					end if;
					
				when SEVICT =>
					-- wait until request has completed
					if mem_wack='1' then
						--> old data written, clear cache and return to idle state
						cache_valid <= '0';
						state       <= SIDLE;
					end if;
			end case;
		end if;
	end process;
	
	-- set 'static' connections to memory interface
	mem_addr  <= resize(cache_addr, mem_addr'length);
	mem_wdata <= cache_data;
	
	-- memory interface
	memif: entity xvga_wcache_ddr2if
		generic map (
			BASE_ADDR	=> BASE_ADDR
		)
		port map (
			-- common
			clk 		=> clk,
			reset		=> reset,
			
			-- user interface
			addr		=> mem_addr,
			rreq		=> mem_rreq,
			rack		=> mem_rack,
			rdata		=> mem_rdata,
			wreq		=> mem_wreq,
			wack		=> mem_wack,
			wdata		=> mem_wdata,
			
			-- DDR2 interface
			ddr2_dclk	=> ddr2_dclk,
			ddr2_rdi	=> ddr2_rdi,
			ddr2_rdo	=> ddr2_rdo,
			ddr2_wri	=> ddr2_wri,
			ddr2_wro	=> ddr2_wro
		);

end rtl;




