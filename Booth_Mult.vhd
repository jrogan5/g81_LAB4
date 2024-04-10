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
    signal i : integer := 0;
    signal step : integer := 0;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            case step is
                when 0 =>
                    if ready = '1' then
                        M <= (In_1); 
                        Q <= In_2 & '0';
                        A <= (others => '0'); -- Initialize A to 0
                        step <= step + 1;
                        done <= '0';
                        S <= (15 downto 0 => '0');
                    end if;
                when 1 => 
                    case Q(1 downto 0) is
                        when "10" =>
                            A <= std_logic_vector(signed(A) - signed(M));
                        when "01" =>
                            A <= std_logic_vector(signed(A) + signed(M)); -- same here
                        when others =>
                            null;
                    end case;
                    step <= step + 1;
                when 2 =>
                    AQ <= std_logic_vector(shift_right(signed(A & Q),1)); -- shifting of AQ happens each time
                    step <= step + 1;
                when 3 =>
                    Q <= AQ(8 downto 0); -- split up A and Q
                    A <= AQ(16 downto 9);
                    i <= i + 1; -- increment i by 1
                    if (i = 7) then
                        step <= step + 1;
                        i <= 0;
                    else
                        step <= 1;
                    end if;
                when 4 =>
                    step <= 0;
                    done <= '1';  
                    S <= A & Q(8 downto 1);
                when others =>
                    null;
            end case;
        end if;
    end process;
end arch;