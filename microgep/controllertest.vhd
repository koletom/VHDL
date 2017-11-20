library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.helper.all;

entity controllertest is port(
	OUTData: out std_logic_vector(MEMBitsWidth-1 downto 0)
);
end entity;

architecture BEH of controllertest is
component controller is 
	port (  clk:std_logic;   
		rst:std_logic;   
	        OUTData: out std_logic_vector(MEMBitsWidth-1 downto 0)
	);
end component;
signal lclk:std_logic:='0';
signal lrst:std_logic:='0';
signal lOUTData: std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');

begin

controllermap:controller port map(lclk,lrst,lOUTData);

process
begin
	lrst<='0';
	for idx in 0 to 1500 loop
 		lclk <= '1';
		OUTData <= lOUTData;
		wait for 10 ps;

		lclk <= '0';
		OUTData <= lOUTData;
		wait for 10 ps;
	end loop;	

	lclk <= '1';
	lrst<='1';
	OUTData <= lOUTData;
	wait for 10 ps;

	lclk <= '0';
	OUTData <= lOUTData;
	wait for 10 ps;

end process;
end BEH;

