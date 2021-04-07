library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity DataPath is
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
end DataPath;

architecture arch of DataPath is

	component ALU is
	port(
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		ALU_SEL : in std_logic_vector(2 downto 0);
		
		NZVC : out std_logic_vector(3 downto 0);
		ALU_RESULT : out std_logic_vector(7 downto 0)
	);
	end component;

	signal BUS1 : std_logic_vector(7 downto 0);
	signal BUS2 : std_logic_vector(7 downto 0);
	signal ALU_RESULT : std_logic_vector(7 downto 0);
	signal IR_REG : std_logic_vector(7 downto 0);
	signal MAR : std_logic_vector(7 downto 0);
	signal S_PTR : std_logic_vector(7 downto 0) := x"86";
	signal PC : std_logic_vector(7 downto 0);
	signal A_REG : std_logic_vector(7 downto 0);
	signal B_REG : std_logic_vector(7 downto 0);
	signal CCR : std_logic_vector(3 downto 0);
	signal CCR_IN : std_logic_vector(3 downto 0);
    
begin
	-- BUS1 MUX:
	BUS1 <= PC when (BUS1_SEL = "00") else
			A_REG when (BUS1_SEL = "01") else
			B_REG when (BUS1_SEL = "10") else
			S_PTR when (BUS1_SEL = "11");
	-- BUS2 MUX:
	BUS2 <= ALU_RESULT when (BUS2_SEL = "00") else
			BUS1 when (BUS2_SEL = "01") else
			FROM_MEMORY when (BUS2_SEL = "10") else (others => '0');
	
	--IR
	process(clk, rst)
	begin
		if(rst = '1') then
			IR_REG <= (others => '0');
		elsif(rising_edge(clk)) then
			if(IR_LOAD = '1') then
				IR_REG <= BUS2;
			end if;
		end if;
	end process;
	IR <= IR_REG;
	
	--MAR
	process(clk, rst)
	begin
		if(rst = '1') then
			MAR <= (others => '0');
		elsif(rising_edge(clk)) then
			if(MAR_LOAD = '1') then
				MAR <= BUS2;
			end if;
		end if;
	end process;
	ADDRESS <= MAR;
	
	--PC
	process(clk, rst)
	begin
		if(rst = '1') then
			PC <= (others => '0');
		elsif(rising_edge(clk)) then
			if(PC_LOAD = '1') then
				PC <= BUS2;
			elsif(PC_INC = '1') then
				PC <= PC + x"01";
			end if;
		end if;
	end process;
	
	--Stack Pointer
	process(clk, rst)
	begin
		if(rst = '1') then
			S_PTR <= x"90";
		elsif(rising_edge(clk)) then
			if(S_PTR_LOAD = '1') then
				S_PTR <= BUS2;
			elsif(S_PTR_DEC = '1') then
				S_PTR <= S_PTR - x"01";
			end if;
		end if;
	end process;
	
	--A REGISTER
	process(clk, rst)
	begin
		if(rst = '1') then
			A_REG <= (others => '0');
		elsif(rising_edge(clk)) then
			if(A_LOAD = '1') then
				A_REG <= BUS2;
			end if;
		end if;
	end process;
	
	--B REGISTER
	process(clk, rst)
	begin
		if(rst = '1') then
			B_REG <= (others => '0');
		elsif(rising_edge(clk)) then
			if(B_LOAD = '1') then
				B_REG <= BUS2;
			end if;
		end if;
	end process;
	
	--ALU
    ALU_U: ALU port map
				(
					A => B_REG,
					B => BUS1,
					ALU_SEL => ALU_SEL,
				    NZVC => CCR_IN,
				    ALU_RESULT => ALU_RESULT
				);
	
	--CCR REGISTER
	process(clk, rst)
	begin
		if(rst = '1') then
			CCR <= (others => '0');
		elsif(rising_edge(clk)) then
			if(CCR_LOAD = '1') then
				CCR <= CCR_IN;
			end if;
		end if;
	end process;
	CCR_RESULT <= CCR;
	
	TO_MEMORY <= BUS1;

end architecture;