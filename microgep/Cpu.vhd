library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.helper.all;

entity CPU is 
	port (Clk,Rst:std_logic;
	ramindata: std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');
	cmd: std_logic_vector(MEMBitsWidth-1 DOWNTO 0);
	cmdattr: std_logic_vector(MEMBitsWidth*2-1 DOWNTO 0);
	romaddress: out integer;
	ramoutaddress: out integer;
	ramoutdata: out std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');
	ram_wr: out std_logic;	
	cpuOUT: out std_logic_vector(MEMBitsWidth-1 downto 0));
end entity;

architecture BEH of CPU is
	signal pc:integer:=0;
	signal reg:std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');
	signal result:std_logic_vector(MEMBitsWidth*2-1 downto 0):=(others=>'0');
		
	signal lramaddress:integer:=0;
	signal lramindata:std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');
	signal lramoutdata:std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');

	signal lramwr,nullflag,negativflag:std_logic:='0';

	signal lcpuOUT: std_logic_vector(MEMBitsWidth-1 downto 0):=(others=>'0');

begin
	romaddress <= pc;		
	ram_wr <= lramwr;
	cpuOUT <= lcpuOUT;

	programline_proc:process(Clk,Rst,pc)
	variable currentstate:states:=load_command; 
	variable temp:signed(7 downto 0):=(others => '0');
	begin
	
	if rst = '1' then 
		reg <= (others=>'0');
		pc <= 0;
		lramaddress <= 0;
		lramoutdata <= (others => '0');
		lramwr <= '0';
		lcpuOUT <= (others=>'0');
		currentstate := load_command;

	elsif rising_edge(Clk) then		
		case currentstate is
		when load_command =>			
			currentstate := set_rmaddress;			
		when set_rmaddress =>
			lramwr <= '0';	
			currentstate := set_lmaddress;
			if unsigned(cmd) < 5 then
				lramaddress <= to_integer(unsigned(cmdattr));
			else
				null;
			end if;
		when set_lmaddress =>
			ramoutaddress <= lramaddress;
			currentstate := load_memorydata;
		when load_memorydata =>					
			lramindata <= ramindata;
			currentstate := process_command;
		when set_wmaddress =>
			ramoutaddress <= lramaddress;
			currentstate := save_memorydata;
		when save_memorydata =>
			if lramwr = '1' then
				ramoutdata <= lramoutdata;
			else
				null;
			end if;
			currentstate := end_procpline;
		when end_procpline =>
			lramwr <= '0';	
			currentstate := load_command;
		when process_command =>
			currentstate := set_wmaddress;
			pc <= pc + CodeLineBytes;

			case cmd is
			when cBRK =>    currentstate := isprogramended;
			when cBRA =>    pc <= to_integer(unsigned(cmdattr(MEMBitsWidth*2-1 DOWNTO 0)));
					currentstate := end_procpline;
			when cBRZ => 	if nullflag = '1' then 
						pc <= to_integer(unsigned(cmdattr(MEMBitsWidth*2-1 DOWNTO 0)));
					else 
						null;
					end if;
					currentstate := end_procpline;		
			when cBRP => 	if negativflag = '1' then 
						pc <= to_integer(unsigned(cmdattr(MEMBitsWidth*2-1 DOWNTO 0)));
					else
						null;
					end if;
					currentstate := end_procpline;
			when cADD =>	temp := signed(reg)+signed(lramindata);
					
					if temp = 0 then
						nullflag <= '1';
					else
						nullflag <= '0';
					end if;
								
					if temp < 0 then											
						negativflag <= '1';
					else
						negativflag <= '0';
					end if;

					reg <= std_logic_vector( temp(MEMBitsWidth-1 downto 0));
					currentstate := end_procpline;
			when cSUB =>	temp := signed(reg)-signed(lramindata);
					
					if temp = 0 then
						nullflag <= '1';
					else
						nullflag <= '0';
					end if;
									
					if temp < 0 then											
						negativflag <= '1';
					else
						negativflag <= '0';
					end if;
					reg <= std_logic_vector( temp(MEMBitsWidth-1 downto 0));
					currentstate := end_procpline;
			when cSTA => 	lramwr <= '1';
					lramaddress <= to_integer(unsigned(cmdattr(MEMBitsWidth*2-1 DOWNTO 0)));
					lramoutdata <= reg;

			when cLOA =>  	reg <= lramindata;
					if to_integer(signed(reg)) = 0 then
						nullflag <= '1';
					else
						nullflag <= '0';
					end if;
										
					if to_integer(signed(reg)) < 0 then											
						negativflag <= '1';
					else
						negativflag <= '0';
					end if;
					currentstate := end_procpline;
			when cDAT => 	reg <= cmdattr(MEMBitsWidth-1 DOWNTO 0); -- DAT csak egy byteot olvasunk be mivel az reg 1 byte az adatszelesseg
					if to_integer(signed(reg)) = 0 then
						nullflag <= '1';
					else
						nullflag <= '0';
					end if;
										
					if to_integer(signed(reg)) < 0 then											
						negativflag <= '1';
					else
						negativflag <= '0';
					end if;
					currentstate := end_procpline;
			when cOUT => 	lcpuout <= reg;
					currentstate := end_procpline;
			when others => null;
			end case;
		when others => null;
		end case;
	end if;	
	end process;		
end BEH;