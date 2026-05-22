----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:26:37 10/12/2022 
-- Design Name: 
-- Module Name:    vga_gen_imagen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_generator is
	Port (
			hsync : in std_logic;
			--hctr : in std_logic_vector (10 downto 0);
			vctr : in std_logic_vector (9 downto 0);
			blank : in std_logic; -- blank interval signal
			clk50MHz : in std_logic; -- main clock
			clk : in std_logic; -- main clock
			reset : in std_logic; -- global reset
			writeBuffer: in std_logic;
			readBuffer: in std_logic;
			siEscribirBuffer: in std_logic;
			dir: in std_logic_vector(9 downto 0);
			datos: in std_logic_vector(31 downto 0);
			datosOUT: out std_logic_vector(31 downto 0);
			R : out std_logic; -- Red colour signal
			G : out std_logic; -- Green colour signal
			B : out std_logic); -- Blue colour signal
end image_generator;

architecture Behavioral of image_generator is

	signal hctr_int : integer range 1586 downto 0;
	signal vctr_int : integer range 524 downto 0;
	signal R_int, G_int, B_int: std_logic;
	signal color: std_logic_vector (2 downto 0);
	signal pixel : std_logic;
	--Se crea el búfer de memoria de video (32x24 blanco y negro)
	type memBuffer is array (0 to 23) of std_logic_vector(31 downto 0);
	signal videoBuffer : memBuffer;
	signal posx, posy, conty : unsigned(4 downto 0);
	signal contx : unsigned(5 downto 0);

begin
--hctr_int <= to_INTEGER(unsigned(hctr));
vctr_int <= to_INTEGER(unsigned(vctr));
-- utilizamos biestables de salida para evitar posibles Glitches
-- Iniiciaizamos los biestables a cero
process (clk50MHz,reset,R_int,G_int,B_int)
begin
	if clk50MHz='1' and clk50MHz'event then
		if (reset = '1' or blank='0')  then
			R <= '0';
			G <= '0';
			B <= '0';
		else
			R <= R_int;
			G <= G_int;
			B <= B_int;
		end if;
	end if;
end process;
-- Colores obtenidos en función de R G B (1 bit per signal)
-- 000: black
-- 001: blue
-- 010: green
-- 011: cyan

-- Circuito combinacional que genera los colores de cada franja
-- en función de la posición horizontal de cada punto
-- franja vertical blanca de la izda
--color <= "111" when ((hctr_int >= 0) and (hctr_int < 308) and (blank = '1'))
--	else
---- aquí comienza la imagen de 640 x 480
---- que consiste en 7 barras verticales de diferentes colores
--	"001" when ((hctr_int >= 308) and (hctr_int < 399) and (blank = '1')) else
--	"010" when ((hctr_int >= 399) and (hctr_int < 490) and (blank = '1')) else
--	"011" when ((hctr_int >= 490) and (hctr_int < 581) and (blank = '1')) else
--	"111" when ((hctr_int >= 581) and (hctr_int < 672) and (blank = '1')) else
--	"101" when ((hctr_int >= 672) and (hctr_int < 763) and (blank = '1')) else
--	"110" when ((hctr_int >= 763) and (hctr_int < 854) and (blank = '1')) else
--	"100" when ((hctr_int >= 854) and (hctr_int <= 948) and (blank = '1')) else
--	"111" when ((hctr_int > 948) and (hctr_int <= 1257) and (blank = '1')) else
--	"000"; -- Intérvalos blank (blank = 0)
--R_int <= color(2);
--G_int <= color(1);
--B_int <= color(0);

--Parte de escritura del buffer de memoria con el clk mips
ESCRIBIRBUFFER: process(clk, datos, dir)
begin
	if(clk'event and clk='1')then
		if(reset='0')then
			if(writebuffer='1' and siEscribirBuffer='1') then
				if(unsigned(dir)<24)then
					videoBuffer(to_integer(unsigned(dir))) <= datos;
				end if;
			end if;
		else
			videoBuffer <= (others=>(others=>'0'));
		end if;
	end if;
end process;

--Contadores para determinar la posicion del puntero del framebuffer basado en 
CONTPOSX: process(clk50mhz, contx, posx, reset, blank)
begin
	if(clk50mhz'event and clk50mhz='1')then
		if(reset='1' or blank='0')then
			contx <= to_unsigned(0,6);
			posx <=to_unsigned(0,5);
		else
			if(contx=38)then
				contx <= to_unsigned(0,6);
				if(posx=31)then
					posx <= posx;
				else
					posx <= posx + 1;
				end if;
			else
				contx <= contx + 1;
				posx <= posx;
			end if;
		end if;
	end if;
end process;


CONTPOSY: process(hsync)
begin
	if(hsync'event and hsync='0')then
		if(reset='1' or vctr_int>479)then
			posy <= to_unsigned(0,5);
			conty <= to_unsigned(0,5);
		else
			if(conty = 19)then
			   conty <= to_unsigned(0,5);
				if(posy = 23)then
					posy <= posy;
				else
					posy <= posy+1;
				end if;
			else
				conty <= conty + 1;
				posy <= posy;
			end if;
		end if;
	end if;
end process;

pixel <= videoBuffer(to_integer(posy))(to_integer(31-posx));
R_int <= pixel;
G_int <= pixel;
B_int <= pixel;

LeerBuffer: process(readBuffer,siEscribirBuffer,videoBuffer,dir)
begin
if(readBuffer='1' and siEscribirBuffer='1')then
	datosOUT <= videoBuffer(to_integer(unsigned(dir)));
else
	datosOUT <= x"00000000";
end if;
end process;

end Behavioral;

