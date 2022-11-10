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
        distancia   : out std_logic_vector(23 downto 0)
    );
end interface_esp32_fd;

architecture arch_interface_esp32_fd of interface_esp32_fd is
	signal s_dado_recebido : std_logic_vector(7 downto 0);

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
	
	component registrador_n is
    generic (
       constant N: integer := 8 
    );
    port (
       clock  : in  std_logic;
       clear  : in  std_logic;
       enable : in  std_logic;
       D      : in  std_logic_vector (N-1 downto 0);
       Q      : out std_logic_vector (N-1 downto 0) 
    );
	end component;
	
begin

	RECEPTOR: rx_serial_8N2
		port map (
			clock => clock,
			reset => reset,
			dado_serial => dado_serial,
			dado_recebido => s_dado_recebido,
			tem_dado => open,
			pronto_rx => pronto_rx,
			db_estado => open,
			db_dado_serial => open
		);
		
	REG_U: registrador_n
		generic map(
			N => 8
		)
		port map(
			clock => clock,
			clear => reset,
			enable => armazena_u,
			D => s_dado_recebido,
			Q => distancia(7 downto 0)
		);
	
	REG_D: registrador_n
		generic map(
			N => 8
		)
		port map(
			clock => clock,
			clear => reset,
			enable => armazena_d,
			D => s_dado_recebido,
			Q => distancia(15 downto 8)
		);
	
	REG_C: registrador_n
		generic map(
			N => 8
		)
		port map(
			clock => clock,
			clear => reset,
			enable => armazena_c,
			D => s_dado_recebido,
			Q => distancia(23 downto 16)
		);
end architecture;