library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Booth_Mult is
    Port (
        In_1, In_2 : in std_logic_vector (7 downto 0);
        clk : in std_logic;
        ready : in std_logic;
        done : out std_logic;
        S : out std_logic_vector (15 downto 0)
    );
end Booth_Mult;

architecture arch of Booth_Mult is
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

    -- misc
    signal cond     : std_logic_vector(1 downto 0);
    signal sub_sel  : std_logic;
    signal shift    : integer range 8 downto 1;

    -- combinational logic outputs
    signal Q_out    : std_logic_vector (8 downto 0);
    signal A_out    : std_logic_vector (7 downto 0);


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
            elsif shift = 8 then --ready is zero
                done <= '1'; -- process is complete. Don't update registers.
            else -- ready is zero
                shift <= shift + 1; -- process incomplete. move onto nect phase
                Q_reg <= Q_out; -- update registers (excluding M)
                A_reg <= A_out;
            end if;
        end if;
    end process;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                          COMBINATIONAL LOGIC                              --
-------------------------------------------------------------------------------
    cond <= Q_reg(1 downto 0);

    -- select whether to propogate A or A +/- M 
    with cond select
    addend <=   M_reg when "01",
                M_reg when "10",
                (others => '0') when others;

    -- choose A + M or A - M            
    with cond select
    sub_sel <=  '1' when "10",
                '0' when others;


    addsub_mantissas : addsub
    port map(A => A_reg, B => addend, sub => sub_sel, sum => sum_out); -- sum_frac includes the hidden bit. 

    AQ <= std_logic_vector(shift_right(signed(sum_out & Q_reg),1)); -- shifting operation
    
    -- combinational logic outputs (register inputs)
    A_out <= AQ(16 downto 9); 
    Q_out <= AQ(8 downto 0);

    -- multiplier result
    S <= AQ(16 downto 1);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end arch;