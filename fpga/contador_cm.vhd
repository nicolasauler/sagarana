library IEEE;
use IEEE.std_logic_1164.all;

entity contador_cm is
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
end entity contador_cm;

architecture contador_cm_arch of contador_cm is

signal s_fluxo_fim, s_fluxo_arredonda, s_fluxo_tick: std_logic;
signal s_controle_conta_bcd, s_controle_zera_bcd, s_controle_conta_tick, s_controle_zera_tick: std_logic;
signal s_edge_start,s_edge_fim: std_logic;

component edge_detector is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
end component;

component edge_detector_descida is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
end component;
	
component contador_cm_fd is
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
end component;

component contador_cm_uc is
    port (
        clock      : in  std_logic;
		  reset      : in  std_logic;
		  fim        : in  std_logic;
		  edge_start : in std_logic;
		  edge_fim   : in std_logic;
        arredonda  : in  std_logic;
		  tick       : in  std_logic;
        conta_bcd  : out std_logic;
        zera_bcd   : out std_logic;
		  conta_tick : out std_logic;
        zera_tick  : out std_logic;
        pronto     : out std_logic
    );
end component;

begin

EDS: edge_detector
	 port map(
	     clock => clock,
		  signal_in => pulso,
		  output => s_edge_start
	 );

EDD: edge_detector_descida
	 port map(
	     clock => clock,
		  signal_in => pulso,
		  output => s_edge_fim
	 );

FD: contador_cm_fd
    port map ( 
        clock => clock,
        conta_bcd => s_controle_conta_bcd,
        zera_bcd => s_controle_zera_bcd,
        conta_tick => s_controle_conta_tick,
        zera_tick => s_controle_zera_tick,
        digito0 => digito0,
        digito1 => digito1,
        digito2 => digito2,
		  fim => s_fluxo_fim,
        arredonda => s_fluxo_arredonda,
		  tick => s_fluxo_tick
    );

UC: contador_cm_uc
    port map ( 
        clock => clock,
		  reset => reset,
		  fim => s_fluxo_fim,
		  edge_start => s_edge_start,
		  edge_fim => s_edge_fim,
        arredonda => s_fluxo_arredonda,
		  tick => s_fluxo_tick,
        conta_bcd => s_controle_conta_bcd,
        zera_bcd => s_controle_zera_bcd,
		  conta_tick => s_controle_conta_tick,
        zera_tick => s_controle_zera_tick,
        pronto => pronto
    );

end architecture;