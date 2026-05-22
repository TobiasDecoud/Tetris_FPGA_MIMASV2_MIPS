----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:52 10/11/2022 
-- Design Name: 
-- Module Name:    divCLK100a50 - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divCLK100a50 is
    Port ( clk100mhz : in  STD_LOGIC;
           clk50mhz : out  STD_LOGIC);
end divCLK100a50;

architecture Behavioral of divCLK100a50 is
    signal tmp: std_logic := '0';
begin
	process (clk100mhz)
	begin
		if clk100mhz'event and clk100mhz = '1' then
			tmp <= not tmp;
		end if;
	end process;

   clk50mhz <= tmp;

end Behavioral;


