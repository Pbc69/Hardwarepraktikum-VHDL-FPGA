-------------------------------------------------------------------------------
-- sdram_arbiter_read ---------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
library work;
	use work.xddr2.all;

entity xddr2_arbiter_read is
	generic (
		COUNT 		: natural
	);
	port(
		-- common
		clk			: in  std_logic;
		reset		: in  std_logic;

		-- input
		in_c2p		: out xddr2_rdb_c2p(COUNT-1 downto 0);
		in_p2c		: in  xddr2_rdb_p2c(COUNT-1 downto 0);
		
		-- output
		out_c2p		: in  xddr2_rd_c2p;
		out_p2c		: out xddr2_rd_p2c
	);
end xddr2_arbiter_read;

architecture rtl of xddr2_arbiter_read is

	-- status
	signal selected		: std_logic_vector(COUNT-1 downto 0);
	signal active		: std_logic;
	signal request		: std_logic;
	
	-- arbiter signals
	signal arb_req		: std_logic_vector(COUNT-1 downto 0);
	signal arb_ack		: std_logic;
	signal arb_grant	: std_logic_vector(COUNT-1 downto 0);
	signal arb_nogrant	: std_logic;
	
begin

	-- update status
	process(clk, reset)
	begin
		if reset='1' then
			selected <= (others=>'0');
			active   <= '0';
			request  <= '0';
		elsif rising_edge(clk) then
			-- update active-flag
			if out_c2p.start='1' then
				active <= '1';
			elsif out_c2p.done='1' then
				active <= '0';
			end if;
			
			-- update selection
			if active='0' and out_c2p.start='0'  then
				if request='0' then
					selected <= arb_grant;
					request  <= not arb_nogrant;
				end if;
			else
				request <= '0';
			end if;
		end if;
	end process;

	-- connect datasources and arbiter 
	arb_ack <= out_c2p.start;
	process(in_p2c,out_c2p,selected)
	begin
		for i in 0 to COUNT-1 loop
			arb_req(i)      <= in_p2c(i).req;
			in_c2p(i).start <= out_c2p.start and selected(i);
			in_c2p(i).done  <= out_c2p.done  and selected(i);
			in_c2p(i).valid <= out_c2p.valid and selected(i);
			in_c2p(i).data  <= out_c2p.data;
		end loop;
	end process;
	
	-- create request-flag
	out_p2c.req <= request;
	
	-- get data from selected source
	process(selected, in_p2c, active)
		variable found : std_logic;
	begin
		found := '0';
		out_p2c.addr <= (others=>'0'); 
		out_p2c.size <= (others=>'0');
		for i in 0 to COUNT-1 loop
			if found='0' and selected(i)='1' then
				out_p2c.addr <= in_p2c(i).addr;
				out_p2c.size <= in_p2c(i).size;
				found := '1';
			end if;
		end loop;
	end process;

	-- arbiter
	i_arb: entity xbus_common.arbiter_roundrobin
		generic map (
			SIZE    => COUNT
		)
		port map (
			clk		=> clk,
			reset 	=> reset,
			norr    => '0',
			req		=> arb_req,
			ack		=> arb_ack,
			grant	=> arb_grant,
			nogrant	=> arb_nogrant
		);

end rtl;

-------------------------------------------------------------------------------
-- xddr2_arbiter_write --------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library xbus_common;
	use xbus_common.all;
library work;
	use work.xddr2.all;

entity xddr2_arbiter_write is
	generic (
		COUNT 		: natural
	);
	port(
		-- common
		clk			: in  std_logic;
		reset		: in  std_logic;

		-- input
		in_c2p		: out xddr2_wrb_c2p(COUNT-1 downto 0);
		in_p2c		: in  xddr2_wrb_p2c(COUNT-1 downto 0);
		
		-- output
		out_c2p		: in  xddr2_wr_c2p;
		out_p2c		: out xddr2_wr_p2c
	);
end xddr2_arbiter_write;

architecture rtl of xddr2_arbiter_write is

	-- status
	signal selected		: std_logic_vector(COUNT-1 downto 0);
	signal active		: std_logic;
	signal request		: std_logic;
	
	-- arbiter signals
	signal arb_req		: std_logic_vector(COUNT-1 downto 0);
	signal arb_ack		: std_logic;
	signal arb_grant	: std_logic_vector(COUNT-1 downto 0);
	signal arb_nogrant	: std_logic;
	
begin

	-- update status
	process(clk, reset)
	begin
		if reset='1' then
			selected <= (others=>'0');
			active   <= '0';
			request  <= '0';
		elsif rising_edge(clk) then
			-- update active-flag
			if out_c2p.start='1' then
				active <= '1';
			elsif out_c2p.done='1' then
				active <= '0';
			end if;
			
			-- update selection
			if active='0' and out_c2p.start='0'  then
				if request='0' then
					selected <= arb_grant;
					request  <= not arb_nogrant;
				end if;
			else
				request <= '0';
			end if;
		end if;
	end process;

	-- connect datasources and arbiter 
	arb_ack <= out_c2p.start;
	process(in_p2c,out_c2p,selected)
	begin
		for i in 0 to COUNT-1 loop
			arb_req(i)      <= in_p2c(i).req;
			in_c2p(i).start <= out_c2p.start and selected(i);
			in_c2p(i).done  <= out_c2p.done  and selected(i);
			in_c2p(i).wen   <= out_c2p.wen   and selected(i);
		end loop;
	end process;
		
	-- create request-flag
	out_p2c.req <= request;
	
	-- get data from selected source
	process(selected, in_p2c)
		variable found : std_logic;
	begin
		found := '0';
		out_p2c.addr <= (others=>'0'); 
		out_p2c.size <= (others=>'0');
		out_p2c.data <= (others=>'0');
		for i in 0 to COUNT-1 loop
			if found='0' and selected(i)='1' then
				out_p2c.addr <= in_p2c(i).addr;
				out_p2c.size <= in_p2c(i).size;
				out_p2c.data <= in_p2c(i).data;
				found := '1';
			end if;
		end loop;
	end process;

	-- arbiter
	i_arb: entity xbus_common.arbiter_roundrobin
		generic map (
			SIZE    => COUNT
		)
		port map (
			clk		=> clk,
			reset 	=> reset,
			norr    => '0',
			req		=> arb_req,
			ack		=> arb_ack,
			grant	=> arb_grant,
			nogrant	=> arb_nogrant
		);

end rtl;
