library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04 is
	 port (
		 clock : in std_logic;
		 reset : in std_logic;
		 medir : in std_logic;
		 echo : in std_logic;
		 trigger : out std_logic;
		 medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
		 pronto : out std_logic;
		 db_estado : out std_logic_vector(3 downto 0) -- estado da UC
	 );
end entity interface_hcsr04;

architecture interface_hcsr04_arch of interface_hcsr04 is

signal s_fluxo_fim_medida, s_controle_registra, s_controle_gera, s_controle_zera, s_zera1s, s_pronto1s: std_logic;

component interface_hcsr04_fd is 
    port ( 
        clock       : in  std_logic;
        pulso       : in  std_logic;
        zera        : in  std_logic;
		  reset       : in std_logic;
        registra    : in  std_logic;
        gera        : in std_logic;
		  zera1s      : in std_logic;
		  pronto1s    : out std_logic;
		  distancia   : out std_logic_vector(11 downto 0);
		  fim         : out std_logic;
        fim_medida  : out std_logic;
        trigger     : out std_logic
    );
end component;

component interface_hcsr04_uc is 
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
		  pronto1s   : in std_logic;
		  zera1s     : out std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0) 
    );
end component;

begin

FD: interface_hcsr04_fd
    port map ( 
        clock => clock,
        pulso => echo,
        zera => s_controle_zera,
		  reset => reset,
        registra => s_controle_registra,
        gera => s_controle_gera,
		  zera1s => s_zera1s,
		  pronto1s => s_pronto1s,
		  distancia => medida,
		  fim => open,
        fim_medida => s_fluxo_fim_medida,
        trigger => trigger
    );

UC: interface_hcsr04_uc
    port map ( 
        clock => clock,
        reset => reset,
        medir => medir,
        echo => echo,
        fim_medida => s_fluxo_fim_medida,
		  zera1s => s_zera1s,
		  pronto1s => s_pronto1s,
        zera => s_controle_zera,
        gera => s_controle_gera,
        registra => s_controle_registra,
        pronto => pronto,
        db_estado => db_estado
    );

end interface_hcsr04_arch;