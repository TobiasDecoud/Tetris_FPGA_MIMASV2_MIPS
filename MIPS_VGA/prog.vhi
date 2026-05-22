
-- VHDL Instantiation Created from source file prog.vhd -- 14:28:40 05/22/2026
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT prog
	PORT(
		dataDeMI : IN std_logic_vector(31 downto 0);
		clk : IN std_logic;
		rx : IN std_logic;
		Atn : IN std_logic;          
		dataAMI : OUT std_logic_vector(31 downto 0);
		dirMI : OUT std_logic_vector(8 downto 0);
		writeMI : OUT std_logic;
		rstMIPS : OUT std_logic;
		tx : OUT std_logic
		);
	END COMPONENT;

	Inst_prog: prog PORT MAP(
		dataDeMI => ,
		dataAMI => ,
		dirMI => ,
		writeMI => ,
		rstMIPS => ,
		clk => ,
		rx => ,
		tx => ,
		Atn => 
	);


