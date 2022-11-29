--------------------------------------------------------------------
-- Arquivo   : interface_esp32_tb.vhd
-- Projeto   : Sagarana
--------------------------------------------------------------------
-- Descricao : testbench para componente interface_esp32 baseado no
--             testbench rx_serial_tb.vhd  
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/11/22     1.0    Bancada A6        v1
--                         Izabela Marina
--                         Lucas Ramos
--                         Nicolas Auler
--
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_esp32_tb is
end entity;

architecture tb of interface_esp32_tb is
  
    -- Declara��o de sinais para conectar o componente a ser testado (DUT)
    signal clock_in              : std_logic  := '0';
    signal reset_in              : std_logic  := '0';
    signal start_in              : std_logic  := '0';
    -- saidas
    signal pronto_out            : std_logic  := '0';
    signal sel_envio_out         : std_logic_vector(1 downto 0) := "00";
    signal distancia_out         : std_logic_vector(23 downto 0) := x"000000";
  
    -- para procedimento UART_WRITE_BYTE
    signal entrada_serial_in : std_logic := '1';
    signal serialData        : std_logic_vector(7 downto 0) := "00000000";
  
    -- Configura��es do clock
    constant clockPeriod : time := 20 ns;            -- 50MHz
    -- constant bitPeriod   : time := 5208*clockPeriod; -- 5208 clocks por bit (9.600 bauds)
    constant bitPeriod   : time := 434*clockPeriod;  -- 434 clocks por bit (115.200 bauds)
    
    ---- UART_WRITE_BYTE()
    -- Procedimento para geracao da sequencia de comunicacao serial 8N2
    -- adaptacao de codigo acessado de:
    -- https://www.nandland.com/goboard/uart-go-board-project-part1.html
    procedure UART_WRITE_BYTE (
        Data_In : in  std_logic_vector(7 downto 0);
        signal Serial_Out : out std_logic ) is
    begin
  
        -- envia Start Bit
        Serial_Out <= '0';
        wait for bitPeriod;
  
        -- envia 8 bits seriais (dados)
        for ii in 0 to 7 loop
            Serial_Out <= Data_In(ii);
            wait for bitPeriod;
        end loop;  -- loop ii
  
        -- envia 2 Stop Bits
        Serial_Out <= '1';
        wait for 2*bitPeriod;
  
    end UART_WRITE_BYTE;
    -- fim procedure
  
    ---- Array de casos de teste
    type caso_teste_type is record
        id   : natural;
        data0 : std_logic_vector(7 downto 0);
        data1 : std_logic_vector(7 downto 0);
        data2 : std_logic_vector(7 downto 0);     
    end record;
  
    type casos_teste_array is array (natural range <>) of caso_teste_type;
    constant casos_teste : casos_teste_array :=
        (
            (1, "00110100","00110011","00110001"), --134
            (2, "00110000","00110000","00110010"), --200 
	        (3, "00110000","00110000","00110000")  --000 
        );
    signal caso : natural;
  
    ---- controle do clock e simulacao
    signal keep_simulating: std_logic := '0'; -- delimita o tempo de gera��o do clock
  
  
begin
 
    ---- Gerador de Clock
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
    
    -- Instancia��o direta DUT (Device Under Test)
    DUT: entity work.interface_esp32
         port map (  
            clock => clock_in,
            reset => reset_in,
            entrada_serial => entrada_serial_in,
            sel_envio => sel_envio_out,
            start => start_in,
            distancia => distancia_out,
            pronto => pronto_out,
            db_estado => open
         );
    
    ---- Geracao dos sinais de entrada (estimulo)
    stimulus: process is
    begin
    
        ---- inicio da simulacao
        assert false report "inicio da simulacao" severity note;
        keep_simulating <= '1';
        -- reset com 5 periodos de clock
        reset_in <= '0';
        -- wait for bitPeriod;
        reset_in <= '1', '0' after 5*clockPeriod; 
        wait for bitPeriod;
      
        ---- loop pelos casos de teste
        for i in casos_teste'range loop
            caso <= casos_teste(i).id;
            assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;
            serialData <= casos_teste(i).data0; -- caso de teste "i"
            -- aguarda 2 periodos de bit antes de enviar bits
            wait for 2*bitPeriod;

            -- inicia circuito
            start_in <= '1';
            wait until rising_edge(clock_in);
            wait for clockPeriod; -- pulso partida
            start_in <= '0';

            -- aguarda solicitação da unidade
            assert false report "Aguardando unidade" severity note;
            wait until sel_envio_out="01";

            -- envia bits seriais para circuito de recepcao
            assert false report "Enviando unidade" severity note;
            UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>entrada_serial_in );
            entrada_serial_in <= '1'; -- repouso
            wait for bitPeriod;
            serialData <= casos_teste(i).data1;

            assert false report "Enviando dezena" severity note;
            UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>entrada_serial_in );
            entrada_serial_in <= '1'; -- repouso
            wait for bitPeriod;
            serialData <= casos_teste(i).data2;

            assert false report "Enviando centena" severity note;
            UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>entrada_serial_in );
            entrada_serial_in <= '1'; -- repouso
            wait for bitPeriod;
      
            -- 2) intervalo entre casos de teste
            wait for 2*bitPeriod;
            assert false report "Fim caso" severity note;
        end loop;
      
        ---- final dos casos de teste da simulacao
        -- reset
        reset_in <= '0';
        wait for bitPeriod;
        reset_in <= '1', '0' after 5*clockPeriod; 
        wait for bitPeriod;
      
        ---- final da simulacao
        assert false report "fim da simulacao" severity note;
        keep_simulating <= '0';
        
        wait; -- fim da simula��o: aguarda indefinidamente
    
    end process stimulus;

end architecture tb;