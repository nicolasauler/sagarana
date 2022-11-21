library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	 port (
	 clock : in std_logic;
	 reset : in std_logic;
	 posicao : in std_logic_vector(3 downto 0);
    pwm     : out std_logic;
	 db_pwm : out std_logic;
	 db_posicao : out std_logic_vector(3 downto 0)
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
		when "0000" => 	s_largura <=	 50000;
      when "0001" =>    s_largura <=    53333;
		when "0010" =>		s_largura <=	 57000;
      when "0011" =>    s_largura <=    60000;
		when "0100" =>		s_largura <=	 63333;
      when "0101" =>    s_largura <=    67000;
		when "0110" =>		s_largura <=	 70000;
		when "0111" =>    s_largura <=    73333;
		when "1000" =>		s_largura <=	 77000;
      when "1001" =>    s_largura <=    80000;
		when "1010" =>		s_largura <=	 83333;
      when "1011" =>    s_largura <=    87000;
		when "1100" =>		s_largura <=	 90000;
		when "1101" =>    s_largura <=    93333;
		when "1110" =>		s_largura <=	 97000;	
		when "1111" =>    s_largura <=    100000;
      when others =>   	s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
db_posicao <= posicao;
  
end controle_servo_3_arch;