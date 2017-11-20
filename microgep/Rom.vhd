library IEEE;
use ieee.std_logic_1164.all;

use work.helper.all;

entity ROM is
	port (clk: std_logic; 
			address: integer;
			code: out std_logic_vector(MEMBitsWidth-1 DOWNTO 0);
			number: out std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0)			
		);
end entity;

architecture BEH of ROM is	
	signal lcode: std_logic_vector(MEMBitsWidth-1 DOWNTO 0):=(others=>'0');
	signal lnumber: std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0):=(others=>'0');
begin	
	process(clk,address,lcode,lnumber)
	begin			
		if address >= 0 and address<PROGRAM'length-3 then
			lcode<=PROGRAM(address);
			lnumber(15 downto 8)<=PROGRAM(address+1);
			lnumber(7 downto 0)<=PROGRAM(address+2);			
			code <= lcode;
			number <= lnumber;					
		else
			null;
		end if;

	end process;
end BEH;