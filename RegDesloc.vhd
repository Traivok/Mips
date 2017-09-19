--------------------------------------------------------------------------------
-- Title		: Registrador de Deslocamento
-- Project		: CPU Multi-ciclo
--------------------------------------------------------------------------------
-- File			: RegDesloc.vhd
-- Author		: Emannuel Gomes Mac�do <egm@cin.ufpe.br>
--				  Fernando Raposo Camara da Silva <frcs@cin.ufpe.br>
--				  Pedro Machado Manh�es de Castro <pmmc@cin.ufpe.br>
--				  Rodrigo Alves Costa <rac2@cin.ufpe.br>
-- Organization : Universidade Federal de Pernambuco
-- Created		: 10/07/2002
-- Last update	: 26/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade respons�vel pelo deslocamento de um vetor de 32 
--                bits para a direita e para a esquerda. 
--				  Entradas:
--				  	* N: vetor de 3 bits que indica a quantidade de 
--					deslocamentos   
--				  	* Shift: vetor de 3 bits que indica a fun��o a ser 
--					realizada pelo registrador   
--				  Abaixo seguem os valores referentes � entrada shift e as 
--                respectivas fun��es do registrador: 
--				  
--				  Shift					FUN��O DO REGISTRADOR
--				  000					faz nada
--				  001					carrega vetor (sem deslocamentos)
--				  010					deslocamento � esquerda n vezes
--				  011					deslocamento � direita l�gico n vezes
--				  100					deslocamento � direita aritm�tico n vezes
--				  101					rota��o � direita n vezes
--				  110					rota��o � esquerda n vezes
--------------------------------------------------------------------------------
-- Copyright (c) notice
--		Universidade Federal de Pernambuco (UFPE).
--		CIn - Centro de Informatica.
--		Developed by computer science undergraduate students.
--		This code may be used for educational and non-educational purposes as 
--		long as its copyright notice remains unchanged. 
--------------------------------------------------------------------------------
-- Revisions		: 2
-- Revision Number	: 2.0
-- Version			: 1.2
-- Date				: 26/11/2002
-- Modifier			: Marcus Vinicius Lima e Machado <mvlm@cin.ufpe.br>
--				  	  Paulo Roberto Santana Oliveira Filho <prsof@cin.ufpe.br>
--					  Viviane Cristina Oliveira Aureliano <vcoa@cin.ufpe.br>
-- Description		:
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 3
-- Revision Number	: 1.2
-- Version			: 1.3
-- Date				: 08/08/2008
-- Modifier			: Jo�o Paulo Fernandes Barbosa (jpfb@cin.ufpe.br)
-- Description		: Os sinais de entrada e sa�da passam a ser do tipo std_logic.
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Short name: desl
ENTITY RegDesloc IS
		PORT(
			Clk		: IN	STD_LOGIC;	-- Clock do sistema
		 	Reset	: IN	STD_LOGIC;	-- Reset
			Shift 	: IN	STD_LOGIC_vector (2 downto 0);	-- Fun��o a ser realizada pelo registrador 
			N		: IN	STD_LOGIC_vector (4 downto 0);	-- Quantidade de deslocamentos
			Entrada : IN	STD_LOGIC_vector (31 downto 0);	-- Vetor a ser deslocado
			Saida	: OUT	STD_LOGIC_vector (31 downto 0)	-- Vetor deslocado
		);
END RegDesloc;

