library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is
    port (
        clock: in std_logic;
        reset: in std_logic;
        ligar: in std_logic;
        echo: in std_logic;
		  sel_db: in std_logic_vector(1 downto 0);
		  sel_mode_serial: in std_logic;
		  entrada_serial : in std_logic;
        trigger: out std_logic;
		  pwm: out std_logic;
		  saida_serial: out std_logic;
		  fim_posicao: out std_logic;
		  db_pwm: out std_logic;
		  db_saida_serial: out std_logic;
		  db_trigger: out std_logic;
		  db_echo: out std_logic;
		  hex0: out std_logic_vector(6 downto 0);
		  hex1: out std_logic_vector(6 downto 0);
		  hex2: out std_logic_vector(6 downto 0);
		  hex3: out std_logic_vector(6 downto 0);
		  hex4: out std_logic_vector(6 downto 0);
		  hex5: out std_logic_vector(6 downto 0);
		  db_serial: out std_logic_vector(1 downto 0);
		  db_modo: out std_logic
    );
end entity sonar;

architecture sonar_arch of sonar is

signal s_trigger, s_saida_serial, s_pwm, s_reset, s_conta_pos, s_zera2s, s_transmite, s_medir, s_set_ff, s_reset_ff, s_pronto2s, s_pronto_medicao, s_pronto_transmissao, s_sel_transmissao : std_logic;
signal s_sel_caractere : std_logic_vector(1 downto 0);
signal s_db_estado : std_logic_vector (3 downto 0);
signal s_serial: std_logic_vector(1 downto 0);

component sonar_fd is
    port (
        clock: in std_logic;
		  reset : in std_logic;
        reset_uc: in std_logic;
        echo: in std_logic;
		  conta_pos: in std_logic;
		  zera2s: in std_logic;
		  transmite: in std_logic;
		  medir: in std_logic;
		  sel_mode_serial: in std_logic;
		  entrada_serial : in std_logic;
		  sel_depuracao: in std_logic_vector(1 downto 0);
		  sel_caractere: in std_logic_vector(1 downto 0); 
		  set_ff: in std_logic;
		  reset_ff: in std_logic;
		  db_estado: in std_logic_vector(3 downto 0);
		  envio_serial: out std_logic_vector(1 downto 0);
        trigger: out std_logic;
		  pwm: out std_logic;
		  saida_serial: out std_logic;
		  pronto2s: out std_logic;
		  pronto_medicao: out std_logic;
		  pronto_transmissao: out std_logic;
		  sel_transmissao: out std_logic;
		  db_pwm: out std_logic;
		  hex0: out std_logic_vector(6 downto 0);
		  hex1: out std_logic_vector(6 downto 0);
		  hex2: out std_logic_vector(6 downto 0);
		  hex3: out std_logic_vector(6 downto 0);
		  hex4: out std_logic_vector(6 downto 0);
		  hex5: out std_logic_vector(6 downto 0);
		  db_envio_serial: out std_logic_vector(1 downto 0);
		  db_modo: out std_logic
    );
end component;

component sonar_uc is
	 port (
		clock : in std_logic;
		reset : in std_logic;
		ligar: in std_logic;
		pronto_medicao: in std_logic;
		pronto_transmissao: in std_logic;
		sel_transmissao: in std_logic;
		pronto2s: in std_logic;
		recebe_serial: in std_logic_vector(1 downto 0);
		conta_pos: out std_logic;
		zera2s: out std_logic;
		transmite: out std_logic;
		medir: out std_logic;
		sel_caractere: out std_logic_vector (1 downto 0);
		set_ff: out std_logic;
		reset_ff: out std_logic;
		reseta_tudo: out std_logic;
		db_estado: out std_logic_vector (3 downto 0);
		fim_posicao: out std_logic
	 );
end component;

begin

FD: sonar_fd
port map(
		clock => clock,
		reset => reset,
		reset_uc => s_reset,
		echo => echo,
		conta_pos => s_conta_pos,
		zera2s => s_zera2s,
		transmite => s_transmite,
		medir => s_medir,
		sel_mode_serial => sel_mode_serial,
		entrada_serial => entrada_serial,
		sel_depuracao => sel_db,
		sel_caractere => s_sel_caractere,
		set_ff => s_set_ff,
		reset_ff => s_reset_ff,
		db_estado => s_db_estado,
      trigger => s_trigger,
		pwm => pwm,
		saida_serial => s_saida_serial,
		pronto2s => s_pronto2s,
	   pronto_medicao => s_pronto_medicao,
	   pronto_transmissao => s_pronto_transmissao,
	   sel_transmissao => s_sel_transmissao,
	   db_pwm => db_pwm,
		hex0 => hex0,
		hex1 => hex1,
		hex2 => hex2,
		hex3 => hex3,
		hex4 => hex4,
		hex5 => hex5,
		envio_serial => s_serial,
		db_envio_serial => db_serial,
		db_modo => db_modo

);

UC: sonar_uc
port map(
		clock => clock,
		reset => reset,
		ligar => ligar,
		pronto_medicao => s_pronto_medicao,
		pronto_transmissao => s_pronto_transmissao,
		sel_transmissao => s_sel_transmissao,
		pronto2s => s_pronto2s,
		conta_pos => s_conta_pos,
		transmite => s_transmite,
		medir => s_medir,
		sel_caractere => s_sel_caractere,
		set_ff => s_set_ff,
		reset_ff => s_reset_ff,
		reseta_tudo => s_reset,
		db_estado => s_db_estado,
		fim_posicao => fim_posicao,
		recebe_serial => s_serial
);

saida_serial <= s_saida_serial;
db_saida_serial <= s_saida_serial;
trigger <= s_trigger;
db_trigger <= s_trigger;
db_echo <= echo;
		

end architecture sonar_arch;