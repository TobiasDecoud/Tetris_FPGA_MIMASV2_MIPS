----------------------------------------------------------------------------------
-- Company: Universidad Catlica
-- Engineer: Vicente Gonzlez
-- 
-- Create Date:    16:36:42 06/13/2019 
-- Design Name: 
-- Module Name:    entrada - Behavioral 
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

entity entrada is
    Port ( north : in  STD_LOGIC;
           south : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (3 downto 0);
           alMIPS : out  STD_LOGIC_VECTOR (5 downto 0));
end entrada;

architecture Behavioral of entrada is

begin

	alMIPS <= not(sw) & not(south) & not(north);

end Behavioral;

