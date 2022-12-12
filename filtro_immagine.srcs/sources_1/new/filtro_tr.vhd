library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filtro_tr is
    port(
        -- Inputs
        clk : in std_logic;
        pixel : in std_logic_vector(7 downto 0);    -- Valore del pixel [0,255]
        dati_disponibili : in std_logic;            -- '1' indica dati pixel disponibili
        -- Output
        pixel_elaborato : out std_logic_vector(7 downto 0);     -- Valore del pixel elaborato [0,255]
        elaborazione_terminata : out std_logic
    );
end filtro_tr;

architecture Behavioral of filtro_tr is
    
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(dati_disponibili = '1') then
                elaborazione_terminata <= '1';
            else
                elaborazione_terminata <= '0';
            end if;
            pixel_elaborato <= pixel;
        end if;
    end process;
end Behavioral;
