LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY top_DE10 IS
	PORT ( CLOCK_50 : IN std_logic;
			 SW : IN std_logic_vector(9 downto 0); KEY : IN std_logic_vector(1 downto 0);
			LED : OUT  std_logic_vector(9 downto 0);
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 downto 0));
--	PORT ( HEX00,HEX01,HEX02,HEX03,HEX04,HEX05,HEX06 : OUT std_logic);
END top_DE10;



ARCHITECTURE arch_top OF top_DE10 IS


COMPONENT Dvide_Freq
	PORT (in_clk : IN std_logic; out_cpt23 : OUT std_logic);
END COMPONENT;


COMPONENT DCB is
	port (datai : IN std_logic_vector (3 downto 0);
		segm : OUT std_logic_vector (6 downto 0) );
end COMPONENT; 

COMPONENT Serial_transmitter IS
PORT (H, reset, WR, CTS : IN std_logic;
		C : IN std_logic_vector (1 downto 0);
		Data : IN std_logic_vector (7 downto 0);
		TxRDY, CLK, Txd : OUT std_logic);
END COMPONENT;

SIGNAL  datain : std_logic_vector (3 downto 0) := X"A";
SIGNAL  C_in, out_txd : std_logic_vector (3 downto 0) := X"0";
SIGNAL  Data : std_logic_vector (7 downto 0);
SIGNAL 	H, CTS, WR, reset, TxRDY, CLK, Txd : std_logic;


BEGIN

	
-- reset
	reset <= SW(0);
-- CTS
	CTS <= KEY(0);	
-- WR
	WR <= KEY(1);	
-- C
	C_in(0) <= SW(1);
	C_in(1) <= SW(1);
-- DATA
	Data <= SW(9 downto 2);
	
	
-- output Txd represented on 4 bits	
	out_txd(0) <= Txd;	
	
-- Display LEDs
	LED(0) <= reset;
	LED(1) <= CTS;	
	LED(2) <= WR;
	LED(8) <= TxRDY;
	LED(9) <= H;	
-- Other LEDs off	
	LED(7 downto 3) <= "00000";
	
	
-- Divide input frequency 50 MHz by 2 exp 24
Divide : Dvide_Freq
		PORT MAP ( in_clk => CLOCK_50, out_cpt23 => H);
		
		
-- Display 7 segments
		
-- LSB of DATA	on Seg 0	
	DCB1 : DCB
		PORT MAP (datai => Data(3 downto 0), segm => HEX0);

-- MSB of DATA	on Seg 1	
	DCB2 : DCB
		PORT MAP (datai => Data(7 downto 4), segm => HEX1);
		
-- Division factor C on Seg 2
		DCB3 : DCB
		PORT MAP (datai => C_in, segm => HEX2);
	
-- output Txd on Seg 5		
	DCB4 : DCB
		PORT MAP (datai => out_txd, segm => HEX5);

-- CLK on Seg 4
	HEX4(6) <= CLK;
	HEX4(5 downto 0) <= "111111";

-- Seg 3 off	
	HEX3 <= "1111111";
	
-- Instance of Serial_transmitter 
-- uncomment to instantiate the system

--		Ser_trans : Serial_transmitter
--			PORT MAP (H, reset, WR, CTS, C_in(1 downto 0), Data, TxRDY, CLK, Txd);

END arch_top;