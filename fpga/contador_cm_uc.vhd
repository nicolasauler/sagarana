library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_uc is
    port (
        clock      : in  std_logic;
		  reset      : in  std_logic;
		  fim        : in  std_logic;
		  edge_start : in std_logic;
		  edge_fim   : in std_logic;
        arredonda  : in  std_logic;
		  tick       : in  std_logic;
        conta_bcd  : out std_logic;
        zera_bcd   : out std_logic;
		  conta_tick : out std_logic;
        zera_tick  : out std_logic;
        pronto     : out std_logic
    );
end entity;

architecture contador_cm_uc_arch of contador_cm_uc is

    type tipo_estado is (inicial, preparacao, contagem, adiciona, aproxima, final);
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
    process (fim, edge_start, edge_fim, arredonda, tick, Eatual) 
    begin
      case Eatual is
		
        when inicial =>         if edge_start='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
										  end if;
										  
        when preparacao =>      Eprox <= contagem;
		  
        when contagem =>        if edge_fim = '1' and arredonda = '1' then Eprox <= aproxima;
		                          elsif edge_fim = '1' and arredonda = '0' then Eprox <= final;
										  elsif tick='1' then  Eprox <= adiciona;
										  else Eprox <= contagem;
                                end if;
										  
        when adiciona =>        if edge_fim ='1' and arredonda = '1' then Eprox <= aproxima;
			                       elsif edge_fim = '1' and arredonda = '0' then Eprox <= final;
                                else Eprox <= contagem;
                                end if;
										  
        when aproxima =>        Eprox <= final;
									  
        when final =>           if edge_start = '1' then Eprox <= preparacao;
		                          else Eprox <= final;
										  end if;

        when others =>          Eprox <= inicial;
		  
      end case;
		
    end process;

  -- saidas de controle
  with Eatual select
      conta_tick <= '0' when aproxima | final, '1' when others;
  with Eatual select
      zera_tick <= '1' when preparacao, '0' when others;
  with Eatual select
      conta_bcd <= '1' when adiciona | aproxima , '0' when others;
  with Eatual select
      zera_bcd <= '1' when preparacao, '0' when others;
  with Eatual select
      pronto <= '1' when final, '0' when others;
	 
end architecture;