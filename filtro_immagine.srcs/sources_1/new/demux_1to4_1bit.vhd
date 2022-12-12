library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_1to4_1bit is
    port(
        -- Input
        ingresso : in std_logic;     -- Ingresso
        selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
        -- Output
        tr : out std_logic;          -- Uscita verso il filtro trasparente
        neg : out std_logic;         -- Uscita verso il filtro negativo
        soglia : out std_logic;      -- Uscita verso il filtro soglia
        lum : out std_logic          -- Usicta verso il filtro di luminosita'
    );
end demux_1to4_1bit;

architecture Dataflow of demux_1to4_1bit is

begin
    tr <= ingresso when selezione="00" else '0';
    neg <= ingresso when selezione="01" else '0';
    soglia <= ingresso when selezione="10" else '0';
    lum <= ingresso when selezione="11" else '0';
end Dataflow;
