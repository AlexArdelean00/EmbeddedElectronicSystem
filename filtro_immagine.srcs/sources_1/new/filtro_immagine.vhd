library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filtro_immagine is
    port(
        -- Input
        clk : in std_logic;                                 -- Clock di sitema
        RsRx : in std_logic;                                -- Linea in ingresso seriale
        switch_valore : in std_logic_vector(7 downto 0);    -- Controllano la soglia o la luminosita'
        switch_selezione : in std_logic_vector(1 downto 0); -- Selezionano il filtro
        -- Output
        RsTx : out std_logic                                -- Linea in uscita seriale
    );
end filtro_immagine;

architecture Structural of filtro_immagine is
    component ricevitore_uart
        port(
            -- Input
            clk                 : in std_logic;
            RsRx                : in std_logic;
            -- Output
            dati_out            : out std_logic_vector(7 downto 0); 
            dati_disponibili    : out std_logic
        );
    end component;
    
    component filtri
        port(
            -- Input
            clk : in std_logic;
            dati_ricevitore : in std_logic_vector(7 downto 0);
            dati_ricevitore_disponibili : in std_logic;
            switch_valore : in std_logic_vector(7 downto 0);    -- Controllano la soglia o la luminosita'
            switch_selezione : in std_logic_vector(1 downto 0); -- Selezionano il filtro
            -- Ouput
            dati_trasmettitore : out std_logic_vector(7 downto 0);
            dati_trasmettitore_disponibili : out std_logic
        );
    end component;
    
    component trasmettitore_uart
        port(
            -- Input
            clk                     : in std_logic;
            abilita_trasmissione    : in std_logic;
            dati_in                 : in std_logic_vector(7 downto 0);
            -- Output
            RsTx                    : out std_logic
        );
    end component;
    
    signal dati_ricevitore : std_logic_vector(7 downto 0);
    signal ricevitore_disponibile : std_logic;
    
    signal dati_trasmettitore : std_logic_vector(7 downto 0);
    signal dati_elaborati_disponibili : std_logic;
begin
    U1: ricevitore_uart
    port map(
        -- Input
        clk => clk,
        RsRx => RsRx,
        -- Output
        dati_out => dati_ricevitore,
        dati_disponibili => ricevitore_disponibile
    );
    
    U2: filtri
    port map(
        -- Input
        clk => clk,
        dati_ricevitore => dati_ricevitore,
        dati_ricevitore_disponibili => ricevitore_disponibile,
        switch_valore => switch_valore,
        switch_selezione => switch_selezione,
        -- Ouput
        dati_trasmettitore => dati_trasmettitore,
        dati_trasmettitore_disponibili => dati_elaborati_disponibili
    );
    
    U3: trasmettitore_uart
    port map(
        -- Input
        clk => clk,
        abilita_trasmissione => dati_elaborati_disponibili,
        dati_in => dati_trasmettitore,
        -- Output
        RsTx => RsTx
    );
end Structural;