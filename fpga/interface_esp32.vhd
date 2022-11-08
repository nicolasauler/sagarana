library IEEE;
use IEEE.std_logic_1164.all;

entity interface_esp32 is
	 port (
		 clock : in std_logic;
		 reset : in std_logic;
		 entrada_serial : in std_logic;
		 start : out std_logic;
		 distancia : out std_logic_vector (23 downto);
		 pronto : out std_logic;
		 db_estado : out std_logic_vector(3 downto 0) -- estado da UC
	 );
end entity interface_esp32;

architecture interface_esp32_arch of interface_esp32 is

signal s_sel_envio : std_logic_vector (1 downto 0);
signal s_armazena_u, s_armazena_d, s_armazena_c, s_pronto_rx, s_start : std_logic;

	component interface_esp32_fd is 
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
        start       : out std_logic
    );
	end component;
	
	component interface_esp32_uc is 
    port ( 
        clock       : in  std_logic;
		  reset		  : in std_logic;
		  start       : in std_logic;
		  pronto_rx   : in std_logic;
		  armazena_u  : out std_logic;
		  armazena_d  : out std_logic;
		  armazena_c  : out std_logic;
		  pronto      : out std_logic;
		  zera        : out std_logic;
		  sel_envio   : out std_logic_vector(1 downto 0);
		  db_estado   : out std_logic_vector(3 downto 0)
    );
	end component;

begin 

	FD: interface_esp32_fd
		port map(
		  clock  => clock,
		  reset	=> reset,
		  dado_serial => entrada_serial,
		  sel_envio => s_sel_envio,
		  armazena_u  => s_aramazena_u,
		  armazena_d  => s_aramazena_d,
		  armazena_c  => s_aramazena_c,
		  pronto_rx   => s_pronto_rx,
        distancia   => distancia,
        start => s_start
		 );
		 
	UC: interface_esp32_uc
		port map(
			clock => clock,
			reset => reset,
			start => s_start,
			pronto_rx => s_pronto_rx,
			armazena_u => s_armazena_u,
			armazena_d  => s_aramazena_d,
			armazena_c  => s_aramazena_c,
			pronto => pronto,
			zera => open,
			sel_envio => s_sel_envio,
			db_estado => db_estado
		);