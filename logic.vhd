LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.ALL;

PACKAGE logic IS
	TYPE weight_state IS (L,M);			-- Etats : L, M
	TYPE weight IS (Least, Most, LeastMost);	-- Poids = (Least, Most, LeastMost)
END logic;
