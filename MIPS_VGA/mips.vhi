
-- VHDL Instantiation Created from source file mips.vhd -- 14:30:00 05/22/2026
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT mips
	PORT(
		clk100mhz : IN std_logic;
		reset1 : IN std_logic;
		reset0 : IN std_logic;
		north : IN std_logic;
		south : IN std_logic;
		sw : IN std_logic_vector(3 downto 0);
		rx : IN std_logic;
		atn : IN std_logic;
		siRojo : IN std_logic;
		siVerde : IN std_logic;
		siAzul : IN std_logic;          
		salida : OUT std_logic_vector(7 downto 0);
		tx : OUT std_logic;
		sevenSegment : OUT std_logic_vector(7 downto 0);
		sevenSegmentEnable : OUT std_logic_vector(2 downto 0);
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		Red : OUT std_logic_vector(2 downto 0);
		Green : OUT std_logic_vector(2 downto 0);
		Blue : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	Inst_mips: mips PORT MAP(
		clk100mhz => ,
		reset1 => ,
		reset0 => ,
		north => ,
		south => ,
		sw => ,
		salida => ,
		rx => ,
		tx => ,
		atn => ,
		sevenSegment => ,
		sevenSegmentEnable => ,
		siRojo => ,
		siVerde => ,
		siAzul => ,
		hsync => ,
		vsync => ,
		Red => ,
		Green => ,
		Blue => 
	);


