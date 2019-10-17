LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.ALL;

ENTITY bascule_RS IS
	PORT(
		S : IN std_logic;
		R : IN std_logic;
		Q : BUFFER Std_Logic
	);
END bascule_RS;

ARCHITECTURE behaviour OF bascule_RS IS
SIGNAL notQ: std_logic;
BEGIN
	Q <= R NOR notQ;
	notQ <= S NOR Q; 
END behaviour;