LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.logic.ALL;

ENTITY timer8084 IS
	PORT(
		RD		: IN std_logic;				
		WR		: IN std_logic;
		A0		: IN std_logic;
		CS		: IN std_logic;
		DIN		: IN std_logic_vector(7 DOWNTO 0);
		DOUT		: OUT std_logic_vector(7 DOWNTO 0);
		--D		: INOUT std_logic_vector(7 DOWNTO 0);
		d_out_latch	: OUT std_logic_vector(15 DOWNTO 0);	-- d_buf_out 
		clk 		: IN std_logic;				
		gate 		: IN std_logic;
		main_out 	: OUT std_logic;			-- out
		charg_d_out 	: OUT std_logic				-- charg_d
	);
END timer8084;

ARCHITECTURE arch_timer8084 OF timer8084 IS

-- Composants
COMPONENT dialog_manager IS	-- Gestion dialogue
	PORT(	
		RD 		: IN 	std_logic;			
		WR		: IN 	std_logic;
		A0	 	: IN 	std_logic;
		CS  		: IN 	std_logic;
		--D 		: INOUT std_logic_vector(7 DOWNTO 0);
		DIN   		: IN 	std_logic_vector(7 DOWNTO 0);
		DOUT   		: OUT 	std_logic_vector(7 DOWNTO 0);
		d_buf_out 	: IN 	std_logic_vector(15 DOWNTO 0);
		d_buf_in 	: OUT	std_logic_vector(15 DOWNTO 0);
		charg_d_set	: BUFFER std_logic := '0';
		Latch_d 	: OUT 	 std_logic;
		out_reset 	: BUFFER std_logic:= '0'
	);
END COMPONENT;
	
COMPONENT decompt_mode0 IS	-- Decompt_mode0
	PORT(
		d_buf_in :	IN std_logic_vector(15 DOWNTO 0);
		charg_d :	IN std_logic;
		clk :		IN std_logic;
		gate :		IN std_logic;
		charg_d_reset :	OUT std_logic := '0';
		count_val :	BUFFER std_logic_vector(15 DOWNTO 0);
		out_set :	OUT std_logic := '0'
	);
END COMPONENT;

COMPONENT latch_entity IS	-- Gestion buffer
	PORT(	
		count_val 	: IN 	std_logic_vector(15 DOWNTO 0);
		Latch_d 	: IN 	std_logic;
		d_buf_out 	: OUT	std_logic_vector(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT bascule_RS IS 	-- Variables partages : out, charg_d
	PORT(
		S : IN std_logic;  
		R : IN std_logic;
		Q : OUT Std_Logic
	);
END COMPONENT;

-- Signals intermediares
SIGNAL d_buf_in_sig, d_buf_out_sig			: std_logic_vector(15 DOWNTO 0);
SIGNAL charg_d_set_sig, Latch_d_sig, out_reset_sig	: std_logic;
SIGNAL charg_d_sig, charg_d_reset_sig, out_set_sig 	: std_logic;	
SIGNAL count_val_sig 					: std_logic_vector(15 DOWNTO 0);

BEGIN
	d_out_latch <= d_buf_out_sig;
	charg_d_out <= charg_d_sig;

	gestion_dialogue: 
		dialog_manager 	PORT MAP (RD => RD, WR => WR, A0 => A0, CS => CS, DIN => DIN, DOUT => DOUT, d_buf_out => d_buf_out_sig, 
				d_buf_in => d_buf_in_sig, charg_d_set => charg_d_set_sig, Latch_d => Latch_d_sig, out_reset => out_reset_sig);

		--dialog_manager 	PORT MAP (RD => RD, WR => WR, A0 => A0, CS => CS, D => D, d_buf_out => d_out_latch, d_buf_in => d_buf_in_sig,
		--		charg_d_set => charg_d_set_sig, Latch_d => Latch_d_sig, out_reset => out_reset_sig, RW_op => RW_op; Etat_w => Etat_w; Etat_r => Etat_r);

	decompteur : 
		decompt_mode0 	PORT MAP (d_buf_in => d_buf_in_sig, charg_d => charg_d_sig, clk => clk, gate => gate, charg_d_reset => charg_d_reset_sig,
				count_val => count_val_sig, out_set => out_set_sig);
	
	RS_charg_d : 
		bascule_RS 	PORT MAP (S => charg_d_set_sig, R => charg_d_reset_sig, Q => charg_d_sig);

	RS_out :
		bascule_RS 	PORT MAP (S => out_set_sig,  R => out_reset_sig, Q => main_out);

	gestion_buffer	: 
		latch_entity 	PORT MAP (count_val => count_val_sig, Latch_d => Latch_d_sig, d_buf_out => d_buf_out_sig);		

END arch_timer8084;