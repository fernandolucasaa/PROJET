LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.logic.ALL;

ENTITY dialog_manager IS
	PORT(	
		RD 		: IN 	std_logic;			
		WR		: IN 	std_logic;
		A0		: IN 	std_logic;
		CS  		: IN 	std_logic;
		--D 		: INOUT std_logic_vector(7 DOWNTO 0);
		DIN   		: IN 	std_logic_vector(7 DOWNTO 0);
		DOUT   		: OUT 	std_logic_vector(7 DOWNTO 0);
	    	d_buf_out 	: IN 	std_logic_vector(15 DOWNTO 0);
		d_buf_in	: OUT	std_logic_vector(15 DOWNTO 0);
		charg_d_set	: BUFFER 	std_logic := '0';
		Latch_d 	: OUT 	std_logic;
		out_reset	: BUFFER 	std_logic := '0'
	);
END dialog_manager;

ARCHITECTURE arch_dialog OF dialog_manager IS

SIGNAL RW_op 	: std_logic_vector(1 DOWNTO 0);
SIGNAL Etat_w 	: weight_state := L;
SIGNAL Etat_r 	: weight_state := L;

BEGIN
	PROCESS(CS)
	BEGIN
		IF (rising_edge(CS)) THEN 									-- Test envoi Mot CPU
			IF (charg_d_set = '1') THEN
				charg_d_set <= '0';
			END IF;
			--IF (out_reset = '0') THEN 
				--out_reset <= '1';
			--END IF;
			IF (WR = '1' AND RD = '0') THEN				
				IF (A0 = '0') THEN							-- RECEPTION DATA
					out_reset <= '1';						-- out := 0
					IF (Etat_w = L) THEN
						d_buf_in(7 DOWNTO 0) <= DIN;				-- d_buf_in.lsb := DP
						--d_buf_in(7 DOWNTO 0) <= D;
						--IF (RW_op = LeastMost) THEN				-- Test etat
						IF (RW_op = "11") THEN
							Etat_w <= M;
						--ELSIF (RW_op = Least) THEN
						ELSIF (RW_op = "01") THEN
							d_buf_in(15 DOWNTO 8) <= (OTHERS => '0');	-- d_buf_in.msb := 0
							charg_d_set <= '1';				-- charg_d := true
						END IF;
					ELSIF (Etat_w = M) THEN						-- Etat_w = M
						d_buf_in(15 DOWNTO 8) <= DIN;				-- d_buf_in.msb := DP
						--d_buf_in(15 DOWNTO 8) <= D;
						--IF (RW_op = LeastMost) THEN				-- Test etat
						IF (RW_op = "11") THEN
							Etat_w <= L;
						--ELSIF (RW_op = Most) THEN
						ELSIF (RW_op = "10") THEN
							d_buf_in(7 DOWNTO 0) <= (OTHERS=>'0');		-- d_buf_in.lsb := 0
						END IF;
						charg_d_set <= '1';					-- charg_d := true
					END IF;
				ELSE									-- RECEPTION CONTROLE
					RW_op <= DIN(5 DOWNTO 4);
					--IF (D(5) = '0' AND D(4) = '0') THEN					
					IF (DIN(5) = '0' AND DIN(4) = '0') THEN 			-- DP.RW = Latch 
						Latch_d <= '1';
					ELSE
						IF (DIN(5) = '1' AND DIN(4) = '0') THEN
						--IF (D(5) = '1' AND D(4) = '0') THEN			
							--RW_op <= Most;
							RW_op <= "10";
						ELSIF (DIN(5) = '0' and DIN(4) = '1') THEN
						--ELSIF (D(5) = '0' AND D(4) = '1') THEN
							--RW_op <= Least;
							RW_op <= "01";
						ELSIF (DIN(5) = '1' AND DIN(4) = '1') THEN
							--RW_op <= LeastMost;
							RW_op <= "11";
						END IF;
						Latch_d <= '0';
						out_reset <= '1';
						--IF (RW_op == Most) THEN				-- Test MSB
						IF (RW_op = "10") THEN	
							Etat_r <= M;
							Etat_w <= M;
						ELSE
							Etat_r <= L;
							Etat_w <= L;
						END IF;
					END IF;
				END IF;
			ELSIF (WR = '0' AND RD = '1') THEN						-- ENVOI DATA
				IF (Etat_r = L) THEN
					DOUT <= d_buf_out(7 DOWNTO 0);					-- DT := d_buf_out.lsb
					--D <= d_buf_out(7 DOWNTO 0);
					--IF (RW_op = LeastMost) THEN					-- Test etat
					IF (RW_op = "11") THEN
						Etat_r <= M;
					--ELSIF (RW_op = Least) THEN
					ELSIF (RW_op = "01") THEN
						Latch_d <= '0';
					END IF;
				ELSIF(Etat_r = M) THEN							-- Etat_r = M
					DOUT <= d_buf_out(15 DOWNTO 8);					-- DT := d_buf_out.msb
					--D <= d_buf_out(15 DOWNTO 8);
					--IF (RW_op = LeastMost) THEN					-- Test etat
					IF (RW_op = "11") THEN
						Etat_r <= L;
					--ELSIF (RW_op = Most) THEN
					END IF;
					Latch_d <= '0';
				END IF;
			END IF;
		--ELSE
			--DOUT <= (OTHERS => 'Z');
			--D <= (OTHERS => 'Z');
			--charg_d_set <= '0';
			--out_reset <= '0';
		END IF;
	END PROCESS;

END arch_dialog;