LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.logic.ALL;

ENTITY decompt_mode0 IS
	PORT(
		d_buf_in :	IN std_logic_vector(15 DOWNTO 0);
		charg_d :	IN std_logic;
		clk :		IN std_logic;
		gate :		IN std_logic;
		charg_d_reset :	OUT std_logic := '0';
		count_val :	BUFFER std_logic_vector(15 DOWNTO 0);
		out_set :	OUT std_logic := '0'
	);
END decompt_mode0;

ARCHITECTURE behaviour OF decompt_mode0 IS
BEGIN 
	PROCESS(clk, charg_d, gate)
	BEGIN
		IF (rising_edge(clk)) THEN		
			IF charg_d = '0' THEN						-- Test chargement
				IF gate = '1' THEN
					count_val <= count_val - 1;
					IF (count_val = "0000000000000000") THEN	-- Test valeur compteur
						out_set <= '1';				-- out := 1
					--ELSE
					--	out_set <= '0';						
					END IF;
				END IF;
				charg_d_reset <= '0';
			ELSIF charg_d = '1' THEN
				charg_d_reset <= '1';					-- charg_d := false
				count_val <= d_buf_in;
				out_set <= '0';
			END IF;
		--ELSE
		--	charg_d_reset <= '0';
		--	out_set <= '0';
		END IF;
	END PROCESS;
END behaviour;