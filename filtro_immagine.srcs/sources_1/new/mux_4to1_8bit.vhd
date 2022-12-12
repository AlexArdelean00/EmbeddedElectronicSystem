library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_4to1_8bit is
    port(
        -- Input
        selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
        tr : in std_logic_vector(7 downto 0);           -- Ingresso proveniente dal filtro trasparente
        neg : in std_logic_vector(7 downto 0);          -- Ingresso proveniente dal filtro negativo
        soglia : in std_logic_vector(7 downto 0);       -- Ingresso proveniente dal filtro soglia
        lum : in std_logic_vector(7 downto 0);          -- Ingresso proveniente dal filtro di luminosita'
        -- Output
        uscita : out std_logic_vector(7 downto 0)       -- Uscita
    );
end mux_4to1_8bit;

architecture Dataflow of mux_4to1_8bit is
begin
    with selezione select
        uscita <=   tr when "00",
                    neg when "01",
                    soglia when "10",
                    lum when others;
end Dataflow;
