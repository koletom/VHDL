library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.helper.all;

entity controller is 
	port (  clk:std_logic;   -- orajel
		rst:std_logic;   -- resetjel
	        OUTData: out std_logic_vector(MEMBitsWidth-1 downto 0) -- kimeneti byte
	);
end entity;

architecture BEH of controller is
component ROM is port ( clk: std_logic;  -- orajel
			address: integer; -- az aktualis programsor ROMbeli cime
			code: out std_logic_vector(MEMBitsWidth-1 DOWNTO 0); -- aktualis utasitas
			number: out std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0) -- utasitas attributum 
		);
end component;

component RAM is port (clk, -- orajel
			rst, -- resetjel
			wr:std_logic; -- RAM iras es/vagy olvasas jelzo
	      		address: integer; -- RAM aktualis cime			
			data: std_logic_vector(MEMBitsWidth-1 downto 0); -- RAMba tarolando ertek
			odata: out std_logic_vector(MEMBitsWidth-1 downto 0) -- RAMbol kiolvasott ertek
		);
end component;

component CPU is 
	port (Clk,Rst:std_logic; -- orajel, resetjel
	ramindata: std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0'); -- rambol kiolvasott ertek
	cmd: std_logic_vector(MEMBitsWidth-1 DOWNTO 0); -- aktualis CPU parancs
	cmdattr: std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0); -- aktualis CPU parancs attributuma
	romaddress: out integer; -- kovetkezo programsor címe a ROMban
	ramoutaddress: out integer; -- RAM irasi címe
	ramoutdata: out std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0'); -- RAMban tarolando ertek
	ram_wr: out std_logic; -- RAM iras engedely
	cpuOUT: out std_logic_vector(MEMBitsWidth-1 downto 0)); -- Kimeneti ertek
end component;


signal lromaddress:integer:=0; -- aktualis/kovetkezo programsor cime a ROMban
signal ramaddress:integer:=0; -- RAM aktualis cime
signal lcmd: std_logic_vector(MEMBitsWidth-1 DOWNTO 0):=(others=>'0'); -- aktualis utasitas
signal lcmdAttr: std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0):=(others=>'0'); -- utasitas attributum
signal lwr:std_logic:='0'; -- RAM iras enegedely
signal ramoutdata:std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0'); -- RAM kimeneti CPU bemeneti ertek
signal ramindata:std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0'); -- RAM bemeneti CPU kimeneti ertek

begin
	ROMEntity: ROM port map (clk, lromaddress,lcmd,lcmdAttr);
	RAMEntity: RAM port map (clk, rst,lwr,ramaddress, ramindata, ramoutdata);
	CPUEntity: CPU port map (clk, rst, ramoutdata, lcmd, lcmdAttr,lromaddress,ramaddress,ramindata,lwr,OUTData);
end BEH;
		
