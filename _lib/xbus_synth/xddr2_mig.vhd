-------------------------------------------------------------------------------
-- DISCLAIMER OF LIABILITY
-- 
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you a 
-- license to use this text/file solely for design, simulation, 
-- implementation and creation of design files limited 
-- to Xilinx devices or technologies. Use with non-Xilinx 
-- devices or technologies is expressly prohibited and 
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information 
-- "as-is" solely for use in developing programs and 
-- solutions for Xilinx devices, with no obligation on the 
-- part of Xilinx to provide support. By providing this design, 
-- code, or information as one possible implementation of 
-- this feature, application or standard, Xilinx is making no 
-- representation that this implementation is free from any 
-- claims of infringement. You are responsible for 
-- obtaining any rights you may require for your implementation. 
-- Xilinx expressly disclaims any warranty whatsoever with 
-- respect to the adequacy of the implementation, including 
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied 
-- warranties of merchantability or fitness for a particular 
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications is
-- expressly prohibited.
--
-- Any modifications that are made to the Source Code are 
-- done at the user's sole risk and will be unsupported.
--
-- Copyright (c) 2006-2007 Xilinx, Inc. All rights reserved.
--
-- This copyright and support notice must be retained as part 
-- of this text at all times.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor		    : Xilinx
-- \   \   \/    Version	    : 2.2
--  \   \        Application	    : MIG
--  /   /        Filename	    : xddr2mig_parameters_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2008/03/05 16:38:33 $
-- \   \  /  \   Date Created	    : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-------------------------------------------------------------------------------

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use UNISIM.VCOMPONENTS.all;


package  xddr2mig_parameters_0  is

-- The reset polarity is set to active low by default. 
-- You can change this by editing the parameter RESET_ACTIVE_LOW.
-- Please do not change any of the other parameters directly by editing the RTL. 
-- All other changes should be done through the GUI.

constant   DATA_WIDTH                                : INTEGER   :=  16;
constant   DATA_STROBE_WIDTH                         : INTEGER   :=  2;
constant   DATA_MASK_WIDTH                           : INTEGER   :=  2;
constant   CLK_WIDTH                                 : INTEGER   :=  1;
constant   CKE_WIDTH                                 : INTEGER   :=  1;
constant   ROW_ADDRESS                               : INTEGER   :=  13;
constant   MEMORY_WIDTH                              : INTEGER   :=  8;
constant   REGISTERED                                : INTEGER   :=  0;
constant   DATABITSPERSTROBE                         : INTEGER   :=  8;
constant   RESET_PORT                                : INTEGER   :=  0;
constant   MASK_ENABLE                               : INTEGER   :=  1;
constant   COLUMN_ADDRESS                            : INTEGER   :=  10;
constant   BANK_ADDRESS                              : INTEGER   :=  2;
constant   DEBUG_EN                                  : INTEGER   :=  0;
constant   LOAD_MODE_REGISTER                        : std_logic_vector(12 downto 0) := "0010100110010";

constant   EXT_LOAD_MODE_REGISTER                    : std_logic_vector(12 downto 0) := "0000000000000";

constant   RESET_ACTIVE_LOW                         : std_logic := '1';
constant   RFC_COUNT_VALUE                            : std_logic_vector(7 downto 0) := "00001101";
constant   TWR_COUNT_VALUE                            : std_logic_vector(2 downto 0) := "010";
constant   MAX_REF_WIDTH                                   : INTEGER   :=  11;
constant   MAX_REF_CNT                     : std_logic_vector(10 downto 0) := "01000000001";

end xddr2mig_parameters_0  ;

--><------------------------------------------------------------------------><-

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_tap_dly is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    tapin : in  std_logic;
    flop2 : out std_logic_vector(31 downto 0)
    );
end xddr2mig_tap_dly;

architecture arc_tap_dly of xddr2mig_tap_dly is

  signal tap        : std_logic_vector(31 downto 0);
  signal flop1      : std_logic_vector(31 downto 0);
  signal high       : std_logic;
  signal low        : std_logic;
  signal flop2_xnor : std_logic_vector(30 downto 0);
  signal reset_r    : std_logic;

  attribute syn_preserve : boolean;
  attribute syn_preserve of tap   : signal is true;
  attribute syn_preserve of flop1 : signal is true;    


begin

  process(clk)
  begin
    if(clk'event and clk='1') then
      reset_r <= reset;
    end if;
  end process;

  high <= '1';
  low  <= '0';

  l0 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tapin,
      I2 => low,
      I3 => high,
      O  => tap(0)
      );

  l1 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(0),
      I2 => low,
      I3 => high,
      O  => tap(1)
      );
  l2 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(1),
      I2 => low,
      I3 => high,
      O  => tap(2)
      );
  l3 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(2),
      I2 => low,
      I3 => high,
      O  => tap(3)
      );
  l4 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(3),
      I2 => low,
      I3 => high,
      O  => tap(4)
      );
  l5 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(4),
      I2 => low,
      I3 => high,
      O  => tap(5)
      );
  l6 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(5),
      I2 => low,
      I3 => high,
      O  => tap(6)
      );
  l7 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(6),
      I2 => low,
      I3 => high,
      O  => tap(7)
      );
  l8 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(7),
      I2 => low,
      I3 => high,
      O  => tap(8)
      );
  l9 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(8),
      I2 => low,
      I3 => high,
      O  => tap(9)
      );
  l10 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(9),
      I2 => low,
      I3 => high,
      O  => tap(10)
      );
  l11 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(10),
      I2 => low,
      I3 => high,
      O  => tap(11)
      );
  l12 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(11),
      I2 => low,
      I3 => high,
      O  => tap(12)
      );
  l13 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(12),
      I2 => low,
      I3 => high,
      O  => tap(13)
      );
  l14 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(13),
      I2 => low,
      I3 => high,
      O  => tap(14)
      );
  l15 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(14),
      I2 => low,
      I3 => high,
      O  => tap(15)
      );
  l16 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(15),
      I2 => low,
      I3 => high,
      O  => tap(16)
      );
  l17 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(16),
      I2 => low,
      I3 => high,
      O  => tap(17)
      );
  l18 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(17),
      I2 => low,
      I3 => high,
      O  => tap(18)
      );
  l19 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(18),
      I2 => low,
      I3 => high,
      O  => tap(19)
      );
  l20 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(19),
      I2 => low,
      I3 => high,
      O  => tap(20)
      );
  l21 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(20),
      I2 => low,
      I3 => high,
      O  => tap(21)
      );
  l22 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(21),
      I2 => low,
      I3 => high,
      O  => tap(22)
      );
  l23 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(22),
      I2 => low,
      I3 => high,
      O  => tap(23)
      );
  l24 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(23),
      I2 => low,
      I3 => high,
      O  => tap(24)
      );
  l25 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(24),
      I2 => low,
      I3 => high,
      O  => tap(25)
      );
  l26 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(25),
      I2 => low,
      I3 => high,
      O  => tap(26)
      );
  l27 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(26),
      I2 => low,
      I3 => high,
      O  => tap(27)
      );
  l28 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(27),
      I2 => low,
      I3 => high,
      O  => tap(28)
      );
  l29 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(28),
      I2 => low,
      I3 => high,
      O  => tap(29)
      );
  l30 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(29),
      I2 => low,
      I3 => high,
      O  => tap(30)
      );
  l31 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(30),
      I2 => low,
      I3 => high,
      O  => tap(31)
      );

  gen_tap1 : for tap1_i in 0 to 31 generate
    r : FDR port map (
      Q => flop1(tap1_i),
      C => clk,
      D => tap(tap1_i),
      R => reset_r
      );
  end generate;
  
  gen_asgn : for asgn_i in 0 to 30 generate
    flop2_xnor(asgn_i)  <= flop1(asgn_i) xnor flop1(asgn_i+1);
  end generate;

  gen_tap2 : for tap2_i in 0 to 30 generate
    u : FDR port map (
      Q => flop2(tap2_i),
      C => clk,
      D => flop2_xnor(tap2_i),
      R => reset_r
      );
  end generate;
  
  u31 : FDR
    port map (
      Q => flop2(31),
      C => clk,
      D => flop1(31),
      R => reset_r
      );
  
end arc_tap_dly;

--><------------------------------------------------------------------------><-


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_cal_ctl is
  port (
    clk                    : in  std_logic;
    reset                  : in  std_logic;
    flop2                  : in  std_logic_vector(31 downto 0);
    tapfordqs              : out std_logic_vector(4 downto 0);
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );
end xddr2mig_cal_ctl;

architecture arc_cal_ctl of xddr2mig_cal_ctl is

  signal cnt                : std_logic_vector(5 downto 0);
  signal cnt1               : std_logic_vector(5 downto 0);
  signal trans_onedtct      : std_logic;
  signal trans_twodtct      : std_logic;
  signal phase_cnt          : std_logic_vector(4 downto 0);
  signal tap_dly_reg        : std_logic_vector(31 downto 0);
  signal enb_trans_two_dtct : std_logic;
  signal tapfordqs_val      : std_logic_vector(4 downto 0);
  signal cnt_val            : integer;
  signal reset_r            : std_logic;

  constant tap1        : std_logic_vector(4 downto 0) := "01111";
  constant tap2        : std_logic_vector(4 downto 0) := "10111";
  constant tap3        : std_logic_vector(4 downto 0) := "11011";
  constant tap4        : std_logic_vector(4 downto 0) := "11101";
  constant tap5        : std_logic_vector(4 downto 0) := "11110";
  constant tap6        : std_logic_vector(4 downto 0) := "11111";
  constant default_tap : std_logic_vector(4 downto 0) := "11101";

  attribute syn_keep : boolean;
  attribute syn_keep of cnt                : signal is true;
  attribute syn_keep of cnt1               : signal is true;
  attribute syn_keep of trans_onedtct      : signal is true;
  attribute syn_keep of trans_twodtct      : signal is true;
  attribute syn_keep of tap_dly_reg        : signal is true;
  attribute syn_keep of enb_trans_two_dtct : signal is true;
  attribute syn_keep of phase_cnt          : signal is true;
  attribute syn_keep of tapfordqs_val      : signal is true;

begin

  dbg_phase_cnt          <= phase_cnt;
  dbg_cnt                <= cnt1;
  dbg_trans_onedtct      <= trans_onedtct;
  dbg_trans_twodtct      <= trans_twodtct;
  dbg_enb_trans_two_dtct <= enb_trans_two_dtct;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      reset_r <= reset;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      tapfordqs <= tapfordqs_val;
    end if;
  end process;

