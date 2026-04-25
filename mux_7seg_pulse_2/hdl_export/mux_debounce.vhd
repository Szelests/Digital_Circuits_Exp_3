LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux_debounce IS
  PORT (
    clock_50MHz : in  std_logic; -- Clock da placa
    CLK_BTN     : in  std_logic; -- 1 bit (Fio único do botão)
    CLEAR       : in  std_logic; -- 1 bit (Fio único do botão)
    HEX0  	 : out std_logic_vector(6 downto 0) -- 7 bits (Segmentos)
  );
END mux_debounce;

--------------------------------------------------------------------------------
-- MUX logic
--------------------------------------------------------------------------------

ARCHITECTURE RTL OF mux_debounce IS

    -- Array da ROM (Display)
    type display_rom is array (0 to 15) of std_logic_vector(6 downto 0); 

    constant MAPA_7SEG : display_rom := (
        "1111110", -- 0
        "0110000", -- 1
        "1101101", -- 2
        "1111001", -- 3
        "0110011", -- 4
        "1011011", -- 5
        "1011111", -- 6
        "1110000", -- 7
        "1111111", -- 8
        "1111011", -- 9
        "1110111", -- A
        "0011111", -- B
        "1001110", -- C
        "0111101", -- D
        "1111011", -- E (Dígito 9)
        "0111100"  -- F (Letra J)        
    );
    
    -- Fios internos 
    signal clock_btn_inv : std_logic; -- Botão de clock invertido
    signal clear_btn_inv : std_logic; -- Botão de clear invertido
    signal pulse_cleared : std_logic; -- Pulso limpo
    signal count : unsigned(3 downto 0) := "0000";

    -- Declarando componente de Deobouncer
	COMPONENT debouncer IS
        PORT ( CLOCK, BTN_IN : in std_logic; BTN_OUT : out std_logic );
     END COMPONENT;
    
BEGIN

    -- Inversão da lógica active-low dos botões físicos
    clear_btn_inv  <= not CLEAR;

    -- Conectando a caixinha: Entra o botão sujo, sai o botão limpo.
    -- O 'clk_50MHz' faz a matemática do tempo.
    U1: debouncer PORT MAP (
        CLOCK   => clock_50MHz,
        BTN_IN  => CLK_BTN,
        BTN_OUT => pulse_cleared
    );

    clock_btn_inv <= not pulse_cleared;
    

    -- O ideal é que a lista de sensibilidade monitore os sinais que ela realmente testa
    process(clock_btn_inv, clear_btn_inv)
    begin 
        -- Zera assincronamente se o botão Clear for apertado
        if clear_btn_inv = '1' then
            count <= "0000";
    
        -- Senão, detecta a batida do relógio (Quando APERTA o botão físico)
        elsif rising_edge(clock_btn_inv) then
            count <= count + 1;
        end if;
    end process;
        
    -- Converte a contagem para integer para poder achar a "gaveta" correta da ROM
    HEX0 <= MAPA_7SEG(to_integer(count));

END RTL;