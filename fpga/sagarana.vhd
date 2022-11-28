library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity projeto_sagarana is
    port (
        clock: in std_logic;
        reset: in std_logic;
        ligar: in std_logic;
		  sel_db: in std_logic_vector(1 downto 0);
		  entrada_serial : in std_logic;
		  entrada_serial_pc : in std_logic;
		  pwm: out std_logic;
		  saida_serial: out std_logic;
		  fim_posicao: out std_logic;
		  db_pwm: out std_logic;
		  db_saida_serial: out std_logic;
		  sel_envio: out std_logic_vector (1 downto 0);
		  hex0: out std_logic_vector(6 downto 0);
		  hex1: out std_logic_vector(6 downto 0);
		  hex2: out std_logic_vector(6 downto 0);
		  hex3: out std_logic_vector(6 downto 0);
		  hex4: out std_logic_vector(6 downto 0);
		  hex5: out std_logic_vector(6 downto 0);
		  db_modo: out std_logic;
		  db_entrada_serial: out std_logic
    );
end entity projeto_sagarana;

architecture sagarana_arch of projeto_sagarana is

signal s_pronto_pula, s_iniciar, s_armazena, s_rst_interface, s_pronto_dados, s_sol_dados, s_saida_serial, s_pwm, s_reset, s_conta_pos, s_zera_pausa, s_zera_pula, s_transmite, s_medir, s_set_ff, s_reset_ff, s_pronto_pausa, s_pronto_medicao, s_pronto_transmissao, s_sel_transmissao : std_logic;
signal s_sel_caractere : std_logic_vector(1 downto 0);
signal s_db_estado : std_logic_vector (3 downto 0);

component sagarana_fd is
    port (
        clock: in std_logic;
		  reset : in std_logic;
        reset_uc: in std_logic;
		  conta_pos: in std_logic;
		  zeraPausa: in std_logic;
		  zeraPula: in std_logic;
		  transmite: in std_logic;
		  sol_dados: in std_logic;
		  entrada_serial : in std_logic;
		  entrada_serial_pc : in std_logic;
		  sel_depuracao: in std_logic_vector(1 downto 0);
		  sel_caractere: in std_logic_vector(1 downto 0); 
		  set_ff: in std_logic;
		  reset_ff: in std_logic;
		  armazena: in std_logic;
		  reset_interface: in std_logic;
		  db_estado: in std_logic_vector(3 downto 0);
		  pwm: out std_logic;
		  saida_serial: out std_logic;
		  prontoPausa: out std_logic;
		  prontoPula: out std_logic;
		  pronto_dados: out std_logic;
		  pronto_transmissao: out std_logic;
		  sel_transmissao: out std_logic;
		  sel_envio: out std_logic_vector(1 downto 0);
		  db_pwm: out std_logic;
		  iniciar: out std_logic;
		  hex0: out std_logic_vector(6 downto 0);
		  hex1: out std_logic_vector(6 downto 0);
		  hex2: out std_logic_vector(6 downto 0);
		  hex3: out std_logic_vector(6 downto 0);
		  hex4: out std_logic_vector(6 downto 0);
		  hex5: out std_logic_vector(6 downto 0);
		  db_modo: out std_logic
    );
end component;

component sagarana_uc is
	 port (
		clock : in std_logic;
		reset : in std_logic;
		ligar: in std_logic;
		iniciar: in std_logic;
		pronto_dados: in std_logic;
		pronto_transmissao: in std_logic;
		sel_transmissao: in std_logic;
		prontoPausa: in std_logic;
		prontoPula: in std_logic;
		conta_pos: out std_logic;
		zeraPausa: out std_logic;
		zeraPula: out std_logic;
		transmite: out std_logic;
		armazena: out std_logic;
		reset_interface: out std_logic;
		sol_dados: out std_logic;
		sel_caractere: out std_logic_vector (1 downto 0);
		set_ff: out std_logic;
		reset_ff: out std_logic;
		reseta_tudo: out std_logic;
		db_estado: out std_logic_vector (3 downto 0);
		fim_posicao: out std_logic
	 );
end component;

begin

FD: sagarana_fd
port map(
		  clock => clock,
		  reset => reset,
        reset_uc => s_reset,
		  conta_pos => s_conta_pos,
		  zeraPausa => s_zera_pausa,
		  zeraPula => s_zera_pula,
		  transmite => s_transmite,
		  sol_dados => s_sol_dados,
		  entrada_serial => entrada_serial,
		  entrada_serial_pc => entrada_serial_pc,
		  sel_depuracao => sel_db,
		  sel_caractere => s_sel_caractere, 
		  set_ff => s_set_ff,
		  reset_ff => s_reset_ff,
		  armazena => s_armazena,
		  reset_interface => s_rst_interface,
		  db_estado => s_db_estado,
		  pwm => pwm,
		  saida_serial => s_saida_serial,
		  prontoPausa => s_pronto_pausa,
		  prontoPula => s_pronto_pula,
		  pronto_dados => s_pronto_dados,
		  pronto_transmissao => s_pronto_transmissao,
		  sel_transmissao => s_sel_transmissao,
		  sel_envio => sel_envio,
		  db_pwm => db_pwm,
		  iniciar => s_iniciar,
		  hex0 => hex0,
		  hex1 => hex1,
		  hex2 => hex2,
		  hex3 => hex3,
		  hex4 => hex4,
		  hex5 => hex5,
		  db_modo => db_modo

);

UC: sagarana_uc
port map(
		clock => clock,
		reset => reset,
		ligar => ligar,
		iniciar => s_iniciar,
		pronto_dados => s_pronto_dados,
		pronto_transmissao => s_pronto_transmissao,
		sel_transmissao => s_sel_transmissao,
		prontoPausa => s_pronto_pausa,
		prontoPula => s_pronto_pula,
		conta_pos => s_conta_pos,
		zeraPausa => s_zera_pausa,
		zeraPula => s_zera_pula,
		transmite => s_transmite,
		armazena => s_armazena,
		reset_interface => s_rst_interface,
		sol_dados => s_sol_dados,
		sel_caractere => s_sel_caractere,
		set_ff => s_set_ff,
		reset_ff => s_reset_ff,
		reseta_tudo => s_reset,
		db_estado => s_db_estado,
		fim_posicao => fim_posicao
);

saida_serial <= s_saida_serial;
db_saida_serial <= s_saida_serial;
db_entrada_serial <= entrada_serial;
		

end architecture sagarana_arch;