library IEEE;
use IEEE.std_logic_1164.all;

entity contador_cm_fd is
    port (
        clock      : in  std_logic;
        conta_bcd  : in  std_logic;
        zera_bcd   : in  std_logic;
        conta_tick : in  std_logic;
        zera_tick  : in  std_logic;
        digito0    : out std_logic_vector(3 downto 0);
        digito1    : out std_logic_vector(3 downto 0);
        digito2    : out std_logic_vector(3 downto 0);
		  fim        : out std_logic;
        arredonda  : out std_logic;
		  tick       : out std_logic
    );
end entity;

architecture contador_cm_fd_arch of contador_cm_fd is

signal s_Q_contador_m: std_logic_vector(11 downto 0);

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
        fim   : out std_logic
    );
end component;

component contador_bcd_3digitos is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0); 
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
end component;

component analisa_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        valor            : in  std_logic_vector (N-1 downto 0);
        zero             : out std_logic;
        meio             : out std_logic;
        fim              : out std_logic;
        metade_superior  : out std_logic
    );
end component;

begin

CM: contador_m
    generic map (
        M => 2941,
        N => 12
    )
    port map (
        clock => clock,
        zera  => zera_tick,
        conta => conta_tick,
        Q     => s_Q_contador_m,
        fim   => tick
    );

C_BCD: contador_bcd_3digitos
    port map( 
        clock   => clock,
        zera    => zera_bcd,
        conta   => conta_bcd,
        digito0 => digito0,
        digito1 => digito1,
        digito2 => digito2,
        fim     => fim
    );

A_M: analisa_m
    generic map (
        M => 2941,
        N => 12
    )
    port map (
        valor => s_Q_contador_m,
        zero => open,
        meio => open,
        fim => open,
        metade_superior => arredonda
    );

end architecture;