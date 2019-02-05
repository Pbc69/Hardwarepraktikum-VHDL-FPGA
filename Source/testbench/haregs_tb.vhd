---------------------------------------------------------------------------------------------------
--
-- Titel:    TestBench von HAREGS
-- Autor:    Andreas Engel
-- Datum:    25.07.07
-- Laufzeit: 400ns
--
---------------------------------------------------------------------------------------------------

-- Libraries:
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.all;
	use work.hadescomponents.all;

---------------------------------------------------------------------------------------------------


-- Entity:
entity haregs_tb is
end haregs_tb;
---------------------------------------------------------------------------------------------------


-- Architecture:
architecture TB_ARCHITECTURE of haregs_tb is
	
	-- Stimulie
	signal clk, reset, regwrite   : std_logic   :=  '0';
	signal aopadr, bopadr, wopadr : t_haregsAdr :=  "000";
	signal wop                    : t_word      := x"00000000";
	
	-- beobachtete Signale
	signal aop, bop : t_word;	
	
	-- Beobachtungsprozedur
	procedure prove(a, b: t_word := (others => 'U')) is
	begin
		if a(a'left)/='U' then
      assert aop = a 
      report "wrong AOP 0x" & to_hex(aop) & "; expected 0x" & to_hex(a)  
      severity error;
    end if;
    
    if b(b'left)/='U' then
      assert bop = b 
      report "wrong BOP 0x" & to_hex(bop) & "; expected 0x" & to_hex(b)  
      severity error;
    end if;    
  end;

begin

	-- RESET Stimulus
  reset    <= '1',
              '0'     after  5 ns,
              '1'     after 355 ns,
              '0'     after 370 ns;          
  
  -- REGWRITE Stimulus              
  regwrite <= '0',
              '1'     after   5 ns,
              '0'     after  185 ns;
    
  -- Beschaltung der Eingänge und Beobachtung der Ausgänge
  test: process
  begin       
  
    --   7ns
    --   9ns
    --  15ns  
         
    --  25ns
    --  28ns
    --  35ns
    
    --  45ns
    --  48ns
    --  53ns
    --  55ns 
    --  58ns   
     
    --  65ns
    --  68ns
    --  75ns
     
    --  85ns
    --  88ns
    --  95ns
     
    -- 105ns
    -- 108ns
    -- 113ns
    -- 115ns
    -- 118ns
     
    -- 125ns
    -- 128ns
    -- 135ns
                                                                                             
    -- 145ns
    -- 148ns
    -- 155ns
     
    -- 165ns
    -- 168ns
    -- 175ns
                                                                                           
                                                                                          
    -- 185ns Regwrite <= 0
                                                                                           
    -- 187ns
    -- 192ns
    -- 202ns
     
    -- 205ns
    -- 212ns
    -- 222ns
    -- 224ns
    -- 226ns
          
    -- 228ns
    -- 232ns
    -- 242ns
     
    -- 245ns
    -- 252ns
    -- 262ns
     
    -- 265ns
    -- 272ns
    -- 282ns
       
    -- 285ns
    -- 292ns
    -- 302ns
    -- 304ns
    -- 306ns 
    
    -- 308ns
    -- 312ns
    -- 322ns
     
    -- 325ns
    -- 332ns
    -- 342ns
    
    
    -- 352ns
    
    -- 355ns Reset <= 1
    
    -- 362ns
	
	report "!!!TEST DONE !!!"
		severity NOTE;
	
    wait;
  end process;
             
end TB_ARCHITECTURE;
---------------------------------------------------------------------------------------------------
