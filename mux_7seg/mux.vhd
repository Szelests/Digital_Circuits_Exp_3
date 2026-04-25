--------------------------------------------------------------------------------
-- Project :
-- File    :
-- Autor   :
-- Date    :
--
--------------------------------------------------------------------------------
-- Description :
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux IS
  PORT (
	SW 	: in  std_logic_vector(3 downto 0); -- Chaves de A(0) até D(3)
	HEX0 : out std_logic_vector(6 downto 0) -- Segmentos de a(6) até g(0)
    );
END mux;

--------------------------------------------------------------------------------
-- MUX logic
--------------------------------------------------------------------------------

ARCHITECTURE TypeArchitecture OF mux IS

	-- Cria um tipo que é um array do qual cada elemento contém um vetor de 7 bits
	type display_rom is array (0 to 15) of std_logic_vector(6 downto 0); 

	-- Preenche a lista com a tabela verdade
	constant MAPA_7SEG : display_rom := (
	   "1111110", -- Índice 0 (Hex 0)
        "0110000", -- Índice 1 (Hex 1)
        "1101101", -- Índice 2 (Hex 2)
        "1111001", -- Índice 3 (Hex 3)
        "0110011", -- Índice 4 (Hex 4)
        "1011011", -- Índice 5 (Hex 5)
        "1011111", -- Índice 6 (Hex 6)
        "1110000", -- Índice 7 (Hex 7)
        "1111111", -- Índice 8 (Hex 8)
        "1111011", -- Índice 9 (Hex 9)
        "1110111", -- Índice 10 (Hex A)
        "0011111", -- Índice 11 (Hex B)
        "1001110", -- Índice 12 (Hex C)
        "0111101", -- Índice 13 (Hex D)
        "1111011", -- Índice 14 (Hex E -> O dígito '9')
        "0111100"  -- Índice 15 (Hex F -> A letra 'J')		
	);
	
    -- CRIA O FIO INTERMEDIÁRIO 
    signal sw_invertido : std_logic_vector(3 downto 0);

BEGIN

	sw_invertido <= not SW;

	-- Pegamos os 4 bits da chave física (SW), transformamos em número inteiro 
     -- e jogamos o resultado da tabela direto para os pinos do display (HEX0)
	HEX0 <= MAPA_7SEG(to_integer(unsigned(sw_invertido)));

END TypeArchitecture;
