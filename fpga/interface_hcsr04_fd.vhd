library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_fd is 
    port ( 
        clock       : in  std_logic;
        pulso       : in  std_logic;
        zera        : in  std_logic;
		  reset		  : in std_logic;
        registra    : in  std_logic;
        gera        : in std_logic;
		  zera1s      : in std_logic;
		  pronto1s    : out std_logic;
		  distancia   : out std_logic_vector(11 downto 0);
		  fim         : out std_logic;
        fim_medida  : out std_logic;
        trigger     : out std_logic
    );
end interface_hcsr04_fd;

architecture arch_interface_hcsr04_fd of interface_hcsr04_fd is

signal s_contador_digito_0, s_contador_digito_1, s_contador_digito_2: std_logic_vector(3 downto 0);

component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
end component;

component contador_cm is 
    generic (
        constant R : integer;
        constant N : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        pulso   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
		  fim     : out std_logic;
        pronto  : out std_logic
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

component gerador_pulso is
   generic (
        largura: integer:= 25
   );
   port(
        clock  : in  std_logic;
        reset  : in  std_logic;
        gera   : in  std_logic;
        para   : in  std_logic;
        pulso  : out std_logic;
        pronto : out std_logic
   );
end component;

begin

TIMER: contador_m
    generic map(
        M => 50000000,
        N => 26
    )
    port map (
        clock => clock,
        zera => zera1s,
        conta => '1',
        Q => open,
        fim => pronto1s,
        meio => open
    );

CT: contador_cm
   generic map(
        R => 2941,
		  N => 12
   )
    port map ( 
        clock => clock,
        pulso => pulso,
        reset => zera,
        digito0 => s_contador_digito_0,
        digito1 => s_contador_digito_1,
        digito2 => s_contador_digito_2,
        fim => fim,
		  pronto => fim_medida
    );

RG: registrador_n
    generic map (
       N => 12
    )
    port map (
       clock => clock,
       clear => reset,
       enable => registra,
       D (11 downto 8) => s_contador_digito_2,
		 D (7 downto 4) =>  s_contador_digito_1,
		 D (3 downto 0) => s_contador_digito_0,
       Q => distancia
    );

GP: gerador_pulso
   generic map (
        largura => 500
   )
   port map(
        clock => clock,
        reset => zera,
        gera => gera,
        para => '0',
        pulso => trigger,
        pronto => open
   );

end architecture arch_interface_hcsr04_fd;
