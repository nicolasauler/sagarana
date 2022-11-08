library ieee;
use ieee.std_logic_1164.all;

entity interface_esp32_fd is 
    port ( 
        clock       : in  std_logic;
		  reset		  : in std_logic;
		  dado_serial : in std_logic;
		  sel_envio   : in std_logic_vector(1 downto 0);
		  armazena_u  : in std_logic;
		  armazena_d  : in std_logic;
		  armazena_c  : in std_logic;
		  pronto_rx   : out std_logic;
        distancia   : out std_logic_vector(23 downto 0);
		  fim         : out std_logic;
        start       : out std_logic
    );
end interface_esp32_fd;

architecture arch_interface_esp32_fd of interface_esp32_fd is
	signal s_medida_0, s_medida_1, s_medida_2 : std_logic_vector(7 downto 0);

	component rx_serial_8N2 is
		  port (
			  clock : in std_logic;
			  reset : in std_logic;
			  dado_serial : in std_logic;
			  dado_recebido : out std_logic_vector(7 downto 0);
			  tem_dado : out std_logic;
			  pronto_rx : out std_logic;
			  db_estado : out std_logic_vector(3 downto 0);
			  db_dado_serial: out std_logic
		  );
	end component;
	
	component 
