library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port(
		clk : in std_logic;
		rst : in std_logic;
		from_memory : in std_logic_vector(7 downto 0);
		
		to_memory : out std_logic_vector(7 downto 0);
		write_en : out std_logic;
		address : out std_logic_vector(7 downto 0)
	);
end CPU;

architecture arch of CPU is
	
	component control_unit is
	port(
		clk : in std_logic;
		rst : in std_logic;
		CCR_RESULT : in std_logic_vector(3 downto 0);
		IR : in std_logic_vector(7 downto 0);
		
		IR_LOAD : out std_logic;
		MAR_LOAD : out std_logic;
		PC_LOAD : out std_logic;
		PC_INC : out std_logic;
		A_LOAD : out std_logic;
		B_LOAD : out std_logic;
		ALU_SEL : out std_logic_vector(2 downto 0);
		CCR_LOAD : out std_logic;
		S_PTR_LOAD : out std_logic;
		S_PTR_DEC : out std_logic;
		BUS1_SEL : out std_logic_vector(1 downto 0);
		BUS2_SEL : out std_logic_vector(1 downto 0);
		WRITE_EN : out std_logic
	);
	end component;
	
	component DataPath is
	port(
		clk : in std_logic;
		rst : in std_logic;
		IR_LOAD : in std_logic;
		MAR_LOAD : in std_logic;
		PC_LOAD : in std_logic;
		PC_INC : in std_logic;
		A_LOAD : in std_logic;
		B_LOAD : in std_logic;
		ALU_SEL : in std_logic_vector(2 downto 0);
		CCR_LOAD : in std_logic;
		S_PTR_LOAD : in std_logic;
		S_PTR_DEC : in std_logic;
		BUS1_SEL : in std_logic_vector(1 downto 0);
		BUS2_SEL : in std_logic_vector(1 downto 0);
		FROM_MEMORY : in std_logic_vector(7 downto 0);
		
		IR : out std_logic_vector(7 downto 0);
		CCR_RESULT : out std_logic_vector(3 downto 0);
		ADDRESS : out std_logic_vector(7 downto 0);
		TO_MEMORY : out std_logic_vector(7 downto 0)
	);
	end component;

signal IR_LOAD : std_logic;
signal IR : std_logic_vector(7 downto 0);
signal MAR_LOAD : std_logic;
signal PC_LOAD : std_logic;
signal PC_INC : std_logic;
signal S_PTR_LOAD : std_logic;
signal S_PTR_DEC : std_logic;
signal A_LOAD : std_logic;
signal B_LOAD : std_logic;
signal ALU_SEL : std_logic_vector(2 downto 0);
signal CCR_LOAD : std_logic;
signal CCR_RESULT : std_logic_vector(3 downto 0);
signal BUS1_SEL : std_logic_vector(1 downto 0);
signal BUS2_SEL : std_logic_vector(1 downto 0);

begin

control_unit_module: control_unit port map
								(
									clk => clk,
									rst => rst,
									CCR_RESULT => CCR_RESULT,
									IR => IR,
									IR_LOAD => IR_LOAD,
								    MAR_LOAD => MAR_LOAD,
								    PC_LOAD => PC_LOAD,
								    PC_INC => PC_INC,
								    A_LOAD => A_LOAD,
								    B_LOAD => B_LOAD,
								    ALU_SEL => ALU_SEL,
								    CCR_LOAD => CCR_LOAD,
									S_PTR_LOAD => S_PTR_LOAD,
									S_PTR_DEC => S_PTR_DEC,
								    BUS1_SEL => BUS1_SEL,
								    BUS2_SEL => BUS2_SEL,
								    WRITE_EN => write_en
								);

data_path_module: DataPath port map
							(
								clk => clk,
								rst => rst,
								IR_LOAD => IR_LOAD,
								MAR_LOAD => MAR_LOAD,
								PC_LOAD => PC_LOAD,
								PC_INC => PC_INC,
								A_LOAD => A_LOAD,
								B_LOAD => B_LOAD,
								ALU_SEL => ALU_SEL,
								CCR_LOAD => CCR_LOAD,
								S_PTR_LOAD => S_PTR_LOAD,
								S_PTR_DEC => S_PTR_DEC,
								BUS1_SEL => BUS1_SEL,
								BUS2_SEL => BUS2_SEL,
								FROM_MEMORY => from_memory,
								IR => IR,
								CCR_RESULT => CCR_RESULT, 
								ADDRESS => address,
								TO_MEMORY => to_memory
							);
end architecture;