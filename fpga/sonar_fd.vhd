library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
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
end entity sonar_fd;

architecture sonar_fd_arch of sonar_fd is

signal s_edge_output, s_sel_transmissao, s_reset: std_logic;
signal s_out_muxpos, s_out_muxdist, s_out_mux: std_logic_vector(6 downto 0);
signal s_interface_medida: std_logic_vector(11 downto 0);
signal saida_rom: std_logic_vector(23 downto 0);
signal posicao_cont, s_db_posicao: std_logic_vector(2 downto 0);
signal estado_medidor, estado_transmissor, estado_receptor, s_hex0, s_hex1, s_hex2, s_hex3, s_hex4, s_hex5: std_logic_vector(3 downto 0);
signal s_dado_recebido: std_logic_vector(6 downto 0);
signal s_envio_serial: std_logic_vector(1 downto 0) := "10";


component mux_4x1_n is
    generic (
        constant BITS: integer := 4
    );
    port( 
        D3      : in  std_logic_vector (BITS-1 downto 0);
        D2      : in  std_logic_vector (BITS-1 downto 0);
        D1      : in  std_logic_vector (BITS-1 downto 0);
        D0      : in  std_logic_vector (BITS-1 downto 0);
        SEL     : in  std_logic_vector (1 downto 0);
        MUX_OUT : out std_logic_vector (BITS-1 downto 0)
    );
end component;

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

component interface_hcsr04 is
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
end component;

component tx_serial_7E2 is
    port (
	  clock         : in  std_logic;
	  reset         : in  std_logic;
	  partida       : in  std_logic;
	  dados_ascii   : in  std_logic_vector (6 downto 0);
	  saida_serial  : out std_logic;
	  pronto        : out std_logic;
	  db_tick : out std_logic;
	  db_saida_serial : out std_logic;
	  db_estado : out std_logic_vector (2 downto 0)
    );
end component;

component rx_serial_7E2 is
     port (
        clock : in std_logic;
        reset : in std_logic;
        dado_serial : in std_logic;
        dado_recebido : out std_logic_vector(6 downto 0);
        tem_dado : out std_logic;
        paridade_ok : out std_logic;
        pronto_rx : out std_logic;
        db_estado : out std_logic_vector(3 downto 0);
		  db_dado_serial: out std_logic
     );
end component;

component sr_ff is
	port( 
	s, r, clock: in std_logic;
	q, qbar: out std_logic);
end component;

component controle_servo_3 is
	 port (
	 clock : in std_logic;
	 reset : in std_logic;
	 posicao : in std_logic_vector(2 downto 0);
    pwm     : out std_logic;
	 db_pwm : out std_logic;
	 db_posicao : out std_logic_vector(2 downto 0)
	 );
end component;

component hex7seg is
 port (
	  hexa : in  std_logic_vector(3 downto 0);
	  sseg : out std_logic_vector(6 downto 0)
 );
end component;

component contadorg_updown_m is
    generic (
        constant M: integer := 50 -- modulo do contador
    );
    port (
        clock  : in  std_logic;
        zera_as: in  std_logic;
        zera_s : in  std_logic;
        conta  : in  std_logic;
        Q      : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        inicio : out std_logic;
        fim    : out std_logic;
        meio   : out std_logic 
   );
end component;

component edge_detector is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
end component;

component rom_angulos_8x24 is
    port (
        endereco : in  std_logic_vector(2 downto 0);
        saida    : out std_logic_vector(23 downto 0)
    ); 
end component;

begin

CONT2S: contador_m
generic map(
        M => 100000000,  
        N => 27 
)
port map(
        clock => clock,
        zera  => zera2s,
        conta => '1',
        Q     => open,
        fim   => pronto2s,
        meio  => open
    );

SM: controle_servo_3
port map(
	 clock => clock,
	 reset => s_reset,
	 posicao => posicao_cont,
    pwm     => pwm,
	 db_pwm => db_pwm,
	 db_posicao => s_db_posicao
);	

CONTPOS: contadorg_updown_m
generic map(
		M => 8
)
port map(
		clock  => clock,
	   zera_as => s_reset,
	   zera_s => '0',
	   conta  => conta_pos,
	   Q      => posicao_cont,
	   inicio => open,
	   fim    => open,
	   meio   => open 
);
		
	

ROM: rom_angulos_8x24
port map(
		endereco => posicao_cont,
		saida => saida_rom
);

MUXPOS: mux_4x1_n
generic map(
		BITS => 7
	)
