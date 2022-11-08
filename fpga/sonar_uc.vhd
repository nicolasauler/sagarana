library ieee;
use ieee.std_logic_1164.all;

entity sonar_uc is
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
end entity sonar_uc;

architecture sonar_uc_arch of sonar_uc is

    type tipo_estado is (inicial, preparacao, conta2s, espera2s, medida, aguarda_medida, transmite_centena,
	 espera_centena, transmite_dezena, espera_dezena, transmite_unidade, espera_unidade,transmite_especial, espera_especial, muda_transmissao, fim_pos, espera_r);
								
    signal Eatual, Eprox: tipo_estado;
	 
begin

    -- estado
    process (reset, ligar, clock)
    begin
        if reset = '1' or ligar = '0' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (Eatual, ligar, pronto_medicao, pronto_transmissao, sel_transmissao, pronto2s, recebe_serial)
	 
    begin
	 
      case Eatual is
		
        when inicial => Eprox <= preparacao;
		  
		  when preparacao => Eprox <= conta2s;
		  
		  when conta2s => Eprox <= espera2s;
		  
		  when espera2s => if recebe_serial = "01" then Eprox <= espera_r; 
		  
								elsif pronto2s = '1' then Eprox <= medida; else Eprox <= espera2s; end if;
								
		  when espera_r => if recebe_serial = "10" then Eprox <= conta2s; else Eprox <= espera_r; end if;
		  
		  when medida => Eprox <= aguarda_medida;
		  
		  when aguarda_medida => if pronto_medicao = '0' then Eprox <= aguarda_medida; else Eprox <= transmite_centena; end if;
		  
        when transmite_centena => Eprox <= espera_centena;
		  
		  when espera_centena => if pronto_transmissao = '0' then Eprox <= espera_centena; else Eprox <= transmite_dezena; end if;
		  
        when transmite_dezena => Eprox <= espera_dezena;
		  
		  when espera_dezena => if pronto_transmissao = '0' then Eprox <= espera_dezena; else Eprox <= transmite_unidade; end if;
		  
        when transmite_unidade => Eprox <= espera_unidade;
		  
		  when espera_unidade => if pronto_transmissao = '0' then Eprox <= espera_unidade; else Eprox <= transmite_especial; end if;
		  
        when transmite_especial =>  Eprox <= espera_especial;
		  
		  when espera_especial => if pronto_transmissao = '0' then Eprox <= espera_especial; elsif sel_transmissao = '0' then Eprox <= muda_transmissao; else Eprox <= fim_pos; end if;
		  
		  when muda_transmissao => Eprox <= transmite_centena;
		  
		  when fim_pos => Eprox <= conta2s;
		  
        when others => Eprox <= inicial;
		  
      end case;
		
    end process;

  -- saidas de controle
  with Eatual select
		conta_pos <= '1' when fim_pos, '0' when others;
		
  with Eatual select
		zera2s <= '1' when conta2s, '0' when others;
		
  with Eatual select
		reseta_tudo <= '1' when preparacao, '0' when others;
		
  with Eatual select
      medir <= '1' when medida, '0' when others;
		
  with Eatual select
	   transmite <= '1' when transmite_centena | transmite_dezena | transmite_unidade | transmite_especial, '0' when others;
		
  with Eatual select		
		sel_caractere <= "00" when transmite_centena | espera_centena,
				 "01" when transmite_dezena  | espera_dezena,
				 "10" when transmite_unidade  | espera_unidade,
				 "11" when transmite_especial  | espera_especial,
				 "00" when others;
				 
  with Eatual select				 
      set_ff <= '1' when muda_transmissao, '0' when others;
		
  with Eatual select				 
      reset_ff <= '1' when conta2s, '0' when others;
  
  with Eatual select
		fim_posicao <= '1' when fim_pos, '0' when others; 
						
		
  with Eatual select		
		db_estado <= "0000" when inicial,
						 "0001" when preparacao,
					    "0010" when conta2s,
						 "0011" when espera2s,
						 "0100" when medida,
						 "0101" when aguarda_medida,
						 "0110" when transmite_centena,
						 "0111" when espera_centena,
						 "1000" when transmite_dezena,
						 "1001" when espera_dezena,
						 "1010" when transmite_especial,
						 "1011" when espera_especial,
						 "1100" when muda_transmissao,
						 "1101" when fim_pos,
						 "1110" when espera_r,
						 "0000" when others;

end architecture sonar_uc_arch;