library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	 port (
	 clock : in std_logic;
	 reset : in std_logic;
	 posicao : in std_logic_vector(2 downto 0);
    pwm     : out std_logic;
	 db_pwm : out std_logic;
	 db_posicao : out std_logic_vector(2 downto 0)
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
      when "000" =>    s_largura <=    35000;  -- pulso de 0.7 ms
      when "001" =>    s_largura <=    45700;  -- pulso de 0.914 ms
      when "010" =>    s_largura <=    56450;  -- pulso de 1.129 ms
		when "011" =>    s_largura <=    67150;  -- pulso de 1.343 ms
      when "100" =>    s_largura <=    77850;  -- pulso de 1.557 ms
      when "101" =>    s_largura <=    88550;  -- pulso de 1.771 ms
		when "110" =>    s_largura <=    99300;  -- pulso de 1.986 ms
		when "111" =>    s_largura <=    110000; -- pulso de 2.2 ms
      when others =>   s_largura <=     0;  -- nulo   saida 0
    end case;
  end process;
  
db_posicao <= posicao;
  
end controle_servo_3_arch;