library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wrapper is
    Port (  input_operand : in std_logic_vector(7 downto 0);
            clk_mode : in std_logic; -- switch: automatic or manually incremented
            ready    : in std_logic; -- switch: loading phase
            B0, B1, B2, B3 : in std_logic;
            segment0 : out std_logic_vector(6 downto 0);
            segment1 : out std_logic_vector(6 downto 0);
            segment2 : out std_logic_vector(6 downto 0);
            segment3 : out std_logic_vector(6 downto 0);
            segment4 : out std_logic_vector(6 downto 0);
            segment5 : out std_logic_vector(6 downto 0)
        );
end wrapper;

architecture arch of wrapper is
    signal in1, in2 : std_logic_vector(7 downto 0);
    signal mult_out : std_logic_vector(15 downto 0);
    signal S : std_logic_vector(15 downto 0);
    signal M, Q : std_logic_vector (7 downto 0);
    signal clk : std_logic := '0'; -- Initialize clock signal
    signal done : std_logic;

    component LED_decoder is
        port ( code : in std_logic_vector(3 downto 0);
               segments_out : out std_logic_vector(6 downto 0) );
    end component;

    component Booth_Mult is
        Port (  In_1, In_2      : in std_logic_vector(7 downto 0);
                clk             : in std_logic;
                ready           : in std_logic;
                done            : out std_logic;
                S               : out std_logic_vector (15 downto 0)
        );
    end component;

begin
    -- Clock process for synchronization
    process (clk_mode, B3)
    begin
        if clk_mode = '1' then
            clk <= not B3; -- Invert B3 for synchronization
        else
            clk <= '0'; 
        end if;
    end process;

    -- Process for loading input operands
    process (ready, B0, input_operand)
    begin
        if ready = '1' and not B0 = '1' then
            in1 <= input_operand;
        end if;
    end process;

    process (ready, B1, input_operand)
    begin
        if ready = '1' and not B1 = '1' then
            in2 <= input_operand;
        end if;
    end process;

    -- Booth multiplier instantiation
    mult : Booth_Mult port map( In_1 => in1, In_2 => in2, S => mult_out, clk => clk, ready => ready, done => done );

    -- LED decoders instantiation
    s0 : LED_decoder port map( code => mult_out(3 downto 0), segments_out => segment0 );
    s1 : LED_decoder port map( code => mult_out(7 downto 4), segments_out => segment1 );
    s2 : LED_decoder port map( code => mult_out(11 downto 8), segments_out => segment2 );    
    s3 : LED_decoder port map( code => mult_out(15 downto 12), segments_out => segment3 );
    s4 : LED_decoder port map( code => mult_out(15 downto 12), segments_out => segment4 );
    s5 : LED_decoder port map( code => mult_out(11 downto 8), segments_out => segment5 );
end arch;

