library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filtri is
    port(
        -- Input
        clk : in std_logic;
        dati_ricevitore : in std_logic_vector(7 downto 0);
        dati_ricevitore_disponibili : in std_logic;
        switch_valore : in std_logic_vector(7 downto 0);    -- Controllano la soglia o la luminosità
        switch_selezione : in std_logic_vector(1 downto 0); -- Selezionano il filtro
        -- Ouput
        dati_trasmettitore : out std_logic_vector(7 downto 0);
        dati_trasmettitore_disponibili : out std_logic
    );
end filtri;

architecture Structural of filtri is
    component demux_1to4_8bit
        port(
            -- Input
            ingresso : in std_logic_vector(7 downto 0);     -- Ingresso
            selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
            -- Output
            tr : out std_logic_vector(7 downto 0);          -- Uscita verso il filtro trasparente
            neg : out std_logic_vector(7 downto 0);         -- Uscita verso il filtro negativo
            soglia : out std_logic_vector(7 downto 0);      -- Uscita verso il filtro soglia
            lum : out std_logic_vector(7 downto 0)          -- Usicta verso il filtro di luminosità
        );
    end component;
    
    component demux_1to4_1bit
        port(
            -- Input
            ingresso : in std_logic;     -- Ingresso
            selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
            -- Output
            tr : out std_logic;          -- Uscita verso il filtro trasparente
            neg : out std_logic;         -- Uscita verso il filtro negativo
            soglia : out std_logic;      -- Uscita verso il filtro soglia
            lum : out std_logic          -- Usicta verso il filtro di luminosità
        );
    end component;
    
    component mux_4to1_8bit
        port(
            -- Input
            selezione : in std_logic_vector(1 downto 0);    -- Seleziona il segnale
            tr : in std_logic_vector(7 downto 0);           -- Ingresso proveniente dal filtro trasparente
            neg : in std_logic_vector(7 downto 0);          -- Ingresso proveniente dal filtro negativo
            soglia : in std_logic_vector(7 downto 0);       -- Ingresso proveniente dal filtro soglia
            lum : in std_logic_vector(7 downto 0);          -- Ingresso proveniente dal filtro di luminosità
            -- Output
            uscita : out std_logic_vector(7 downto 0)       -- Uscita
        );
    end component;
    
    component filtro_tr
         port(
            -- Inputs
            clk : in std_logic;
            pixel : in std_logic_vector(7 downto 0);    -- Valore del pixel [0,255]
            dati_disponibili : in std_logic;            -- '1' indica dati pixel disponibili
            -- Output
            pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
            elaborazione_terminata : out std_logic
        );
    end component;
    
    component filtro_negativo
         port(
            -- Inputs
            clk : in std_logic;
            pixel : in std_logic_vector(7 downto 0);    -- Valore del pixel [0,255]
            dati_disponibili : in std_logic;            -- '1' indica dati pixel disponibili
            -- Output
            pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
            elaborazione_terminata : out std_logic
        );
    end component;
    
    component filtro_soglia
        port(
            -- Inputs
            clk : in std_logic;
            pixel : in std_logic_vector(7 downto 0);            -- Valore del pixel [0,255]
            dati_disponibili : in std_logic;                    -- '1' indica dati pixel disponibili
            valore_soglia : in std_logic_vector(7 downto 0);    -- Soglia
            -- Output
            pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
            elaborazione_terminata : out std_logic
        );
    end component;
    
    component filtro_luminosita
        port(
            -- Inputs
            clk : in std_logic;
            pixel : in std_logic_vector(7 downto 0);                -- Valore del pixel [0,255]
            dati_disponibili : in std_logic;                        -- '1' indica dati pixel disponibili
            valore_luminosita : in std_logic_vector(7 downto 0);    -- Soglia
            -- Output
            pixel_elaborato : out std_logic_vector(7 downto 0);      -- Valore del pixel elaborato [0,255]
            elaborazione_terminata : out std_logic
        );
    end component;
    
    component mux_4to1_1bit
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
    end component;
    
    signal ingresso_tr : std_logic_vector(7 downto 0);
    signal ingresso_neg : std_logic_vector(7 downto 0);
    signal ingresso_soglia : std_logic_vector(7 downto 0);
    signal ingresso_lum : std_logic_vector(7 downto 0);
    
    signal dd_tr : std_logic;
    signal dd_neg : std_logic;
    signal dd_soglia : std_logic;
    signal dd_lum : std_logic;
    
    signal uscita_tr : std_logic_vector(7 downto 0);
    signal uscita_neg : std_logic_vector(7 downto 0);
    signal uscita_soglia : std_logic_vector(7 downto 0);
    signal uscita_lum : std_logic_vector(7 downto 0);
    
    signal et_tr : std_logic;
    signal et_neg : std_logic;
    signal et_soglia : std_logic;
    signal et_lum : std_logic;
begin
    U1: demux_1to4_8bit
    port map(
        -- Input
        ingresso => dati_ricevitore,
        selezione => switch_selezione,
        -- Output
        tr => ingresso_tr,
        neg => ingresso_neg,
        soglia => ingresso_soglia,
        lum => ingresso_lum
    );
    
    U8: demux_1to4_1bit
    port map(
        -- Input
        ingresso => dati_ricevitore_disponibili,
        selezione => switch_selezione,
        -- Output
        tr => dd_tr,
        neg => dd_neg,
        soglia => dd_soglia,
        lum => dd_lum
    );
    
    U2: filtro_tr
    port map(
        -- Inputs
        clk => clk,
        pixel => ingresso_tr,
        dati_disponibili => dd_tr,
        -- Output
        pixel_elaborato => uscita_tr,
        elaborazione_terminata => et_tr
    );
    
    U3: filtro_negativo
    port map(
        -- Inputs
        clk => clk,
        pixel => ingresso_neg,
        dati_disponibili => dd_neg,
        -- Output
        pixel_elaborato => uscita_neg,
        elaborazione_terminata => et_neg
    );
    
    U4: filtro_soglia
    port map(
        -- Inputs
        clk => clk,
        pixel => ingresso_soglia,
        dati_disponibili => dd_soglia,
        valore_soglia => switch_valore,
        -- Output
        pixel_elaborato => uscita_soglia,
        elaborazione_terminata => et_soglia
    );
    
    U5: filtro_luminosita
    port map(
        -- Inputs
        clk => clk,
        pixel => ingresso_lum,
        dati_disponibili => dd_lum,
        valore_luminosita => switch_valore,
        -- Output
        pixel_elaborato => uscita_lum,
        elaborazione_terminata => et_lum
    );
    
    U6: mux_4to1_8bit
    port map(
        -- Input
        selezione => switch_selezione,
        tr => uscita_tr,
        neg => uscita_neg,
        soglia => uscita_soglia,
        lum => uscita_lum,
        -- Output
        uscita => dati_trasmettitore
    );
    
    U7: mux_4to1_1bit
    port map(
        -- Input
        selezione => switch_selezione,
        tr => et_tr,    
        neg => et_neg,       
        soglia => et_soglia,        
        lum => et_lum,            
        -- Output
        uscita => dati_trasmettitore_disponibili
    );

end Structural;