-----------For Successive Transition-------------------

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if(reset_r = '1') then
        enb_trans_two_dtct <= '0';
      elsif(phase_cnt >= "00001") then
        enb_trans_two_dtct <= '1';
      else
        enb_trans_two_dtct <= '0';
      end if;
    end if;
  end process;

  process (clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1') then
        tap_dly_reg <= "00000000000000000000000000000000";
      elsif(cnt(5) = '1') then
        tap_dly_reg <= flop2;
      else
        tap_dly_reg <= tap_dly_reg;
      end if;
    end if;
  end process;

--------Free Running Counter For Counting 32 States ----------------------
------- Two parallel counters are used to fix the timing ------------------

  process (clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1' or cnt(5) = '1') then
        cnt(5 downto 0) <= "000000";
      else
        cnt(5 downto 0) <= cnt(5 downto 0) + "000001";
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1' or cnt1(5) = '1') then
        cnt1(5 downto 0) <= "000000";
      else
        cnt1(5 downto 0) <= cnt1(5 downto 0) + "000001";
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if(reset_r = '1' or cnt(5) = '1') then
        phase_cnt <= "00000";
      elsif (trans_onedtct = '1' and trans_twodtct = '0') then
        phase_cnt <= phase_cnt + "00001";
      else
        phase_cnt <= phase_cnt;
      end if;
    end if;
  end process;

----------- Checking For The First Transition ------------------

  process (clk)
  begin
    if clk'event and clk = '1' then
      if (reset_r = '1' or cnt(5) = '1') then
        trans_onedtct <= '0';
        trans_twodtct <= '0';
      elsif (cnt(4 downto 0) = "00000" and tap_dly_reg(0) = '1') then
        trans_onedtct <= '1';
        trans_twodtct <= '0';
      elsif (tap_dly_reg(cnt_val) = '1' and trans_twodtct = '0') then
        if(trans_onedtct = '1' and enb_trans_two_dtct = '1') then
          trans_twodtct <= '1';
        else
          trans_onedtct <= '1';
        end if;
      end if;
    end if;
  end process;

  cnt_val <= conv_integer(cnt(4 downto 0));

  -- Tap values for Left/Right banks
  process (clk)
  begin
    if clk'event and clk = '1' then
      if(reset_r = '1') then
        tapfordqs_val <= default_tap;
      elsif(cnt1(4) = '1' and cnt1(3) = '1' and cnt1(2) = '1' and cnt1(1) = '1'
        and cnt1(0) = '1') then
        if ((trans_onedtct = '0') or (trans_twodtct = '0')
			or (phase_cnt > "01011")) then
          tapfordqs_val <= tap4;
        elsif (phase_cnt > "01000") then
          tapfordqs_val <= tap3;
        else
          tapfordqs_val <= tap2;
        end if;
      else
        tapfordqs_val <= tapfordqs_val;
      end if;
    end if;
  end process;

end arc_cal_ctl;

--><------------------------------------------------------------------------><-

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
library work;
use work.all;

entity xddr2mig_cal_top is
  port(
    clk                    : in  std_logic;
    clk0dcmlock            : in  std_logic;
    reset                  : in  std_logic;
    tapfordqs              : out std_logic_vector(4 downto 0);
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );
end xddr2mig_cal_top;

architecture arc of xddr2mig_cal_top is

  ATTRIBUTE X_CORE_INFO          : STRING;
  ATTRIBUTE CORE_GENERATION_INFO : STRING;

  ATTRIBUTE X_CORE_INFO of arc : ARCHITECTURE  IS "mig_v2_1_ddr2_sp3, Coregen 10.1i_ip0";
  ATTRIBUTE CORE_GENERATION_INFO of arc : ARCHITECTURE IS "ddr2_sp3,mig_v2_1,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=0010100110010, ext_load_mode_register=0000000000000}";

  signal fpga_rst  : std_logic;
  signal flop2_val : std_logic_vector(31 downto 0);

  attribute syn_noprune : boolean;
  attribute syn_noprune of cal_ctl0 : label is true;
  attribute syn_noprune of tap_dly0 : label is true;
	
begin

  fpga_rst <= (not reset) or (not clk0dcmlock);

  cal_ctl0 : entity xddr2mig_cal_ctl
    port map(
      clk                    => clk,
      reset                  => fpga_rst,
      flop2                  => flop2_val,
      tapfordqs              => tapfordqs,
      dbg_phase_cnt          => dbg_phase_cnt,
      dbg_cnt                => dbg_cnt,
      dbg_trans_onedtct      => dbg_trans_onedtct,
      dbg_trans_twodtct      => dbg_trans_twodtct,
      dbg_enb_trans_two_dtct => dbg_enb_trans_two_dtct
      );

  tap_dly0 : entity xddr2mig_tap_dly
    port map (
      clk                    => clk,
      reset                  => fpga_rst,
      tapin		     => clk,
      flop2		     => flop2_val
      );

end arc;

--><------------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;

entity xddr2mig_controller_iobs_0 is
  port(
    clk0              : in  std_logic;
    ddr_rasb_cntrl    : in  std_logic;
    ddr_casb_cntrl    : in  std_logic;
    ddr_web_cntrl     : in  std_logic;
    ddr_cke_cntrl     : in  std_logic;
    ddr_csb_cntrl     : in  std_logic;
    ddr_odt_cntrl     : in  std_logic;
    ddr_address_cntrl : in  std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_ba_cntrl      : in  std_logic_vector((BANK_ADDRESS -1) downto 0);
    rst_dqs_div_int   : in  std_logic;
    ddr_odt           : out std_logic;
    ddr_rasb          : out std_logic;
    ddr_casb          : out std_logic;
    ddr_web           : out std_logic;
    ddr_ba            : out std_logic_vector((BANK_ADDRESS -1) downto 0);
    ddr_address       : out std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_cke           : out std_logic;
    ddr_csb           : out std_logic;
    rst_dqs_div       : out std_logic;
    rst_dqs_div_in    : in  std_logic;
    rst_dqs_div_out   : out std_logic
    );
end xddr2mig_controller_iobs_0;

architecture arc of xddr2mig_controller_iobs_0 is

  signal ddr_web_q       : std_logic;
  signal ddr_rasb_q      : std_logic;
  signal ddr_casb_q      : std_logic;
  signal ddr_cke_q       : std_logic;
  signal ddr_cke_int     : std_logic;
  signal ddr_address_reg : std_logic_vector((ROW_ADDRESS -1) downto 0);
  signal ddr_ba_reg      : std_logic_vector((BANK_ADDRESS -1) downto 0);
  signal ddr_odt_reg     : std_logic;
  signal clk180          : std_logic;
  
  attribute iob          : string;

  attribute iob of iob_rasb : label is "true";
  attribute iob of iob_casb : label is "true";
  attribute iob of iob_web  : label is "true";
  attribute iob of iob_cke  : label is "true";
  attribute iob of iob_odt  : label is "true";

begin

  clk180 <= not clk0;

---- *******************************************  ----
----  Includes the instantiation of FD for cntrl  ----
----            signals                           ----
---- *******************************************  ----

  iob_web : FD
    port map (
      Q => ddr_web_q,
      D => ddr_web_cntrl,
      C => clk180
      );

  iob_rasb : FD
    port map (
      Q => ddr_rasb_q,
      D => ddr_rasb_cntrl,
      C => clk180
      );

  iob_casb : FD
    port map (
      Q => ddr_casb_q,
      D => ddr_casb_cntrl,
      C => clk180
      );

---- *************************************  ----
----  Output buffers for control signals    ----
---- *************************************  ----

  r16 : OBUF
    port map (
      I => ddr_web_q,
      O => ddr_web
      );

  r17 : OBUF
    port map (
      I => ddr_rasb_q,
      O => ddr_rasb
      );

  r18 : OBUF
    port map (
      I => ddr_casb_q,
      O => ddr_casb
      );

  r19 : OBUF
    port map (
      I => ddr_csb_cntrl,
      O => ddr_csb
      );

  iob_cke1 : FD
    port map(
      Q => ddr_cke_int,
      D => ddr_cke_cntrl,
      C => clk0
      );

  iob_cke : FD
    port map(
      Q => ddr_cke_q,
      D => ddr_cke_int,
      C => clk180
      );

  r20 : OBUF
    port map (
      I => ddr_cke_q,
      O => ddr_cke
      );

  iob_odt : FD
    port map (
      Q => ddr_ODT_reg,
      D => ddr_ODT_cntrl,
      C => clk180
      );

  ODT_iob_obuf : OBUF
    port map (
      I => ddr_ODT_reg,
      O => ddr_ODT
      );

---- *******************************************  ----
----  Includes the instantiation of FD and OBUF   ----
----  for row address and bank address            ----
---- *******************************************  ----

  gen_addr : for i in (ROW_ADDRESS -1) downto 0 generate
    attribute IOB of iob_addr         : label is "true";
  begin
    iob_addr : FD
      port map (
        Q => ddr_address_reg(i),
        D => ddr_address_cntrl(i),
        C => clk180
        );
    r : OBUF
      port map (
        I => ddr_address_reg(i),
        O => ddr_address(i)
        );
  end generate;

  gen_ba : for i in (BANK_ADDRESS -1) downto 0 generate
    attribute IOB of iob_ba         : label is "true";       
  begin
    iob_ba : FD
      port map (
        Q => ddr_ba_reg(i),
        D => ddr_ba_cntrl(i),
        C => clk180
        );
    r : OBUF
      port map (
        I => ddr_ba_reg(i),
        O => ddr_ba(i)
        );
  end generate;

  rst_iob_inbuf : IBUF
    port map(
      I => rst_dqs_div_in,
      O => rst_dqs_div
      );

  rst_iob_outbuf : OBUF
    port map (
      I => rst_dqs_div_int,
      O => rst_dqs_div_out
      );

end arc;


--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;

entity xddr2mig_controller_0 is
  generic
    (
     COL_WIDTH : integer := COLUMN_ADDRESS;
     ROW_WIDTH : integer := ROW_ADDRESS
    );
  port(
    clk               : in  std_logic;
    rst0              : in  std_logic;
    rst180            : in  std_logic;
    address           : in  std_logic_vector(((ROW_ADDRESS + COLUMN_ADDRESS)-1)
                                            downto 0);
    bank_addr         : in  std_logic_vector((BANK_ADDRESS-1) downto 0);
    command_register  : in  std_logic_vector(2 downto 0);
    burst_done        : in  std_logic;
    ddr_rasb_cntrl    : out std_logic;
    ddr_casb_cntrl    : out std_logic;
    ddr_web_cntrl     : out std_logic;
    ddr_ba_cntrl      : out std_logic_vector((BANK_ADDRESS-1) downto 0);
    ddr_address_cntrl : out std_logic_vector((ROW_ADDRESS-1) downto 0);
    ddr_cke_cntrl     : out std_logic;
    ddr_csb_cntrl     : out std_logic;
    ddr_odt_cntrl     : out std_logic;
    dqs_enable        : out std_logic;
    dqs_reset         : out std_logic;
    write_enable      : out std_logic;
    rst_calib         : out std_logic;
    rst_dqs_div_int   : out std_logic;
    cmd_ack           : out std_logic;
    init              : out std_logic;
    ar_done           : out std_logic;
    wait_200us        : in  std_logic;
    auto_ref_req      : out std_logic
    );
end xddr2mig_controller_0;


architecture arc of xddr2mig_controller_0 is

  type s_m is (IDLE, PRECHARGE, AUTO_REFRESH, ACTIVE,
               FIRST_WRITE, WRITE_WAIT, BURST_WRITE,
               PRECHARGE_AFTER_WRITE, PRECHARGE_AFTER_WRITE_2, READ_WAIT,
               BURST_READ, ACTIVE_WAIT);

  type s_m1 is (INIT_IDLE, INIT_PRECHARGE,
                INIT_AUTO_REFRESH, INIT_LOAD_MODE_REG);
  signal next_state, current_state           : s_m;
  signal init_next_state, init_current_state : s_m1;

  signal ack_reg              : std_logic;
  signal ack_o                : std_logic;
  signal auto_ref             : std_logic;
  signal auto_ref1            : std_logic;
  signal autoref_value        : std_logic;
  signal auto_ref_detect1     : std_logic;
  signal autoref_count        : std_logic_vector((MAX_REF_WIDTH-1) downto 0);
  signal ar_done_p            : std_logic;
  signal auto_ref_issued      : std_logic;
  signal auto_ref_issued_p    : std_logic;
  signal ba_address_reg1      : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal ba_address_reg2      : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal burst_length         : std_logic_vector(2 downto 0);
  signal burst_cnt_max        : std_logic_vector(2 downto 0);
  signal cas_count            : std_logic_vector(2 downto 0);
  signal column_address_reg   : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal ddr_rasb1            : std_logic;
  signal ddr_casb1            : std_logic;
  signal ddr_web1             : std_logic;
  signal ddr_ba1              : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal ddr_address1         : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal dqs_enable_out       : std_logic;
  signal dqs_reset_out        : std_logic;
  signal dll_rst_count        : std_logic_vector(7 downto 0);
  signal init_count           : std_logic_vector(3 downto 0);
  signal init_done            : std_logic;
  signal init_done_r1         : std_logic;
  signal init_done_dis        : std_logic;
  signal init_done_value      : std_logic;
  signal init_memory          : std_logic;
  signal init_mem             : std_logic;
  signal initialize_memory    : std_logic;
  signal init_pre_count       : std_logic_vector(6 downto 0);
  signal ref_freq_cnt         : std_logic_vector((MAX_REF_WIDTH-1) downto 0);
  signal read_cmd             : std_logic;
  signal read_cmd1            : std_logic;
  signal read_cmd2            : std_logic;
  signal read_cmd3            : std_logic;
  signal rcdr_count           : std_logic_vector(2 downto 0);
  signal rcdw_count           : std_logic_vector(2 downto 0);
  signal rp_cnt_value         : std_logic_vector(2 downto 0);
  signal rfc_count_reg        : std_logic;
  signal ar_done_reg          : std_logic;
  signal rdburst_end_1        : std_logic;
  signal rdburst_end_2        : std_logic;
  signal rdburst_end          : std_logic;
  signal rp_count             : std_logic_vector(2 downto 0);
  signal rfc_count            : std_logic_vector(7 downto 0);
  signal row_address_reg      : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal column_address1      : std_logic_vector((ROW_ADDRESS -1) downto 0);
  signal rst_dqs_div_r        : std_logic;
  signal rst_dqs_div_r1       : std_logic;
  signal wrburst_end_cnt      : std_logic_vector(2 downto 0);
  signal wrburst_end          : std_logic;
  signal wrburst_end_1        : std_logic;
  signal wrburst_end_2        : std_logic;
  signal wrburst_end_3        : std_logic;
  signal wr_count             : std_logic_vector(2 downto 0);
  signal write_enable_out     : std_logic;
  signal write_cmd_in         : std_logic;
  signal write_cmd2           : std_logic;
  signal write_cmd3           : std_logic;
  signal write_cmd1           : std_logic;
  signal go_to_active_value   : std_logic;
  signal go_to_active         : std_logic;
  signal dqs_div_cascount     : std_logic_vector(2 downto 0);
  signal dqs_div_rdburstcount : std_logic_vector(2 downto 0);
  signal dqs_enable1          : std_logic;
  signal dqs_enable2          : std_logic;
  signal dqs_enable3          : std_logic;
  signal dqs_reset1_clk0      : std_logic;
  signal dqs_reset2_clk0      : std_logic;
  signal dqs_reset3_clk0      : std_logic;
  signal dqs_enable_int       : std_logic;
  signal dqs_reset_int        : std_logic;
  signal rst180_r             : std_logic;
  signal rst0_r               : std_logic;
  signal emr                  : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr                  : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr_dll_rst          : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr_dll_set          : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal ddr_odt1             : std_logic;
  signal ddr_odt2             : std_logic;
  signal rst_dqs_div_int1     : std_logic;
  signal accept_cmd_in        : std_logic;
  signal dqs_enable_i         : std_logic;
  signal auto_ref_wait        : std_logic;
  signal auto_ref_wait1       : std_logic;
  signal auto_ref_wait2       : std_logic;
  signal rpcnt0               : std_logic;
  signal address_reg          : std_logic_vector(((ROW_ADDRESS +
                                                   COLUMN_ADDRESS)-1) downto 0);
  signal ddr_rasb2            : std_logic;
  signal ddr_casb2            : std_logic;
  signal ddr_web2             : std_logic;
  signal count6               : std_logic_vector(5 downto 0);
  signal clk180               : std_logic;
  signal odt_deassert         : std_logic;
  


  constant cntnext     : std_logic_vector(5 downto 0)  := "101000";
  constant addr_const1 : std_logic_vector(14 downto 0) := "000010000000000";
  constant addr_const2 : std_logic_vector(14 downto 0) := "000001110000000";  --380
  constant addr_const3 : std_logic_vector(14 downto 0) := "000110001111111";  --C7F
  constant ba_const1   : std_logic_vector(2 downto 0)  := "010";
  constant ba_const2   : std_logic_vector(2 downto 0)  := "011";
  constant ba_const3   : std_logic_vector(2 downto 0)  := "001";

  attribute iob                        : string;
  attribute syn_preserve               : boolean;
  attribute syn_keep                   : boolean;

  attribute iob of rst_iob_out                 : label is "true";
  attribute syn_preserve of lmr_dll_rst        : signal is true;
  attribute syn_preserve of lmr_dll_set        : signal is true;
  attribute syn_preserve of ba_address_reg1    : signal is true;
  attribute syn_preserve of ba_address_reg2    : signal is true;
  attribute syn_preserve of column_address_reg : signal is true;
  attribute syn_preserve of row_address_reg    : signal is true;

begin

  clk180      <= not clk;
  emr         <= EXT_LOAD_MODE_REGISTER;
  lmr         <= LOAD_MODE_REGISTER;
  lmr_dll_rst <= lmr(ROW_ADDRESS - 1 downto 9) & '1' & lmr(7 downto 0);
  lmr_dll_set <= lmr(ROW_ADDRESS - 1 downto 9) & '0' & lmr(7 downto 0);


-- Input : COMMAND REGISTER FORMAT
-- 000 - NOP
-- 010 - Initialize memory
-- 100 - Write Request
-- 110 - Read request


-- Input : Address format
-- row address = address((ROW_ADDRESS + COLUMN_ADDRESS) -1 downto COLUMN_ADDRESS)
-- column address = address(COLUMN_ADDRESS-1 downto 0)

  ddr_csb_cntrl     <= '0';
  ddr_cke_cntrl     <= not wait_200us;
  init              <= init_done;
  ddr_rasb_cntrl    <= ddr_rasb2;
  ddr_casb_cntrl    <= ddr_casb2;
  ddr_web_cntrl     <= ddr_web2;
  rst_dqs_div_int   <= rst_dqs_div_int1;
  ddr_address_cntrl <= ddr_address1;
  ddr_ba_cntrl      <= ddr_ba1;

  -- turn off auto-precharge when issuing read/write commands (A10 = 0)
  -- mapping the column address for linear addressing.
  gen_ddr_addr_col_0: if (COL_WIDTH = ROW_WIDTH-1) generate
    column_address1 <= (address_reg(COL_WIDTH-1 downto 10) & '0' &
                        address_reg(9 downto 0));
  end generate;

  gen_ddr_addr_col_1: if ((COL_WIDTH > 10) and
                          not(COL_WIDTH = ROW_WIDTH-1)) generate
    column_address1(ROW_WIDTH-1 downto COL_WIDTH+1) <= (others => '0');
    column_address1(COL_WIDTH downto 0) <=
      (address_reg(COL_WIDTH-1 downto 10) & '0' & address_reg(9 downto 0));
  end generate;

  gen_ddr_addr_col_2: if (not((COL_WIDTH > 10) or
                              (COL_WIDTH = ROW_WIDTH-1))) generate
    column_address1(ROW_WIDTH-1 downto COL_WIDTH+1) <= (others => '0');
    column_address1(COL_WIDTH downto 0) <=
      ('0' & address_reg(COL_WIDTH-1 downto 0));
  end generate;


  process(clk)
  begin
    if clk'event and clk = '0' then
      rst180_r <= rst180;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      rst0_r <= rst0;
    end if;
  end process;

--******************************************************************************
-- Register user address
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      row_address_reg    <= address_reg(((ROW_ADDRESS + COLUMN_ADDRESS)-1) downto
                                        COLUMN_ADDRESS);
      column_address_reg <= column_address1;
      ba_address_reg1    <= bank_addr;
      ba_address_reg2    <= ba_address_reg1;
      address_reg        <= address;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        burst_length <= "000";
      else
        burst_length <= lmr(2 downto 0);
      end if;
    end if;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '0') then
      if rst180_r = '1' then
        accept_cmd_in <= '0';
      elsif (current_state = IDLE and ((rpcnt0 and rfc_count_reg and
                                        not(auto_ref_wait) and
                                        not(auto_ref_issued)) = '1')) then
        accept_cmd_in <= '1';
      else
        accept_cmd_in <= '0';
      end if;
    end if;
  end process;
--******************************************************************************
-- Commands from user.
--******************************************************************************
  initialize_memory <= '1' when (command_register = "010") else '0';
  write_cmd_in      <= '1' when (command_register = "100" and
                                 accept_cmd_in = '1') else '0';
  read_cmd          <= '1' when (command_register = "110" and
                                 accept_cmd_in = '1') else '0';

--******************************************************************************
-- write_cmd1 is asserted when user issued write command and the controller s/m
-- is in idle state and AUTO_REF is not asserted.
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        write_cmd1   <= '0';
        write_cmd2   <= '0';
        write_cmd3   <= '0';
      else
        if (accept_cmd_in = '1') then
          write_cmd1 <= write_cmd_in;
        end if;
        write_cmd2   <= write_cmd1;
        write_cmd3   <= write_cmd2;
      end if;
    end if;
  end process;

--******************************************************************************
-- read_cmd1 is asserted when user issued read command and the controller s/m
-- is in idle state and AUTO_REF is not asserted.
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        read_cmd1   <= '0';
        read_cmd2   <= '0';
        read_cmd3   <= '0';
      else
        if (accept_cmd_in = '1') then
          read_cmd1 <= read_cmd;
        end if;
        read_cmd2   <= read_cmd1;
        read_cmd3   <= read_cmd2;
      end if;
    end if;
  end process;

--******************************************************************************
-- rfc_count
-- An executable command can be issued only after Trfc period after a AUTOREFRESH
-- command is issued. rfc_count_value is set in the parameter file depending on
-- the memory device speed grade and the selected frequency.For example for 5B
-- speed grade, at 133Mhz, rfc_counter_value = 8'b00001001.
-- ( Trfc/clk_period= 75/7.5= 10)
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rfc_count <= "00000000";
      elsif(current_state = AUTO_REFRESH) then
        rfc_count <= RFC_COUNT_VALUE;
      elsif(rfc_count /= "00000000") then
        rfc_count <= rfc_count - '1';
      end if;
    end if;
  end process;

--******************************************************************************
-- rp_count
-- An executable command can be issued only after Trp period after a PRECHARGE
-- command is issued. rp_count value is fixed to support all memory speed grades.
--******************************************************************************
  rp_cnt_value <= "100" when (next_state = PRECHARGE) else
                  (rp_count - "001") when (rpcnt0 /= '1') else
                  "000";
  
--******************************************************************************
-- ACTIVE to READ/WRITE counter
--
-- rcdr_count
-- ACTIVE to READ delay - Minimum interval between ACTIVE and READ command.
-- rcdr_count value is fixed to support all memory speed grades.
--
-- rcdw_count
-- ACTIVE to WRITE delay - Minimum interval between ACTIVE and WRITE command.
-- rcdw_count value is fixed to support all memory speed grades.
--
--******************************************************************************

  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        rcdr_count <= "000";
      elsif (current_state = ACTIVE) then
        rcdr_count <= "001";
      elsif (rcdr_count /= "000") then
        rcdr_count <= rcdr_count - '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        rcdw_count <= "000";
      elsif (current_state = ACTIVE) then
        rcdw_count <= "001";
      elsif (rcdw_count /= "000") then
        rcdw_count <= rcdw_count - '1';
      end if;
    end if;
  end process;

--******************************************************************************
-- WR Counter
-- a PRECHARGE command can be applied only after 2 cycles after a WRITE command
-- has finished executing
--******************************************************************************
  
  process (clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        wr_count   <= "000";
      else
        if (dqs_enable_int = '1') then
          wr_count <= TWR_COUNT_VALUE;
        elsif (wr_count /= "000") then
          wr_count <= wr_count - "001";
        end if;
      end if;
    end if;
  end process;

--******************************************************************************
-- autoref_count - This counter is used to issue AUTO REFRESH command to
-- the memory for every 7.8125us.
-- (Auto Refresh Request is raised for every 7.7 us to allow for termination
-- of any ongoing bus transfer).For example at 200MHz frequency
-- autoref_count = refresh_time_period/clock_period = 7.7us/5ns = 1540
--******************************************************************************
  
  ref_freq_cnt <= MAX_REF_CNT;
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        autoref_value <= '0';
      elsif (autoref_count = ref_freq_cnt) then
        autoref_value <= '1';
      else
        autoref_value <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        autoref_count <= (others => '0');
      elsif (autoref_value = '1') then
        autoref_count <= (others => '0');
      else
        autoref_count <= autoref_count + '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_detect1 <= '0';
        auto_ref1        <= '0';
      else
        auto_ref_detect1 <= autoref_value and init_done;
        auto_ref1        <= auto_ref_detect1;
      end if;
    end if;
  end process;

  ar_done_p <= '1' when ar_done_reg = '1' else '0';

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_wait   <= '0';
        ar_done         <= '0';
        auto_ref_issued <= '0';
      else
        if (auto_ref1 = '1' and auto_ref_wait = '0') then
          auto_ref_wait <= '1';
        elsif (auto_ref_issued = '1') then
          auto_ref_wait <= '0';
        else
          auto_ref_wait <= auto_ref_wait;
        end if;
        ar_done         <= ar_done_p;
        auto_ref_issued <= auto_ref_issued_p;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_wait1   <= '0';
        auto_ref_wait2   <= '0';
        auto_ref         <= '0';
      else
        if (auto_ref_issued_p = '1') then
          auto_ref_wait1 <= '0';
          auto_ref_wait2 <= '0';
          auto_ref       <= '0';
        else
          auto_ref_wait1 <= auto_ref_wait;
          auto_ref_wait2 <= auto_ref_wait1;
          auto_ref       <= auto_ref_wait2;
        end if;
      end if;
    end if;
  end process;

  auto_ref_req      <= auto_ref_wait;
  auto_ref_issued_p <= '1' when (current_state = AUTO_REFRESH) else '0';

--******************************************************************************
-- Common counter for the Initialization sequence
--******************************************************************************
  
  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        count6 <= "000000";
      elsif(init_current_state = INIT_AUTO_REFRESH or init_current_state
            = INIT_PRECHARGE or init_current_state = INIT_LOAD_MODE_REG) then
        count6 <= cntnext;
      elsif(count6 /= "000000") then
        count6 <= count6 - '1';
      else
        count6 <= "000000";
      end if;
    end if;
  end process;

--******************************************************************************
-- While doing consecutive READs or WRITEs, the burst_cnt_max value determines
-- when the next READ or WRITE command should be issued. burst_cnt_max shows the
-- number of clock cycles for each burst. 
-- e.g burst_cnt_max = 2 for a burst length of 4
--                   = 4 for a burst length of 8
--******************************************************************************

  burst_cnt_max <= "010" when burst_length = "010" else
                   "100" when burst_length = "011" else
                   "000";

  
  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        cas_count <= "000";
      elsif(current_state = BURST_READ) then
        cas_count <= burst_cnt_max - '1';
      elsif(cas_count /= "000") then
        cas_count <= cas_count - '1';
      end if;
    end if;
  end process;


  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        wrburst_end_cnt <= "000";
      elsif ((current_state = FIRST_WRITE) or (current_state = BURST_WRITE)) then
        wrburst_end_cnt <= burst_cnt_max;
      elsif (wrburst_end_cnt /= "000") then
        wrburst_end_cnt <= wrburst_end_cnt - '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rdburst_end_1   <= '0';
      else
        if(burst_done = '1') then
          rdburst_end_1 <= '1';
        else
          rdburst_end_1 <= '0';
        end if;
        rdburst_end_2   <= rdburst_end_1;
      end if;
    end if;
  end process;

  rdburst_end <= rdburst_end_1 or rdburst_end_2;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        wrburst_end_1   <= '0';
      else
        if (burst_done = '1') then
          wrburst_end_1 <= '1';
        else
          wrburst_end_1 <= '0';
        end if;
        wrburst_end_2   <= wrburst_end_1;
        wrburst_end_3   <= wrburst_end_2;
      end if;
    end if;
  end process;

  wrburst_end <= wrburst_end_1 or wrburst_end_2 or wrburst_end_3;

--******************************************************************************
-- dqs_enable and dqs_reset signals are used to generate DQS signal during write
-- data.
--******************************************************************************
  dqs_enable_out <= '1' when ((current_state = FIRST_WRITE) or
                              (current_state = BURST_WRITE) or
                              (WRburst_end_cnt /= "000")) else '0';
  dqs_reset_out  <= '1' when current_state = FIRST_WRITE  else '0';
  dqs_enable     <= dqs_enable_i;
  
    dqs_enable_i   <= dqs_enable2;
  dqs_reset      <= dqs_reset2_clk0;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        dqs_enable_int <= '0';
        dqs_reset_int  <= '0';
      else
        dqs_enable_int <= dqs_enable_out;
        dqs_reset_int  <= dqs_reset_out;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if rst0_r = '1' then
        dqs_enable1     <= '0';
        dqs_enable2     <= '0';
        dqs_enable3     <= '0';
        dqs_reset1_clk0 <= '0';
        dqs_reset2_clk0 <= '0';
        dqs_reset3_clk0 <= '0';
      else
        dqs_enable1     <= dqs_enable_int;
        dqs_enable2     <= dqs_enable1;
        dqs_enable3     <= dqs_enable2;
        dqs_reset1_clk0 <= dqs_reset_int;
        dqs_reset2_clk0 <= dqs_reset1_clk0;
        dqs_reset3_clk0 <= dqs_reset2_clk0;
      end if;
    end if;
  end process;

--******************************************************************************
--Write Enable signal to the datapath
--******************************************************************************

  write_enable_out <= '1' when (wrburst_end_cnt /= "000")else '0';
  cmd_ack          <= ack_reg;
  ack_o            <= '1' when ((write_cmd_in = '1') or (write_cmd1 = '1') or
                                (read_cmd = '1') or (read_cmd1 = '1')) else '0';
  

  process(clk)
  begin
   if clk'event and clk = '0' then
    if rst180_r = '1' then
     write_enable <= '0';
    else
     write_enable <= write_enable_out;
    end if;
   end if;
  end process;


  ACK_REG_INST1 : FD
    port map (
      Q => ack_reg,
      D => ack_o,
      C => clk180
      );

--******************************************************************************
-- init_done will be asserted when initialization sequence is complete
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_memory  <= '0';
        init_done    <= '0';
        init_done_r1 <= '0';
      else
        init_memory  <= init_mem;
        init_done_r1 <= init_done;
        if ((init_done_value = '1')and (init_count = "1011")) then
          init_done  <= '1';
        else
          init_done  <= '0';
        end if;
      end if;
    end if;
  end process;

  init_done_dis <= '1' when ( init_done = '1' and init_done_r1 = '0') else
                   '0';
  
  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '0' then
        --synthesis translate_off
        assert (init_done_dis = '0') report "INITIALIZATION_DONE" severity note;
        --synthesis translate_on
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '0' then
      if initialize_memory = '1' or rst180_r = '1' then
        init_pre_count <= "1010000";
      else
        init_pre_count <= init_pre_count - "0000001";
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_mem <= '0';
      elsif (initialize_memory = '1') then
        init_mem <= '1';
      elsif ((init_count = "1011") and (count6 = "000001")) then
        init_mem <= '0';
      else
        init_mem <= init_mem;
      end if;
    end if;
  end process;

-- Counter for Memory Initialization sequence


 process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        init_count <= "0000";
      elsif(((init_current_state = INIT_PRECHARGE) or 
		(init_current_state = INIT_LOAD_MODE_REG) or
		(init_current_state = INIT_AUTO_REFRESH)) and init_memory = '1') then
        init_count <= init_count + '1';
      else
        init_count <= init_count;
      end if;
    end if;
  end process;

  
  init_done_value     <= '1' when ((init_count = "1011") and
                               (dll_rst_count = "00000001")) else '0';

-- Counter to count 200 clock cycles When DLL reset is issued during initialization.
  

 process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dll_rst_count <= "00000000";
      elsif(init_count = "0011") then
        dll_rst_count <= "11001000";
      elsif(dll_rst_count /= "00000001") then
        dll_rst_count <= dll_rst_count - '1';
      else
        dll_rst_count <= dll_rst_count;
      end if;
    end if;
  end process;


  go_to_active_value  <= '1' when ((write_cmd_in = '1') and (accept_cmd_in = '1'))
                         or ((read_cmd = '1') and (accept_cmd_in = '1'))
                         else '0';

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        go_to_active <= '0';
      else
        go_to_active <= go_to_active_value;
      end if;
    end if;
  end process;

--******************************************************************************
-- Register counter values
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rp_count      <= "000";
        ar_done_reg   <= '0';
        rfc_count_reg <= '0';
        rpcnt0        <= '1';
      else
        if(rp_count(2) = '0' and rp_count(1) = '0' and rp_cnt_value(2) = '0') then
          rpcnt0 <= '1';
        else
          rpcnt0 <= '0';
        end if;
        rp_count      <= rp_cnt_value;
        if(rfc_count = "00000010") then   --2
          ar_done_reg <= '1';
        else
          ar_done_reg <= '0';
        end if;
        if(ar_done_reg = '1') then
          rfc_count_reg <= '1';
        elsif (init_done = '1' and init_mem = '0' and rfc_count = "00000000")
        then
          rfc_count_reg <= '1';
        elsif (auto_ref_issued = '1') then
          rfc_count_reg <= '0';
        else
          rfc_count_reg <= rfc_count_reg;
        end if;
      end if;
    end if;
  end process;

--******************************************************************************
-- Initialization state machine
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_current_state <= INIT_IDLE;
      else
        init_current_state <= init_next_state;
      end if;
    end if;
  end process;

  process (rst180_r, init_count, init_current_state, init_memory, count6,
           init_pre_count)
  begin
    if rst180_r = '1' then
      init_next_state             <= INIT_IDLE;
    else
      case init_current_state is
        when INIT_IDLE    =>
          if init_memory = '1' then
            case init_count is
              when "0000" =>
                if(init_pre_count = "0000001") then
                  init_next_state <= INIT_PRECHARGE;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0001" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0010" =>
                -- for reseting DLL in Base Mode register
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0011" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;  -- For EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0100" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;  -- For EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0101" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_PRECHARGE;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0110" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_AUTO_REFRESH;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0111" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_AUTO_REFRESH;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1000" =>
                -- to deactivate the rst DLL bit in the LMR
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1001" =>
                -- to set OCD to default in EMR
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1010" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_LOAD_MODE_REG;  --  OCD exit in EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1011" =>
                if (count6 = "000001") then
                  init_next_state <= INIT_IDLE;
                else
                  init_next_state <= init_current_state;
                end if;
              when others =>
                init_next_state   <= INIT_IDLE;
            end case;
          else
            init_next_state <= INIT_IDLE;
          end if;
        when INIT_PRECHARGE =>
          init_next_state <= INIT_IDLE;
        when INIT_LOAD_MODE_REG =>
          init_next_state <= INIT_IDLE;
        when INIT_AUTO_REFRESH =>
          init_next_state <= INIT_IDLE;
        when others =>
          init_next_state <= INIT_IDLE;
      end case;
    end if;
  end process;

--******************************************************************************
-- MAIN state machine
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        current_state <= IDLE;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  process (rst180_r, cas_count, wr_count,
           go_to_active, write_cmd1, read_cmd3, current_state,
           wrburst_end, wrburst_end_cnt,
           rdburst_end, init_memory, rcdw_count, rcdr_count, 
           auto_ref, rfc_count_reg, rpcnt0)
  begin
    if rst180_r = '1' then
      next_state         <= IDLE;
    else
      case current_state is
        
        when IDLE =>
          if (init_memory = '0') then
            if(auto_ref = '1' and rfc_count_reg = '1' and rpcnt0 = '1') then
              next_state <= AUTO_REFRESH;  -- normal Refresh in the IDLE state
            elsif go_to_active = '1' then
              next_state <= ACTIVE;
            else
              next_state <= IDLE;
            end if;
          else
            next_state   <= IDLE;
          end if;
          
        when PRECHARGE =>
          next_state <= IDLE;
          
        when AUTO_REFRESH =>
          next_state <= IDLE;
          
        when ACTIVE =>
          next_state <= ACTIVE_WAIT;
          
        when ACTIVE_WAIT =>
          if (rcdw_count = "000" and write_cmd1 = '1') then
            next_state <= FIRST_WRITE;
          elsif (rcdr_count = "000" and read_cmd3 = '1') then
            next_state <= BURST_READ;
          else
            next_state <= ACTIVE_WAIT;
          end if;
          
        when FIRST_WRITE =>
          next_state <= WRITE_WAIT;
          
        when WRITE_WAIT =>
          case wrburst_end is
            when '1' =>
              next_state <= PRECHARGE_AFTER_WRITE;
            when '0' =>
              if wrburst_end_cnt = "010" then
                next_state <= BURST_WRITE;
              else
                next_state <= WRITE_WAIT;
              end if;
            when others =>
              next_state   <= WRITE_WAIT;
          end case;
          
        when BURST_WRITE =>
          next_state <= WRITE_WAIT;
          
        when PRECHARGE_AFTER_WRITE =>
          next_state <= PRECHARGE_AFTER_WRITE_2;
          
        when PRECHARGE_AFTER_WRITE_2 =>
          if(wr_count = "00") then
            next_state <= PRECHARGE;
          else
            next_state <= PRECHARGE_AFTER_WRITE_2;
          end if;
          
        when READ_WAIT  =>
          case rdburst_end is
            when '1'    =>
              next_state   <= PRECHARGE_AFTER_WRITE;
            when '0'    =>
              if cas_count = "001" then
                next_state <= BURST_READ;
              else
                next_state <= READ_WAIT;
              end if;
            when others =>
              next_state   <= READ_WAIT;
          end case;

        when BURST_READ =>
          next_state <= READ_WAIT;

        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_address1 <= (others => '0');
      elsif (init_mem = '1') then
        case (init_count) is
          when "0000" | "0101" =>
            ddr_address1 <= addr_const1((ROW_ADDRESS - 1) downto 0);
          when "0001"               =>
            ddr_address1 <= (others => '0');
          when "0010"               =>
            ddr_address1 <= (others => '0');
          when "0011"               =>
            ddr_address1 <= emr;
          when "0100"               =>
            ddr_address1 <= lmr_dll_rst;
          when "1000"               =>
            ddr_address1 <= lmr_dll_set;
          when "1001"               =>
            ddr_address1 <= emr or addr_const2((ROW_ADDRESS - 1) downto 0);
          when "1010"               =>
            ddr_address1 <= emr and addr_const3((ROW_ADDRESS - 1) downto 0);
          when others               =>
            ddr_address1 <= (others => '0');
        end case;
      elsif (current_state = PRECHARGE) then
        ddr_address1 <= addr_const1((ROW_ADDRESS - 1) downto 0);
      elsif (current_state = ACTIVE) then
        ddr_address1 <= row_address_reg;
      elsif (current_state = BURST_WRITE or current_state = FIRST_WRITE or
             current_state = BURST_READ) then
        ddr_address1 <= column_address_reg((ROW_ADDRESS - 1) downto 0);
      else
        ddr_address1 <= (others => '0');
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_ba1     <= (others => '0');
      elsif (init_mem = '1') then
        case (init_count) is
          when "0001" =>
            ddr_ba1 <= ba_const1((BANK_ADDRESS -1) downto 0);
          when "0010" =>
            ddr_ba1 <= ba_const2((BANK_ADDRESS -1) downto 0);
          when "0011" | "1001" | "1010" =>
            ddr_ba1 <= ba_const3((BANK_ADDRESS -1) downto 0);
          when others =>
            ddr_ba1 <= (others => '0');
        end case;
      elsif (current_state = ACTIVE or current_state = FIRST_WRITE or
             current_state = BURST_WRITE or current_state = BURST_READ) then
        ddr_ba1     <= ba_address_reg2;
      else
        ddr_ba1     <= (others => '0');
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        odt_deassert <= '0';
      elsif(wrburst_end_3 = '1') then
        odt_deassert <= '1';
      elsif(write_cmd3 = '0') then
        odt_deassert <= '0';
      else
        odt_deassert <= odt_deassert;
      end if;
    end if;
  end process;

  ddr_odt1 <= '1' when (write_cmd3 = '1' and (emr(6) = '1' or emr(2) = '1') and
                        odt_deassert = '0') else '0';

--******************************************************************************
-- Register CONTROL SIGNALS outputs
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_odt2  <= '0';
        ddr_rasb2 <= '1';
        ddr_casb2 <= '1';
        ddr_web2  <= '1';
      else
        ddr_odt2  <= ddr_odt1;
        ddr_rasb2 <= ddr_rasb1;
        ddr_casb2 <= ddr_casb1;
        ddr_web2  <= ddr_web1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_odt_cntrl <= '0';
      else
        ddr_odt_cntrl <= ddr_odt2;
      end if;
    end if;
  end process;

--******************************************************************************
-- control signals to the Memory
--******************************************************************************

  ddr_rasb1 <= '0' when (current_state = ACTIVE or current_state = PRECHARGE or
                         current_state = AUTO_REFRESH or
                         init_current_state = INIT_PRECHARGE or
                         init_current_state = INIT_AUTO_REFRESH or
                         init_current_state = INIT_LOAD_MODE_REG) else '1';

  ddr_casb1 <= '0' when (current_state = BURST_READ or
                         current_state = BURST_WRITE or
                         current_state = FIRST_WRITE or
                         current_state = AUTO_REFRESH or
                         init_current_state = INIT_AUTO_REFRESH or
                         init_current_state = INIT_LOAD_MODE_REG) else '1';

  ddr_web1 <= '0' when (current_state = BURST_WRITE or
                        current_state = FIRST_WRITE or
                        current_state = PRECHARGE or
                        init_current_state = INIT_PRECHARGE or
                        init_current_state = INIT_LOAD_MODE_REG) else '1';

-------------------------------------------------------------------------------

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dqs_div_cascount     <= "000";
      else
        if(ddr_rasb2 = '1' and ddr_casb2 = '0' and ddr_web2 = '1') then
          dqs_div_cascount   <= burst_cnt_max;
        else
          if dqs_div_cascount /= "000" then
            dqs_div_cascount <= dqs_div_cascount - "001";
          else
            dqs_div_cascount <= dqs_div_cascount;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dqs_div_rdburstcount     <= "000";
      else
        if (dqs_div_cascount = "001" and burst_length = "010") then
          dqs_div_rdburstcount   <= "010";
        elsif (dqs_div_cascount = "011" and burst_length = "011") then
          dqs_div_rdburstcount   <= "100";
        else
          if dqs_div_rdburstcount /= "000" then
            dqs_div_rdburstcount <= dqs_div_rdburstcount - "001";
          else
            dqs_div_rdburstcount <= dqs_div_rdburstcount;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        rst_dqs_div_r     <= '0';
      else
        if (dqs_div_cascount = "001" and burst_length = "010")then
          rst_dqs_div_r   <= '1';
        elsif (dqs_div_cascount = "011" and burst_length = "011")then
          rst_dqs_div_r   <= '1';
        else
          if (dqs_div_rdburstcount = "001" and dqs_div_cascount = "000") then
            rst_dqs_div_r <= '0';
          else
            rst_dqs_div_r <= rst_dqs_div_r;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)                          -- For Reg dimm
  begin
    if(clk'event and clk = '0') then
      rst_dqs_div_r1 <= rst_dqs_div_r;
    end if;
  end process;

  process (clk)
  begin
    if (clk'event and clk = '0') then
      if (dqs_div_cascount /= "000" or dqs_div_rdburstcount /= "000") then
        rst_calib <= '1';
      else
        rst_calib <= '0';
      end if;
    end if;
  end process;

  rst_iob_out : FD
    port map (
      Q => rst_dqs_div_int1,
            D => rst_dqs_div_r, 
      C => clk
      );

end arc;

--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_s3_dm_iob is
  port (
    ddr_dm       : out std_logic;   --Data mask output
    mask_falling : in std_logic;    --Mask output on falling edge
    mask_rising  : in std_logic;    --Mask output on rising edge
    clk90        : in std_logic
    );
end xddr2mig_s3_dm_iob;

architecture arc of xddr2mig_s3_dm_iob is

--***********************************************************************\
-- Internal signal declaration
--***********************************************************************/

  signal mask_o : std_logic;
  signal gnd    : std_logic;
  signal vcc    : std_logic;
  signal clk270 : std_logic;
begin

  gnd    <= '0';
  vcc    <= '1';
  clk270 <= not clk90;

-- Data Mask Output during a write command

  DDR_DM0_OUT : FDDRRSE
    port map (
      Q  => mask_o,
      C0 => clk270,
      C1 => clk90,
      CE => vcc,
      D0 => mask_rising,
      D1 => mask_falling,
      R  => gnd,
      S  => gnd
      );

  DM1_OBUF : OBUF
    port map (
      I => mask_o,
      O => ddr_dm
      );
  
end arc;


--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_s3_dq_iob is
  port (
    ddr_dq_inout       : inout std_logic;  --Bi-directional SDRAM data bus
    write_data_falling : in    std_logic;  --Transmit data, output on falling edge
    write_data_rising  : in    std_logic;  --Transmit data, output on rising edge
    read_data_in       : out   std_logic;  -- Received data
    clk90              : in    std_logic;  --Clock 90
    write_en_val       : in    std_logic
    );
end xddr2mig_s3_dq_iob;

architecture arc of xddr2mig_s3_dq_iob is

--***********************************************************************\
-- Internal signal declaration
--***********************************************************************/
  signal ddr_en   : std_logic;          -- Tri-state enable signal
  signal ddr_dq_q : std_logic;          -- Data output intermediate signal
  signal gnd      : std_logic;
  signal clock_en : std_logic;
  signal enable_b : std_logic;
  signal clk270   : std_logic;

  attribute iob         : string;

  attribute iob of DQ_T         : label is "true";

begin
  
  clk270   <= not clk90;
  gnd      <= '0';
  enable_b <= not write_en_val;
  clock_en <= '1';

-- Transmission data path

  DDR_OUT : FDDRRSE
    port map (
      Q  => ddr_dq_q,
      C0 => clk270,
      C1 => clk90,
      CE => clock_en,
      D0 => write_data_rising,
      D1 => write_data_falling,
      R  => gnd,
      S  => gnd
      );

  DQ_T : FD
    port map (
      D => enable_b,
      C => clk270,
      Q => ddr_en
      );

  DQ_OBUFT : OBUFT
    port map (
      I => ddr_dq_q,
      T => ddr_en,
      O => ddr_dq_inout
      );

-- Receive data path

  DQ_IBUF : IBUF
    port map(
      I => ddr_dq_inout,
      O => read_data_in
      );

end arc;

--><-----------------------------------------------------------------------><--


library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_s3_dqs_iob is
  port(
    clk            : in    std_logic;
    ddr_dqs_reset  : in    std_logic;
    ddr_dqs_enable : in    std_logic;
    ddr_dqs        : inout std_logic;
    ddr_dqs_n          : inout std_logic;
    dqs            : out   std_logic);
end xddr2mig_s3_dqs_iob;

architecture arc of xddr2mig_s3_dqs_iob is


  signal dqs_q            : std_logic;
  signal ddr_dqs_enable1  : std_logic;
  signal vcc              : std_logic;
  signal gnd              : std_logic;
  signal ddr_dqs_enable_b : std_logic;
  signal data1            : std_logic;
  signal clk180           : std_logic;

  attribute IOB               : string;
  
  attribute IOB of U1         : label is "true";

begin

--******************************************************************************
-- Output DDR generation. This includes instantiation of the output DDR flip flop.
-- Additionally, to keep synthesis tools from register sharing, manually
-- instantiate the output tri-state flip-flop.
--******************************************************************************
  vcc              <= '1';
  gnd              <= '0';
  clk180           <= not clk;
  ddr_dqs_enable_b <= not ddr_dqs_enable;
  data1            <= '0' when ddr_dqs_reset = '1' else
                      '1';

  U1 : FD
    port map (
      D => ddr_dqs_enable_b,
      Q => ddr_dqs_enable1,
      C => clk
      );


  U2 : FDDRRSE
    port map (
      Q    => dqs_q,
      C0 => clk,
      C1 => clk180,
      CE => vcc,
      D0 => data1,
      D1 => gnd,
      R  => gnd,
      S  => gnd
      );



--***********************************************************************
-- IO buffer for dqs signal. Allows for distribution of dqs
-- to the data (DQ) loads.
--***********************************************************************


    U3 : OBUFTDS port map (
            I  => dqs_q,
            T  => ddr_dqs_enable1,
            O  => ddr_dqs,
            OB => ddr_dqs_n
            );

     U4 : IBUFDS  port map(
                   I  => ddr_dqs,
                   IB => ddr_dqs_n,
                   O  => dqs
                   );



end arc;


--><-----------------------------------------------------------------------><--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_data_path_iobs_0 is
  port(
    clk                : in    std_logic;
    clk90              : in    std_logic;
    dqs_reset          : in    std_logic;
    dqs_enable         : in    std_logic;
    ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);
    ddr_dqs_n          : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dq             : inout std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_falling : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_en_val       : in    std_logic;
    data_mask_f        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    dqs_int_delay_in   : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dm             : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    ddr_dq_val         : out   std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end xddr2mig_data_path_iobs_0;

architecture arc of xddr2mig_data_path_iobs_0 is

  signal ddr_dq_in  : std_logic_vector((DATA_WIDTH-1) downto 0);

begin

  ddr_dq_val <= ddr_dq_in;


gen_dm: for dm_i in 0 to DATA_MASK_WIDTH-1 generate
    s3_dm_iob_inst : entity xddr2mig_s3_dm_iob
      port map (
        ddr_dm       => ddr_dm(dm_i),
        mask_falling => data_mask_f(dm_i),
        mask_rising  => data_mask_r(dm_i),
        clk90        => clk90
        );
  end generate;

--***********************************************************************
--    Read Data Capture Module Instantiations
--***********************************************************************
-- DQS IOB instantiations
--***********************************************************************
  
  gen_dqs: for dqs_i in 0 to DATA_STROBE_WIDTH-1 generate
    s3_dqs_iob_inst : entity xddr2mig_s3_dqs_iob 
      port map (
        clk             => clk,
        ddr_dqs_reset   => dqs_reset,
        ddr_dqs_enable  => dqs_enable,
        ddr_dqs         => ddr_dqs(dqs_i),
        ddr_dqs_n       => ddr_dqs_n(dqs_i),
        dqs             => dqs_int_delay_in(dqs_i)
        );
  end generate;



--******************************************************************************
-- DDR Data bit instantiations
--******************************************************************************

  gen_dq: for dq_i in 0 to DATA_WIDTH-1 generate
    s3_dq_iob_inst : entity xddr2mig_s3_dq_iob
      port map (
        ddr_dq_inout       => ddr_dq(dq_i),
        write_data_falling => write_data_falling(dq_i),
        write_data_rising  => write_data_rising(dq_i),
        read_data_in       => ddr_dq_in(dq_i),
        clk90              => clk90,
        write_en_val       => write_en_val
        );
  end generate;

end arc;

--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_dqs_delay is
  port (
    clk_in  : in  std_logic;
    sel_in  : in  std_logic_vector(4 downto 0);
    clk_out : out std_logic
    );
end xddr2mig_dqs_delay;

architecture arc_dqs_delay of xddr2mig_dqs_delay is

  signal delay1 : std_logic;
  signal delay2 : std_logic;
  signal delay3 : std_logic;
  signal delay4 : std_logic;
  signal delay5 : std_logic;
  signal high   : std_logic;

  attribute syn_noprune : boolean;
  attribute syn_noprune of one   : label is true;
  attribute syn_noprune of two   : label is true;
  attribute syn_noprune of three : label is true;
  attribute syn_noprune of four  : label is true;
  attribute syn_noprune of five  : label is true;
  attribute syn_noprune of six   : label is true;

begin

  high <= '1';

  one : LUT4 generic map (INIT => x"f3c0")
    port map (
      I0  => high,
      I1 => sel_in(4),
      I2 => delay5,
      I3 => clk_in,
      O  => clk_out
      );
  
  two : LUT4 generic map (INIT => x"ee22")
    port map (
      I0 => clk_in,
      I1 => sel_in(2),
      I2 => high,
      I3 => delay3,
      O  => delay4
      );

  three : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => clk_in,
      I1 => sel_in(0),
      I2 => delay1,
      I3 => high,
      O  => delay2
      );

  four : LUT4 generic map (INIT => x"ff00")
    port map (
      I0 => high,
      I1 => high,
      I2 => high,
      I3 => clk_in,
      O  => delay1
      );

  five : LUT4 generic map (INIT => x"f3c0")
    port map (
      I0 => high,
      I1 => sel_in(3),
      I2 => delay4,
      I3 => clk_in,
      O  => delay5
      );

  six : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => clk_in,
      I1 => sel_in(1),
      I2 => delay2,
      I3 => high,
      O  => delay3
      );

end arc_dqs_delay;

--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_fifo_0_wr_en_0 is
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    din             : in  std_logic;
    rst_dqs_delay_n : out std_logic;
    dout            : out std_logic
    );

