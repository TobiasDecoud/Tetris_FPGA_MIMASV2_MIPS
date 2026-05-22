----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:13:25 10/12/2022 
-- Design Name: 
-- Module Name:    vga_controlador - Behavioral 
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

entity vga_controlador is
    Port ( clk50mhz : in  STD_LOGIC;
	        clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
			  writeBuffer: in std_logic;
			  readBuffer : IN std_logic;
			  siEscribirBuffer: in std_logic;
			  dir: in std_logic_vector(9 downto 0);
			  datos: in std_logic_vector(31 downto 0);
			  lineaOUT : out std_logic_vector(31 downto 0);
           R : out  STD_LOGIC;
           G : out  STD_LOGIC;
           B : out  STD_LOGIC);
end vga_controlador;

architecture Behavioral of vga_controlador is

	signal hsync_temp : std_logic;

	COMPONENT contador_horizontal
	PORT(
		clk50MHz : IN std_logic;
		reset : IN std_logic;          
		h_cuenta : OUT std_logic_vector(10 downto 0)
		);
	END COMPONENT;
	
	COMPONENT contador_vertical
	PORT(
		hsync : IN std_logic;
		clk50MHz : IN std_logic;
		reset : IN std_logic;          
		v_cuenta : OUT std_logic_vector(9 downto 0)
		);
	END COMPONENT;
	
	COMPONENT generador_blank
	PORT(
		hctr : IN std_logic_vector(10 downto 0);
		vctr : IN std_logic_vector(9 downto 0);          
		blank : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT generador_hsync
	PORT(
		h_cuenta : IN std_logic_vector(10 downto 0);
		clk50MHz : IN std_logic;
		reset : IN std_logic;          
		hsync : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT generador_vsync
	PORT(
		v_cuenta : IN std_logic_vector(9 downto 0);
		clk50MHz : IN std_logic;
		reset : IN std_logic;          
		vsync : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT image_generator
	PORT(
		hsync : std_logic;
		--hctr : IN std_logic_vector(10 downto 0);
		vctr : IN std_logic_vector(9 downto 0);
		blank : IN std_logic;
		clk50MHz : IN std_logic;
		clk : in std_logic;
		reset : IN std_logic;
		writeBuffer : IN std_logic;
		readBuffer : IN std_logic;
		siEscribirBuffer : IN std_logic;
		dir : IN std_logic_vector(9 downto 0);
		datos : IN std_logic_vector(31 downto 0);
		datosOUT: out std_logic_vector(31 downto 0);
		R : OUT std_logic;
		G : OUT std_logic;
		B : OUT std_logic
		);
	END COMPONENT;
	
	--señales necesarias
	signal hcnt : std_logic_vector(10 downto 0);
	signal vcnt : std_logic_vector(9 downto 0);
	signal blank : std_logic;
	
begin

	Inst_contador_horizontal: contador_horizontal PORT MAP(
		clk50MHz => clk50mhz,
		reset => reset,
		h_cuenta => hcnt
	);
	
	Inst_contador_vertical: contador_vertical PORT MAP(
		hsync => hsync_temp,
		clk50MHz => clk50mhz,
		reset => reset,
		v_cuenta => vcnt
	);
	
	Inst_generador_blank: generador_blank PORT MAP(
		hctr => hcnt,
		vctr => vcnt,
		blank => blank
	);
	
	Inst_generador_hsync: generador_hsync PORT MAP(
		h_cuenta => hcnt,
		clk50MHz => clk50mhz,
		reset => reset,
		hsync => hsync_temp
	);
	
	Inst_generador_vsync: generador_vsync PORT MAP(
		v_cuenta => vcnt,
		clk50MHz => clk50mhz,
		reset => reset,
		vsync => vsync
	);
	
	Inst_image_generator: image_generator PORT MAP(
		hsync => hsync_temp,
		--hctr => hcnt,
		vctr => vcnt,
		blank => blank,
		clk50MHz => clk50mhz,
		clk => clk,
		reset => reset,
		writeBuffer => writeBuffer,
		readBuffer => readBuffer,
		siEscribirBuffer => siEscribirBuffer,
		dir => dir,
		datos => datos,
		datosOUT => lineaOUT,
		R => R,
		G => G,
		B => B
	);

	hsync <= hsync_temp;

end Behavioral;

