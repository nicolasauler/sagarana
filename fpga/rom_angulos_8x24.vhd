-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : rom_angulos_8x24.vhd
-- Projeto   : Experiencia 6 - Sistema de Sonar
-------------------------------------------------------------------------
-- Descricao : 
--             memoria rom 8x24 (descricao comportamental)
--             conteudo com 8 posicoes angulares predefinidos
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/09/2019  1.0     Edson Midorikawa  criacao
--     01/10/2020  1.1     Edson Midorikawa  revisao
--     09/10/2021  1.2     Edson Midorikawa  revisao
--     24/09/2022  1.3     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_angulos_16x24 is
    port (
        endereco : in  std_logic_vector(3 downto 0);
        saida    : out std_logic_vector(23 downto 0)
    ); 
end entity;

architecture rom_arch of rom_angulos_16x24 is
    type memoria_16x24 is array (integer range 0 to 15) of std_logic_vector(23 downto 0);
    constant tabela_angulos: memoria_16x24 := (
		  x"303030",
        x"303132", 
		  x"303234",
        x"303336", 
		  x"303438",
        x"303630", 
		  x"303732",
        x"303834", 
		  x"303936",
        x"313038", 
		  x"313230",
        x"313332", 
		  x"313434",
        x"313536", 
		  x"313638",
        x"313830"  
    );
begin

    saida <= tabela_angulos(to_integer(unsigned(endereco)));

end architecture rom_arch;