end xddr2mig_fifo_0_wr_en_0;

architecture arc of xddr2mig_fifo_0_wr_en_0 is

  signal din_delay : std_ulogic;
  signal tie_high  : std_ulogic;
  
begin

  rst_dqs_delay_n <= not din_delay;
  dout            <= din or din_delay;
  tie_high        <= '1';

  delay_ff : FDCE
    port map (
      Q   => din_delay,
      C   => clk,
      CE  => tie_high,
      CLR => reset,
      D   => din
      );

end arc;

--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_fifo_1_wr_en_0 is
  port (
    clk             : in  std_logic;
    rst_dqs_delay_n : in  std_logic;
    reset           : in  std_logic;
    din             : in  std_logic;
    dout            : out std_logic
    );
end xddr2mig_fifo_1_wr_en_0;

architecture arc of xddr2mig_fifo_1_wr_en_0 is

  signal din_delay     : std_ulogic;
  signal tie_high      : std_ulogic;
  signal dout0         : std_ulogic;
  signal rst_dqs_delay : std_logic;

begin

  rst_dqs_delay <= not rst_dqs_delay_n;
  dout0         <= din and rst_dqs_delay_n;
  dout          <= rst_dqs_delay or din_delay;
  tie_high      <= '1';

  delay_ff_1 : FDCE
    port map (
      Q   => din_delay,
      C   => clk,
      CE  => tie_high,
      CLR => reset,
      D   => dout0
      );

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_rd_gray_cntr is
  port (
    clk90    : in  std_logic;
    reset90  : in  std_logic;
    cnt_en   : in  std_logic;
    rgc_gcnt : out std_logic_vector(3 downto 0)
    );
