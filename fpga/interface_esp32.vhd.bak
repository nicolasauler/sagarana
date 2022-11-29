library IEEE;
use IEEE.std_logic_1164.all;

entity interface_esp32 is
	 port (
		 clock : in std_logic;
		 reset : in std_logic;
		 medir : in std_logic;
		 entrada_serial : in std_logic;
		 start : out std_logic;
		 medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
		 pronto : out std_logic;
		 db_estado : out std_logic_vector(3 downto 0) -- estado da UC
	 );
end entity interface_esp32;

