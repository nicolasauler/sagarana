library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sagarana_fd is
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
end entity sagarana_fd;

architecture sagarana_fd_arch of sagarana_fd is

signal s_edge_output, s_sel_transmissao, s_reset: std_logic;
signal s_out_muxpos, s_out_muxdist, s_out_mux, s_dado_recebido: std_logic_vector(7 downto 0);
signal s_distancia, s_registrador: std_logic_vector(23 downto 0);
signal saida_rom: std_logic_vector(23 downto 0);
signal posicao_cont, s_db_posicao: std_logic_vector(6 downto 0);
signal s_estado_rx_interface, s_estado_interface, estado_transmissor, estado_receptor, s_hex0, s_hex1, s_hex2, s_hex3, s_hex4, s_hex5: std_logic_vector(3 downto 0);
signal s_iniciar: std_logic := '0';

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

component interface_esp32 is
	 port (
		 clock : in std_logic;
		 reset : in std_logic;
		 entrada_serial : in std_logic;
		 start : in std_logic;
		 sel_envio : out std_logic_vector(1 downto 0);
		 distancia : out std_logic_vector (23 downto 0);
		 pronto : out std_logic;
		 db_estado : out std_logic_vector(3 downto 0);
		 estado_rx : out std_logic_vector(3 downto 0)
	 );
end component;

component tx_serial_8N2 is
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        partida       : in  std_logic;
        dados_ascii   : in  std_logic_vector (7 downto 0);
        saida_serial  : out std_logic;
        pronto        : out std_logic;
		  db_tick : out std_logic;
		  db_saida_serial : out std_logic;
		  db_estado : out std_logic_vector (2 downto 0)
    );
end component;

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

component sr_ff is
	port( 
	s, r, clock: in std_logic;
	q, qbar: out std_logic);
end component;

component controle_servo_3 is
	 port (
	 clock : in std_logic;
	 reset : in std_logic;
	 posicao : in std_logic_vector(6 downto 0);
    pwm     : out std_logic;
	 db_pwm : out std_logic;
	 db_posicao : out std_logic_vector(6 downto 0)
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

component rom_angulos_128x24 is
    port (
        endereco : in  std_logic_vector(6 downto 0);
        saida    : out std_logic_vector(23 downto 0)
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

REGISTRADOR: registrador_n
generic map(
		  N => 24
)
port map(
		  clock => clock,
		  clear => reset,
		  enable => armazena,
		  D => s_distancia,
		  Q => s_registrador
);

CONTPAUSA: contador_m
generic map(
        M => 1500000,  
        N => 27 
)
port map(
        clock => clock,
        zera  => zeraPausa,
        conta => '1',
        Q     => open,
        fim   => prontoPausa,
        meio  => open
    );
	 
CONTPULA: contador_m
generic map(
        M => 50000000,  
        N => 27 
)
port map(
        clock => clock,
        zera  => zeraPula,
        conta => '1',
        Q     => open,
        fim   => prontoPula,
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
		M => 128
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
		
	

ROM: rom_angulos_128x24
port map(
		endereco => posicao_cont,
		saida => saida_rom
);

MUXPOS: mux_4x1_n
generic map(
		BITS => 8
	)
port map( 
	  D3 => "00101100",
	  D2 => saida_rom(7 downto 0), 
	  D1 => saida_rom(15 downto 8),
	  D0 => saida_rom(23 downto 16),
	  SEL => sel_caractere,
	  MUX_OUT => s_out_muxpos
 );
 
MUXDIST: mux_4x1_n
generic map(
		BITS => 8
	)
port map( 
	  D3 => "00100011",
	  D2 => s_registrador(7 downto 0), 
	  D1 => s_registrador(15 downto 8),
	  D0 => s_registrador(23 downto 16),
	  SEL => sel_caractere,
	  MUX_OUT => s_out_muxdist
 );

TRANSMISSOR: tx_serial_8N2
port map (
	  clock => clock,
     reset => s_reset,
     partida => transmite,
     dados_ascii => s_out_mux,
     saida_serial => saida_serial,
     pronto => pronto_transmissao,
	  db_tick => open,
	  db_saida_serial => open,
	  db_estado => estado_transmissor(2 downto 0)
    );

edge: edge_detector
port map(
		 clock => clock,
		 signal_in => sol_dados,
		 output => s_edge_output
	);
	
interface: interface_esp32
port map (
		 clock => clock,
		 reset => (s_reset or reset_interface),
		 entrada_serial => entrada_serial,
		 start => s_edge_output,
		 sel_envio => sel_envio,
		 distancia => s_distancia,
		 pronto => pronto_dados, 
		 db_estado => s_estado_interface,
		 estado_rx => s_estado_rx_interface
	 );

flipflop_rs: sr_ff
port map(
		clock => clock,
		s => set_ff,
		r => reset_ff,
		q => s_sel_transmissao,
		qbar => open
);

receptor: rx_serial_8N2
     port map(
        clock => clock,
        reset => s_reset,
        dado_serial => entrada_serial_pc,
        dado_recebido => s_dado_recebido,
        tem_dado => open,
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
	  D1 => s_registrador(3 downto 0),
	  D0 => s_registrador(3 downto 0),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex0
 );
 
MUXHEX1: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => "1111", 
	  D1 => s_registrador(11 downto 8),
	  D0 => s_registrador(11 downto 8),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex1
 );
 
MUXHEX2: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => s_dado_recebido(3 downto 0), 
	  D1 => s_registrador(19 downto 16),
	  D0 => s_registrador(19 downto 16),
	  SEL => sel_depuracao,
	  MUX_OUT => s_hex2
 );
 
MUXHEX3: mux_4x1_n
generic map(
		BITS => 4
	)
port map( 
	  D3 => "1111",
	  D2 => s_dado_recebido(7 downto 4), 
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
	  D2 => s_estado_rx_interface, 
	  D1 => s_estado_interface,
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
     s_iniciar <= '1' when "01110011", --s
	               '0' when "01100110", --f
			         s_iniciar when others;
				  
	
iniciar <= s_iniciar;
sel_transmissao <= s_sel_transmissao;
estado_transmissor(3) <= '0';
s_reset <= reset_uc or reset;
end architecture sagarana_fd_arch;