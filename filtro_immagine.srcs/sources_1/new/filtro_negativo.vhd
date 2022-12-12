library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtro_negativo is
    port(
        -- Inputs
        clk : in std_logic;
        pixel : in std_logic_vector(7 downto 0);    -- Valore del pixel [0,255]
        dati_disponibili : in std_logic;            -- '1' indica dati pixel disponibili
        -- Output
        pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
        elaborazione_terminata : out std_logic
    );
end filtro_negativo;

architecture Behavioral of filtro_negativo is

begin
    -- pixel_elaborato <= pixel;
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(dati_disponibili = '1') then
                elaborazione_terminata <= '1';
            else
                elaborazione_terminata <= '0';
            end if;
            pixel_elaborato <= std_logic_vector(255-unsigned(pixel));
        end if;
    end process;
end Behavioral;
