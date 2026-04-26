LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux_counter_alone IS
  GENERIC (
        -- Tempo necessário para confirmar a estabilidade.
        -- Para 50MHz, 50.000.000 de ciclos = 1000 milissegundos ou 1 segundo.
        TEMPO_1S : integer := 50000000
  );

  PORT (
    clock_50MHz : in  std_logic; -- Clock da placa
    START       : in  std_logic; -- 1 bit (Fio único do botão)
    CLEAR       : in  std_logic; -- 1 bit (Fio único do botão)
    HEX0  	 : out std_logic_vector(6 downto 0) -- 7 bits (Segmentos)
  );
END mux_counter_alone;

--------------------------------------------------------------------------------
-- MUX logic
--------------------------------------------------------------------------------

ARCHITECTURE RTL OF mux_counter_alone IS

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
    signal start_inv     : std_logic; -- Botão de clock invertido
    signal clear_inv     : std_logic; -- Botão de clear invertido
    signal pulse_cleared : std_logic; -- Pulso limpo
    signal count         : unsigned(3 downto 0) := "0000";
    -- Contador que conta de 0 até o tempo de um segundo segundo o clock 
    signal counter       : integer range 0 to TEMPO_1S := 0;
    -- Memória do botão
    signal pause         : std_logic := '0'; -- 0 = rodando, 1 = pausado
    signal previous_state: std_logic := '1'; -- Memória para detectar clique

    -- Declarando componente de Deobouncer
	COMPONENT debouncer IS
        PORT ( CLOCK, BTN_IN : in std_logic; BTN_OUT : out std_logic );
     END COMPONENT;
    
BEGIN

    -- Inversão da lógica active-low dos botões físicos
    clear_inv  <= not CLEAR;

    -- Conectando a caixinha: Entra o botão sujo, sai o botão limpo.
    -- O 'clk_50MHz' faz a matemática do tempo.
    U1: debouncer PORT MAP (
        CLOCK   => clock_50MHz,
        BTN_IN  => START,
        BTN_OUT => pulse_cleared
    );

    start_inv <= not pulse_cleared;
    
    process(clock_50MHz, clear_inv)
    begin 
	   -- Rset
	   if clear_inv = '1' then
	       count <= "0000";
 		  counter <= 0;
 		  pause <= '0';
 		  previous_state <= '1';

	   -- Motor do clock
	   elsif rising_edge(clock_50MHz) then

		 -- ====================================================
           -- BLOCO A: Detecção do Botão (Toggle Play/Pause)
           -- ====================================================
		if previous_state = '0' and start_inv = '1' then
			pause <= not pause;
          end if;
		previous_state <= start_inv;


		 -- ====================================================
           -- BLOCO B: O Cronômetro (O Clock Enable)
           -- ====================================================
           if pause = '0' then
		 	 if counter = TEMPO_1S -1 then
	      		count <= count + 1;
	      		counter <= 0;
	      	else
	      		counter <= counter + 1;
	      	end if;
	      end if;
	   end if;
    end process;
        
    -- Converte a contagem para integer para poder achar a "gaveta" correta da ROM
    HEX0 <= MAPA_7SEG(to_integer(count));

END RTL;