library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Radix4_Booth_Mult is
    Port (
        In_1, In_2 : in std_logic_vector (7 downto 0);
        clk : in std_logic;
        ready : in std_logic;
        done : out std_logic;
        S : out std_logic_vector (15 downto 0)
    );
end Radix4_Booth_Mult;

architecture arch of Radix4_Booth_Mult is
-------------------------------------------------------------------------------
--                               SIGNALS                                     --
-------------------------------------------------------------------------------
    -- register outputs
    signal M_reg    : std_logic_vector (7 downto 0);
    signal Q_reg    : std_logic_vector (8 downto 0);
    signal A_reg    : std_logic_vector (7 downto 0);

    -- adder/subtractor output
    signal addend   : std_logic_vector (7 downto 0);
    signal sum_out  : std_logic_vector (7 downto 0);

    -- shifter output
    signal AQ       : std_logic_vector(16 downto 0);

    -- combinational logic outputs
    signal Q_out    : std_logic_vector (8 downto 0);
    signal A_out    : std_logic_vector (7 downto 0);

    -- misc
    signal cond     : std_logic_vector(2 downto 0);
    signal sub_sel  : std_logic;
    signal shift    : integer range 4 downto 1;  
-------------------------------------------------------------------------------
------------------------------------------------------------------------------- 

-------------------------------------------------------------------------------
--                               COMPONENTS                                  --
-------------------------------------------------------------------------------
component addsub is -- adder / subtractor for mantissa addition step
port(
    A     : in     std_logic_vector (7 downto 0);
    B     : in     std_logic_vector (7 downto 0);
    sub   : in     std_logic;
    sum   : out    std_logic_vector (7 downto 0)
    );
end component;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
                
    
begin
-------------------------------------------------------------------------------
--                          INPUT REGISTER                                   --
-------------------------------------------------------------------------------
    process(clk)
        begin
        if rising_edge(clk) then
            if ready = '1' then
                M_reg <= In_1; 
                Q_reg <= In_2 & '0';
                A_reg <= (others => '0'); -- Initialize A to 0
                shift <= 1;
                done <= '0';
            elsif shift = 4 then  
                done <= '1'; -- process is complete. Don't update registers.
            else 
                shift <= shift + 1; -- process not complete so move to next phase
                Q_reg <= Q_out; -- update required registers 
                A_reg <= A_out; -- update required registers 
            end if;
        end if;
    end process;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                          COMBINATIONAL LOGIC                              --
-------------------------------------------------------------------------------
   cond <= Q_reg(2 downto 0);  -- Extracting the last three bits of Q_reg

    -- Select A or A +/- M or A +/- 2M based last three bits of Q_reg
    with cond select
    addend <=   M_reg when "001",                     -- M
                M_reg when "010",                     -- M
                std_logic_vector(shift_left(signed(M_reg),1)) when "011",   -- 2M
                std_logic_vector(shift_left(signed(M_reg),1)) when "100",   -- 2M
                M_reg when "101",                     -- M
                M_reg when "110",                     -- M
                (others => '0') when others;          -- 0


    -- Choose A + M or A - M based on the conditions derived from the last three bits of Q_reg
    with cond select
      sub_sel <=    '1' when "100",  -- subtraction 
                    '1' when "110",  -- ^^
                    '1' when "101",  -- ^^
                    '0' when others; -- addition
    addsub_mantissas : addsub
    port map(A => A_reg, B => addend, sub => sub_sel, sum => sum_out);  

    AQ <= std_logic_vector(shift_right(signed(sum_out & Q_reg), 2)); 
    
    -- combinational logic outputs (register inputs)
    A_out <= AQ(16 downto 9); 
    Q_out <= AQ(8 downto 0);

    -- multiplier result
    S <= AQ(16 downto 1);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end arch;