end xddr2mig_rd_gray_cntr;

architecture arc of xddr2mig_rd_gray_cntr is

  signal gc_int  : std_logic_vector(3 downto 0);
  signal d_in    : std_logic_vector(3 downto 0);
  signal reset90_r : std_logic;

begin

  rgc_gcnt    <= gc_int(3 downto 0);
  
  process(clk90)
  begin
    if(clk90'event and clk90 = '1') then
      reset90_r <= reset90;
    end if;
  end process;

  process(gc_int)
  begin
    case gc_int is
      when "0000" => d_in <= "0001";    --0 > 1
      when "0001" => d_in <= "0011";    --1 > 3
      when "0010" => d_in <= "0110";    --2 > 6
      when "0011" => d_in <= "0010";    --3 > 2
      when "0100" => d_in <= "1100";    --4 > c
      when "0101" => d_in <= "0100";    --5 > 4
      when "0110" => d_in <= "0111";    --6 > 7
      when "0111" => d_in <= "0101";    --7 > 5
      when "1000" => d_in <= "0000";    --8 > 0
      when "1001" => d_in <= "1000";    --9 > 8
      when "1010" => d_in <= "1011";    --10 > b
      when "1011" => d_in <= "1001";    --11 > 9
      when "1100" => d_in <= "1101";    --12 > d
      when "1101" => d_in <= "1111";    --13 > f
      when "1110" => d_in <= "1010";    --14 > a
      when "1111" => d_in <= "1110";    --15 > e
      when others => d_in <= "0001";    --0 > 1
    end case;
  end process;

  bit0 : FDRE
    port map (
      Q  => gc_int(0),
      C  => clk90,
      CE => cnt_en,
      D  => d_in(0),
      R  => reset90_r
      );

  bit1 : FDRE
    port map (
      Q  => gc_int(1),
      C  => clk90,
      CE => cnt_en,
      D  => d_in(1),
      R  => reset90_r
      );

  bit2 : FDRE
    port map (
      Q  => gc_int(2),
      C  => clk90,
      CE => cnt_en,
      D  => d_in(2),
      R  => reset90_r
      );

  bit3 : FDRE
    port map (
      Q  => gc_int(3),
      C  => clk90,
      CE => cnt_en,
      D    => d_in(3),
      R  => reset90_r
      );
  
end arc;

--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use UNISIM.VCOMPONENTS.all;

entity xddr2mig_wr_gray_cntr is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    cnt_en   : in  std_logic;
    wgc_gcnt : out std_logic_vector(3 downto 0)
    );
