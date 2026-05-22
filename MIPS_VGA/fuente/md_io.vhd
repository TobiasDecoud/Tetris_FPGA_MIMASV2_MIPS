----------------------------------------------------------------------------------
-- Company: Universidad Catlica
-- Engineer: Vicente Gonzlez
-- 
-- Create Date:    14:44:35 06/14/2017 
-- Design Name: 
-- Module Name:    md_io - Behavioral 
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
use work.general.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity md_io is
    Port ( dir       : in  STD_LOGIC_VECTOR (31 downto 0);
           datain    : in  STD_LOGIC_VECTOR (31 downto 0);
           memwrite  : in  STD_LOGIC;
           memread   : in  STD_LOGIC;
			  tipoAcc   : in STD_LOGIC_VECTOR (2 downto 0); --tipo de operacin a realizar, cargar bytes, half word y word
           clk       : in  STD_LOGIC;
			  clk50mhz  : in STD_LOGIC;
			  reset     : in STD_LOGIC;
			  north     : in STD_LOGIC;
			  south     : in STD_LOGIC;
			  sw        : in STD_LOGIC_VECTOR (3 downto 0);
           dataout   : out  STD_LOGIC_VECTOR (31 downto 0);
			  salida    : out std_logic_vector(7 downto 0);
			  sevenSegment : OUT std_logic_vector(7 downto 0);
			  sevenSegmentEnable : OUT std_logic_vector(2 downto 0);
			  hsync : OUT std_logic;
		  	  vsync : OUT std_logic;
			  R : OUT std_logic;
			  G : OUT std_logic;
			  B : OUT std_logic
			  
			  );
end md_io;

architecture Behavioral of md_io is
	COMPONENT entrada
    Port ( north  : in  STD_LOGIC;
           south  : in  STD_LOGIC;
           sw     : in  STD_LOGIC_VECTOR (3 downto 0);
           alMIPS : out  STD_LOGIC_VECTOR (5 downto 0)
			 );
	END COMPONENT;

	COMPONENT decodificador
	PORT(
		ent : IN std_logic_vector(31 downto 0);          
		csMem : OUT std_logic;
		csParPort : OUT std_logic;
		cs7seg : OUT std_logic;
		csVideoBuffer : OUT std_logic;
		csMillis : OUT std_logic;
		csEntrada : OUT std_logic
		);
	END COMPONENT;

	COMPONENT md
    Port ( dir      : STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_DATOS -1 +2 downto 0);
           datain   : in  STD_LOGIC_VECTOR (31 downto 0);
           cs       : in  STD_LOGIC;
           memwrite : in  STD_LOGIC;
           memread  : in  STD_LOGIC;
			  tipoAcc  : in STD_LOGIC_VECTOR (2 downto 0);
           clk      : in  STD_LOGIC;
           dataout  : out  STD_LOGIC_VECTOR (31 downto 0)
			);
	END COMPONENT;

	COMPONENT salida_par
    Port ( sel        : in  STD_LOGIC;
			  reset        : in  STD_LOGIC;
           write_cntl : in  STD_LOGIC;
           clk        : in  STD_LOGIC;
           data       : in  STD_LOGIC_VECTOR (7 downto 0);
           salida     : out  STD_LOGIC_VECTOR (7 downto 0)
			);
	END COMPONENT;
	
	COMPONENT seven_seg
	PORT(
		sel : IN std_logic;
		reset : IN std_logic;
		write_cnt2 : IN std_logic;
		clk : IN std_logic;
		data_in : IN std_logic_vector(9 downto 0);          
		sevenSegment : OUT std_logic_vector(7 downto 0);
		SevenSegmentEnable : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	
	COMPONENT vga_controlador
	PORT(
		clk50mhz : IN std_logic;
		clk : IN std_logic;
		reset : IN std_logic;
		writeBuffer : IN std_logic;
		readBuffer : IN std_logic;
		siEscribirBuffer : IN std_logic;
		dir : IN std_logic_vector(9 downto 0);
		datos : IN std_logic_vector(31 downto 0);
      lineaOUT : out std_logic_vector(31 downto 0);		
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		R : OUT std_logic;
		G : OUT std_logic;
		B : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT contador_miliseg
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		escribir : IN std_logic;
		csMilliseg : IN std_logic;          
		miliseg : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

-- Definimos seales para interconexin interna en este mdulo
	signal csMem       : STD_LOGIC;
	signal csSalidaPar : STD_LOGIC;
	signal csLCD       : STD_LOGIC;
	signal csVideoBuffer       : STD_LOGIC;
	signal cs7seg       : STD_LOGIC;
	signal csMillis       : STD_LOGIC;
	signal csEntrada   : STD_LOGIC;
	signal datosMem    : STD_LOGIC_VECTOR (31 downto 0);
	signal datosEntrada: STD_LOGIC_VECTOR (5 downto 0);
	signal datosMilisegundos : STD_LOGIC_VECTOR (31 downto 0);
	signal datosVideoBuffer : STD_LOGIC_VECTOR (31 downto 0);
	signal pixel : std_logic_VECTOR (7 downto 0);
	
begin

	-- Multiplexor de salida
	dataout <= datosMem                                    when csMem = '1'     else
			     "00000000000000000000000000" & datosEntrada when csEntrada = '1' else
				  datosMilisegundos									 when csMillis = '1'  else
				  datosVideoBuffer 									 when csVideoBuffer = '1'  else
			     (others => '0');

	Inst_entrada: entrada PORT MAP (
		north  => north,
		south  => south,
		sw     => sw,
		alMIPS => datosEntrada
	);
	
	Inst_decodificador: decodificador PORT MAP(
		ent => dir(31 downto 0),
		csMem => csMem,
		csParPort => csSalidaPar,
		cs7seg => cs7seg,
		csVideoBuffer => csVideoBuffer,
		csMillis => csMillis,
		csEntrada => csEntrada
	);

	Inst_md: md PORT MAP(
		dir      => dir(NUM_BITS_MEMORIA_DATOS -1+2 downto 0),
      datain   => datain,
      cs       => csMem,
      memwrite => memwrite,
      memread  => memread,
		tipoAcc  => tipoAcc,
      clk      => clk,
      dataout  => datosMem
	);

	Inst_salida_par: salida_par PORT MAP(
		sel => csSalidaPar,
		reset => reset,
      write_cntl => memwrite,
      clk => clk,
      data=> datain(7 downto 0),
      salida => salida
	);
	
	Inst_seven_seg: seven_seg PORT MAP(
		sel => cs7seg,
		reset => reset,
		write_cnt2 => memwrite,
		clk => clk,
		data_in => datain(9 downto 0),
		sevenSegment => sevenSegment,
		SevenSegmentEnable => sevenSegmentEnable
	);
	
	Inst_vga_controlador: vga_controlador PORT MAP(
		clk50mhz => clk50mhz,
		clk => clk,
		reset => reset,
		hsync => hsync,
		vsync => vsync,
		writeBuffer => memwrite,
		readBuffer => memread,
		siEscribirBuffer => csVideoBuffer,
		dir => dir(11 downto 2),
		datos => datain,
		lineaOUT => datosVideoBuffer,
		R => R,
		G => G,
		B => B
	);
	
	Inst_contador_miliseg: contador_miliseg PORT MAP(
		clk => clk,
		reset => reset,
		miliseg => datosMilisegundos,
		escribir => memwrite,
		csMilliseg => csMillis
	);

end Behavioral;

