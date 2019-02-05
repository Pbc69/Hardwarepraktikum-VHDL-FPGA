library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
	use xbus_common.xtoolbox.all;
library work;
	use work.xddr2.all;
	use work.all;

entity xvga_rcache is
	generic (
		BASE_ADDR	: natural
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- output
		out_vsync	: in  std_logic;
		out_hsync	: in  std_logic;
		out_enable	: in  std_logic;
		out_data	: out std_logic_vector(11 downto 0);
		
		-- DDR2 interface
		ddr2_dclk	: in  std_logic;
		ddr2_rdi	: in  xddr2_rd_c2p;
		ddr2_rdo	: out xddr2_rd_p2c
	);
end xvga_rcache;

architecture rtl of xvga_rcache is	

	-- constants
	constant PAGESIZE	: natural := 64;
	constant CACHESIZE	: natural := 2*PAGESIZE;
	constant ALEN  		: natural := log2(CACHESIZE);

	-- internal types
	subtype cache_laddr_t is unsigned(ALEN-1 downto 0);
	subtype cache_saddr_t is unsigned(ALEN-2 downto 0);
	subtype cache_data_t is std_logic_vector(31 downto 0);
	type cache_t is array (0 to CACHESIZE-1) of cache_data_t;
	
	-- expended ram read port
	signal ram_rreq   : std_logic;
	signal ram_rstart : std_logic;
	signal ram_rdone  : std_logic;
	signal ram_raddr  : unsigned(23 downto 0);
	signal ram_rsize  : unsigned(9 downto 0);
	signal ram_rvalid : std_logic;
	signal ram_rdata  : std_logic_vector(31 downto 0);

	-- input control (DDR2 -> cache)
	signal wfilled : std_logic;
	signal wreq    : std_logic;
	signal wpage   : std_logic;
	signal wrreq   : std_logic;
	signal wstart  : std_logic;
	signal wssync  : std_logic;
	signal wraddr  : unsigned(23 downto 0);
	signal wcaddr  : cache_saddr_t;
	
	-- output control (cache -> output-port)
	signal rpage   : std_logic;
	signal ractive : std_logic;
	signal rstart1 : std_logic;
	signal rstart2 : std_logic;
	signal rstart3 : std_logic;
	signal raddr   : cache_saddr_t;
	signal rfill   : unsigned(0 downto 0);
	signal rbuf    : cache_data_t;
	
	-- dual-port RAM (= cache)
	signal cache_raddr : cache_laddr_t;
	signal cache_waddr : cache_laddr_t;
	signal cache_rdata : cache_data_t;
	signal cache_wdata : cache_data_t;
	signal cache_wen   : std_logic;
	signal cache       : cache_t := (others=>(others=>'0'));
	
begin

	-- expanded read port
	ram_rstart    <= ddr2_rdi.start;
	ram_rdone     <= ddr2_rdi.done;
	ram_rvalid    <= ddr2_rdi.valid;
	ram_rdata     <= ddr2_rdi.data;
	ddr2_rdo.req  <= ram_rreq;
	ddr2_rdo.addr <= ram_raddr + to_unsigned(BASE_ADDR,24);
	ddr2_rdo.size <= ram_rsize;

	-- input control (external ram -> cache)
	process(clk, reset)
	begin
		if reset='1' then
			wstart   <= '0';
			wreq     <= '0';
			wpage    <= '0';
			wfilled  <= '0';
			wraddr   <= (others=>'0');
			wrreq    <= '0';
		elsif rising_edge(clk) then
			-- set dafault-values
			wstart <= '0';
			
			-- update status
			if out_vsync='1' then
				-- start reading frame
				wreq    <= '0';
				wpage   <= '1';
				wfilled <= '0';
				wraddr  <= to_unsigned(0, wraddr'length);
			elsif wreq='0' and (wfilled='0' or rpage=wpage) then
				-- start reading cache-page
				wstart  <= '1';
				wreq    <= '1';
				wpage   <= not wpage;
				wfilled <= '0';
				wrreq   <= '1';
			elsif ram_rstart='1' then
				-- clear request-flag after started
				wrreq   <= '0';
			elsif ram_rdone='1' then
				-- done reading cache-page
				wreq    <= '0';
				wrreq   <= '0';
				wfilled <= '1';
				wraddr  <= wraddr + PAGESIZE;
			end if;
		end if;
	end process;
	
	-- bring start-flag into ram-domain
	syncws: entity xbus_common.sync_feedback
		port map (
			i_clk	=> clk,
			i_data	=> wstart,
			o_clk	=> ddr2_dclk,
			o_data	=> wssync
		);
		
	-- update cache-write-address
	process(ddr2_dclk)
	begin
		if rising_edge(ddr2_dclk) then
			if wssync='1' then
				wcaddr <= to_unsigned(0, wcaddr'length);
			elsif ram_rvalid='1' then
				wcaddr <= wcaddr+1;
			end if;
		end if;
	end process;
	
	-- connect ram control signals
	ram_rreq  <= wrreq;
	ram_raddr <= wraddr;
	ram_rsize <= to_unsigned(PAGESIZE, ram_rsize'length);
	
	
	--
	-- output control (cache -> output-port)
	--
	
	-- output control
	process(clk, reset)
	begin
		if reset='1' then
			rpage    <= '0';
			rstart1  <= '0';
			rstart2  <= '0';
			rstart3  <= '0';
			ractive  <= '0';
			rpage    <= '0';
			raddr    <= (others=>'0');
			rfill    <= (others=>'0');
			rbuf     <= (others=>'0');
			out_data <= (others=>'0');
		elsif rising_edge(clk) then
			rstart1 <= '0';
			rstart2 <= rstart1;
			rstart3 <= rstart2;
			if out_vsync='1' then
				ractive <= '0';
			elsif ractive='0' and wfilled='1' then
				ractive <= '1';
				rstart1 <= '1';
				rpage   <= wpage;
				raddr   <= to_unsigned(0, raddr'length);
				rfill   <= to_unsigned(0, rfill'length);
			elsif ractive='1' and (rstart2='1' or rstart3='1' or out_enable='1') then
				if rfill=0  then
					--> load new word into output-shift-buffer
					rfill <= to_unsigned(1, rfill'length);
					rbuf  <= cache_rdata;
					if raddr=(PAGESIZE-1) then
						raddr <= to_unsigned(0, raddr'length);
						rpage <= wpage;
					else
						raddr <= raddr+1;
					end if;
				elsif out_enable='1' then
					--> output next byte from output-shift-buffer
					rfill <= rfill - 1;
					rbuf  <= x"0000" & rbuf(31 downto 16);
				end if;
				
				-- update output
				out_data <= rbuf(11 downto 0);
			end if;
		end if;
	end process;

	
	--
	-- infer cache
	--
	
	-- connect cache
	cache_wen   <= ram_rvalid;
	cache_wdata <= ram_rdata;
	cache_waddr <= wpage & wcaddr;
	cache_raddr <= rpage & raddr;

	-- infer block-ram for cache
	process(clk)
	begin
		if rising_edge(clk) then
			cache_rdata <= cache(to_integer(cache_raddr));
		end if;
	end process;
	process(ddr2_dclk)
	begin
		if rising_edge(ddr2_dclk) then
			if cache_wen='1' then
				cache(to_integer(cache_waddr)) <= cache_wdata;
			end if;
		end if;
	end process;
end rtl;