end xddr2mig_wr_gray_cntr;

architecture arc of xddr2mig_wr_gray_cntr is

  signal d_in   : std_logic_vector(3 downto 0);
  signal gc_int : std_logic_vector(3 downto 0);

begin

  wgc_gcnt <= gc_int(3 downto 0);

  process(gc_int)
  begin
    case gc_int is
      when "0000" => d_in <= "0001";    --0 > 1
      when "0001" => d_in <= "0011";    --1 > 3
      when "0010" => d_in <= "0110";    --2 > 6
      when "0011" => d_in <= "0010";    --3 > 2
      when "0100" => d_in <= "1100";    --4 > c
      when "0101" => d_in <= "0100";    --5 > 4
      when "0110" => d_in <= "0111";    --6 > 7
      when "0111" => d_in <= "0101";    --7 > 5
      when "1000" => d_in <= "0000";    --8 > 0
      when "1001" => d_in <= "1000";    --9 > 8
      when "1010" => d_in <= "1011";    --a > b
      when "1011" => d_in <= "1001";    --b > 9
      when "1100" => d_in <= "1101";    --c > d
      when "1101" => d_in <= "1111";    --d > f
      when "1110" => d_in <= "1010";    --e > a
      when "1111" => d_in <= "1110";    --f > e
      when others => d_in <= "0001";    --0 > 1
    end case;
  end process;

  bit0 : FDCE
    port map (
      Q   => gc_int(0),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(0)
      );

  bit1 : FDCE
    port map (
      Q   => gc_int(1),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(1)
      );
  
  bit2 : FDCE
    port map (
      Q   => gc_int(2),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(2)
      );

  bit3 : FDCE
    port map (
      Q   => gc_int(3),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(3)
      );

end arc;

--><-----------------------------------------------------------------------><--

library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;

entity xddr2mig_ram8d_0 is
  port (
    dout  : out std_logic_vector((DATABITSPERSTROBE -1) downto 0);
    waddr : in  std_logic_vector(3 downto 0);
    din   : in  std_logic_vector((DATABITSPERSTROBE -1) downto 0);
    raddr : in  std_logic_vector(3 downto 0);
    wclk0 : in  std_logic;
    wclk1 : in  std_logic;
    we    : in  std_logic
    );
end xddr2mig_ram8d_0;

architecture arc of xddr2mig_ram8d_0 is

