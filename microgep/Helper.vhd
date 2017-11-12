library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Helper is
	constant ROMWidth : integer := 1024;	-- Program memoria merete byteokban
	constant RAMWidth : integer := 512;     -- RAM memoria merete byteokban
	constant MEMBitsWidth : integer := 8;	-- adatszelesseg
	constant CodeLineBytes: integer := 3;	-- egy programsor hossza 
	type LINEType is -- Parancssor strukturaja
	record
		Code:std_logic_vector(MEMBitsWidth-1 DOWNTO 0);
		Number:std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0);
	end record;

	type states is (load_command,set_lmaddress,  -- CPU allapotok
			set_rmaddress,set_wmaddress, 
			load_memorydata, process_command, 
			save_memorydata, end_procpline, isprogramended);

	type RAMType is array(0 TO RAMWidth - 1) of std_logic_vector(MemBitsWidth-1 downto 0);	-- RAM tipus definicioja

	type ROMType is array(0 TO ROMWidth - 1) OF std_logic_vector(MEMBitsWidth-1 DOWNTO 0);	-- ROM tipus definicioja
	constant cADD : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"01"; -- A xxxx RAM címen lév? érték hozzáadása az akkumolátorhoz és beállítja a negatív ill. 0 jelz?t
	constant cSUB : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"02"; -- Kivonja az xxxx RAM címen lév? értéket az akkumolátor aktuális értékéb?l és beállítja a negatív ill. 0 jelz?t
	constant cSTA : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"03"; -- Beírja az akkumolátor aktuális értékét az xxxx RAM címre
	constant cLOA : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"04"; -- Betölti az xxxx RAM címen lév? értéket az akkumolátorba
	constant cDAT : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"05"; -- Beállítja az akkumulátor értékét xx-re mivel jelenleg 8bites az adatszélesség ezért csak 256nál kissebb érték lesz figyelembe véve
	constant cBRA : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"06"; -- Átállítja a program mutatót az XXXX értékre és onnan folytatódik a program futása
	constant cBRZ : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"07"; -- Ha a null jelz? 1 akkor átállítja a program mutatót az XXXX értékre és onnan folytatódik a program futása
	constant cBRP : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"08"; -- Ha a negatív jelz?  0 akkor átállítja a program mutatót az XXXX értékre és onnan folytatódik a program futása
	constant cOUT : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"5A"; -- Kiírja az akkumolátor aktuális értékét a kimenetre
	constant cBRK : std_logic_vector(MEMBitsWidth-1 DOWNTO 0) := x"FF"; -- Program vége

-- Aktuális program hexa kódja c#ban irt compiler megtalalhato itt:https://github.com/koletom/LMCCompiler
	constant PROGRAM:ROMType:=(X"05", X"00", X"01", X"03", X"00", X"00", X"04", X"00", X"00", X"5A", X"00", X"00", X"01", X"00", X"00", X"03", X"00", X"01", X"04", X"00", 
X"01", X"5A", X"00", X"00", X"01", X"00", X"00", X"03", X"00", X"02", X"04", X"00", X"02", X"01", X"00", X"00", X"03", X"00", X"03", X"04", 
X"00", X"03", X"01", X"00", X"00", X"03", X"00", X"04", X"04", X"00", X"04", X"01", X"00", X"00", X"03", X"00", X"05", X"04", X"00", X"05", 
X"01", X"00", X"00", X"03", X"00", X"06", X"04", X"00", X"06", X"01", X"00", X"00", X"03", X"00", X"07", X"04", X"00", X"07", X"01", X"00", 
X"00", X"03", X"00", X"08", X"04", X"00", X"08", X"01", X"00", X"00", X"03", X"00", X"09", X"04", X"00", X"09", X"01", X"00", X"00", X"03", 
X"00", X"0A", X"04", X"00", X"0A", X"01", X"00", X"00", X"03", X"00", X"0B", X"04", X"00", X"0B", X"01", X"00", X"00", X"03", X"00", X"0C", 
X"04", X"00", X"0C", X"01", X"00", X"00", X"03", X"00", X"0D", X"04", X"00", X"0D", X"01", X"00", X"00", X"03", X"00", X"0E", X"04", X"00", 
X"0E", X"01", X"00", X"00", X"03", X"00", X"0F", X"04", X"00", X"0F", X"01", X"00", X"00", X"03", X"00", X"10", X"04", X"00", X"10", X"01", 
X"00", X"00", X"03", X"00", X"11", X"04", X"00", X"11", X"01", X"00", X"00", X"03", X"00", X"12", X"04", X"00", X"12", X"01", X"00", X"00", 
X"03", X"00", X"13", X"04", X"00", X"13", X"01", X"00", X"00", X"03", X"00", X"14", X"04", X"00", X"14", X"01", X"00", X"00", X"03", X"00", 
X"15", X"04", X"00", X"15", X"01", X"00", X"00", X"03", X"00", X"16", X"04", X"00", X"16", X"01", X"00", X"00", X"03", X"00", X"17", X"04", 
X"00", X"17", X"01", X"00", X"00", X"03", X"00", X"18", X"04", X"00", X"18", X"01", X"00", X"00", X"03", X"00", X"19", X"04", X"00", X"19", 
X"01", X"00", X"00", X"03", X"00", X"1A", X"04", X"00", X"1A", X"01", X"00", X"00", X"03", X"00", X"1B", X"04", X"00", X"1B", X"01", X"00", 
X"00", X"03", X"00", X"1C", X"04", X"00", X"1C", X"01", X"00", X"00", X"03", X"00", X"1D", X"04", X"00", X"1D", X"01", X"00", X"00", X"03", 
X"00", X"1E", X"04", X"00", X"1E", X"01", X"00", X"00", X"03", X"01", X"F6", X"04", X"01", X"F6", X"01", X"00", X"00", X"03", X"01", X"F7", 
X"04", X"01", X"F7", X"01", X"00", X"00", X"03", X"01", X"F8", X"04", X"01", X"F8", X"01", X"00", X"00", X"03", X"01", X"F9", X"04", X"01", 
X"F9", X"01", X"00", X"00", X"03", X"01", X"FA", X"04", X"01", X"FA", X"01", X"00", X"00", X"03", X"01", X"FB", X"04", X"01", X"FB", X"01", 
X"00", X"00", X"03", X"01", X"FC", X"04", X"01", X"FC", X"01", X"00", X"00", X"03", X"01", X"FD", X"04", X"01", X"FD", X"01", X"00", X"00", 
X"03", X"01", X"FE", X"01", X"00", X"00", X"03", X"01", X"FE", X"04", X"01", X"FE", X"01", X"00", X"00", X"03", X"01", X"FF", X"04", X"01", 
X"FF", X"05", X"00", X"01", X"01", X"00", X"0A", X"03", X"00", X"0A", X"5A", X"00", X"00", X"07", X"00", X"00", X"06", X"01", X"7D", X"FF", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00");	
		
end Helper;


