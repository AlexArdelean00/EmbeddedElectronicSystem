library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity trasmettitore_uart is
    port(
        -- Input
        clk                     : in std_logic;
        abilita_trasmissione    : in std_logic;
        dati_in                 : in std_logic_vector(7 downto 0);
        -- Output
        RsTx                    : out std_logic
    );
end trasmettitore_uart;

architecture Behavioral of trasmettitore_uart is
    constant f_clock : integer := 100000000;                -- 100.000.000 Hz = 100 MHz
    constant f_baud : integer := 4000000;                   -- 4.000.000 bit/s
    constant campioni_per_baud : integer := f_clock/f_baud; -- 25 cicli di clock ogni bit
    
    type stato_t is (attesa, start, trasmissione, stop);
    signal stato : stato_t := attesa;
    
    signal buffer_trasmissione : std_logic_vector(7 downto 0) := (others => '0');
begin
    -- Gestisce lo stato della macchina
    process(clk)
        variable contatore_campioni : integer range 0 to campioni_per_baud-1 := 0;
        variable contatore_bit : integer range 0 to 7 := 0;
    begin
        if(rising_edge(clk)) then
            case stato is
                when attesa =>
                    -- Attende segnale di abilitazione della trasmissione
                    if(abilita_trasmissione = '0') then
                        stato <= attesa;
                    -- Segnale di abilitazione della trasmissione ricevuto
                    else
                        stato <= start;
                        contatore_campioni := 1;
                    end if;
                when start =>
                    -- Trasmette il bit di start 
                    if(contatore_campioni < campioni_per_baud-1) then
                        stato <= start;
                        contatore_campioni := contatore_campioni + 1;
                        buffer_trasmissione <= dati_in;
                    -- Bit di start trasmesso
                    else
                        stato <= trasmissione;
                        contatore_campioni := 0;        
                    end if;      
                when trasmissione =>
                    -- Trasmette il bit utile
                    if(contatore_campioni < campioni_per_baud-1) then
                        stato <= trasmissione;
                        contatore_campioni := contatore_campioni + 1;
                    -- Controlla se ci sono ancora bit da trasmettere
                    else
                        contatore_campioni := 0;
                        -- Ci sono ancora bit da trasmettere
                        if(contatore_bit < 7) then
                            stato <= trasmissione;
                            contatore_bit := contatore_bit + 1;   
                            buffer_trasmissione <= '0' & buffer_trasmissione(7 downto 1); 
                        -- Trasmessi 8 bit
                        else
                            stato <= stop;
                            contatore_bit := 0;  
                        end if;
                    end if; 
                when stop =>
                    -- Trasmette il bit di stop
                    if(contatore_campioni < campioni_per_baud-1) then
                        stato <= stop;
                        contatore_campioni := contatore_campioni + 1;
                    -- Bit di stop trasmesso
                    else
                        -- Segnale di abilitazione non ricevuto
                        if(abilita_trasmissione = '0') then
                            stato <= attesa;
                            contatore_campioni := 0;
                        -- Segnale di abilitazione della trasmissione ricevuto
                        else
                            stato <= start;
                            contatore_campioni := 0;
                        end if;       
                    end if; 
            end case;
        end if;
    end process;
    
    -- Gestisce l'output della macchina
    process(clk)
    begin
        if(rising_edge(clk)) then
            case stato is
                -- In attesa imposta la linea alta
                when attesa =>
                    RsTx <= '1';
                -- Trasmette il bit di start '0'
                when start =>
                    RsTx <= '0';
                -- Trasmette i dati utili
                when trasmissione =>
                    RsTx <= buffer_trasmissione(0);
                -- Trasmette il bit di stop '1'
                when stop =>
                    RsTx <= '1';
            end case;
        end if;
    end process;
end Behavioral;