begin

  fifo_bit0 : RAM16X1D
    port map (
	  DPO    => dout(0),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(0),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk1,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit1 : RAM16X1D
    port map (
	  DPO    => dout(1),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(1),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk0,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit2 : RAM16X1D
    port map (
	  DPO    => dout(2),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(2),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk1,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit3 : RAM16X1D
    port map (
	  DPO    => dout(3),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(3),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk0,
      SPO    => OPEN,
      WE     => we 
	  );

fifo_bit4 : RAM16X1D
    port map (
	  DPO    => dout(4),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(4),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk1,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit5 : RAM16X1D
    port map (
	  DPO    => dout(5),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(5),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk0,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit6 : RAM16X1D
    port map (
	  DPO    => dout(6),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(6),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk1,
      SPO    => OPEN,
      WE     => we 
	  );

  fifo_bit7 : RAM16X1D
    port map (
	  DPO    => dout(7),
      A0     => waddr(0),
      A1     => waddr(1),
      A2     => waddr(2),
      A3     => waddr(3),
      D      => din(7),
      DPRA0  => raddr(0),
      DPRA1  => raddr(1),
      DPRA2  => raddr(2),
      DPRA3  => raddr(3),
      WCLK   => wclk0,
      SPO    => OPEN,
      WE     => we 
	  );

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_data_read_controller_0 is
  port(
    clk                   : in  std_logic;
    clk90                 : in  std_logic;
    reset                 : in  std_logic;
    reset90               : in  std_logic;
    rst_dqs_div_in        : in  std_logic;
    delay_sel             : in  std_logic_vector(4 downto 0);
    dqs_int_delay_in      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_en_val      : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_1_wr_en_val      : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_addr_val    : out std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    fifo_1_wr_addr_val    : out std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    dqs_delayed_col0_val  : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    dqs_delayed_col1_val  : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo0_rd_addr         : in  std_logic_vector(3 downto 0);
    fifo1_rd_addr         : in  std_logic_vector(3 downto 0);
    u_data_val            : out std_logic;
    read_valid_data_1_val : out std_logic;
    -- debug signals
    vio_out_dqs           : in  std_logic_vector(4 downto 0);
    vio_out_dqs_en        : in  std_logic;
    vio_out_rst_dqs_div   : in  std_logic_vector(4 downto 0);
    vio_out_rst_dqs_div_en: in  std_logic
    );

end xddr2mig_data_read_controller_0;

architecture arc of xddr2mig_data_read_controller_0 is

  signal dqs_delayed_col0    : std_logic_vector((data_strobe_width-1) downto 0);
  signal dqs_delayed_col1    : std_logic_vector((data_strobe_width-1) downto 0);
  signal fifo_0_wr_addr      : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
  signal fifo_1_wr_addr      : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
  signal fifo_0_empty        : std_logic;
  signal fifo_1_empty        : std_logic;
  signal read_valid_data_0_1 : std_logic;
  signal read_valid_data_r   : std_logic;
  signal read_valid_data_r1  : std_logic;

-- FIFO WRITE ENABLE SIGNALS
  signal fifo_0_wr_en        : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal fifo_1_wr_en        : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  
-- FIFO_WR_POINTER Delayed signals in clk90 domain
  signal fifo_0_wr_addr_d    : std_logic_vector(3 downto 0);
  signal fifo_0_wr_addr_2d   : std_logic_vector(3 downto 0);
  signal fifo_0_wr_addr_3d   : std_logic_vector(3 downto 0);
  signal fifo_1_wr_addr_d    : std_logic_vector(3 downto 0);
  signal fifo_1_wr_addr_2d   : std_logic_vector(3 downto 0);
  signal fifo_1_wr_addr_3d   : std_logic_vector(3 downto 0);

  signal rst_dqs_div         : std_logic;
  signal reset90_r           : std_logic;
  signal reset_r             : std_logic;
  signal rst_dqs_delay_0_n   : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col0_n  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col1_n  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal delay_sel_rst_dqs_div : std_logic_vector(4 downto 0);
  signal delay_sel_dqs         : std_logic_vector(4 downto 0);

  attribute syn_preserve  : boolean;
  attribute syn_noprune   : boolean;
  attribute buffer_type   : string;
  attribute buffer_type  of  dqs_delayed_col0: signal is "none";
  attribute buffer_type  of  dqs_delayed_col1: signal is "none";

begin

  process(clk)
  begin
    if(clk'event and clk = '1') then
      reset_r <= reset;
    end if;
  end process;

  process(clk90)
  begin
    if(clk90'event and clk90 = '1') then
      reset90_r <= reset90;
    end if;
  end process;

  fifo_0_wr_addr_val   <= fifo_0_wr_addr;
  fifo_1_wr_addr_val   <= fifo_1_wr_addr;
  fifo_0_wr_en_val     <= fifo_0_wr_en;
  fifo_1_wr_en_val     <= fifo_1_wr_en;
  dqs_delayed_col0_val <= dqs_delayed_col0 ;
  dqs_delayed_col1_val <= dqs_delayed_col1 ;

  gen_asgn : for asgn_i in 0 to DATA_STROBE_WIDTH-1 generate
    dqs_delayed_col0_n(asgn_i) <= not dqs_delayed_col0(asgn_i);
    dqs_delayed_col1_n(asgn_i) <= not dqs_delayed_col1(asgn_i);
  end generate;
  
-- data_valid signal is derived from fifo_0 and fifo_1 empty signals only
-- FIFO WRITE POINTER DELAYED SIGNALS
-- To avoid meta-stability due to the domain crossing from ddr_dqs to clk90

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      if reset90_r = '1' then
        fifo_0_wr_addr_d <= "0000";
        fifo_1_wr_addr_d <= "0000";
      else
        fifo_0_wr_addr_d <= fifo_0_wr_addr(3 downto 0);
        fifo_1_wr_addr_d <= fifo_1_wr_addr(3 downto 0);
      end if;
    end if;
  end process;

-- FIFO WRITE POINTER DOUBLE DELAYED SIGNALS

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      if reset90_r = '1' then
        fifo_0_wr_addr_2d <= "0000";
        fifo_1_wr_addr_2d <= "0000";
      else
        fifo_0_wr_addr_2d <= fifo_0_wr_addr_d;
        fifo_1_wr_addr_2d <= fifo_1_wr_addr_d;
      end if;
    end if;
  end process;

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      if reset90_r = '1' then
        fifo_0_wr_addr_3d <= "0000";
        fifo_1_wr_addr_3d <= "0000";
      else
        fifo_0_wr_addr_3d <= fifo_0_wr_addr_2d;
        fifo_1_wr_addr_3d <= fifo_1_wr_addr_2d;
      end if;
    end if;
  end process;
  
-- user data valid output signal from data path.

  fifo_0_empty          <= '1' when (fifo0_rd_addr(3 downto 0) =
                                     fifo_0_wr_addr_3d(3 downto 0)) else '0';
  fifo_1_empty          <= '1' when (fifo1_rd_addr(3 downto 0) =
                                     fifo_1_wr_addr_3d(3 downto 0)) else '0';
  read_valid_data_0_1   <= ((not fifo_0_empty) and (not fifo_1_empty));
  read_valid_data_1_val <= (read_valid_data_0_1);

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      if reset90_r = '1' then
        u_data_val         <= '0';
        read_valid_data_r  <= '0';
        read_valid_data_r1 <= '0';
      else
        read_valid_data_r  <= read_valid_data_0_1;
        read_valid_data_r1 <= read_valid_data_r;
        u_data_val         <= read_valid_data_r1;
      end if;
    end if;
  end process;


  debug_rst_dqs_div_ena : if (DEBUG_EN = 1) generate
    delay_sel_rst_dqs_div <= vio_out_rst_dqs_div(4 downto 0) when  (vio_out_rst_dqs_div_en = '1')
				             else delay_sel;  
  end generate; 

  debug_rst_dqs_div_dis : if (DEBUG_EN = 0) generate
    delay_sel_rst_dqs_div <= delay_sel;  
  end generate; 


-- delayed rst_dqs_div logic

  rst_dqs_div_delayed : entity xddr2mig_dqs_delay
    port map (
      clk_in  => rst_dqs_div_in,
      sel_in  => delay_sel_rst_dqs_div,
      clk_out => rst_dqs_div
      );


  debug_ena : if (DEBUG_EN = 1) generate
    delay_sel_dqs <= vio_out_dqs(4 downto 0) when  (vio_out_dqs_en = '1')
				             else delay_sel;  
  end generate; 

  debug_dis : if (DEBUG_EN = 0) generate
    delay_sel_dqs <= delay_sel;  
  end generate; 


--******************************************************************************
-- DQS Internal Delay Circuit implemented in LUTs
--******************************************************************************
    gen_delay: for dly_i in 0 to DATA_STROBE_WIDTH-1 generate
    attribute syn_noprune of dqs_delay_col0: label is true;
    attribute syn_noprune of dqs_delay_col1: label is true;
  begin
 -- Internal Clock Delay circuit placed in the first
   -- column (for falling edge data) adjacent to IOBs
    dqs_delay_col0 : entity xddr2mig_dqs_delay
      port map (
        clk_in  => dqs_int_delay_in(dly_i),
        sel_in  => delay_sel_dqs,
        clk_out => dqs_delayed_col0(dly_i)
       );
  -- Internal Clock Delay circuit placed in the second
  --column (for rising edge data) adjacent to IOBs
    dqs_delay_col1 : entity xddr2mig_dqs_delay
      port map (
        clk_in  => dqs_int_delay_in(dly_i),
        sel_in  => delay_sel_dqs,
        clk_out => dqs_delayed_col1(dly_i)
        );
  end generate;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

gen_wr_en: for wr_en_i in 0 to DATA_STROBE_WIDTH-1 generate
    attribute syn_noprune : boolean;
	attribute syn_noprune of fifo_0_wr_en_inst : label is true;
	attribute syn_noprune of fifo_1_wr_en_inst : label is true;
begin
    fifo_0_wr_en_inst: entity xddr2mig_fifo_0_wr_en_0
      port map (
        clk             => dqs_delayed_col1_n (wr_en_i),
        reset           => reset_r,
        din             => rst_dqs_div,
        rst_dqs_delay_n => rst_dqs_delay_0_n(wr_en_i),
        dout            => fifo_0_wr_en(wr_en_i)
        );
    fifo_1_wr_en_inst: entity xddr2mig_fifo_1_wr_en_0
      port map (
        clk             => dqs_delayed_col0(wr_en_i),
        rst_dqs_delay_n => rst_dqs_delay_0_n(wr_en_i),
        reset           => reset_r,
        din             => rst_dqs_div,
        dout            => fifo_1_wr_en(wr_en_i)
        );
  end generate;

-------------------------------------------------------------------------------
-- write pointer gray counter instances
-------------------------------------------------------------------------------

  gen_wr_addr: for wr_addr_i in 0 to DATA_STROBE_WIDTH-1 generate
    attribute syn_noprune : boolean;
    attribute syn_noprune of fifo_0_wr_addr_inst : label is true;
    attribute syn_noprune of fifo_1_wr_addr_inst : label is true;
  begin
    fifo_0_wr_addr_inst : entity xddr2mig_wr_gray_cntr
      port map (
        clk      => dqs_delayed_col1(wr_addr_i),
        reset    => reset_r,
        cnt_en   => fifo_0_wr_en(wr_addr_i),
        wgc_gcnt => fifo_0_wr_addr((wr_addr_i*4-1)+4 downto wr_addr_i*4)
        );
    fifo_1_wr_addr_inst : entity xddr2mig_wr_gray_cntr
      port map (
        clk      => dqs_delayed_col0_n(wr_addr_i),
        reset    => reset_r,
        cnt_en   => fifo_1_wr_en(wr_addr_i),
        wgc_gcnt => fifo_1_wr_addr((wr_addr_i*4-1)+4 downto wr_addr_i*4)
        );        
  end generate;

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_data_read_0 is
  port(
    clk90             : in  std_logic;
    reset90         : in  std_logic;
    ddr_dq_in         : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    read_valid_data_1 : in  std_logic;
    fifo_0_wr_en      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_1_wr_en      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_addr    : in std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    fifo_1_wr_addr    : in std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    dqs_delayed_col0  : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    dqs_delayed_col1  : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    user_output_data  : out std_logic_vector((2*DATA_WIDTH-1) downto 0);
    fifo0_rd_addr_val : out std_logic_vector(3 downto 0);
    fifo1_rd_addr_val : out std_logic_vector(3 downto 0)
    );
end xddr2mig_data_read_0;

architecture arc of xddr2mig_data_read_0 is

  signal read_valid_data_1_r  : std_logic;
  signal read_valid_data_1_r1 : std_logic;
  signal fifo0_rd_addr        : std_logic_vector(3 downto 0);
  signal fifo1_rd_addr        : std_logic_vector(3 downto 0);

  signal first_sdr_data       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal reset90_r          : std_logic;
  signal fifo0_rd_addr_r      : std_logic_vector((4*DATA_STROBE_WIDTH-1) downto 0);
  signal fifo1_rd_addr_r      : std_logic_vector((4*DATA_STROBE_WIDTH-1) downto 0);
  signal fifo_0_data_out      : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_1_data_out      : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_0_data_out_r    : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_1_data_out_r    : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal dqs_delayed_col0_n   : std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);
  signal dqs_delayed_col1_n   : std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);

  attribute syn_keep : boolean;
  attribute syn_keep of fifo0_rd_addr_r : signal is true;
  attribute syn_keep of fifo1_rd_addr_r : signal is true;

begin

  process(clk90)
  begin
    if(clk90'event and clk90='1') then
      reset90_r <= reset90;
    end if;
  end process;

  gen_asgn : for asgn_i in 0 to DATA_STROBE_WIDTH-1 generate
    dqs_delayed_col0_n(asgn_i) <= not dqs_delayed_col0(asgn_i);
    dqs_delayed_col1_n(asgn_i) <= not dqs_delayed_col1(asgn_i);
  end generate;
  
  user_output_data  <= first_sdr_data;
  fifo0_rd_addr_val <= fifo1_rd_addr;
  fifo1_rd_addr_val <= fifo0_rd_addr;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      fifo_0_data_out_r <= fifo_0_data_out;
      fifo_1_data_out_r <= fifo_1_data_out;
    end if;
  end process;

  gen_addr : for addr_i in 0 to DATA_STROBE_WIDTH-1 generate
    process(clk90)
    begin
      if clk90'event and clk90 = '1' then
        fifo0_rd_addr_r((addr_i*4-1)+ 4 downto addr_i*4) <= fifo0_rd_addr;
        fifo1_rd_addr_r((addr_i*4-1)+ 4 downto addr_i*4) <= fifo1_rd_addr;
      end if;
    end process;
  end generate;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      if reset90_r = '1' then
        first_sdr_data       <= (others => '0');
        read_valid_data_1_r  <= '0';
        read_valid_data_1_r1 <= '0';
      else
        read_valid_data_1_r  <= read_valid_data_1;
        read_valid_data_1_r1 <= read_valid_data_1_r;
        if (read_valid_data_1_r1 = '1') then
          first_sdr_data <=
            (fifo_0_data_out_r & fifo_1_data_out_r);
        else
          first_sdr_data <= first_sdr_data;
        end if;
      end if;
    end if;
  end process;

------------------------------------------------------------------------------
-- fifo0_rd_addr and fifo1_rd_addr counters ( gray counters )
-------------------------------------------------------------------------------

  fifo0_rd_addr_inst : entity xddr2mig_rd_gray_cntr
    port map (
      clk90    => clk90,
      reset90  => reset90,
      cnt_en   => read_valid_data_1,
      rgc_gcnt => fifo0_rd_addr
      );
  fifo1_rd_addr_inst : entity xddr2mig_rd_gray_cntr
    port map (
      clk90    => clk90,
      reset90  => reset90,
      cnt_en   => read_valid_data_1,
      rgc_gcnt => fifo1_rd_addr
      );

-------------------------------------------------------------------------------
-- ram8d instantiations
-------------------------------------------------------------------------------

  gen_strobe: for strobe_i in 0 to DATA_STROBE_WIDTH-1 generate
    attribute syn_noprune : boolean;
    attribute syn_noprune of strobe : label is true;
    attribute syn_noprune of strobe_n : label is true;
  begin
    strobe : entity xddr2mig_ram8d_0
      Port Map (
        dout  => fifo_0_data_out((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        waddr => fifo_0_wr_addr((strobe_i*4-1)+4 downto strobe_i*4),
        din   => ddr_dq_in((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        raddr => fifo0_rd_addr_r((strobe_i*4-1)+4 downto strobe_i*4),
        wclk0 => dqs_delayed_col0(strobe_i),
        wclk1 => dqs_delayed_col1(strobe_i),
        we    => fifo_0_wr_en(strobe_i)
        );
    strobe_n : entity xddr2mig_ram8d_0
      Port Map (
        dout  => fifo_1_data_out((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        waddr => fifo_1_wr_addr((strobe_i*4-1)+4 downto strobe_i*4),
        din   => ddr_dq_in((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        raddr => fifo1_rd_addr_r((strobe_i*4-1)+4 downto strobe_i*4),
        wclk0 => dqs_delayed_col0_n(strobe_i),
        wclk1 => dqs_delayed_col1_n(strobe_i),
        we    => fifo_1_wr_en(strobe_i)
        );
  end generate;

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;

entity xddr2mig_data_write_0 is
  port(
    user_input_data    : in  std_logic_vector((2*DATA_WIDTH-1) downto 0);
    user_data_mask     : in  std_logic_vector((2*DATA_MASK_WIDTH-1) downto 0);
    clk90              : in  std_logic;
    write_enable       : in  std_logic;
    write_en_val       : out std_logic;
    data_mask_f        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    write_data_falling : out std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end xddr2mig_data_write_0;

architecture arc of xddr2mig_data_write_0 is


  signal write_en_P1       : std_logic;  -- write enable Pipeline stage
  signal write_en_P2       : std_logic;
  signal write_en_int      : std_logic;
  signal write_data0       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data1       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data2       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data3       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data4       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data_m0     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m1     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m2     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m3     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m4     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);

  signal write_data90       : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data90_1     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data90_2     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data_m90     : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m90_1   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m90_2   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);

  signal write_data270     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data270_1   : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data270_2   : std_logic_vector((DATA_WIDTH-1) downto 0);

  signal write_data_m270   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m270_1 : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m270_2 : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);

  

  attribute syn_preserve : boolean;
  attribute syn_preserve of write_data0 : signal is true;
  attribute syn_preserve of write_data1 : signal is true;
  attribute syn_preserve of write_data2 : signal is true;
  attribute syn_preserve of write_data3 : signal is true;
  attribute syn_preserve of write_data4 : signal is true;

  attribute syn_preserve of write_data_m0 : signal is true;
  attribute syn_preserve of write_data_m1 : signal is true;
  attribute syn_preserve of write_data_m2 : signal is true;
  attribute syn_preserve of write_data_m3 : signal is true;
  attribute syn_preserve of write_data_m4 : signal is true;

  attribute syn_preserve of write_data90   : signal is true;
  attribute syn_preserve of write_data90_1 : signal is true;
  attribute syn_preserve of write_data90_2 : signal  is true;

  attribute syn_preserve of write_data270   : signal is true;
  attribute syn_preserve of write_data270_1 : signal is true;
  attribute syn_preserve of write_data270_2 : signal is true;

begin

  write_data0   <= user_input_data;
  write_data_m0 <= user_data_mask;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_data1   <= write_data0;
      write_data_m1 <= write_data_m0;
      write_data2   <= write_data1;
      write_data_m2 <= write_data_m1;
      write_data3   <= write_data2;
      write_data_m3 <= write_data_m2;
      write_data4   <= write_data3;
      write_data_m4 <= write_data_m3;
    end if;
  end process;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_data90        <= write_data4((DATA_WIDTH-1) downto 0); 
      write_data_m90      <= write_data_m4((DATA_MASK_WIDTH-1) downto 0);
      write_data90_1     <= write_data90;
      write_data_m90_1   <= write_data_m90;
      write_data90_2      <= write_data90_1;
      write_data_m90_2 <= write_data_m90_1;

    end if;
  end process;


  process(clk90)
  begin
    if clk90'event and clk90 = '0' then
      write_data270     <= write_data4((DATA_WIDTH*2-1) downto DATA_WIDTH);
      write_data_m270   <= write_data_m4((DATA_MASK_WIDTH*2-1) downto DATA_MASK_WIDTH);
      write_data270_1 <= write_data270;
      write_data270_2   <= write_data270_1;
      write_data_m270_1 <= write_data_m270;
      write_data_m270_2 <= write_data_m270_1;

    end if;
  end process;

  write_data_rising  <= write_data270_2;
  write_data_falling <= write_data90_2;
  data_mask_r        <= write_data_m270_2;
  data_mask_f        <= write_data_m90_2; 

-- write enable for data path
  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_en_P1 <= write_enable;
      write_en_P2 <= write_en_P1;
    end if;
  end process;

-- write enable for data path
  process(clk90)
  begin
    if clk90'event and clk90 = '0' then
      write_en_int <= write_en_P2;
      write_en_val <= write_en_P1;
    end if;
  end process;

end arc;


--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_data_path_0 is
  port(
    user_input_data    : in  std_logic_vector(((2*DATA_WIDTH)-1) downto 0);
    user_data_mask     : in  std_logic_vector((2*DATA_MASK_WIDTH-1) downto 0);
    clk                : in  std_logic;
    clk90              : in  std_logic;
    reset              : in  std_logic;
    reset90            : in  std_logic;
    write_enable       : in  std_logic;
    rst_dqs_div_in     : in  std_logic;
    delay_sel          : in  std_logic_vector(4 downto 0);
    dqs_int_delay_in   : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    dq                 : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    u_data_val         : out std_logic;
    user_output_data   : out std_logic_vector(((2*DATA_WIDTH)-1) downto 0);
    write_en_val       : out std_logic;
    data_mask_f        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    write_data_falling : out std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : out std_logic_vector((DATA_WIDTH-1) downto 0);
    -- debug signals
    vio_out_dqs            : in  std_logic_vector(4 downto 0);
    vio_out_dqs_en         : in  std_logic;
    vio_out_rst_dqs_div    : in  std_logic_vector(4 downto 0);
    vio_out_rst_dqs_div_en : in  std_logic
    );
end xddr2mig_data_path_0;

architecture arc of xddr2mig_data_path_0 is

  signal fifo0_rd_addr     : std_logic_vector(3 downto 0);
  signal fifo1_rd_addr     : std_logic_vector(3 downto 0);
  signal read_valid_data_1 : std_logic;
  signal fifo_0_wr_addr    : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
  signal fifo_1_wr_addr    : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
  signal fifo_0_wr_en      : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal fifo_1_wr_en      : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col0  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col1  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);

begin

  data_read0 : entity xddr2mig_data_read_0
    port map (
      clk90             => clk90,
      reset90           => reset90,
      ddr_dq_in         => dq,
      read_valid_data_1 => read_valid_data_1,
      fifo_0_wr_en      => fifo_0_wr_en,
      fifo_1_wr_en      => fifo_1_wr_en,
      fifo_0_wr_addr    => fifo_0_wr_addr,
      fifo_1_wr_addr    => fifo_1_wr_addr,
      dqs_delayed_col0  => dqs_delayed_col0,
      dqs_delayed_col1  => dqs_delayed_col1,
      user_output_data  => user_output_data,
      fifo0_rd_addr_val => fifo0_rd_addr,
      fifo1_rd_addr_val => fifo1_rd_addr
      );

  data_read_controller0 : entity xddr2mig_data_read_controller_0
    port map (
      clk                    => clk,
      clk90                  => clk90,
      reset                  => reset,
      reset90                => reset90,
      rst_dqs_div_in         => rst_dqs_div_in,
      delay_sel              => delay_sel,
      dqs_int_delay_in       => dqs_int_delay_in,
      fifo0_rd_addr          => fifo0_rd_addr,
      fifo1_rd_addr          => fifo1_rd_addr,
      u_data_val             => u_data_val,
      fifo_0_wr_en_val       => fifo_0_wr_en,
      fifo_1_wr_en_val       => fifo_1_wr_en,
      fifo_0_wr_addr_val     => fifo_0_wr_addr,
      fifo_1_wr_addr_val     => fifo_1_wr_addr,
      dqs_delayed_col0_val   => dqs_delayed_col0,
      dqs_delayed_col1_val   => dqs_delayed_col1,
      read_valid_data_1_val  => read_valid_data_1,
      vio_out_dqs            => vio_out_dqs,
      vio_out_dqs_en         => vio_out_dqs_en,
      vio_out_rst_dqs_div    => vio_out_rst_dqs_div,
      vio_out_rst_dqs_div_en => vio_out_rst_dqs_div_en
      );

  data_write0 : entity xddr2mig_data_write_0
    port map (
      user_input_data    => user_input_data,
      user_data_mask     => user_data_mask,
      clk90              => clk90,
      write_enable       => write_enable,
      write_en_val       => write_en_val,
      write_data_falling => write_data_falling,
      write_data_rising  => write_data_rising,
      data_mask_f        => data_mask_f,
      data_mask_r        => data_mask_r
      );

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
library work;
use work.all;

entity xddr2mig_infrastructure is
  port(
    delay_sel_val1_val : out std_logic_vector(4 downto 0);
    delay_sel_val      : in  std_logic_vector(4 downto 0);
    rst_calib1         : in  std_logic;
    clk_int            : in  std_logic;
    -- debug signals
    dbg_delay_sel      : out std_logic_vector(4 downto 0);
    dbg_rst_calib      : out std_logic
    );
end xddr2mig_infrastructure;

architecture arc of xddr2mig_infrastructure is
  
  signal delay_sel_val1 : std_logic_vector(4 downto 0);
  signal rst_calib1_r1  : std_logic;
  signal rst_calib1_r2  : std_logic;
  
begin

  delay_sel_val1_val <= delay_sel_val1;
  dbg_delay_sel      <= delay_sel_val1;
  dbg_rst_calib      <= rst_calib1_r2;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '0' then
      rst_calib1_r1    <= rst_calib1;
    end if;
  end process;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '1' then
      rst_calib1_r2    <= rst_calib1_r1;
    end if;
  end process;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '1' then
      if (rst_calib1_r2 = '0') then
        delay_sel_val1 <= delay_sel_val;
      else
        delay_sel_val1 <= delay_sel_val1;
      end if;
    end if;
  end process;

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_infrastructure_iobs_0 is
  port(
    ddr2_ck   : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr2_ck_n : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    clk0      : in std_logic
    );
end xddr2mig_infrastructure_iobs_0;

architecture arc of xddr2mig_infrastructure_iobs_0 is

    signal ddr2_clk_q     : std_logic;
  signal vcc    : std_logic;
  signal gnd    : std_logic;
  signal clk180 : std_logic;

---- **************************************************
---- iob attributes for instantiated FDDRRSE components
---- **************************************************
begin

  gnd    <= '0';
  vcc    <= '1';
  clk180 <= not clk0;
  
---- ***********************************************************
---- This includes instantiation of the output DDR flip flop
---- for ddr clk's and dimm clk's
---- ***********************************************************
   
 U_clk_i : FDDRRSE 
  port map (
    Q => ddr2_clk_q,
    C0 => clk0,
    C1 => clk180,
    CE => vcc,
    D0 => vcc,
    D1 => gnd,
    R => gnd,
    S => gnd 
    );

---- ******************************************
---- Ouput BUffers for ddr clk's and dimm clk's
---- ******************************************

r_inst : OBUFDS 
	  port map (
        I  => ddr2_clk_q,
        O  => ddr2_ck(0),
        OB => ddr2_ck_n(0)
		);

end arc;


--><-----------------------------------------------------------------------><--


library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;

entity xddr2mig_infrastructure_top is
  port(
    reset_in_n             : in  std_logic;
    delay_sel_val1_val     : out std_logic_vector(4 downto 0);
    sys_rst_val            : out std_logic;
    sys_rst90_val          : out std_logic;
    clk_int                : in  std_logic;
    clk90_int              : in  std_logic;
    dcm_lock               : in  std_logic;
    sys_rst180_val         : out std_logic;
    wait_200us             : out std_logic;
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );

end xddr2mig_infrastructure_top;

architecture arc of xddr2mig_infrastructure_top is

  signal user_rst       : std_logic;
  signal user_cal_rst   : std_logic;
  signal sys_rst_o      : std_logic;
  signal sys_rst_1      : std_logic := '1';
  signal sys_rst        : std_logic;
  signal sys_rst90_o    : std_logic;
  signal sys_rst90_1    : std_logic := '1';
  signal sys_rst90      : std_logic;
  signal sys_rst180_o   : std_logic;
  signal sys_rst180_1   : std_logic := '1';
  signal sys_rst180     : std_logic;
  signal delay_sel_val1 : std_logic_vector(4 downto 0);
  signal clk_int_val1   : std_logic;
  signal clk_int_val2   : std_logic;
  signal clk90_int_val1 : std_logic;
  signal clk90_int_val2 : std_logic;
  signal wait_200us_i   : std_logic;
  signal wait_200us_int : std_logic;
  signal wait_clk90     : std_logic;
  signal wait_clk270    : std_logic;
  signal counter200     : std_logic_vector(15 downto 0);
  signal sys_clk_ibuf   : std_logic;
  
begin

  sys_rst_val        <= sys_rst;
  sys_rst90_val      <= sys_rst90;
  sys_rst180_val     <= sys_rst180;
  delay_sel_val1_val <= delay_sel_val1;
-- To remove delta delays in the clock signals observed during simulation ,
-- Following signals are used
  clk_int_val1       <= clk_int;
  clk90_int_val1     <= clk90_int;
  clk_int_val2       <= clk_int_val1;
  clk90_int_val2     <= clk90_int_val1;
  user_rst           <= not reset_in_n when RESET_ACTIVE_LOW = '1' else reset_in_n;
  user_cal_rst       <= reset_in_n     when RESET_ACTIVE_LOW = '1' else not reset_in_n;

--For 200us during power up
  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' then
        wait_200us_i   <= '1';
        counter200     <= (others => '0');
      else
        if( counter200 < 33400
		-- synopsys translate_off
			and counter200 < 50
		-- synopsys translate_on
	                          ) then
          wait_200us_i <= '1';
          counter200   <= counter200 + 1;
        else
          counter200   <= counter200;
          wait_200us_i <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      wait_200us <= wait_200us_i;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      wait_200us_int <= wait_200us_i;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '0' then
      if user_rst = '1' or dcm_lock = '0' then
        wait_clk270 <= '1';
      else
        wait_clk270 <= wait_200us_int;
      end if;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '1' then
      wait_clk90 <= wait_clk270;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' or wait_200us_int = '1' then
        sys_rst_o <= '1';
        sys_rst_1 <= '1';
        sys_rst   <= '1';
      else
        sys_rst_o <= '0';
        sys_rst_1 <= sys_rst_o;
        sys_rst   <= sys_rst_1;
      end if;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' or wait_clk90 = '1' then
        sys_rst90_o <= '1';
        sys_rst90_1 <= '1';
        sys_rst90   <= '1';
      else
        sys_rst90_o <= '0';
        sys_rst90_1 <= sys_rst90_o;
        sys_rst90   <= sys_rst90_1;
      end if;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '0' then
      if user_rst = '1' or dcm_lock = '0' or wait_clk270 = '1' then
        sys_rst180_o <= '1';
        sys_rst180_1 <= '1';
        sys_rst180   <= '1';
      else
        sys_rst180_o <= '0';
        sys_rst180_1 <= sys_rst180_o;
        sys_rst180   <= sys_rst180_1;
      end if;
    end if;
  end process;

  cal_top0 : entity xddr2mig_cal_top
    port map (
      clk                    => clk_int_val2,
      clk0dcmlock            => dcm_lock,
      reset                  => user_cal_rst,
      tapfordqs              => delay_sel_val1,
      dbg_phase_cnt          => dbg_phase_cnt,
      dbg_cnt                => dbg_cnt,
      dbg_trans_onedtct      => dbg_trans_onedtct,
      dbg_trans_twodtct      => dbg_trans_twodtct,
      dbg_enb_trans_two_dtct => dbg_enb_trans_two_dtct
      );

end arc;

--><-----------------------------------------------------------------------><--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.xddr2mig_parameters_0.all;
library work;
use work.all;


library UNISIM;
use UNISIM.VCOMPONENTS.all;


entity xddr2mig_iobs_0 is
  port(
    clk                : in    std_logic;
    clk90              : in    std_logic;
    ddr_rasb_cntrl     : in    std_logic;
    ddr_casb_cntrl     : in    std_logic;
    ddr_web_cntrl      : in    std_logic;
    ddr_cke_cntrl      : in    std_logic;
    ddr_csb_cntrl      : in    std_logic;
    ddr_address_cntrl  : in    std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_ba_cntrl       : in    std_logic_vector((BANK_ADDRESS -1) downto 0);
    ddr_odt_cntrl      : in std_logic;
    rst_dqs_div_int    : in std_logic;
    dqs_reset          : in std_logic;
    dqs_enable         : in std_logic;
    ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dqs_n         : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
 
    ddr_dq             : inout std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_falling : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_en_val       : in    std_logic;
    data_mask_f        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    ddr_odt            : out   std_logic;
    ddr2_ck            : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr2_ck_n          : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr_rasb           : out   std_logic;
    ddr_casb           : out   std_logic;
    ddr_web            : out   std_logic;
    ddr_ba             : out   std_logic_vector((BANK_ADDRESS -1) downto 0);
    ddr_address        : out   std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_cke            : out   std_logic;
    ddr_csb            : out   std_logic;
    rst_dqs_div        : out   std_logic;
    rst_dqs_div_in     : in    std_logic;
    rst_dqs_div_out    : out   std_logic;
    dqs_int_delay_in   : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dm             : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    dq                 : out   std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end xddr2mig_iobs_0;


architecture arc of xddr2mig_iobs_0 is

  ATTRIBUTE X_CORE_INFO          : STRING;
  ATTRIBUTE CORE_GENERATION_INFO : STRING;

  ATTRIBUTE X_CORE_INFO of arc : ARCHITECTURE  IS "mig_v2_1_ddr2_sp3, Coregen 10.1i_ip0";
  ATTRIBUTE CORE_GENERATION_INFO of arc : ARCHITECTURE IS "ddr2_sp3,mig_v2_1,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=0010100110010, ext_load_mode_register=0000000000000}";

begin

  infrastructure_iobs0 : entity xddr2mig_infrastructure_iobs_0
    port map (
      clk0      => clk,
      ddr2_ck   => ddr2_ck,
      ddr2_ck_n => ddr2_ck_n
      );

  controller_iobs0 : entity xddr2mig_controller_iobs_0
    port map (
      clk0              => clk,
      ddr_rasb_cntrl    => ddr_rasb_cntrl,
      ddr_casb_cntrl    => ddr_casb_cntrl,
      ddr_web_cntrl     => ddr_web_cntrl,
      ddr_cke_cntrl     => ddr_cke_cntrl,
      ddr_csb_cntrl     => ddr_csb_cntrl,
      ddr_odt_cntrl     => ddr_odt_cntrl,
      ddr_address_cntrl => ddr_address_cntrl((ROW_ADDRESS -1) downto 0),
      ddr_ba_cntrl      => ddr_ba_cntrl((BANK_ADDRESS -1) downto 0),
      rst_dqs_div_int   => rst_dqs_div_int,
      ddr_rasb          => ddr_rasb,
      ddr_casb          => ddr_casb,
      ddr_web           => ddr_web,
      ddr_ba            => ddr_ba((BANK_ADDRESS -1) downto 0),
      ddr_address       => ddr_address((ROW_ADDRESS -1) downto 0),
      ddr_cke           => ddr_cke,
      ddr_csb           => ddr_csb,
      ddr_odt           => ddr_odt,
      rst_dqs_div       => rst_dqs_div,
      rst_dqs_div_in    => rst_dqs_div_in,
      rst_dqs_div_out   => rst_dqs_div_out
      );

  datapath_iobs0 : entity xddr2mig_data_path_iobs_0
    port map (
      clk                => clk,
      clk90              => clk90,
      dqs_reset          => dqs_reset,
      dqs_enable         => dqs_enable,
      ddr_dqs            => ddr_dqs,
    ddr_dqs_n         => ddr_dqs_n,
      ddr_dq             => ddr_dq,
      write_data_falling => write_data_falling,
      write_data_rising  => write_data_rising,
      write_en_val       => write_en_val,
      data_mask_f        => data_mask_f,
      data_mask_r        => data_mask_r,
      dqs_int_delay_in   => dqs_int_delay_in,
      ddr_dm             => ddr_dm,
      ddr_dq_val         => dq
    );

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use work.xddr2mig_parameters_0.all;
use UNISIM.VCOMPONENTS.all;
library work;
use work.all;

entity xddr2mig_top_0 is
  port(
    wait_200us            : in    std_logic;
    rst_dqs_div_in        : in    std_logic;
    rst_dqs_div_out       : out   std_logic;

    user_input_data       : in    std_logic_vector(((2*DATA_WIDTH)-1) downto 0);
    user_data_mask        : in    std_logic_vector(((DATA_MASK_WIDTH*2)-1) downto 0);
    user_output_data      : out   std_logic_vector(((2*DATA_WIDTH)-1)
                                                   downto 0) := (others => 'Z');
    user_data_valid       : out   std_logic;
    user_input_address    : in    std_logic_vector(((ROW_ADDRESS +
                                                     COLUMN_ADDRESS + BANK_ADDRESS)-1) downto 0);
    user_command_register : in    std_logic_vector(2 downto 0);
    burst_done            : in    std_logic;
    auto_ref_req          : out   std_logic;
    user_cmd_ack          : out   std_logic;
    init_done              : out   std_logic;
    ar_done               : out   std_logic;
    ddr2_dqs              : inout std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);
    ddr2_dqs_n         : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
 
    ddr2_dq               : inout std_logic_vector((DATA_WIDTH-1) downto 0)
                                                             := (others => 'Z');
    ddr2_cke              : out   std_logic;
    ddr2_cs_n             : out   std_logic;
    ddr2_ras_n            : out   std_logic;
    ddr2_cas_n            : out   std_logic;
    ddr2_we_n             : out   std_logic;
    ddr2_dm               : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    ddr2_ba               : out   std_logic_vector((BANK_ADDRESS-1) downto 0);
    ddr2_a                : out   std_logic_vector((ROW_ADDRESS-1) downto 0);
    ddr2_odt              : out   std_logic;
    ddr2_ck               : out   std_logic_vector((CLK_WIDTH-1) downto 0);
    ddr2_ck_n             : out   std_logic_vector((CLK_WIDTH-1) downto 0);
  clk_tb                : out  std_logic;
    clk90_tb          : out  std_logic;
    sys_rst_tb        : out std_logic;
    sys_rst90_tb          : out  std_logic;
    sys_rst180_tb         : out  std_logic;
    clk_int               : in    std_logic;
    clk90_int             : in    std_logic;
    delay_sel_val         : in    std_logic_vector(4 downto 0);
    sys_rst               : in    std_logic;
    sys_rst90             : in    std_logic;
    sys_rst180            : in    std_logic;
    -- debug signals
    dbg_delay_sel          : out std_logic_vector(4 downto 0);
    dbg_rst_calib          : out std_logic;
    vio_out_dqs            : in  std_logic_vector(4 downto 0);
    vio_out_dqs_en         : in  std_logic;
    vio_out_rst_dqs_div    : in  std_logic_vector(4 downto 0);
    vio_out_rst_dqs_div_en : in  std_logic
    );

end xddr2mig_top_0;

architecture arc of xddr2mig_top_0 is
  
  signal rst_calib          : std_logic;
  signal delay_sel          : std_logic_vector(4 downto 0);
  signal write_enable       : std_logic;
  signal dqs_div_rst        : std_logic;
  signal dqs_enable         : std_logic;
  signal dqs_reset          : std_logic;
  signal dqs_int_delay_in   : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dq                 : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_en_val       : std_logic;
  signal data_mask_f        : std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
  signal data_mask_r        : std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_falling : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data_rising  : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal ddr_rasb_cntrl     : std_logic;
  signal ddr_casb_cntrl     : std_logic;
  signal ddr_web_cntrl      : std_logic;
  signal ddr_ba_cntrl       : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal ddr_address_cntrl  : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal ddr_cke_cntrl      : std_logic;
  signal ddr_csb_cntrl      : std_logic;
  signal ddr_odt_cntrl      : std_logic;
  signal rst_dqs_div_int    : std_logic;

begin

  clk_tb            <=  clk_int;
  clk90_tb          <=  clk90_int;
  sys_rst_tb        <=  sys_rst;
  sys_rst90_tb      <=  sys_rst90;
  sys_rst180_tb     <=  sys_rst180;

  controller0 : entity xddr2mig_controller_0
  port map (
    auto_ref_req      => auto_ref_req,
    wait_200us        => wait_200us,
    clk               => clk_int,
    rst0              => sys_rst,
    rst180            => sys_rst180,
    address           => user_input_address(((ROW_ADDRESS + COLUMN_ADDRESS +
                                              BANK_ADDRESS)-1) downto BANK_ADDRESS),
    bank_addr         => user_input_address(BANK_ADDRESS-1 downto 0),
    command_register  => user_command_register,
    burst_done        => burst_done,
    ddr_rasb_cntrl    => ddr_rasb_cntrl,
    ddr_casb_cntrl    => ddr_casb_cntrl,
    ddr_web_cntrl     => ddr_web_cntrl,
    ddr_ba_cntrl      => ddr_ba_cntrl,
    ddr_address_cntrl => ddr_address_cntrl,
    ddr_cke_cntrl     => ddr_cke_cntrl,
    ddr_csb_cntrl     => ddr_csb_cntrl,
    ddr_odt_cntrl     => ddr_odt_cntrl,
    dqs_enable        => dqs_enable,
    dqs_reset         => dqs_reset,
    write_enable      => write_enable,
    rst_calib         => rst_calib,
    rst_dqs_div_int   => rst_dqs_div_int,
    cmd_ack           => user_cmd_ack,
    init              => init_done,
    ar_done           => ar_done
    );

  data_path0 : entity xddr2mig_data_path_0
    port map (
      user_input_data    => user_input_data,
      user_data_mask     => user_data_mask,
      clk                => clk_int,
      clk90              => clk90_int,
      reset              => sys_rst,
      reset90            => sys_rst90,
      write_enable       => write_enable,
      rst_dqs_div_in     => dqs_div_rst,
      delay_sel          => delay_sel,
      dqs_int_delay_in   => dqs_int_delay_in,
      dq                 => dq,
      u_data_val         => user_data_valid,
      user_output_data   => user_output_data,
      write_en_val       => write_en_val,
      data_mask_f        => data_mask_f,
      data_mask_r        => data_mask_r,
      write_data_falling => write_data_falling,
      write_data_rising  => write_data_rising,
--debug signals
      vio_out_dqs            => vio_out_dqs,
      vio_out_dqs_en         => vio_out_dqs_en,
      vio_out_rst_dqs_div    => vio_out_rst_dqs_div,
      vio_out_rst_dqs_div_en => vio_out_rst_dqs_div_en
      );

  infrastructure0 : entity xddr2mig_infrastructure
    port map (
      clk_int            => clk_int,
      rst_calib1         => rst_calib,
      delay_sel_val      => delay_sel_val,
      delay_sel_val1_val => delay_sel,
      dbg_delay_sel      => dbg_delay_sel,
      dbg_rst_calib      => dbg_rst_calib
      );

  iobs0 : entity xddr2mig_iobs_0
    port map (
      clk                => clk_int,
      clk90              => clk90_int,
      ddr_rasb_cntrl     => ddr_rasb_cntrl,
      ddr_casb_cntrl     => ddr_casb_cntrl,
      ddr_odt_cntrl      => ddr_odt_cntrl,
      ddr_web_cntrl      => ddr_web_cntrl,
      ddr_cke_cntrl      => ddr_cke_cntrl,
      ddr_csb_cntrl      => ddr_csb_cntrl,
      ddr_address_cntrl  => ddr_address_cntrl,
      ddr_ba_cntrl       => ddr_ba_cntrl,
      rst_dqs_div_int    => rst_dqs_div_int,
      dqs_reset          => dqs_reset,
      dqs_enable         => dqs_enable,
      ddr_dqs            => ddr2_dqs,
          ddr_dqs_n            => ddr2_dqs_n,
      ddr_dq             => ddr2_dq,
      write_data_falling => write_data_falling,
      write_data_rising  => write_data_rising,
      write_en_val       => write_en_val,
      data_mask_f        => data_mask_f,
      data_mask_r        => data_mask_r,
      ddr_odt            => ddr2_odt,
      ddr2_ck            => ddr2_ck,
      ddr2_ck_n          => ddr2_ck_n,
      ddr_rasb           => ddr2_ras_n,
      ddr_casb           => ddr2_cas_n,
      ddr_web            => ddr2_we_n,
      ddr_ba             => ddr2_ba,
      ddr_address        => ddr2_a,
      ddr_cke            => ddr2_cke,
      ddr_csb            => ddr2_cs_n,
      rst_dqs_div        => dqs_div_rst,
      rst_dqs_div_in     => rst_dqs_div_in,
      rst_dqs_div_out    => rst_dqs_div_out,
      dqs_int_delay_in   => dqs_int_delay_in,
      ddr_dm             => ddr2_dm,
      dq                 => dq
      );

end arc;

--><-----------------------------------------------------------------------><--

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use UNISIM.VCOMPONENTS.all;
library work;
use work.all;

entity xddr2_mig is
  port (
      cntrl0_ddr2_dq                : inout std_logic_vector(15 downto 0);
      cntrl0_ddr2_a                 : out   std_logic_vector(12 downto 0);
      cntrl0_ddr2_ba                : out   std_logic_vector(1 downto 0);
      cntrl0_ddr2_cke               : out   std_logic;
      cntrl0_ddr2_cs_n              : out   std_logic;
      cntrl0_ddr2_ras_n             : out   std_logic;
      cntrl0_ddr2_cas_n             : out   std_logic;
      cntrl0_ddr2_we_n              : out   std_logic;
      cntrl0_ddr2_odt               : out   std_logic;
      cntrl0_ddr2_dm                : out   std_logic_vector(1 downto 0);
      cntrl0_rst_dqs_div_in         : in    std_logic;
      cntrl0_rst_dqs_div_out        : out   std_logic;
      reset_in_n                    : in    std_logic;
      cntrl0_burst_done             : in    std_logic;
      cntrl0_init_done              : out   std_logic;
      cntrl0_ar_done                : out   std_logic;
      cntrl0_user_data_valid        : out   std_logic;
      cntrl0_auto_ref_req           : out   std_logic;
      cntrl0_user_cmd_ack           : out   std_logic;
      cntrl0_user_command_register  : in    std_logic_vector(2 downto 0);
      cntrl0_clk_tb                 : out   std_logic;
      cntrl0_clk90_tb               : out   std_logic;
      cntrl0_sys_rst_tb             : out   std_logic;
      cntrl0_sys_rst90_tb           : out   std_logic;
      cntrl0_sys_rst180_tb          : out   std_logic;
      cntrl0_user_data_mask         : in    std_logic_vector(3 downto 0);
      cntrl0_user_output_data       : out   std_logic_vector(31 downto 0);
      cntrl0_user_input_data        : in    std_logic_vector(31 downto 0);
      cntrl0_user_input_address     : in    std_logic_vector(24 downto 0);
      clk_int                       : in    std_logic;
      clk90_int                     : in    std_logic;
      dcm_lock                      : in    std_logic;
      cntrl0_ddr2_dqs               : inout std_logic_vector(1 downto 0);
      cntrl0_ddr2_dqs_n             : inout std_logic_vector(1 downto 0);
      cntrl0_ddr2_ck                : out   std_logic_vector(0 downto 0);
      cntrl0_ddr2_ck_n              : out   std_logic_vector(0 downto 0)
    );
	attribute syn_keep : boolean;
	attribute syn_keep of clk_int : signal is true;
	attribute syn_keep of clk90_int : signal is true;
end xddr2_mig;

architecture arc of xddr2_mig is

  ATTRIBUTE X_CORE_INFO          : STRING;
  ATTRIBUTE CORE_GENERATION_INFO : STRING;

  ATTRIBUTE X_CORE_INFO of arc : ARCHITECTURE  IS "mig_v2_1_ddr2_sp3, Coregen 10.1i_ip0";
  ATTRIBUTE CORE_GENERATION_INFO of arc  : ARCHITECTURE IS "ddr2_sp3,mig_v2_1,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=0010100110010, ext_load_mode_register=0000000000000}";

  signal sys_rst                : std_logic;
  signal wait_200us             : std_logic;
  signal sys_rst90              : std_logic;
  signal sys_rst180             : std_logic;
  signal delay_sel              : std_logic_vector(4 downto 0);
 -- debug signals 
  signal dbg_phase_cnt          : std_logic_vector(4 downto 0);
  signal dbg_cnt                : std_logic_vector(5 downto 0);
  signal dbg_trans_onedtct      : std_logic;
  signal dbg_trans_twodtct      : std_logic;
  signal dbg_enb_trans_two_dtct : std_logic;
  signal dbg_delay_sel          : std_logic_vector(4 downto 0);
  signal dbg_rst_calib          : std_logic;
-- chipscope signals
  signal dbg_data               : std_logic_vector(19 downto 0);
  signal dbg_trig               : std_logic_vector(3 downto 0);
  signal control0               : std_logic_vector(35 downto 0);
  signal control1               : std_logic_vector(35 downto 0);
  signal vio_out_dqs            : std_logic_vector(4 downto 0);
  signal vio_out_dqs_en         : std_logic;
  signal vio_out_rst_dqs_div    : std_logic_vector(4 downto 0);
  signal vio_out_rst_dqs_div_en : std_logic;
  signal vio_out                : std_logic_vector(11 downto 0); 

  
begin
  top_00 : entity xddr2mig_top_0
    port map (
      ddr2_dq               => cntrl0_ddr2_dq,
      ddr2_a                => cntrl0_ddr2_a,
      ddr2_ba               => cntrl0_ddr2_ba,
      ddr2_cke              => cntrl0_ddr2_cke,
      ddr2_cs_n             => cntrl0_ddr2_cs_n,
      ddr2_ras_n            => cntrl0_ddr2_ras_n,
      ddr2_cas_n            => cntrl0_ddr2_cas_n,
      ddr2_we_n             => cntrl0_ddr2_we_n,
      ddr2_odt              => cntrl0_ddr2_odt,
      ddr2_dm               => cntrl0_ddr2_dm,
      rst_dqs_div_in        => cntrl0_rst_dqs_div_in,
      rst_dqs_div_out       => cntrl0_rst_dqs_div_out,
      burst_done            => cntrl0_burst_done,
      init_done             => cntrl0_init_done,
      ar_done               => cntrl0_ar_done,
      user_data_valid       => cntrl0_user_data_valid,
      auto_ref_req          => cntrl0_auto_ref_req,
      user_cmd_ack          => cntrl0_user_cmd_ack,
      user_command_register => cntrl0_user_command_register,
      clk_tb                => cntrl0_clk_tb,
      clk90_tb              => cntrl0_clk90_tb,
      sys_rst_tb            => cntrl0_sys_rst_tb,
      sys_rst90_tb          => cntrl0_sys_rst90_tb,
      sys_rst180_tb         => cntrl0_sys_rst180_tb,
      user_data_mask        => cntrl0_user_data_mask,
      user_output_data      => cntrl0_user_output_data,
      user_input_data       => cntrl0_user_input_data,
      user_input_address    => cntrl0_user_input_address,
      ddr2_dqs              => cntrl0_ddr2_dqs,
      ddr2_dqs_n            => cntrl0_ddr2_dqs_n,
      ddr2_ck               => cntrl0_ddr2_ck,
      ddr2_ck_n             => cntrl0_ddr2_ck_n,
      clk_int               => clk_int,
      clk90_int             => clk90_int,
      wait_200us             => wait_200us,
      delay_sel_val          => delay_sel,
      sys_rst                => sys_rst,
      sys_rst90              => sys_rst90,
      sys_rst180             => sys_rst180,

    --Debug signals

      dbg_delay_sel          => dbg_delay_sel,
      dbg_rst_calib          => dbg_rst_calib,
      vio_out_dqs            => vio_out_dqs,
      vio_out_dqs_en         => vio_out_dqs_en,
      vio_out_rst_dqs_div    => vio_out_rst_dqs_div,
      vio_out_rst_dqs_div_en => vio_out_rst_dqs_div_en
      );

  infrastructure_top0 : entity xddr2mig_infrastructure_top
    port map (
      wait_200us             => wait_200us,
      delay_sel_val1_val     => delay_sel,
      sys_rst_val            => sys_rst,
      sys_rst90_val          => sys_rst90,
      sys_rst180_val         => sys_rst180,
      dbg_phase_cnt          => dbg_phase_cnt,
      dbg_cnt                => dbg_cnt,
      dbg_trans_onedtct      => dbg_trans_onedtct,
      dbg_trans_twodtct      => dbg_trans_twodtct,
      dbg_enb_trans_two_dtct => dbg_enb_trans_two_dtct,
            reset_in_n            => reset_in_n,
      clk_int               => clk_int,
      clk90_int             => clk90_int,
      dcm_lock              => dcm_lock
      );

end arc;
