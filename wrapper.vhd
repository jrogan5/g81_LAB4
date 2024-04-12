-----------------------------------------------------------------------------
-- WRAPPER FOR ALTERA SOC BOARD

-- James Rogan      261157151
-- Hamza Abudaqa    261175969
-- Date Modified:   2024-04-12

-- INSTRUCTIONS FOR USE:
--  Compile in quartus with the top level set to `wrapper.vhd`
--  In `Pin Planner` :
--      1. Map the switches to input_operand (SW[7..0])
--      2. Map the clock to `PIN_AF14` 
--          (for alternatives: `DE1-SoC_User_manual_revf.pdf`, page 22)
--      3. Map the ready signal to `PIN_AE12` (SW[9])
--      4. Map ready_LED to `PIN_Y21` (LED9)
--      6. Map done to `PIN_V16` (LED0)
--      5. Map the buttons as before
--      6. Map the wrapper segments to the on-board segments 
--          (with the same number instead of flipping them, 
--          I fixed that in software)
-----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wrapper is
    Port (  input_operand   : in std_logic_vector(7 downto 0);
            clk             : in std_logic;     -- clock: automatic 50 MHz
            ready           : in std_logic;     -- switch: loading phase
            B0, B1, B2, B3  : in std_logic;
            done            : out std_logic;    -- LED to indicate when algorithm is done.
            ready_LED       : out std_logic;    -- LED to indicate when ready is high.
            segment0        : out std_logic_vector(6 downto 0); -- 7 segment displays
            segment1        : out std_logic_vector(6 downto 0);
            segment2        : out std_logic_vector(6 downto 0);
            segment3        : out std_logic_vector(6 downto 0)
        );
end wrapper;

architecture arch of wrapper is
    signal in1, in2 : std_logic_vector(7 downto 0);
    signal mult_out : std_logic_vector(15 downto 0);
    signal dig0, dig1, dig2, dig3 : std_logic_vector(3 downto 0);
    signal cond : std_logic_vector(1 downto 0);
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
    -- turn on the ready LED when ready is 1
    ready_LED <= '1' when ready = '1' else '0'; -- if the opposite behavior occurs, 
                                                -- LED pin might be active low or something.
    -- load input 1 from switch bank
    process (B0)
    begin
        if ready = '1' then
            if not B0 = '1' then
                in1 <= input_operand;
            end if;
        end if;
    end process;

    -- load input 2 from switch bank
    process (B1)
    begin
        if ready = '1' then
            if not B1 = '1' then
                in2 <= input_operand;
            end if;
        end if;
    end process;

    cond <= B2 & B3;

    with cond select
    dig3 <=
        "0000" when "01",
        "0000" when "10",
        mult_out(15 downto 12) when others;

    with cond select
    dig2 <=
        "0000" when "01",
        "0000" when "10",
        mult_out(11 downto 8) when others;

    with cond select
    dig1 <=
        in1(7 downto 4) when "01",
        in2(7 downto 4) when "10",
        mult_out(7 downto 4) when others;

        
    with cond select
    dig0 <=
        in1(3 downto 0) when "01",
        in1(3 downto 0) when "10",
        mult_out(3 downto 0)  when others;


    -- Booth multiplier instantiation
    mult : Booth_Mult port map( In_1 => in1, In_2 => in2, S => mult_out, clk => clk, ready => ready, done => done );

    -- LED decoders instantiation
    s0 : LED_decoder port map( code => dig0, segments_out => segment0 );
    s1 : LED_decoder port map( code => dig1, segments_out => segment1 );
    s2 : LED_decoder port map( code => dig2, segments_out => segment2 );    
    s3 : LED_decoder port map( code => dig3, segments_out => segment3 );
end arch;

