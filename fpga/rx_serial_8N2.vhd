library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_8N2 is
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
end entity;

architecture rx_serial_8N2_arch of rx_serial_8N2 is
     
    component rx_serial_uc
    port ( 
       clock : in std_logic;
        reset : in std_logic;
        dado_serial : in std_logic;
        tick    : in  std_logic;
        fim     : in  std_logic;
		  carrega: out std_logic;
		  limpa: out std_logic;
		  zera: out std_logic;
		  desloca: out std_logic;
		  conta: out std_logic;
		  registra: out std_logic;
        tem_dado : out std_logic;
        pronto : out std_logic;
		  db_estado : out std_logic_vector(3 downto 0)
    );
    end component;

    component rx_serial_8N2_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        zera         : in  std_logic;
        conta        : in  std_logic;
        carrega      : in  std_logic;
        desloca      : in  std_logic;
		  registra     : in  std_logic;
		  limpa        : in  std_logic;
		  dado_serial  : in std_logic;
        dado_recebido: out std_logic_vector(7 downto 0);
        fim          : out std_logic
    );
	end component;
    
    component contador_m
    generic (
        constant M : integer; 
        constant N : integer 
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
    
    signal s_reset: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_registra, s_tick, s_limpa, s_fim: std_logic;
begin

    -- sinal reset ativo em alto
    s_reset   <= reset;

    U1_UC: rx_serial_uc 
           port map (
               clock   => clock, 
               reset   => s_reset, 
               dado_serial => dado_serial,
               tick    => s_tick,
               fim     => s_fim,
		         carrega => s_carrega,
		         limpa   => s_limpa,
		         zera    => s_zera,
		         desloca => s_desloca,
		         conta   => s_conta,
		         registra  => s_registra,
               tem_dado => tem_dado,
               pronto => pronto_rx,
		         db_estado => db_estado
           );

    U2_FD: rx_serial_8N2_fd 
           port map (
               clock        => clock, 
               reset        => s_reset, 
               zera         => s_zera, 
               conta        => s_conta, 
               carrega      => s_carrega, 
               desloca      => s_desloca,
		         registra     => s_registra,
					limpa        => s_limpa,
               dado_serial  => dado_serial,
               dado_recebido => dado_recebido,
               fim => s_fim
           );

    U3_TICK: contador_m 
             generic map (
                 M => 434, -- 115.200 bauds
                 N => 12
             ) 
             port map (
                 clock => clock, 
                 zera  => s_zera, 
                 conta => '1', 
                 Q     => open, 
                 fim   => open,
					  meio  => s_tick
             );
				 
	db_dado_serial <= dado_serial;

end architecture;