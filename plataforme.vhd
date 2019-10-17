LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.logic.ALL;

ENTITY plataforme IS
	PORT(
		CLOCK_50 : IN std_logic;
		SW : IN std_logic_vector(9 DOWNTO 0); 
		KEY : IN std_logic_vector(1 DOWNTO 0);
		LED : OUT  std_logic_vector(9 DOWNTO 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO  0)
	);
END plataforme;

ARCHITECTURE arch_plataforme OF plataforme IS

-- Components
COMPONENT DCB
	PORT(
		datai :	IN std_logic_vector (3 DOWNTO 0);
		segm : 	OUT std_logic_vector (6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Dvide_Freq
	PORT (in_clk : IN std_logic; out_cpt23 : OUT std_logic);
END COMPONENT;

COMPONENT timer8084 IS
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
END COMPONENT;

SIGNAL rd, wr, cs, a0, clk, gate, val_out, charg_d_out : std_logic;
SIGNAL DIN, DOUT : std_logic_vector(7 DOWNTO 0);
SIGNAL d_out_latch: std_logic_vector(15 DOWNTO 0); --d_buf_out

BEGIN
-- Inputs
	rd <= SW(0);		-- read
	cs <= not(KEY(0));
	wr <= SW(1);		-- write
	a0 <= SW(2);		-- mode AO
	gate <= SW(3);

	DIN(7 DOWNTO 2) <= SW(9 DOWNTO 4);
	DIN(1 DOWNTO 0) <= "00";

-- Display LEDs
	LED(0) <= rd;
	LED(1) <= wr;
	LED(2) <= a0;
	LED(3) <= gate;
	LED(4) <= cs;
	LED(8) <= charg_d_out;
	LED(7) <= val_out;
	LED(9) <= clk;
	
-- Divide input frequency 50 MHz by 2 exp 24
Divide : Dvide_Freq
		PORT MAP ( in_clk => CLOCK_50, out_cpt23 => clk);

-- Timer8084
	timer : timer8084 PORT MAP (RD => rd, WR => wr, A0 => a0, CS => cs, DIN => DIN, DOUT => DOUT, d_out_latch => d_out_latch, clk => clk,
			gate => gate, main_out => val_out, charg_d_out=> charg_d_out);
	
-- Affichieurs 7 segments
-- LSB de DOUT	
	DCB0 : DCB PORT MAP (datai => DOUT(3 DOWNTO 0), segm => HEX0);

-- MSB de DOUT	
	DCB1 : DCB PORT MAP (datai => DOUT(7 DOWNTO 4), segm => HEX1);

-- d_buf_out
	DCB2 : DCB PORT MAP (datai => d_out_latch(3 DOWNTO 0), segm => HEX2);
	DCB3 : DCB PORT MAP (datai => d_out_latch(7 DOWNTO 4), segm => HEX3);
	DCB4 : DCB PORT MAP (datai => d_out_latch(11 DOWNTO 8), segm => HEX4);
	DCB5 : DCB PORT MAP (datai => d_out_latch(15 DOWNTO 12), segm => HEX5);

END arch_plataforme;