port map( 
	  D3 => "0101100",
	  D2 => saida_rom(6 downto 0), 
	  D1 => saida_rom(14 downto 8),
	  D0 => saida_rom(22 downto 16),
	  SEL => sel_caractere,
	  MUX_OUT => s_out_muxpos
 );
 
MUXDIST: mux_4x1_n
generic map(
		BITS => 7
	)
port map( 
	  D3 => "0100011",
	  D2(6 downto 4) => "011",
	  D2(3 downto 0) => s_interface_medida(3 downto 0),
	  D1(6 downto 4) => "011",
	  D1(3 downto 0) => s_interface_medida(7 downto 4),
	  D0(6 downto 4) => "011",
	  D0(3 downto 0) => s_interface_medida(11 downto 8),
	  SEL => sel_caractere,
	  MUX_OUT => s_out_muxdist
 );

TRANSMISSOR: tx_serial_7E2
port map (
	  clock => clock,
	  reset => s_reset,
	  partida => transmite,
	  dados_ascii => s_out_mux,
	  saida_serial => saida_serial,
	  pronto => pronto_transmissao,
	  db_tick => open,
	  db_estado => estado_transmissor(2 downto 0)
    );

edge: edge_detector
port map(
		 clock => clock,
		 signal_in => medir,
		 output => s_edge_output
	);
	
interface: interface_hcsr04
port map (
		 clock => clock,
		 reset => s_reset,
		 medir => s_edge_output,
		 echo => echo,
		 trigger => trigger,
		 medida => s_interface_medida,
		 pronto => pronto_medicao,
		 db_estado => estado_medidor
);

flipflop_rs: sr_ff
port map(
		clock => clock,
		s => set_ff,
		r => reset_ff,
		q => s_sel_transmissao,
		qbar => open
);

receptor: rx_serial_7E2
     port map(
        clock => clock,
        reset => s_reset,
        dado_serial => entrada_serial,
        dado_recebido => s_dado_recebido,
        tem_dado => open,
        paridade_ok => open,
        pronto_rx => open,
        db_estado => estado_receptor,
		  db_dado_serial => open
);

MUXHEX0: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => db_estado,
	  D2 => estado_receptor, 
	  D1 => s_interface_medida(3 downto 0),
	  D0 => s_interface_medida(3 downto 0),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex0
 );
 
MUXHEX1: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => s_dado_recebido(3 downto 0), 
	  D1 => s_interface_medida(7 downto 4),
	  D0 => s_interface_medida(7 downto 4),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex1
 );
 
MUXHEX2: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2(3) => '0',
	  D2(2 downto 0) => s_dado_recebido(6 downto 4), 
	  D1 => s_interface_medida(11 downto 8),
	  D0 => s_interface_medida(11 downto 8),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex2
 );
 
MUXHEX3: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => "1111", 
	  D1 => "1111",
	  D0 => saida_rom(3 downto 0),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex3
);

MUXHEX4: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => "1111", 
	  D1 => "1111",
	  D0 => saida_rom(11 downto 8),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex4
);

MUXHEX5: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => estado_transmissor, 
	  D1 => estado_medidor,
	  D0 => saida_rom(19 downto 16),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex5
);


hexa0: hex7seg 
port map(
		 hexa => s_hex0,
		 sseg => hex0
);

hexa1: hex7seg 
port map(
		 hexa => s_hex1,
		 sseg => hex1
);

hexa2: hex7seg 
port map(
		 hexa => s_hex2,
		 sseg => hex2
);

hexa3: hex7seg 
port map(
		 hexa => s_hex3,
		 sseg => hex3
);

hexa4: hex7seg 
port map(
		 hexa => s_hex4,
		 sseg => hex4
);

hexa5: hex7seg 
port map(
		 hexa => s_hex5,
		 sseg => hex5
);
	
with s_sel_transmissao select
	s_out_mux <= s_out_muxpos when '0',
					 s_out_muxdist when others;
					 
with s_dado_recebido select
     s_envio_serial <= "01" when "1110000", --p
	               "10" when "1110010", --r
			         "00" when others;
				  
flipflop_rs_modo: sr_ff
port map(
		clock => clock,
		s => s_envio_serial(0),
		r => s_envio_serial(1) or s_reset,
		q => db_modo,
		qbar => open
);
	
db_envio_serial <= s_envio_serial;
envio_serial <= s_envio_serial;
sel_transmissao <= s_sel_transmissao;
estado_transmissor(3) <= '0';
s_reset <= reset_uc or reset;
end architecture sonar_fd_arch;