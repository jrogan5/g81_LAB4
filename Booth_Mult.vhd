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

    signal M : signed (7 downto 0);
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
        case step is 
                when 0 => 
                if ready = '1' then
                    M <= signed(In_1); -- converts M to 2's complement 
                    Q <= In_2 & '0';
                    A <= (7 downto 0 => '0'); -- Initialize A to 0
                    i <= 0; -- initialize index to 0
                    step <= step + 1;
                    done <= '0';
                end if;
            when 1 =>
                cond <= std_logic_vector(Q(1 downto 0));
                case cond is
                    when "10" =>
                        A <= A_int - M;
                    when "01" =>
                        A <= A_int + M;
                    when others => 
                end case;
                step <= step + 1;
            when 2 =>    
                AQ <= std_logic_vector(A) & std_logic_vector(Q); -- shifting of AQ happens each time
                step <= step + 1;
            when 3 =>
                AQ_shifted <= std_logic_vector(shift_right(unsigned(AQ),1));
                step <= step + 1;
            when 4 =>
                Q <= signed(AQ_shifted(8 downto 0)); -- split up A and Q 
                A <= signed(AQ_shifted(16 downto 9));
                A_int <= signed(AQ_shifted(16 downto 9));
                i <= i + 1; -- increment i by 1
                if (i = 8) then
                    step <= 0;
                else 
                    step <= 1;
                end if;
            when others => 
        end case;  
    end process;

    done <= '1' when (i = 8) else '0';
    S <= AQ_shifted(16 downto 1) when (i = 8) else (15 downto 0 => '0');

end arch;