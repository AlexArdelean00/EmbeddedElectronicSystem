library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtro_immagine_tb is
end filtro_immagine_tb;

architecture Behavioral of filtro_immagine_tb is
    component filtro_immagine
        port(
            -- Input
            clk : in std_logic;                                 -- Clock di sitema
            RsRx : in std_logic;                                -- Linea in ingresso seriale
            switch_valore : in std_logic_vector(7 downto 0);    -- Controllano la soglia o la luminosità
            switch_selezione : in std_logic_vector(1 downto 0); -- Selezionano il filtro
            -- Output
            RsTx : out std_logic                                -- Linea in uscita seriale
        );
    end component;
    
    signal clk_tb : std_logic := '0';
    signal RsRx_tb : std_logic := '0';
    signal switch_valore_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal switch_selezione_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal RsTx_tb : std_logic := '0';
    
    constant f_clock : integer := 100000000;                -- 100.000.000 Hz = 100 MHz
    constant f_baud : integer := 4000000;                   -- 4.000.000 bit/s
    constant campioni_per_baud : integer := f_clock/f_baud; -- 25 cicli di clock ogni bit
    constant p_clock : time := 1sec/f_clock;
    constant p_baud : time := 1sec/f_baud;
begin
    U1: filtro_immagine
    port map(
        -- Input
        clk => clk_tb,
        RsRx => RsRx_tb,
        switch_valore => switch_valore_tb,
        switch_selezione => switch_selezione_tb,
        -- Output
        RsTx => RsTx_tb
    );
    
    gen_clock: process
    begin
        wait for p_clock/2;
        clk_tb <= '0';
        wait for p_clock/2;
        clk_tb <= '1';
    end process;
    
    sim_rsrx: process
        variable byte : std_logic_vector(7 downto 0) := (others => '0');
    begin
        RsRx_tb <= '1';
        wait for p_baud*5;
        switch_valore_tb <= "01000000";
        for sel in 0 to 3 loop
            switch_selezione_tb <= std_logic_vector(to_unsigned(sel, 2));
            for i in 0 to 255 loop
                byte := std_logic_vector(to_unsigned(i, 8));
                -- Bit di start
                RsRx_tb <= '0';
                wait for p_baud;
                -- 8 bit utili
                for j in 0 to 7 loop
                    RsRx_tb <= byte(j);
                    wait for p_baud;
                end loop;
                -- Bit di stop
                RsRx_tb <= '1';
                wait for p_baud;
            end loop;
        end loop;
        wait;
    end process;
end Behavioral;
