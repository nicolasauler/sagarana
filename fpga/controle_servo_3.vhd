library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	 port (
	 clock : in std_logic;
	 reset : in std_logic;
	 posicao : in std_logic_vector(6 downto 0);
    pwm     : out std_logic;
	 db_pwm : out std_logic;
	 db_posicao : out std_logic_vector(6 downto 0)
	 );
end entity controle_servo_3;

architecture controle_servo_3_arch of controle_servo_3 is

  constant CONTAGEM_MAXIMA : integer := 1000000;
  
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_servo  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_pwm : std_logic;
  
begin

  process(clock,reset,s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      s_pwm         <= '0';
      largura_servo <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_servo) then
          s_pwm  <= '1';
        else
          s_pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_servo <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
	 
	 pwm <= s_pwm;
	 db_pwm <= s_pwm;
	 
  end process;

  process(posicao)
  begin
    case posicao is
		when "0000000" => 	s_largura <=	 35000; --0.7 ms
      when "0000001" =>    s_largura <=    35590;
		when "0000010" =>		s_largura <=	 36181;
      when "0000011" =>    s_largura <=    36771;
		when "0000100" =>		s_largura <=	 37362;
      when "0000101" =>    s_largura <=    37952;
		when "0000110" =>		s_largura <=	 38543;
		when "0000111" =>    s_largura <=    39133;
		when "0001000" =>		s_largura <=	 39724;
      when "0001001" =>    s_largura <=    40314;
		when "0001010" =>		s_largura <=	 40905;
      when "0001011" =>    s_largura <=    41495;
		when "0001100" =>		s_largura <=	 42086;
		when "0001101" =>    s_largura <=    42676;
		when "0001110" =>		s_largura <=	 43267;	
		when "0001111" =>    s_largura <=    43857;
		when "0010000" =>    s_largura <=    44448;
		when "0010001" =>    s_largura <=    45038;
		when "0010010" =>    s_largura <=    45629;
		when "0010011" =>    s_largura <=    46219;
		when "0010100" =>    s_largura <=    46810;
		when "0010101" =>    s_largura <=    47400;
		when "0010110" =>    s_largura <=    47991;
		when "0010111" =>    s_largura <=    48581;
      when "0011000" =>    s_largura <=    49172;
		when "0011001" =>    s_largura <=    49762;
		when "0011010" =>    s_largura <=    50353;
		when "0011011" =>    s_largura <=    50943;
		when "0011100" =>    s_largura <=    51534;
		when "0011101" =>    s_largura <=    52124;
		when "0011110" =>    s_largura <=    52715;
		when "0011111" =>    s_largura <=    53305;
		when "0100000" =>    s_largura <=    53896;
		when "0100001" =>    s_largura <=    54486;
		when "0100010" =>    s_largura <=    55077;
		when "0100011" =>    s_largura <=    55667;
		when "0100100" =>    s_largura <=    56258;
		when "0100101" =>    s_largura <=    56848;
		when "0100110" =>    s_largura <=    57439;
		when "0100111" =>    s_largura <=    58029;
		when "0101000" =>    s_largura <=    58620;
		when "0101001" =>    s_largura <=    59210;
		when "0101010" =>    s_largura <=    59801;
		when "0101011" =>    s_largura <=    60391;
		when "0101100" =>    s_largura <=    60982;
		when "0101101" =>    s_largura <=    61572;
		when "0101110" =>    s_largura <=    62163;
		when "0101111" =>    s_largura <=    62753;
		when "0110000" =>    s_largura <=    63344;
		when "0110001" =>    s_largura <=    63934;
		when "0110010" =>    s_largura <=    64525;
		when "0110011" =>    s_largura <=    65115;
		when "0110100" =>    s_largura <=    65706;
		when "0110101" =>    s_largura <=    66296;
		when "0110110" =>    s_largura <=    66887;
		when "0110111" =>    s_largura <=    67477;
		when "0111000" =>    s_largura <=    68068;
		when "0111001" =>    s_largura <=    68658;
		when "0111010" =>    s_largura <=    69249;
		when "0111011" =>    s_largura <=    69839;
		when "0111100" =>    s_largura <=    70430;
		when "0111101" =>    s_largura <=    71020;
		when "0111110" =>    s_largura <=    71611;
		when "0111111" =>    s_largura <=    72201;
		when "1000000" =>    s_largura <=    72792;
		when "1000001" =>    s_largura <=    73382;
		when "1000010" =>    s_largura <=    73973;
		when "1000011" =>    s_largura <=    74563;
		when "1000100" =>    s_largura <=    75154;
		when "1000101" =>    s_largura <=    75744;
		when "1000110" =>    s_largura <=    76335;
		when "1000111" =>    s_largura <=    76925;
		when "1001000" =>    s_largura <=    77516;
		when "1001001" =>    s_largura <=    78106;
		when "1001010" =>    s_largura <=    78697;
		when "1001011" =>    s_largura <=    79287;
		when "1001100" =>    s_largura <=    79878;
		when "1001101" =>    s_largura <=    80468;
		when "1001110" =>    s_largura <=    81059;
		when "1001111" =>    s_largura <=    81649;
		when "1010000" =>    s_largura <=    82240;
		when "1010001" =>    s_largura <=    83830;
		when "1010010" =>    s_largura <=    83421;
		when "1010011" =>    s_largura <=    84011;
		when "1010100" =>    s_largura <=    84602;
		when "1010101" =>    s_largura <=    85192;
		when "1010110" =>    s_largura <=    85783;
		when "1010111" =>    s_largura <=    86373;
		when "1011000" =>    s_largura <=    86964;
		when "1011001" =>    s_largura <=    87554;
		when "1011010" =>    s_largura <=    88145;
		when "1011011" =>    s_largura <=    88735;
		when "1011100" =>    s_largura <=    89326;
		when "1011101" =>    s_largura <=    89916;
		when "1011110" =>    s_largura <=    90507;
		when "1011111" =>    s_largura <=    91097;
		when "1100000" =>    s_largura <=    91688;
		when "1100001" =>    s_largura <=    92278;
		when "1100010" =>    s_largura <=    92869;
		when "1100011" =>    s_largura <=    93459;
		when "1100100" =>    s_largura <=    94050;
		when "1100101" =>    s_largura <=    94640;
		when "1100110" =>    s_largura <=    95231;
		when "1100111" =>    s_largura <=    95821;
		when "1101000" =>    s_largura <=    96412;
		when "1101001" =>    s_largura <=    97002;
		when "1101010" =>    s_largura <=    97593;
		when "1101011" =>    s_largura <=    98183;
		when "1101100" =>    s_largura <=    98774;
		when "1101101" =>    s_largura <=    99364;
		when "1101110" =>    s_largura <=    99955;
		when "1101111" =>    s_largura <=    100545;
		when "1110000" =>    s_largura <=    101136;
		when "1110001" =>    s_largura <=    101726;
		when "1110010" =>    s_largura <=    102317;
		when "1110011" =>    s_largura <=    102907;
		when "1110100" =>    s_largura <=    103498;
		when "1110101" =>    s_largura <=    104088;
		when "1110110" =>    s_largura <=    104679;
		when "1110111" =>    s_largura <=    105269;
		when "1111000" =>    s_largura <=    105860;
		when "1111001" =>    s_largura <=    106450;
		when "1111010" =>    s_largura <=    107041;
		when "1111011" =>    s_largura <=    107631;
		when "1111100" =>    s_largura <=    108222;
		when "1111101" =>    s_largura <=    108812;
		when "1111110" =>    s_largura <=    109403;
		when "1111111" =>    s_largura <=    110000; -- 2.2 ms
		when others =>   	s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
db_posicao <= posicao;
  
end controle_servo_3_arch;