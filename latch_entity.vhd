LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.logic.ALL;

ENTITY latch_entity IS
	PORT(	
		count_val 	: IN 	std_logic_vector(15 DOWNTO 0);
		Latch_d 	: IN 	std_logic;
		d_buf_out 	: OUT	std_logic_vector(15 DOWNTO 0)
	);
END latch_entity;

ARCHITECTURE archi_latch OF latch_entity IS
BEGIN
	d_buf_out <= count_val WHEN (Latch_d = '0');
END archi_latch;