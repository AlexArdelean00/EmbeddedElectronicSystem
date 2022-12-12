library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtro_luminosita is
    port(
        -- Inputs
        clk : in std_logic;
        pixel : in std_logic_vector(7 downto 0);                -- Valore del pixel [0,255]
        dati_disponibili : in std_logic;                        -- '1' indica dati pixel disponibili
        valore_luminosita : in std_logic_vector(7 downto 0);    -- Luminosita'
        -- Output
        pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
        elaborazione_terminata : out std_logic
    );
end filtro_luminosita;

architecture Behavioral of filtro_luminosita is

begin
    process(clk)
        variable temp : std_logic_vector(15 downto 0);
    begin
        if(rising_edge(clk)) then
            temp := std_logic_vector(unsigned(pixel) * unsigned(valore_luminosita));
            if(dati_disponibili = '1') then 
                if(temp(15) = '1') then
                    pixel_elaborato <= (others => '1');
                    elaborazione_terminata <= '1';
                else
                    pixel_elaborato <= temp(14 downto 7);
                    elaborazione_terminata <= '1';
                end if;
            else
                elaborazione_terminata <= '0';
            end if;
        end if;
    end process;
end Behavioral;
