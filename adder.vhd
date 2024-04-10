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
    signal A_int : signed (8 downto 0) ; -- note signed addition / subtraction. 
    signal B_int : signed (8 downto 0) ; -- this is to ensure consistent results no matter the relative sizes
                                          -- of the two input operands (mantissas).
    signal sum_int : signed (8 downto 0) ;
begin
    A_int <= signed('0' & A(7 downto 0)); -- extra '0' tacked on for overflow bit.
    B_int <= signed('0' & B(7 downto 0));
    sum_int <=  A_int - B_int when sub = '1'  -- note the abs() functin used here. 
                else A_int + B_int;                  -- want only the magnitude of the sum/difference.
    sum <= std_logic_vector(sum_int(8 downto 1));
end arch;
-- end of addsub VHDL code
-----------------------------------------------------------