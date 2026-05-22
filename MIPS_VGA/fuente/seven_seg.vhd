----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:36:14 10/12/2022 
-- Design Name: 
-- Module Name:    seven_seg - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg is
    Port ( sel : in  STD_LOGIC;
			  reset : in std_logic;
           write_cnt2 : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (9 downto 0);
           sevenSegment : out  STD_LOGIC_VECTOR (7 downto 0);
           SevenSegmentEnable : out  STD_LOGIC_VECTOR (2 downto 0));
end seven_seg;

--Implementación de tres dígitos
architecture Behavioral of seven_seg is

	signal digito,C,D,U : std_logic_vector(3 downto 0);
	signal valorC, valorD, valorU: unsigned(9 downto 0);
	signal contador : unsigned(1 downto 0);
	signal contadorclk : unsigned(14 downto 0);
	signal clkreduc : std_logic;

begin

ENTRADA: process(sel, clk, write_cnt2, data_in)
begin
	if(clk'event and clk='1') then
		if(reset='1')then
			valorC <= to_unsigned(0,10);
		else
			if(write_cnt2='1' and sel='1')then
				valorC <= unsigned(data_in);
			end if;
		end if;
	end if;
end process;

REDUCTORCLK: process(clk, contadorclk)
begin
	if(clk'event and clk='1') then
		if(reset='0')then
			if (contadorclk<12500) then
				contadorclk <= contadorclk +1;
				clkreduc <= '0';
			elsif(contadorclk<25000)then
				contadorclk <= contadorclk +1;
				clkreduc <= '1';
			else
				contadorclk <= to_unsigned(0,15);
				clkreduc <= clkreduc;
			end if;
		else
			contadorclk <= to_unsigned(0,15);
		end if;
	end if;
end process;



DIGITALIZADORC: process(clk, valorC)
begin
	if(clk'event and clk='1') then
		--centena
		if (valorC>999) then
			C <= "1110";
			valorD <= valorC;
		elsif (valorC>=900) then
			C <= "1001";
			valorD <= valorC-900;
		elsif (valorC>=800) then
			C <= "1000";
			valorD <= valorC-800;
		elsif (valorC>=700) then
			C <= "0111";
			valorD <= valorC-700;
		elsif (valorC>=600) then
			C <= "0110";
			valorD <= valorC-600;
		elsif (valorC>=500) then
			C <= "0101";
			valorD <= valorC-500;
		elsif (valorC>=400) then
			C <= "0100";
			valorD <= valorC-400;
		elsif (valorC>=300) then
			C <= "0011";
			valorD <= valorC-300;
		elsif (valorC>=200) then
			C <= "0010";
			valorD <= valorC-200;
		elsif (valorC>=100) then
			C <= "0001";
			valorD <= valorC-100;
		else
			C <= "1111";
			valorD <= valorC;
		end if;
	end if;
end process;

DIGITALIZADORD: process(clk, valorD)
begin
	if(clk'event and clk='1') then
		--Decena
		if (valorD>99) then
			D <= "1110";
			valorU <= valorD;
		elsif (valorD>=90) then
			D <= "1001";
			valorU <= valorD-90;
		elsif (valorD>=80) then
			D <= "1000";
			valorU <= valorD-80;
		elsif (valorD>=70) then
			D <= "0111";
			valorU <= valorD-70;
		elsif (valorD>=60) then
			D <= "0110";
			valorU <= valorD-60;
		elsif (valorD>=50) then
			D <= "0101";
			valorU <= valorD-50;
		elsif (valorD>=40) then
			D <= "0100";
			valorU <= valorD-40;
		elsif (valorD>=30) then
			D <= "0011";
			valorU <= valorD-30;
		elsif (valorD>=20) then
			D <= "0010";
			valorU <= valorD-20;
		elsif (valorD>=10) then
			D <= "0001";
			valorU <= valorD-10;
		else
			if(C="1111")then
				D <= "1111";
			else 
				D <= "0000";
			end if;
			valorU <= valorD;
		end if;
	end if;
end process;

DIGITALIZADORU: process(clk, valorU)
begin
	if(clk'event and clk='1') then
		--Unidad
		if (valorU>9) then
			U <= "1110";
		elsif (valorU=9) then
			U <= "1001";
		elsif (valorU=8) then
			U <= "1000";
		elsif (valorU=7) then
			U <= "0111";
		elsif (valorU=6) then
			U <= "0110";
		elsif (valorU=5) then
			U <= "0101";
		elsif (valorU=4) then
			U <= "0100";
		elsif (valorU=3) then
			U <= "0011";
		elsif (valorU=2) then
			U <= "0010";
		elsif (valorU=1) then
			U <= "0001";
		else
			U <= "0000";
		end if;
	end if;
end process;

CAMBIADOR: process(clkreduc)
begin
	if(clkreduc'event and clkreduc='1') then
		if(reset='0')then
			contador <= contador+1;
		else
			contador <= to_unsigned(3,2);
		end if;
	end if;
end process;

with digito select
		sevenSegment <=  "11111001" when "0001",   --1
         "10100100" when "0010",   --2
         "10110000" when "0011",   --3
         "10011001" when "0100",   --4
         "10010010" when "0101",   --5
         "10000010" when "0110",   --6
         "11111000" when "0111",   --7
         "10000000" when "1000",   --8
         "10010000" when "1001",   --9
         "10001000" when "1010",   --A
         "10000011" when "1011",   --b
         "11000110" when "1100",   --C
         "10100001" when "1101",   --d
         "10000110" when "1110",   --E
         "11111111" when "1111",   --F (todo apagado)
         "11000000" when others;   --0

with contador select
	sevenSegmentEnable <= "110" when to_unsigned(0,2),
								 "101" when to_unsigned(1,2),
								 "011" when to_unsigned(2,2),
								 "111" when others;

with contador select
	digito <= U when to_unsigned(0,2),
				 D when to_unsigned(1,2),
				 C when to_unsigned(2,2),
				 "1111" when others;


end Behavioral;

