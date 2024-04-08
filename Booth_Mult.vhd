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

    signal M : std_logic_vector (7 downto 0);
    signal Q : std_logic_vector (8 downto 0);
    signal A : std_logic_vector (7 downto 0);
    signal cond : std_logic_vector(1 downto 0);
    signal AQ : std_logic_vector(16 downto 0);
    signal AQ_shifted : std_logic_vector(16 downto 0);
    signal A_int: std_logic_vector (7 downto 0);
    signal i : integer := 0;
    signal step : integer := 0;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            case step is
                when 0 =>
                    if ready = '1' then
                        M <= (In_1); -- converts M to 2's complement
                        Q <= In_2 & '0';
                        A <= (others => '0'); -- Initialize A to 0
                        A_int <= (others => '0');
                        step <= step + 1;
                        done <= '0';
                        S <= (others => '0');
                    end if;
                when 1 =>
                    cond <= Q(1 downto 0);
                    case cond is
                        when "10" =>
                            A <= std_logic_vector(signed(A_int) - signed(M)); -- this used to be unsigned but i think it should be signed
                        when "01" =>
                            A <= std_logic_vector(signed(A_int) + signed(M)); -- same here
                        when others =>
                            null;
                    end case;
                    step <= step + 1;
                when 2 =>
                    AQ <= A & Q; -- shifting of AQ happens each time
                    step <= step + 1;
                when 3 =>
                    AQ_shifted <= AQ(0) & AQ(16 downto 1); -- used to be '0' & AQ(16 downto 1)
                    step <= step + 1;
                when 4 =>
                    Q <= AQ_shifted(8 downto 0); -- split up A and Q
                    A <= AQ_shifted(16 downto 9);
                    A_int <= AQ_shifted(16 downto 9);
                    i <= i + 1; -- increment i by 1
                    if (i = 8) then
                        step <= 0;
                        done <= '1';
                        S <= AQ_shifted(16 downto 1);
                    else
                        step <= 1;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;
end arch;