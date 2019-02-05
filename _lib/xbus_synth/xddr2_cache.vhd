library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
	use xbus_common.xtoolbox.all;
library work;
	use work.all;
	use work.xddr2.all;
	
-- 2-way set associative cache
entity xddr2_cache is
	generic (
		BASE_ADDR	: natural;
		SIZE_LINE	: natural;
		SIZE_CACHE	: natural
	);
	port (
		-- common
		clk 		: in  std_logic;
		reset		: in  std_logic;
		
		-- user interface
		addr		: in  unsigned(23 downto 0);
		rreq		: in  std_logic;
		rack		: out std_logic;
		rdata		: out std_logic_vector(31 downto 0);
		wreq		: in  std_logic;
		wack		: out std_logic;
		wdata		: in  std_logic_vector(31 downto 0); 
		
		-- DDR2 interface
		ddr2_dclk	: in  std_logic;
		ddr2_rdi	: in  xddr2_rd_c2p;
		ddr2_rdo	: out xddr2_rd_p2c;
		ddr2_wri	: in  xddr2_wr_c2p;
		ddr2_wro	: out xddr2_wr_p2c
	);
end xddr2_cache;

architecture rtl of xddr2_cache is

	--
	-- constants
	--

	-- config
	constant BITS_TOTAL		: natural := 24;
	constant WAYS			: natural := 2; -- !!! only 2 supported at the moment !!!
	
	-- derived constants
	constant NUM_LINES		: natural := SIZE_CACHE / SIZE_LINE / WAYS;
	constant BITS_AGE		: natural := 1;
	constant BITS_WAY		: natural := log2(WAYS);
	constant BITS_DISPL		: natural := log2(SIZE_LINE);
	constant BITS_INDEX 	: natural := log2(NUM_LINES);
	constant BITS_TAG		: natural := BITS_TOTAL - BITS_INDEX - BITS_DISPL;
	constant SIZE_DRAM		: natural := SIZE_CACHE / WAYS;
	constant BITS_DRAMA		: natural := log2(SIZE_DRAM);
	constant BITS_ENTRY		: natural := BITS_AGE + WAYS*(2+BITS_TAG);
	
	
	--
	-- types
	--

	-- basic types
	subtype age_t       is unsigned(BITS_AGE-1 downto 0);
	subtype way_t       is unsigned(BITS_WAY-1 downto 0);
	subtype addr_t      is unsigned(BITS_TOTAL-1 downto 0);
	subtype index_t     is unsigned(BITS_INDEX-1 downto 0);
	subtype tag_t       is unsigned(BITS_TAG-1 downto 0);
	subtype displ_t     is unsigned(BITS_DISPL-1 downto 0);
	subtype dram_addr_t is unsigned(BITS_DRAMA-1 downto 0);
	subtype entry_slv_t is std_logic_vector(BITS_ENTRY-1 downto 0);

	-- tag-sram type
	type tagram_way_t is record
		valid : std_logic;
		dirty : std_logic;
		tag   : tag_t;
	end record;
	type tagram_ways_t is array(0 to WAYS-1) of tagram_way_t;
	type tagram_entry_t is record
		age : age_t;
		way : tagram_ways_t;
	end record;
	type tagram_t is array(0 to NUM_LINES-1) of entry_slv_t;
	
	-- data-sram type
	subtype dram_word_t is std_logic_vector(31 downto 0);
	type dram_raw_t is array(0 to WAYS-1) of dram_word_t;
	type dataram_t is array(SIZE_DRAM-1 downto 0) of dram_word_t;
	
	-- states
	type state_t is (SIDLE, SREAD, SWRITE, SFETCH, SEVICT);
	
	
	--
	-- helper functions
	--
	
	-- align address to cache-line-boundary
	function align_addr(x : in unsigned) return unsigned is
		variable y : unsigned(x'range);
	begin
		y := x;
		y(BITS_DISPL-1 downto 0) := (others=>'0');
		return y;
	end align_addr;
	
	-- external address => datacache-address
	function ea2da(ea : in unsigned) return unsigned is
	begin
		return resize(ea, BITS_DRAMA);
	end ea2da;
	
	-- external address & displacement => datacache-address
	function ead2da(ea, d : in unsigned) return unsigned is
	begin
		return resize(ea(ea'high downto BITS_DISPL) & d, BITS_DRAMA);
	end ead2da;
	
	-- tag & user-address => external address
	function tua2ea(t, ua : in unsigned) return unsigned is
	begin
		return t & ua(BITS_INDEX+BITS_DISPL-1 downto BITS_DISPL) & (BITS_DISPL-1 downto 0=>'0');
	end tua2ea;
	
	-- convert tag-ram entry into bit-vector
	function entry2slv(x : in tagram_entry_t) return entry_slv_t is
		variable y : entry_slv_t;
		variable n : natural;
	begin
		n := 0;
		y(n+BITS_AGE-1 downto 0) := std_logic_vector(x.age);
		n := n + BITS_AGE;
		for i in x.way'range loop
			y(n+0) := x.way(i).valid;
			y(n+1) := x.way(i).dirty;
			y(n+BITS_TAG+1 downto n+2) := std_logic_vector(x.way(i).tag);
			n := n+2+BITS_TAG;
		end loop;
		return y;
	end entry2slv;
	
	-- parse bit-vector into tag-ram entry
	function slv2entry(x : in entry_slv_t) return tagram_entry_t is
		variable y : tagram_entry_t;
		variable n : natural;
	begin
		n := 0;
		y.age := unsigned(x(n+BITS_AGE-1 downto 0));
		n := n + BITS_AGE;
		for i in y.way'range loop
			y.way(i).valid := x(n+0);
			y.way(i).dirty := x(n+1);
			y.way(i).tag   := unsigned(x(n+BITS_TAG+1 downto n+2));
			n := n+2+BITS_TAG;
		end loop;
		return y;
	end slv2entry;
	
	
	--
	-- signals
	--
	
	-- expanded external read port
	signal ext_rreq		: std_logic;
	signal ext_rstart	: std_logic;
	signal ext_rdone	: std_logic;
	signal ext_raddr	: unsigned(23 downto 0);
	signal ext_rsize	: unsigned(9 downto 0);
	signal ext_rvalid	: std_logic;
	signal ext_rdata	: std_logic_vector(31 downto 0);
		
	-- expanded external write port
	signal ext_wreq		: std_logic;
	signal ext_wstart	: std_logic;
	signal ext_wdone	: std_logic;
	signal ext_waddr	: unsigned(23 downto 0);
	signal ext_wsize	: unsigned(9 downto 0);
	signal ext_wen		: std_logic;
	signal ext_wdata	: std_logic_vector(31 downto 0);
		
	-- main status
	signal state 		: state_t;
	signal ractive		: std_logic;
	signal wactive		: std_logic;
	
	-- cache-line control (user port side)
	signal fetch_start	: std_logic;
	signal fetch_done	: std_logic;
	signal fetch_active	: std_logic;
	signal evict_start	: std_logic;
	signal evict_done	: std_logic;
	signal evict_active	: std_logic;
	
	-- cache-line control (DDR port side)
	signal cline_fetch	: std_logic;
	signal cline_evict1	: std_logic;
	signal cline_evict2	: std_logic;
	signal cline_displ	: displ_t;
	signal cline_way    : way_t;
	
	-- tag-ram mangement
	signal tr_rupd		: std_logic;
	signal tr_wupd		: std_logic;
	signal tr_hit   	: std_logic;
	signal tr_evict 	: std_logic;
	signal tr_oldtag  	: tag_t;
	signal tr_way   	: way_t;
	
	-- data-ram port #1
	signal dram_ren1   : std_logic;
	signal dram_wen1   : std_logic;
	signal dram_way1   : way_t;
	signal dram_addr1  : dram_addr_t;
	signal dram_wdata1 : dram_word_t;
	signal dram_rdata1 : dram_word_t;
	signal dram_rraw1  : dram_raw_t;
	
	-- data-ram port #2
	signal dram_ren2   : std_logic;
	signal dram_wen2   : std_logic;
	signal dram_way2   : way_t;
	signal dram_addr2  : dram_addr_t;
	signal dram_wdata2 : dram_word_t;
	signal dram_rdata2 : dram_word_t;
	signal dram_rraw2  : dram_raw_t;
	
	-- rams
	signal tagram : tagram_t := (others=>(others=>'0'));
	shared variable dataram1 : dataram_t;
	shared variable dataram2 : dataram_t;

begin
	
	--
	-- helper
	--
	
	-- expand read port
	ext_rstart    <= ddr2_rdi.start;
	ext_rdone     <= ddr2_rdi.done;
	ext_rvalid    <= ddr2_rdi.valid;
	ext_rdata     <= ddr2_rdi.data;
	ddr2_rdo.req  <= ext_rreq;
	ddr2_rdo.addr <= ext_raddr;
	ddr2_rdo.size <= ext_rsize;
	
	-- expand write port
	ext_wstart    <= ddr2_wri.start;
	ext_wdone     <= ddr2_wri.done;
	ext_wen       <= ddr2_wri.wen;
	ddr2_wro.req  <= ext_wreq;
	ddr2_wro.addr <= ext_waddr;
	ddr2_wro.size <= ext_wsize;
	ddr2_wro.data <= ext_wdata;
	
	
	--
	-- main control
	--
	
	-- acknowledge request after cache-hit
	wack <= '1' when (state=SWRITE and tr_hit='1') else '0';
	rack <= '1' when (state=SREAD  and tr_hit='1') else '0';
		
	-- pass through read data from data-ram
	rdata <= dram_rdata1;
	
	-- update status
	process(clk, reset)
	begin
		if reset='1' then
			state       <= SIDLE;
			ractive     <= '0';
			wactive     <= '0';
			fetch_start <= '0';
			evict_start <= '0';
		elsif rising_edge(clk) then
			-- clear control-flags by default
			fetch_start <= '0';
			evict_start <= '0';
			
			-- update status
			case state is
				when SIDLE =>
					-- check for requests
					if ractive='1' or (wactive='0' and rreq='1') then
						ractive <= '1';
						state   <= SREAD;
					elsif wactive='1' or wreq='1' then
						wactive <= '1';
						state   <= SWRITE;
					end if;
					
				when SREAD =>
					if tr_hit='1' then
						--> cache hit
						ractive <= '0';
						state   <= SIDLE;
					else
						--> cache miss
						if tr_evict='1' then
							-- need to evict old line first
							evict_start <= '1';
							state       <= SEVICT;
						else
							-- fetch line
							fetch_start <= '1';
							state       <= SFETCH;
						end if;
					end if;
					
				when SWRITE =>
					if tr_hit='1' then
						--> cache hit
						wactive <= '0';
						state   <= SIDLE;
					else
						--> cache miss
						if tr_evict='1' then
							-- need to evict old line first
							evict_start <= '1';
							state       <= SEVICT;
						else
							-- fetch line
							fetch_start <= '1';
							state       <= SFETCH;
						end if;
					end if;
					
				when SFETCH =>
					-- wait until fetch is done
					if fetch_done='1' then
						-- restart request
						state <= SIDLE;
					end if;
					
				when SEVICT =>
					-- wait until old line is evicted
					if evict_done='1' then
						-- now fetch new line
						fetch_start <= '1';
						state       <= SFETCH;
					end if;
			end case;
		end if;
	end process;
	
	
	--
	-- tag-ram
	--
	
	-- update tag-ram when starting new read/write request
	tr_rupd <= '1' when (state=SIDLE and (rreq='1' or ractive='1')) else '0';
	tr_wupd <= '1' when (state=SIDLE and (wreq='1' or wactive='1')) else '0';
	
	-- tag-ram control
	process(clk,reset)
		variable index  : index_t;
		variable tag    : tag_t;
		variable entry  : tagram_entry_t;
		variable hit    : std_logic;
		variable way    : natural range 0 to WAYS-1;
		variable evict  : std_logic;
		variable oldtag : tag_t;
	begin
		if reset='1' then
			tr_hit    <= '0';
			tr_way    <= to_unsigned(0, tr_way'length);
			tr_evict  <= '0';
			tr_oldtag <= to_unsigned(0, tr_oldtag'length);
		elsif rising_edge(clk) then	
			-- check for active request
			if tr_rupd='1' or tr_wupd='1' then
				--> request active, lookup address in tag-ram
				
				-- split address
				index := addr(BITS_INDEX+BITS_DISPL-1 downto BITS_DISPL);
				tag   := addr(BITS_TOTAL-1 downto BITS_INDEX+BITS_DISPL);
				
				-- read entry from tag-ram
				entry := slv2entry(tagram(to_integer(index)));
				
				-- check for cache-hit
				hit := '0';
				way := 0;
				for i in 0 to WAYS-1 loop
					if entry.way(i).valid='1' and entry.way(i).tag=tag then
						way := i;
						hit := '1';
					end if;
				end loop;
				
				-- handle cache miss
				if hit='0' then
					-- get entry to replace
					if entry.way(0).valid='0' or entry.age="0" 
						then way := 0;
						else way := 1;
					end if;
					
					-- check if we need to evict cacheline first
					evict  := entry.way(way).valid and entry.way(way).dirty;
					oldtag := entry.way(way).tag;
					
					-- fill entry
					entry.way(way).valid := '1';
					entry.way(way).dirty := tr_wupd;
					entry.way(way).tag   := tag;
				else
					-- update dirty-flag
					entry.way(way).dirty := entry.way(way).dirty or tr_wupd;
					
					-- nothing to evict
					evict  := '0';
					oldtag := (others=>'0');
				end if;
	
				-- update age-bits
				if way=0 
					then entry.age := "1";
					else entry.age := "0";
				end if;
				
				-- write back entry into RAM
				tagram(to_integer(index)) <= entry2slv(entry);
				
				-- output results
				tr_hit    <= hit;
				tr_way    <= to_unsigned(way, tr_way'length);
				tr_evict  <= evict;
				tr_oldtag <= oldtag;
			end if;
		end if;
	end process;
	
	
	--
	-- cache line updating
	--

	-- cache-line control (user port side)
	process(clk,reset)
	begin
		if reset='1' then
			fetch_active <= '0';
			evict_active <= '0';
			fetch_done   <= '0';
			evict_done   <= '0';
			ext_rreq     <= '0';
			ext_wreq     <= '0';
		elsif rising_edge(clk) then
			-- clear control-flags by default
			fetch_done <= '0';
			evict_done <= '0';
			
			-- update status
			if fetch_active='0' then
				if fetch_start='1' then
					-- start fetching line
					fetch_active <= '1';
					ext_rreq     <= '1';
				end if;
			else
				-- clear request-flag after read starts
				if ext_rstart='1' then
					ext_rreq <= '0';
				end if;
				
				-- check if fetch is done
				if ext_rdone='1' then
					fetch_done   <= '1';
					fetch_active <= '0';
				end if;
			end if;
			
			-- update status
			if evict_active='0' then
				if evict_start='1' then
					-- start evicting line
					evict_active <= '1';
					ext_wreq     <= '1';
				end if;
			else
				-- clear request-flag after write starts
				if ext_wstart='1' then
					ext_wreq <= '0';
				end if;
				
				-- check if evict is done
				if ext_wdone='1' then
					evict_done   <= '1';
					evict_active <= '0';
				end if;
			end if;
		end if;
	end process;
	
	-- bring control-signals into DDR clock domain
	i_sync_fs: entity xbus_common.sync_feedback
		port map (
			i_clk  => clk,
			o_clk  => ddr2_dclk,
			i_data => fetch_start,
			o_data => cline_fetch
		);
	i_sync_es: entity xbus_common.sync_feedback
		port map (
			i_clk  => clk,
			o_clk  => ddr2_dclk,
			i_data => evict_start,
			o_data => cline_evict1
		);
		
	-- cache-line control (DDR port side)
	process(ddr2_dclk,reset)
	begin
		if reset='1' then
			cline_evict2 <= '0';
			cline_displ  <= (others=>'0');
			cline_way    <= (others=>'0');
		elsif rising_edge(ddr2_dclk) then
			-- bring selected way into this clock domain
			cline_way <= tr_way;
			
			-- create delayed start-evict-flag
			cline_evict2 <= cline_evict1;
			
			-- update data-ram address
			if cline_fetch='1' or cline_evict1='1' then
				cline_displ <= to_unsigned(0, BITS_DISPL);
			elsif ext_rvalid='1' or ext_wen='1' or cline_evict2='1' then
				cline_displ <= cline_displ+1;
			end if;
		end if;
	end process;

	-- static signals to external memory 
	ext_raddr <= to_unsigned(BASE_ADDR, 24) + align_addr(addr);
	ext_waddr <= to_unsigned(BASE_ADDR, 24) + tua2ea(tr_oldtag, addr);
	ext_rsize <= to_unsigned(SIZE_LINE, ext_rsize'length);
	ext_wsize <= to_unsigned(SIZE_LINE, ext_wsize'length);
	ext_wdata <= dram_rdata2;
	
	
	--
	-- data ram
	--
	
	-- connect user-port of dataram
	dram_way1   <= tr_way;
	dram_addr1  <= ea2da(addr);
	dram_ren1   <= tr_rupd;
	dram_wen1   <= '1' when (state=SWRITE and tr_hit='1') else '0';
	dram_wdata1 <= wdata;

	-- connect ddr-port of dataram
	dram_way2   <= cline_way;
	dram_addr2  <= ead2da(addr,cline_displ);
	dram_ren2   <= ext_wen or cline_evict2;
	dram_wen2   <= ext_rvalid;
	dram_wdata2 <= ext_rdata;

	-- output multiplexer
	dram_rdata1 <= dram_rraw1(to_integer(dram_way1));
	dram_rdata2 <= dram_rraw2(to_integer(dram_way2));
	
	-- infer data-rams (fully unrolled, because XST won't infer ram otherwise)
	process(clk)
	begin
		if rising_edge(clk) then
			if dram_ren1='1' or dram_wen1='1' then
				if dram_way1=0 and dram_wen1='1' then
					dataram1(to_integer(dram_addr1)) := dram_wdata1;
				end if;
				dram_rraw1(0) <= dataram1(to_integer(dram_addr1));
			end if;
			if dram_ren1='1' or dram_wen1='1' then
				if dram_way1=1 and dram_wen1='1' then
					dataram2(to_integer(dram_addr1)) := dram_wdata1;
				end if;
				dram_rraw1(1) <= dataram2(to_integer(dram_addr1));
			end if;
		end if;
	end process;
	process(ddr2_dclk)
	begin
		if rising_edge(ddr2_dclk) then
			if dram_ren2='1' or dram_wen2='1' then
				if dram_way2=0 and dram_wen2='1' then
					dataram1(to_integer(dram_addr2)) := dram_wdata2;
				end if;
				dram_rraw2(0) <= dataram1(to_integer(dram_addr2));
			end if;
			if dram_ren2='1' or dram_wen2='1' then
				if dram_way2=1 and dram_wen2='1' then
					dataram2(to_integer(dram_addr2)) := dram_wdata2;
				end if;
				dram_rraw2(1) <= dataram2(to_integer(dram_addr2));
			end if;
		end if;
	end process;
end rtl;
