library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_4to1_1bit is
    port(
        -- Input
        selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
        tr : in std_logic;           
        neg : in std_logic;          
        soglia : in std_logic;       
        lum : in std_logic;          
        -- Output
        uscita : out std_logic       
    );
end mux_4to1_1bit;

architecture Dataflow of mux_4to1_1bit is
begin
    with selezione select
        uscita <=   tr when "00",
                    neg when "01",
                    soglia when "10",
                    lum when others;
end Dataflow;
