library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_1to4_8bit is
    port(
        -- Input
        ingresso : in std_logic_vector(7 downto 0);     -- Ingresso
        selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
        -- Output
        tr : out std_logic_vector(7 downto 0);          -- Uscita verso il filtro trasparente
        neg : out std_logic_vector(7 downto 0);         -- Uscita verso il filtro negativo
        soglia : out std_logic_vector(7 downto 0);      -- Uscita verso il filtro soglia
        lum : out std_logic_vector(7 downto 0)          -- Usicta verso il filtro di luminosita'
    );
end demux_1to4_8bit;

architecture Dataflow of demux_1to4_8bit is

begin
    tr <= ingresso when selezione="00" else (others => '0');
    neg <= ingresso when selezione="01" else (others => '0');
    soglia <= ingresso when selezione="10" else (others => '0');
    lum <= ingresso when selezione="11" else (others => '0');
end Dataflow;
