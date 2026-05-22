----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:08:22 10/20/2022 
-- Design Name: 
-- Module Name:    contador_miliseg - Behavioral 
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

entity contador_miliseg is
    Port ( clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
           miliseg : out  STD_LOGIC_VECTOR (31 downto 0);
           escribir : in  STD_LOGIC;
           csMilliseg : in  STD_LOGIC);
end contador_miliseg;

architecture Behavioral of contador_miliseg is
	signal contador : unsigned(14 downto 0);
	signal Milisegundos: unsigned(31 downto 0);

begin
OP: process(clk, escribir, csMilliseg)
begin
	if(clk'event and clk='1')then
		if(reset='0')then
			if(csMilliseg='1')then
				if(escribir='1')then
					Milisegundos <= to_unsigned(0,32);
					contador <= to_unsigned(0,15);
				end if;
			else
				if(contador<19999)then
					contador <= contador + 1;
					Milisegundos <= Milisegundos;
				else
					contador <= to_unsigned(0,15);
					Milisegundos <= Milisegundos + 1;
				end if;
			end if;
		else
			contador <= to_unsigned(0,15);
			Milisegundos <= to_unsigned(0,32);
		end if;
	end if;
end process;
				
miliseg <= std_logic_vector(Milisegundos);				


end Behavioral;

