LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY debouncer IS
  GENERIC (
        -- Tempo necessário para confirmar a estabilidade.
        -- Para 50MHz, 1.000.000 de ciclos = 20 milissegundos.
        TEMPO_MAX : integer := 1000000
  );
  
  PORT (
	CLOCK   : in std_logic; -- Clock de 50MHz da placa
	BTN_IN  : in std_logic; -- Sinal "sujo" 
	BTN_OUT : out std_logic -- Sinal "limpo"
    );
END debouncer;

--------------------------------------------------------------------------------
-- DEBOUNCER LOGIC
--------------------------------------------------------------------------------

ARCHITECTURE RTL OF debouncer IS
	-- Contador que conta de 0 até o tempo máximo estipulado em clocks
	signal counter : integer range 0 to TEMPO_MAX := 0;
	-- Guarda qual é o estado limpo atual (0 ou 1)
	signal clean_state : std_logic :=  '0';

BEGIN

	process(CLOCK)
	-- Se o botão físico estiver diferente do estado que consideramos "limpo"
	begin
		if rising_edge(CLOCK) then
			if BTN_IN /= clean_state then
				counter <= counter + 1;
	
				if counter = TEMPO_MAX then
					clean_state <= BTN_IN;
					counter <= 0;
				end if;
			else 
				-- Se ele trepidar no meio da contagem, ou se já forem iguais, zera o timer
	                counter <= 0;
	                
	          end if;
	     end if;
     end process;

     BTN_OUT <= clean_state;
			
END RTL;
