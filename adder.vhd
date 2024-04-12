-----------------------------------------------------------
-- adder / subtractor 

-- James Rogan 261157151
-- Hamza Abudaqa 261175969
-- Created 2024-03-18
-----------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub is
    port( 
      A     : in     std_logic_vector (7 downto 0);
      B     : in     std_logic_vector (7 downto 0);
      sub   : in     std_logic;
      sum   : out    std_logic_vector (7 downto 0)
    );
end addsub ;

architecture arch of addsub is
    signal A_int : signed (7 downto 0) ;    -- note signed addition / subtraction. 
    signal B_int : signed (7 downto 0) ;    -- this is to ensure consistent results no matter the relative signs
                                            -- and magnitudes of the two input operands.
    signal sum_int : signed (7 downto 0) ;
begin
    A_int <= signed(A); -- std_logic_vector cast to signed
    B_int <= signed(B);
    sum_int <=  A_int - B_int when sub = '1'        -- case: subtraction
                else A_int + B_int;                 -- case: addition
    sum <= std_logic_vector(sum_int(7 downto 0));   -- both multiplier foes not care abou the overflow bit. 
end arch;
-- end of addsub VHDL code
-----------------------------------------------------------