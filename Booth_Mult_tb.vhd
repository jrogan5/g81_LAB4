library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Booth_Mult_tb is
end Booth_Mult_tb;

architecture arch of Booth_Mult_tb is
    signal In_1_tb : std_logic_vector (7 downto 0);
    signal In_2_tb : std_logic_vector (7 downto 0);
    signal clk_tb : std_logic := '0';
    signal ready_tb : std_logic := '0';
    signal done_tb : std_logic;
    signal S_tb : std_logic_vector (15 downto 0);

    component Booth_Mult
        port  (
            In_1, In_2 : in std_logic_vector (7 downto 0) ;
            clk : in std_logic ;
            ready : in std_logic;
            done : out std_logic;
            S : out std_logic_vector (15 downto 0)
        );
    end component;

    constant clk_period : time := 20 ns; -- Clock period

begin

    -- Clock generation process
    clk_gen_proc: process
    begin
        wait for 10 ns;
        while now < 5 us loop -- Simulate for 5 us
            clk_tb <= not clk_tb; -- Toggle clock every half period
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- algoritthm:
        -- 1st clock: ready step. loads them in.
        -- 2nd:
        In_1_tb <= "11111001";  -- -7
        In_2_tb <= "11111101";  -- -3
        ready_tb <= '1';
        wait until rising_edge(clk_tb);
        ready_tb <= '0'; -- Start the multiplication process

        -- Wait for 'done' signal
        wait until done_tb = '1';

        -- Add any additional checks or assertions here

        -- End simulation
        wait;
    end process stimulus;

    -- Instantiate the DUT
    UUT: Booth_Mult
        port map (
            In_1 => In_1_tb,
            In_2 => In_2_tb,
            clk => clk_tb,
            ready => ready_tb,
            done => done_tb,
            S => S_tb
        );

end arch;