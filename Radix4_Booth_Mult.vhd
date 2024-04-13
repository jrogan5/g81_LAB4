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

    -- new signals for bonus to handle extra internal bits
    signal A_signed : signed (7 downto 0);
    signal M_signed : signed (7 downto 0);
    signal A_int    : std_logic_vector (8 downto 0); -- internal signals...
    signal M_int    : std_logic_vector (8 downto 0); -- ...sized for asl 1.  
    signal M2_int   : signed (8 downto 0);

    -- adder/subtractor output
    signal addend   : std_logic_vector (8 downto 0);
    signal sum_out  : std_logic_vector (8 downto 0); 

    -- shifter output
    signal AQ_signed    : signed (17 downto 0); -- 9 + 9 = 18 bits
    signal A_out_signed : signed (8 downto 0); -- 9 bits

    -- combinational logic outputs
    signal Q_out    : std_logic_vector (8 downto 0); -- 9 bits
    signal A_out    : std_logic_vector (7 downto 0); -- 8 bits (after resized)

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
generic(bits : integer range 9 downto 8);
port(
    A     : in     std_logic_vector (bits-1 downto 0);
    B     : in     std_logic_vector (bits-1 downto 0);
    sub   : in     std_logic;
    sum   : out    std_logic_vector (bits-1 downto 0)
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
            if ready = '1' then -- State: idle / first step on algoritm
                M_reg <= In_1; 
                Q_reg <= In_2 & '0';
                A_reg <= (others => '0'); -- Initialize A to 0
                shift <= 1;
                done <= '0';
            elsif shift = 4 then  -- State: finished
                done <= '1'; -- process is complete. Don't update registers.
            else  -- state: running
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
    A_signed <= signed(A_reg); -- signed cast
    M_signed <= signed(M_reg); -- signed cast.

    -- Because of the multiplication by 2, 
    -- we must consider 8 + 1 = 9 bits for internal signals. 
    A_int <= std_logic_vector(resize(A_signed, 9));
    M_int <= std_logic_vector(resize(M_signed, 9));

    -- multiplication by 2, for input to the mux that follows
    M2_int <= shift_left(signed(M_int),1);

    -- Select A or A +/- M or A +/- 2M based last three bits of Q_reg
    with cond select
    addend <=   M_int when "001",                      -- M
                M_int when "010",                      -- M
                std_logic_vector(M2_int) when "011",   -- 2M
                std_logic_vector(M2_int) when "100",   -- 2M
                M_int when "101",                      -- M
                M_int when "110",                      -- M
                (others => '0') when others;           -- 0


    -- Choose (A + addend) or (A - addend) based on the condition
    -- defined by the last three bits of Q_reg
    with cond select
      sub_sel <=    '1' when "100",  -- subtraction 
                    '1' when "101",  -- ^^
                    '1' when "110",  -- ^^
                    '0' when others; -- addition (possibly of zero)
    addsub_unit : addsub
    generic map(bits => 9)
    port map(A => A_int, B => addend, sub => sub_sel, sum => sum_out);  
    

    -- shift right 2 places, dividing by 4. 
    AQ_signed <= shift_right(signed(sum_out & Q_reg), 2); 

    -- break out the first part, which is signed A 
    A_out_signed <= AQ_signed(17 downto 9); -- 9 bits

    -- resize and convert types of A and Q for output of COMB
    A_out <= std_logic_vector(resize(A_out_signed, 8)); -- 8 bits
    Q_out <= std_logic_vector(AQ_signed(8 downto 0));   -- 9 bits

    -- multiplier result
    S <= A_out & Q_out(8 downto 1);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end arch;
