library ieee;
-- Componente retirado de: https://allaboutfpga.com/vhdl-code-flipflop-d-t-jk-sr/
use ieee.std_logic_1164.all;
 
entity sr_ff is
	port( 
	s, r, clock: in std_logic;
	q, qbar: out std_logic);
end sr_ff;
 
architecture behavioral of sr_ff is
	begin
	process(clock)
		variable tmp: std_logic;
		begin
		if(clock='1' and clock'EVENT) then
			if(s='0' and r='0')then
				tmp:=tmp;
			elsif(s='1' and r='1')then
				tmp:='Z';
			elsif(s='0' and r='1')then
				tmp:='0';
			else
				tmp:='1';
			end if;
		end if;
		q <= tmp;
		qbar <= not tmp;
	end process;
end behavioral;
