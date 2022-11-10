library ieee;
use ieee.std_logic_1164.all;

entity interface_esp32_uc is 
    port ( 
        clock       : in  std_logic;
		  reset		  : in std_logic;
		  start       : in std_logic;
		  pronto_rx   : in std_logic;
		  armazena_u  : out std_logic;
		  armazena_d  : out std_logic;
		  armazena_c  : out std_logic;
		  pronto      : out std_logic;
		  zera        : out std_logic;
		  sel_envio   : out std_logic_vector(1 downto 0);
		  db_estado   : out std_logic_vector(3 downto 0)
    );
end interface_esp32_uc;

architecture fsm_arch of interface_esp32_uc is
    type tipo_estado is (inicial, preparacao, 
                         aguarda_unidade, armazena_unidade, aguarda_dezena, armazena_dezena, aguarda_centena, armazena_centena, final);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (start, pronto_rx, Eatual) 
    begin
      case Eatual is
        when inicial =>         if start='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= aguarda_unidade;
        when aguarda_unidade =>  if pronto_rx='0' then Eprox <= aguarda_unidade;
                                else             Eprox <= armazena_unidade;
                                end if;
		  when armazena_unidade => Eprox <= aguarda_dezena;
		  when aguarda_dezena =>  if pronto_rx='0' then Eprox <= aguarda_dezena;
                                else             Eprox <= armazena_dezena;
                                end if;
		  when armazena_dezena => Eprox <= aguarda_centena;
		  when aguarda_centena =>  if pronto_rx='0' then Eprox <= aguarda_centena;
                                else             Eprox <= armazena_centena;
                                end if;
        when armazena_centena =>   Eprox <= final;
        when final =>           Eprox <= inicial;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera <= '1' when preparacao, '0' when others;
  with Eatual select
      sel_envio <= "01" when aguarda_unidade | armazena_unidade, 
						 "10" when aguarda_dezena  | armazena_dezena,
						 "11" when aguarda_centena | armazena_centena,
						 "00" when others;
	
  with Eatual select
		armazena_u <= '1' when armazena_unidade,
						'0' when others;
  with Eatual select
		armazena_d <= '1' when armazena_dezena,
						'0' when others;
  with Eatual select
		armazena_c <= '1' when armazena_centena,
						'0' when others;
	
  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when preparacao, 
                   "0010" when aguarda_unidade, 
                   "0011" when armazena_unidade,
                   "0100" when aguarda_dezena, 
                   "0101" when armazena_dezena, 
                   "0110" when aguarda_centena,
						 "0111" when armazena_centena,
						 "1000" when final,
                   "1111" when others;

end architecture fsm_arch;