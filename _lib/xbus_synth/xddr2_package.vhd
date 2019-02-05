library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
package xddr2 is

	-- RAM read port: port -> controller
	type xddr2_rd_p2c is record
		req  : std_logic;							-- read request
		addr : unsigned(23 downto 0);				-- read address
		size : unsigned(9 downto 0);				-- read size
	end record xddr2_rd_p2c;

	-- RAM read port: controller -> port
	type xddr2_rd_c2p is record
		start  : std_logic;							-- read request started
		done   : std_logic;							-- read request done
		valid  : std_logic;							-- read data valid?
		data   : std_logic_vector(31 downto 0);		-- read data
	end record xddr2_rd_c2p;

	-- RAM write port: port -> controller
	type xddr2_wr_p2c is record
		req  : std_logic;							-- write request
		addr : unsigned(23 downto 0);				-- write address
		size : unsigned(9 downto 0);				-- write size
		data : std_logic_vector(31 downto 0);		-- write data
	end record xddr2_wr_p2c;
	
	-- RAM write port: controller -> port
	type xddr2_wr_c2p is record
		start : std_logic;							-- write request started
		done  : std_logic;							-- write request done
		wen   : std_logic;							-- write enable
	end record xddr2_wr_c2p;
	
	-- array-types of interfaces
	type xddr2_rdb_p2c is array (natural range <>) of xddr2_rd_p2c;
	type xddr2_rdb_c2p is array (natural range <>) of xddr2_rd_c2p;
	type xddr2_wrb_p2c is array (natural range <>) of xddr2_wr_p2c;
	type xddr2_wrb_c2p is array (natural range <>) of xddr2_wr_c2p;
		
end xddr2;

package body xddr2 is
	-- nothing so far
end xddr2;

