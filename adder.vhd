-----------------------------------------------------------
-- adder / subtractor 

-- James Rogan 26115bits-1151
-- Hamza Abudaqa 2611bits-15969
-- Created 2024-03-18
-----------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub is
    generic(bits : integer range 10 downto 8);
    port( 
      A     : in     std_logic_vector (bits-1 downto 0);
      B     : in     std_logic_vector (bits-1 downto 0);
      sub   : in     std_logic;
      sum   : out    std_logic_vector (bits-1 downto 0)
    );
end addsub ;

architecture arch of addsub is
    signal A_int : signed (bits-1 downto 0) ;    -- note signed addition / subtraction. 
    signal B_int : signed (bits-1 downto 0) ;    -- this is to ensure consistent results no matter the relative signs
                                            -- and magnitudes of the two input operands.
    signal sum_int : signed (bits-1 downto 0) ;
begin
    A_int <= signed(A); -- std_logic_vector cast to signed
    B_int <= signed(B);
    sum_int <=  A_int - B_int when sub = '1'        -- case: subtraction
                else A_int + B_int;                 -- case: addition
    sum <= std_logic_vector(sum_int(bits-1 downto 0));   -- booth multiplier does not care abou the overflow bit of addition / subtraction. 
end arch;
-- end of addsub VHDL code
-----------------------------------------------------------