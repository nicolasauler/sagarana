library ieee;
use ieee.std_logic_1164.all;

entity sagarana_uc is
	 port (
		clock : in std_logic;
		reset : in std_logic;
		ligar: in std_logic;
		pronto_dados: in std_logic;
		pronto_transmissao: in std_logic;
		sel_transmissao: in std_logic;
		prontoPausa: in std_logic;
		recebe_serial: in std_logic_vector(1 downto 0);
		conta_pos: out std_logic;
		zeraPausa: out std_logic;
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
end entity sagarana_uc;

architecture sagarana_uc_arch of sagarana_uc is

    type tipo_estado is (inicial, preparacao, contaPausa, esperaPausa, solicita_dados, aguarda_dados, armazena_dado, pula_medida, transmite_centena,
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
    process (Eatual, ligar, pronto_dados, pronto_transmissao, sel_transmissao, prontoPausa, recebe_serial)
	 
    begin
	 
      case Eatual is
		
        when inicial => Eprox <= preparacao;
		  
		  when preparacao => Eprox <= contaPausa;
		  
		  when contaPausa => Eprox <= esperaPausa;
		  
		  when esperaPausa => if recebe_serial = "01" then Eprox <= espera_r; 
		  
								elsif prontoPausa = '1' then Eprox <= solicita_dados; else Eprox <= esperaPausa; end if;
								
		  when espera_r => if recebe_serial = "10" then Eprox <= contaPausa; else Eprox <= espera_r; end if;
		  
		  when solicita_dados => Eprox <= aguarda_dados;
		  
		  when aguarda_dados => if prontoPausa = '1' then Eprox <= pula_medida; elsif pronto_dados = '1' then Eprox <= armazena_dado; else Eprox <= aguarda_dados; end if;
		  
		  when armazena_dado => Eprox <= transmite_centena;
		  
		  when pula_medida => Eprox <= transmite_centena;
        
		  when transmite_centena => Eprox <= espera_centena;
		  
		  when espera_centena => if pronto_transmissao = '0' then Eprox <= espera_centena; else Eprox <= transmite_dezena; end if;
		  
        when transmite_dezena => Eprox <= espera_dezena;
		  
		  when espera_dezena => if pronto_transmissao = '0' then Eprox <= espera_dezena; else Eprox <= transmite_unidade; end if;
		  
        when transmite_unidade => Eprox <= espera_unidade;
		  
		  when espera_unidade => if pronto_transmissao = '0' then Eprox <= espera_unidade; else Eprox <= transmite_especial; end if;
		  
        when transmite_especial =>  Eprox <= espera_especial;
		  
		  when espera_especial => if pronto_transmissao = '0' then Eprox <= espera_especial; elsif sel_transmissao = '0' then Eprox <= muda_transmissao; else Eprox <= fim_pos; end if;
		  
		  when muda_transmissao => Eprox <= transmite_centena;
		  
		  when fim_pos => Eprox <= contaPausa;
		  
        when others => Eprox <= inicial;
		  
      end case;
		
    end process;

  -- saidas de controle
  with Eatual select
		conta_pos <= '1' when fim_pos, '0' when others;
		
  with Eatual select
		zeraPausa <= '1' when contaPausa | solicita_dados, '0' when others;
		
  with Eatual select
		reseta_tudo <= '1' when preparacao, '0' when others;
		
  with Eatual select
		armazena <= '1' when armazena_dado, '0' when others;
		
  with Eatual select
		reset_interface <= '1' when pula_medida, '0' when others;
		
  with Eatual select
      sol_dados <= '1' when solicita_dados, '0' when others;
		
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
      reset_ff <= '1' when contaPausa, '0' when others;
  
  with Eatual select
		fim_posicao <= '1' when fim_pos, '0' when others; 
						
		
  with Eatual select		
		db_estado <= "0000" when inicial, --lembrar que 0 pode ser "espera_r" tbm, mas acho que esse estado vai deixar de existir :)
						 "0001" when preparacao,
					    "0010" when contaPausa,
						 "0011" when esperaPausa,
						 "0100" when solicita_dados,
						 "0101" when aguarda_dados,
						 "0110" when armazena_dado,
						 "0111" when pula_medida,
						 "1000" when transmite_centena,
						 "1001" when espera_centena,
						 "1010" when transmite_dezena,
						 "1011" when espera_dezena,
						 "1100" when transmite_especial,
						 "1101" when espera_especial,
						 "1110" when muda_transmissao,
						 "1111" when fim_pos,
						 "0000" when others;

end architecture sagarana_uc_arch;