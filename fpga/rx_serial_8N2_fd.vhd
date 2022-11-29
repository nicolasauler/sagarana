library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_8N2_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        zera         : in  std_logic;
        conta        : in  std_logic;
        carrega      : in  std_logic;
        desloca      : in  std_logic;
		  registra     : in  std_logic;
		  limpa        : in  std_logic;
		  dado_serial : in std_logic;
        dado_recebido : out std_logic_vector(7 downto 0);
        fim          : out std_logic
    );
end entity rx_serial_8N2_fd;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is
 
    signal s_saida_desloc, s_saida_regist: std_logic_vector (10 downto 0);
 
    component deslocador_n is
    generic (
        constant N : integer
    );
    port(
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector (N-1 downto 0);
        saida          : out std_logic_vector (N-1 downto 0)
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

    U1: deslocador_n 
        generic map (
            N => 11
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => dado_serial, 
            dados          => "11111111111",
            saida          => s_saida_desloc
        );

    U2: contador_m 
        generic map (
            M => 12, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim,
				meio  => open
        );
		  
    U3: registrador_n
	      generic map (
            N => 11
        )  
        port map (
            clock => clock,
            clear => limpa,
            enable => registra,
            D => s_saida_desloc,
            Q => s_saida_regist
        );
	
	dado_recebido <= s_saida_regist(8 downto 1);
    
end architecture;