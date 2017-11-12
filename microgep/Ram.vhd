library IEEE;
use ieee.std_logic_1164.all;

use work.helper.all;

entity RAM is
	port (clk,rst,wr:std_logic; 
			address: integer;
			data: std_logic_vector(MEMBitsWidth-1 downto 0);
			odata: out std_logic_vector(MEMBitsWidth-1 downto 0)
		);
end entity;

architecture BEH of RAM is
	
	signal lram:RAMType:=(others=>(others => '0'));
	signal lwr:std_logic:='0';
	signal ldata: std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');
	signal laddress: integer:= 0;
begin
	lwr <= wr;
	ldata <= data;
	process(clk,rst,address,ldata,lwr)
	begin
		if(address>=0 and address<RAMWidth) then
			if rst = '1' then
				null;
			else			
				if lwr='1' then		
					lram(address)<=ldata;
				else
					null;
				end if;
			end if;

			odata<=lram(address);				
		else
			odata<=(others=>'0');
		end if;
	end process;
end BEH;