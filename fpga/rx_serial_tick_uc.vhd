library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_uc is
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
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazenamento, final, dado_presente);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado
	 
begin

  -- memoria de estado
  process (reset, clock, dado_serial)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (Eatual, fim, dado_serial, tick) 
  begin

    case Eatual is

      when inicial =>      if dado_serial='0' then Eprox <= preparacao;
                           else                Eprox <= inicial;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>       if tick='1' then   Eprox <= recepcao;
                           elsif fim='0' then Eprox <= espera;
                           else               Eprox <= armazenamento;
                           end if;
									
      when armazenamento => Eprox <= final;

      when recepcao =>  	Eprox <= espera;

      when final =>        Eprox <= dado_presente;
		
      when dado_presente =>if dado_serial='1' then   Eprox <= dado_presente;
                           else               Eprox <= preparacao;
                           end if;

      when others =>       Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      carrega <= '1' when preparacao, '0' when others;

  with Eatual select
     limpa <= '1' when preparacao, '0' when others;
  with Eatual select
  
      zera <= '1' when preparacao, '0' when others;
		
  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;
		
  with Eatual select
      registra <= '1' when armazenamento, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;
		
  with Eatual select
      tem_dado <= '1' when dado_presente, '0' when others;
					
   with Eatual select
      db_estado <= "0000" when inicial,     -- 0
					"0001" when preparacao,  -- 1
					"0010" when espera,    -- 2
					"0011" when recepcao,  -- 3
					"0100" when armazenamento,     -- 4
					"0101" when final,     -- 5
					"0110" when dado_presente,     -- 6						
					"0111" when others;      		

end architecture rx_serial_uc_arch;
