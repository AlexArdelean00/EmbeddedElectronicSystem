library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ricevitore_uart is
    port(
        -- Input
        clk                 : in std_logic;
        RsRx                : in std_logic;
        -- Output
        dati_out            : out std_logic_vector(7 downto 0); 
        dati_disponibili    : out std_logic
    );
end ricevitore_uart;

architecture Behavioral of ricevitore_uart is
    constant f_clock : integer := 100000000;                -- 100.000.000 Hz = 100 MHz
    constant f_baud : integer := 4000000;                   -- 4.000.000 bit/s
    constant campioni_per_baud : integer := f_clock/f_baud; -- 25 cicli di clock ogni bit
    
    type stato_t is (attesa, start, ricezione, stop);
    signal stato : stato_t := attesa;
    
    signal buffer_ricezione : std_logic_vector(7 downto 0) := (others => '1');
begin
    -- Gestisce lo stato della macchina
    process(clk)
        variable contatore_campioni : integer range 0 to campioni_per_baud-1 := 0;
        variable contatore_bit : integer range 0 to 7 := 0;
    begin
        if(rising_edge(clk)) then
            case stato is
                when attesa =>
                    -- Un 1 sulla linea di ricezione indica nessun dato presente
                    if(RsRx = '1') then
                        stato <= attesa;
                    -- Uno 0 sulla linea di ricezione indica l'inizio della ricezione
                    else
                        stato <= start;
                        contatore_campioni := 1;
                    end if;
                when start =>
                    -- Centro del bit di start non ancora raggiunto
                    --  NOTA: il -1 e' necessario perche' il contatore parte da 0
                    if(contatore_campioni < campioni_per_baud/2-1) then
                        stato <= start;
                        contatore_campioni := contatore_campioni + 1;
                    -- Centro del bit di start raggiunto
                    else
                        stato <= ricezione;
                        contatore_campioni := 0;
                    end if;
                when ricezione =>
                    -- Centro del bit utile non ancora raggiunto
                    if(contatore_campioni < campioni_per_baud-1) then
                        stato <= ricezione;
                        contatore_campioni := contatore_campioni + 1;
                    -- Centro del bit utile raggiunto
                    else
                        contatore_campioni := 0;
                        -- Ci sono ancora bit da ricevere
                        if(contatore_bit < 7) then
                            buffer_ricezione <= RsRx & buffer_ricezione(7 downto 1);
                            stato <= ricezione;
                            contatore_bit := contatore_bit + 1;
                        -- Ricevuti 8 bit
                        else
                            buffer_ricezione <= RsRx & buffer_ricezione(7 downto 1);
                            stato <= stop;
                            contatore_bit := 0;
                        end if;
                    end if;
                when stop =>
                    -- Centro del bit di stop non ancora raggiunto
                    if(contatore_campioni < campioni_per_baud-1) then
                        stato <= stop;
                        contatore_campioni := contatore_campioni + 1;
                    -- Centro del bit di stop raggiunto
                    else 
                        stato <= attesa;
                        contatore_campioni := 0;
                    end if;
            end case;
        end if;
    end process;
    
    -- Gestisce l'output della macchina
    process(stato)
    begin
        case stato is
            -- Finche' non riceve il bit di stop i dati in uscita non sono validi
            when attesa =>
                dati_disponibili <= '0';
            when start =>
                dati_disponibili <= '0';
            when ricezione =>
                dati_disponibili <= '0';
            -- Bit di stop ricevuto => dati in uscita validi
            when stop =>
                dati_disponibili <= '1';  
        end case;
        dati_out <= buffer_ricezione;
    end process;
end Behavioral;