-- Arquitetura que define o comportamento do registrador de deslocamento
-- Simulation
ARCHITECTURE behavioral_arch OF RegDesloc IS
	
	signal temp		: STD_LOGIC_vector (31 downto 0);	-- Vetor tempor�rio
	
	begin

	-- Clocked process
	process (Clk, Reset)
		begin
			if(Reset = '1') then
				temp <= "00000000000000000000000000000000";

			elsif (Clk = '1' and Clk'event) then
				case Shift is
					when "000" => 						-- Faz nada
						temp <= temp;
					when "001" => 						-- Carrega vetor de entrada, n�o faz deslocamentos
						temp <= Entrada;
					when "010" =>						-- Deslocamento � esquerda N vezes
						case N is
							when "00000" =>				-- Deslocamento � esquerda nenhuma vez
								temp <= temp;
							when "00001" =>
								temp(0 downto 0) <= "0";
								temp(31 downto 1) <= temp(30 downto 0);
							when "00010" =>
								temp(1 downto 0) <= "00";
								temp(31 downto 2) <= temp(29 downto 0);
							when "00011" =>
								temp(2 downto 0) <= "000";
								temp(31 downto 3) <= temp(28 downto 0);
							when "00100" =>
								temp(3 downto 0) <= "0000";
								temp(31 downto 4) <= temp(27 downto 0);
							when "00101" =>
								temp(4 downto 0) <= "00000";
								temp(31 downto 5) <= temp(26 downto 0);
							when "00110" =>
								temp(5 downto 0) <= "000000";
								temp(31 downto 6) <= temp(25 downto 0);
							when "00111" =>
								temp(6 downto 0) <= "0000000";
								temp(31 downto 7) <= temp(24 downto 0);
							when "01000" =>
								temp(7 downto 0) <= "00000000";
								temp(31 downto 8) <= temp(23 downto 0);
							when "01001" =>
								temp(8 downto 0) <= "000000000";
								temp(31 downto 9) <= temp(22 downto 0);
							when "01010" =>
								temp(9 downto 0) <= "0000000000";
								temp(31 downto 10) <= temp(21 downto 0);
							when "01011" =>
								temp(10 downto 0) <= "00000000000";
								temp(31 downto 11) <= temp(20 downto 0);
							when "01100" =>
								temp(11 downto 0) <= "000000000000";
								temp(31 downto 12) <= temp(19 downto 0);
							when "01101" =>
								temp(12 downto 0) <= "0000000000000";
								temp(31 downto 13) <= temp(18 downto 0);
							when "01110" =>
								temp(13 downto 0) <= "00000000000000";
								temp(31 downto 14) <= temp(17 downto 0);
							when "01111" =>
								temp(14 downto 0) <= "000000000000000";
								temp(31 downto 15) <= temp(16 downto 0);
							when "10000" =>
								temp(15 downto 0) <= "0000000000000000";
								temp(31 downto 16) <= temp(15 downto 0);
							when "10001" =>
								temp(16 downto 0) <= "00000000000000000";
								temp(31 downto 17) <= temp(14 downto 0);
							when "10010" =>
								temp(17 downto 0) <= "000000000000000000";
								temp(31 downto 18) <= temp(13 downto 0);
							when "10011" =>
								temp(18 downto 0) <= "0000000000000000000";
								temp(31 downto 19) <= temp(12 downto 0);
							when "10100" =>
								temp(19 downto 0) <= "00000000000000000000";
								temp(31 downto 20) <= temp(11 downto 0);
							when "10101" =>
								temp(20 downto 0) <= "000000000000000000000";
								temp(31 downto 21) <= temp(10 downto 0);
							when "10110" =>
								temp(21 downto 0) <= "0000000000000000000000";
								temp(31 downto 22) <= temp(9 downto 0);
							when "10111" =>
								temp(22 downto 0) <= "00000000000000000000000";
								temp(31 downto 23) <= temp(8 downto 0);
							when "11000" =>
								temp(23 downto 0) <= "000000000000000000000000";
								temp(31 downto 24) <= temp(7 downto 0);
							when "11001" =>
								temp(24 downto 0) <= "0000000000000000000000000";
								temp(31 downto 25) <= temp(6 downto 0);
							when "11010" =>
								temp(25 downto 0) <= "00000000000000000000000000";
								temp(31 downto 26) <= temp(5 downto 0);
							when "11011" =>
								temp(26 downto 0) <= "000000000000000000000000000";
								temp(31 downto 27) <= temp(4 downto 0);
							when "11100" =>
								temp(27 downto 0) <= "0000000000000000000000000000";
								temp(31 downto 28) <= temp(3 downto 0);
							when "11101" =>
								temp(28 downto 0) <= "00000000000000000000000000000";
								temp(31 downto 29) <= temp(2 downto 0);
							when "11110" =>
								temp(29 downto 0) <= "000000000000000000000000000000";
								temp(31 downto 30) <= temp(1 downto 0);
							when "11111" =>
								temp(30 downto 0) <= "0000000000000000000000000000000";
								temp(31 downto 31) <= temp(0 downto 0);
						end case;

					-- Deslocamento � direita l�gico N vezes
					when "011" =>						
						case n is
							when "00000" =>				-- Deslocamento � direita l�gico nenhuma vez
								temp <= temp;
							when "00001" =>
                                temp(30 downto 0) <= temp(31 downto 1);
                                temp(31 downto 31) <= "0";
                            when "00010" =>
                                temp(29 downto 0) <= temp(31 downto 2);
                                temp(31 downto 30) <= "00";
                            when "00011" =>
                                temp(28 downto 0) <= temp(31 downto 3);
                                temp(31 downto 29) <= "000";
                            when "00100" =>
                                temp(27 downto 0) <= temp(31 downto 4);
                                temp(31 downto 28) <= "0000";
                            when "00101" =>
                                temp(26 downto 0) <= temp(31 downto 5);
                                temp(31 downto 27) <= "00000";
                            when "00110" =>
                                temp(25 downto 0) <= temp(31 downto 6);
                                temp(31 downto 26) <= "000000";
                            when "00111" =>
                                temp(24 downto 0) <= temp(31 downto 7);
                                temp(31 downto 25) <= "0000000";
                            when "01000" =>
                                temp(23 downto 0) <= temp(31 downto 8);
                                temp(31 downto 24) <= "00000000";
                            when "01001" =>
                                temp(22 downto 0) <= temp(31 downto 9);
                                temp(31 downto 23) <= "000000000";
                            when "01010" =>
                                temp(21 downto 0) <= temp(31 downto 10);
                                temp(31 downto 22) <= "0000000000";
                            when "01011" =>
                                temp(20 downto 0) <= temp(31 downto 11);
                                temp(31 downto 21) <= "00000000000";
                            when "01100" =>
                                temp(19 downto 0) <= temp(31 downto 12);
                                temp(31 downto 20) <= "000000000000";
                            when "01101" =>
                                temp(18 downto 0) <= temp(31 downto 13);
                                temp(31 downto 19) <= "0000000000000";
                            when "01110" =>
                                temp(17 downto 0) <= temp(31 downto 14);
                                temp(31 downto 18) <= "00000000000000";
                            when "01111" =>
                                temp(16 downto 0) <= temp(31 downto 15);
                                temp(31 downto 17) <= "000000000000000";
                            when "10000" =>
                                temp(15 downto 0) <= temp(31 downto 16);
                                temp(31 downto 16) <= "0000000000000000";
                            when "10001" =>
                                temp(14 downto 0) <= temp(31 downto 17);
                                temp(31 downto 15) <= "00000000000000000";
                            when "10010" =>
                                temp(13 downto 0) <= temp(31 downto 18);
                                temp(31 downto 14) <= "000000000000000000";
                            when "10011" =>
                                temp(12 downto 0) <= temp(31 downto 19);
                                temp(31 downto 13) <= "0000000000000000000";
                            when "10100" =>
                                temp(11 downto 0) <= temp(31 downto 20);
                                temp(31 downto 12) <= "00000000000000000000";
                            when "10101" =>
                                temp(10 downto 0) <= temp(31 downto 21);
                                temp(31 downto 11) <= "000000000000000000000";
                            when "10110" =>
                                temp(9 downto 0) <= temp(31 downto 22);
                                temp(31 downto 10) <= "0000000000000000000000";
                            when "10111" =>
                                temp(8 downto 0) <= temp(31 downto 23);
                                temp(31 downto 9) <= "00000000000000000000000";
                            when "11000" =>
                                temp(7 downto 0) <= temp(31 downto 24);
                                temp(31 downto 8) <= "000000000000000000000000";
                            when "11001" =>
                                temp(6 downto 0) <= temp(31 downto 25);
                                temp(31 downto 7) <= "0000000000000000000000000";
                            when "11010" =>
                                temp(5 downto 0) <= temp(31 downto 26);
                                temp(31 downto 6) <= "00000000000000000000000000";
                            when "11011" =>
                                temp(4 downto 0) <= temp(31 downto 27);
                                temp(31 downto 5) <= "000000000000000000000000000";
                            when "11100" =>
                                temp(3 downto 0) <= temp(31 downto 28);
                                temp(31 downto 4) <= "0000000000000000000000000000";
                            when "11101" =>
                                temp(2 downto 0) <= temp(31 downto 29);
                                temp(31 downto 3) <= "00000000000000000000000000000";
                            when "11110" =>
                                temp(1 downto 0) <= temp(31 downto 30);
                                temp(31 downto 2) <= "000000000000000000000000000000";
                            when "11111" =>
                                temp(0 downto 0) <= temp(31 downto 31);
                                temp(31 downto 1) <= "0000000000000000000000000000000";
						end case;

					-- Deslocamento � direita aritm�tico N vezes
					when "100" =>						
						case n is
							when "00000" =>
                                temp(31 downto 0) <= temp(31 downto 0);
                                temp(31) <= temp(31);
                            when "00001" =>
                                temp(30 downto 0) <= temp(31 downto 1);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                            when "00010" =>
                                temp(29 downto 0) <= temp(31 downto 2);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                            when "00011" =>
                                temp(28 downto 0) <= temp(31 downto 3);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                            when "00100" =>
                                temp(27 downto 0) <= temp(31 downto 4);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                            when "00101" =>
                                temp(26 downto 0) <= temp(31 downto 5);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                            when "00110" =>
                                temp(25 downto 0) <= temp(31 downto 6);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                            when "00111" =>
                                temp(24 downto 0) <= temp(31 downto 7);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                            when "01000" =>
                                temp(23 downto 0) <= temp(31 downto 8);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                            when "01001" =>
                                temp(22 downto 0) <= temp(31 downto 9);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                            when "01010" =>
                                temp(21 downto 0) <= temp(31 downto 10);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                            when "01011" =>
                                temp(20 downto 0) <= temp(31 downto 11);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                            when "01100" =>
                                temp(19 downto 0) <= temp(31 downto 12);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                            when "01101" =>
                                temp(18 downto 0) <= temp(31 downto 13);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                            when "01110" =>
                                temp(17 downto 0) <= temp(31 downto 14);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                            when "01111" =>
                                temp(16 downto 0) <= temp(31 downto 15);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                            when "10000" =>
                                temp(15 downto 0) <= temp(31 downto 16);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                            when "10001" =>
                                temp(14 downto 0) <= temp(31 downto 17);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                            when "10010" =>
                                temp(13 downto 0) <= temp(31 downto 18);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                            when "10011" =>
                                temp(12 downto 0) <= temp(31 downto 19);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                            when "10100" =>
                                temp(11 downto 0) <= temp(31 downto 20);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                            when "10101" =>
                                temp(10 downto 0) <= temp(31 downto 21);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                            when "10110" =>
                                temp(9 downto 0) <= temp(31 downto 22);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                            when "10111" =>
                                temp(8 downto 0) <= temp(31 downto 23);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                            when "11000" =>
                                temp(7 downto 0) <= temp(31 downto 24);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                            when "11001" =>
                                temp(6 downto 0) <= temp(31 downto 25);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                            when "11010" =>
                                temp(5 downto 0) <= temp(31 downto 26);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                            when "11011" =>
                                temp(4 downto 0) <= temp(31 downto 27);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                                temp(4) <= temp(31);
                            when "11100" =>
                                temp(3 downto 0) <= temp(31 downto 28);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                                temp(4) <= temp(31);
                                temp(3) <= temp(31);
                            when "11101" =>
                                temp(2 downto 0) <= temp(31 downto 29);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                                temp(4) <= temp(31);
                                temp(3) <= temp(31);
                                temp(2) <= temp(31);
                            when "11110" =>
                                temp(1 downto 0) <= temp(31 downto 30);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                                temp(4) <= temp(31);
                                temp(3) <= temp(31);
                                temp(2) <= temp(31);
                                temp(1) <= temp(31);
                            when "11111" =>
                                temp(0 downto 0) <= temp(31 downto 31);
                                temp(31) <= temp(31);
                                temp(30) <= temp(31);
                                temp(29) <= temp(31);
                                temp(28) <= temp(31);
                                temp(27) <= temp(31);
                                temp(26) <= temp(31);
                                temp(25) <= temp(31);
                                temp(24) <= temp(31);
                                temp(23) <= temp(31);
                                temp(22) <= temp(31);
                                temp(21) <= temp(31);
                                temp(20) <= temp(31);
                                temp(19) <= temp(31);
                                temp(18) <= temp(31);
                                temp(17) <= temp(31);
                                temp(16) <= temp(31);
                                temp(15) <= temp(31);
                                temp(14) <= temp(31);
                                temp(13) <= temp(31);
                                temp(12) <= temp(31);
                                temp(11) <= temp(31);
                                temp(10) <= temp(31);
                                temp(9) <= temp(31);
                                temp(8) <= temp(31);
                                temp(7) <= temp(31);
                                temp(6) <= temp(31);
                                temp(5) <= temp(31);
                                temp(4) <= temp(31);
                                temp(3) <= temp(31);
                                temp(2) <= temp(31);
                                temp(1) <= temp(31);
                                temp(0) <= temp(31);
						end case;

					-- Rota��o � direita N vezes
					when "101" =>						
						case n is
							when "00000" =>				-- Rota��o � direita nenhuma vez
								temp <= temp;
							when "00001" =>
                                temp(30 downto 0) <= temp(31 downto 1);
                                temp(31 downto 31) <= temp(0 downto 0);
                            when "00010" =>
                                temp(29 downto 0) <= temp(31 downto 2);
                                temp(31 downto 30) <= temp(1 downto 0);
                            when "00011" =>
                                temp(28 downto 0) <= temp(31 downto 3);
                                temp(31 downto 29) <= temp(2 downto 0);
                            when "00100" =>
                                temp(27 downto 0) <= temp(31 downto 4);
                                temp(31 downto 28) <= temp(3 downto 0);
                            when "00101" =>
                                temp(26 downto 0) <= temp(31 downto 5);
                                temp(31 downto 27) <= temp(4 downto 0);
                            when "00110" =>
                                temp(25 downto 0) <= temp(31 downto 6);
                                temp(31 downto 26) <= temp(5 downto 0);
                            when "00111" =>
                                temp(24 downto 0) <= temp(31 downto 7);
                                temp(31 downto 25) <= temp(6 downto 0);
                            when "01000" =>
                                temp(23 downto 0) <= temp(31 downto 8);
                                temp(31 downto 24) <= temp(7 downto 0);
                            when "01001" =>
                                temp(22 downto 0) <= temp(31 downto 9);
                                temp(31 downto 23) <= temp(8 downto 0);
                            when "01010" =>
                                temp(21 downto 0) <= temp(31 downto 10);
                                temp(31 downto 22) <= temp(9 downto 0);
                            when "01011" =>
                                temp(20 downto 0) <= temp(31 downto 11);
                                temp(31 downto 21) <= temp(10 downto 0);
                            when "01100" =>
                                temp(19 downto 0) <= temp(31 downto 12);
                                temp(31 downto 20) <= temp(11 downto 0);
                            when "01101" =>
                                temp(18 downto 0) <= temp(31 downto 13);
                                temp(31 downto 19) <= temp(12 downto 0);
                            when "01110" =>
                                temp(17 downto 0) <= temp(31 downto 14);
                                temp(31 downto 18) <= temp(13 downto 0);
                            when "01111" =>
                                temp(16 downto 0) <= temp(31 downto 15);
                                temp(31 downto 17) <= temp(14 downto 0);
                            when "10000" =>
                                temp(15 downto 0) <= temp(31 downto 16);
                                temp(31 downto 16) <= temp(15 downto 0);
                            when "10001" =>
                                temp(14 downto 0) <= temp(31 downto 17);
                                temp(31 downto 15) <= temp(16 downto 0);
                            when "10010" =>
                                temp(13 downto 0) <= temp(31 downto 18);
                                temp(31 downto 14) <= temp(17 downto 0);
                            when "10011" =>
                                temp(12 downto 0) <= temp(31 downto 19);
                                temp(31 downto 13) <= temp(18 downto 0);
                            when "10100" =>
                                temp(11 downto 0) <= temp(31 downto 20);
                                temp(31 downto 12) <= temp(19 downto 0);
                            when "10101" =>
                                temp(10 downto 0) <= temp(31 downto 21);
                                temp(31 downto 11) <= temp(20 downto 0);
                            when "10110" =>
                                temp(9 downto 0) <= temp(31 downto 22);
                                temp(31 downto 10) <= temp(21 downto 0);
                            when "10111" =>
                                temp(8 downto 0) <= temp(31 downto 23);
                                temp(31 downto 9) <= temp(22 downto 0);
                            when "11000" =>
                                temp(7 downto 0) <= temp(31 downto 24);
                                temp(31 downto 8) <= temp(23 downto 0);
                            when "11001" =>
                                temp(6 downto 0) <= temp(31 downto 25);
                                temp(31 downto 7) <= temp(24 downto 0);
                            when "11010" =>
                                temp(5 downto 0) <= temp(31 downto 26);
                                temp(31 downto 6) <= temp(25 downto 0);
                            when "11011" =>
                                temp(4 downto 0) <= temp(31 downto 27);
                                temp(31 downto 5) <= temp(26 downto 0);
                            when "11100" =>
                                temp(3 downto 0) <= temp(31 downto 28);
                                temp(31 downto 4) <= temp(27 downto 0);
                            when "11101" =>
                                temp(2 downto 0) <= temp(31 downto 29);
                                temp(31 downto 3) <= temp(28 downto 0);
                            when "11110" =>
                                temp(1 downto 0) <= temp(31 downto 30);
                                temp(31 downto 2) <= temp(29 downto 0);
                            when "11111" =>
                                temp(0 downto 0) <= temp(31 downto 31);
                                temp(31 downto 1) <= temp(30 downto 0);
						end case;

					-- Rota��o � esquerda N vezes
					when "110" =>						
						case n is
							when "00000" =>				-- Rota��o � esquerda nenhuma vez
								temp <= temp;
							when "00001" =>
                                temp(0 downto 0) <= temp(31 downto 31);
                                temp(31 downto 1) <= temp(30 downto 0);
                            when "00010" =>
                                temp(1 downto 0) <= temp(31 downto 30);
                                temp(31 downto 2) <= temp(29 downto 0);
                            when "00011" =>
                                temp(2 downto 0) <= temp(31 downto 29);
                                temp(31 downto 3) <= temp(28 downto 0);
                            when "00100" =>
                                temp(3 downto 0) <= temp(31 downto 28);
                                temp(31 downto 4) <= temp(27 downto 0);
                            when "00101" =>
                                temp(4 downto 0) <= temp(31 downto 27);
                                temp(31 downto 5) <= temp(26 downto 0);
                            when "00110" =>
                                temp(5 downto 0) <= temp(31 downto 26);
                                temp(31 downto 6) <= temp(25 downto 0);
                            when "00111" =>
                                temp(6 downto 0) <= temp(31 downto 25);
                                temp(31 downto 7) <= temp(24 downto 0);
                            when "01000" =>
                                temp(7 downto 0) <= temp(31 downto 24);
                                temp(31 downto 8) <= temp(23 downto 0);
                            when "01001" =>
                                temp(8 downto 0) <= temp(31 downto 23);
                                temp(31 downto 9) <= temp(22 downto 0);
                            when "01010" =>
                                temp(9 downto 0) <= temp(31 downto 22);
                                temp(31 downto 10) <= temp(21 downto 0);
                            when "01011" =>
                                temp(10 downto 0) <= temp(31 downto 21);
                                temp(31 downto 11) <= temp(20 downto 0);
                            when "01100" =>
                                temp(11 downto 0) <= temp(31 downto 20);
                                temp(31 downto 12) <= temp(19 downto 0);
                            when "01101" =>
                                temp(12 downto 0) <= temp(31 downto 19);
                                temp(31 downto 13) <= temp(18 downto 0);
                            when "01110" =>
                                temp(13 downto 0) <= temp(31 downto 18);
                                temp(31 downto 14) <= temp(17 downto 0);
                            when "01111" =>
                                temp(14 downto 0) <= temp(31 downto 17);
                                temp(31 downto 15) <= temp(16 downto 0);
                            when "10000" =>
                                temp(15 downto 0) <= temp(31 downto 16);
                                temp(31 downto 16) <= temp(15 downto 0);
                            when "10001" =>
                                temp(16 downto 0) <= temp(31 downto 15);
                                temp(31 downto 17) <= temp(14 downto 0);
                            when "10010" =>
                                temp(17 downto 0) <= temp(31 downto 14);
                                temp(31 downto 18) <= temp(13 downto 0);
                            when "10011" =>
                                temp(18 downto 0) <= temp(31 downto 13);
                                temp(31 downto 19) <= temp(12 downto 0);
                            when "10100" =>
                                temp(19 downto 0) <= temp(31 downto 12);
                                temp(31 downto 20) <= temp(11 downto 0);
                            when "10101" =>
                                temp(20 downto 0) <= temp(31 downto 11);
                                temp(31 downto 21) <= temp(10 downto 0);
                            when "10110" =>
                                temp(21 downto 0) <= temp(31 downto 10);
                                temp(31 downto 22) <= temp(9 downto 0);
                            when "10111" =>
                                temp(22 downto 0) <= temp(31 downto 9);
                                temp(31 downto 23) <= temp(8 downto 0);
                            when "11000" =>
                                temp(23 downto 0) <= temp(31 downto 8);
                                temp(31 downto 24) <= temp(7 downto 0);
                            when "11001" =>
                                temp(24 downto 0) <= temp(31 downto 7);
                                temp(31 downto 25) <= temp(6 downto 0);
                            when "11010" =>
                                temp(25 downto 0) <= temp(31 downto 6);
                                temp(31 downto 26) <= temp(5 downto 0);
                            when "11011" =>
                                temp(26 downto 0) <= temp(31 downto 5);
                                temp(31 downto 27) <= temp(4 downto 0);
                            when "11100" =>
                                temp(27 downto 0) <= temp(31 downto 4);
                                temp(31 downto 28) <= temp(3 downto 0);
                            when "11101" =>
                                temp(28 downto 0) <= temp(31 downto 3);
                                temp(31 downto 29) <= temp(2 downto 0);
                            when "11110" =>
                                temp(29 downto 0) <= temp(31 downto 2);
                                temp(31 downto 30) <= temp(1 downto 0);
                            when "11111" =>
                                temp(30 downto 0) <= temp(31 downto 1);
                                temp(31 downto 31) <= temp(0 downto 0);
						end case;

					-- Funcionalidade n�o definida
					when others =>
					-- N�o Faz nada					
				end case;
			end if;
			Saida <= temp;	
	end process;
END behavioral_arch;

