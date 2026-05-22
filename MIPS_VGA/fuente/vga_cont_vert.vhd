----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:04:11 10/12/2022 
-- Design Name: 
-- Module Name:    vga_cont_vert - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity contador_vertical is
	Port ( hsync : in std_logic; -- horizontal sync signal
			clk50MHz: in std_logic; -- main clock
			reset : in std_logic; -- global reset
			v_cuenta : out std_logic_vector (9 downto 0)
			);
end contador_vertical;

architecture comportamiento of contador_vertical is

	signal v_cuenta_int : integer range 528 downto 0;
	signal hsync_s, hsync_t_1, fa_hsync: std_logic;
	
begin

-- convierte v_cuenta_int en un entero y se asigna a la salida
v_cuenta <= CONV_STD_LOGIC_VECTOR (v_cuenta_int, 10);
-- detector del flanco de subida hsync
process (reset, clk50MHz, hsync_s, hsync_t_1)
begin
	if clk50MHz = '1' and clk50MHz'event then
		if reset = '1' then
			hsync_s <= '0';
			hsync_t_1 <= '0';
		else
			hsync_t_1 <= hsync_s;
			hsync_s <= hsync;
		end if;
	end if;
fa_hsync <= hsync_s and not hsync_t_1;
end process;

-- Contador Vertical
process (fa_hsync,reset,v_cuenta_int,clk50MHz)
begin
	if clk50MHz='1' and clk50MHz'event then
		if reset = '1' then
			v_cuenta_int <= 0;
		else
			if fa_hsync = '1' then
				if v_cuenta_int = 528 then --ajustar bien la cuenta
					v_cuenta_int <= 0;
				else
					v_cuenta_int <= v_cuenta_int + 1;
				end if;
			end if;
		end if;
	end if;
end process;
end comportamiento;
