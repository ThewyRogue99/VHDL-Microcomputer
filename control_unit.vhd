library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity control_unit is
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
end control_unit;

architecture arch of control_unit is

	type state_type is (
							S_FETCH_0, S_FETCH_1, S_FETCH_2, S_DECODE_3,
							S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
							S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
							S_PUSHA_4, S_PUSHA_5, S_PUSHA_6,
							S_INCA_4,
							S_BRA_4, S_BRA_5, S_BRA_6
						);

	signal current_state, next_state : state_type;

	-- Loads and stores --
	constant LDA_IMM : std_logic_vector(7 downto 0) := x"86";
	constant LDA_DIR : std_logic_vector(7 downto 0) := x"87";
	constant LDB_IMM : std_logic_vector(7 downto 0) := x"88";
	constant LDB_DIR : std_logic_vector(7 downto 0) := x"89";
	constant STA_DIR : std_logic_vector(7 downto 0) := x"96";
	constant STB_DIR : std_logic_vector(7 downto 0) := x"97";

	-- Data Manipulations --
	constant ADD_AB : std_logic_vector(7 downto 0) := x"42";
	constant SUB_AB : std_logic_vector(7 downto 0) := x"43";
	constant AND_AB : std_logic_vector(7 downto 0) := x"44";
	constant OR_AB : std_logic_vector(7 downto 0) := x"45";
	constant INCA : std_logic_vector(7 downto 0) := x"46";
	constant INCB : std_logic_vector(7 downto 0) := x"47";
	constant DECA : std_logic_vector(7 downto 0) := x"48";
	constant DECB : std_logic_vector(7 downto 0) := x"49";
	
	-- Stack Instructions
	constant PUSHA : std_logic_vector(7 downto 0) := x"50";
	
	-- Branches --
	constant BRA : std_logic_vector(7 downto 0) := x"20";
	constant BMI : std_logic_vector(7 downto 0) := x"21";
	constant BPL : std_logic_vector(7 downto 0) := x"22";
	constant BEQ : std_logic_vector(7 downto 0) := x"23";
	constant BNE : std_logic_vector(7 downto 0) := x"24";
	constant BVS : std_logic_vector(7 downto 0) := x"25";
	constant BVC : std_logic_vector(7 downto 0) := x"26";
	constant BCS : std_logic_vector(7 downto 0) := x"27";
	constant BCC : std_logic_vector(7 downto 0) := x"28";

begin
	
	process(clk, rst)
	begin
		if(rst = '1') then
			current_state <= S_FETCH_0;
		elsif(rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process;
	
	process(current_state, IR, CCR_RESULT)
	begin
		case current_state is
			when S_FETCH_0 =>
				next_state <= S_FETCH_1;
			when S_FETCH_1 =>
				next_state <= S_FETCH_2;
			when S_FETCH_2 =>
				next_state <= S_DECODE_3;
			when S_DECODE_3 =>
				if(IR = LDA_IMM) then
					next_state <= S_LDA_IMM_4;
				elsif(IR = STA_DIR) then
					next_state <= S_STA_DIR_4;
				elsif(IR = INCA) then
					next_state <= S_INCA_4;
				elsif(IR = BRA) then
					next_state <= S_BRA_4;
				elsif(IR = PUSHA) then
					next_state <= S_PUSHA_4;
				else
					next_state <= S_FETCH_0;
				end if;
			when S_LDA_IMM_4 =>
				next_state <= S_LDA_IMM_5;
			when S_LDA_IMM_5 =>
				next_state <= S_LDA_IMM_6;
			when S_LDA_IMM_6 =>
				next_state <= S_FETCH_0;
			when S_STA_DIR_4 =>
				next_state <= S_STA_DIR_5;
			when S_STA_DIR_5 =>
				next_state <= S_STA_DIR_6;
			when S_STA_DIR_6 =>
				next_state <= S_STA_DIR_7;
			when S_STA_DIR_7 =>
				next_state <= S_FETCH_0;
			when S_PUSHA_4 =>
			    next_state <= S_PUSHA_5;
			when S_PUSHA_5 =>
			    next_state <= S_PUSHA_6;
			when S_PUSHA_6 =>
			    next_state <= S_FETCH_0;
			when S_INCA_4 =>
				next_state <= S_FETCH_0;
			when S_BRA_4 =>
				next_state <= S_BRA_5;
			when S_BRA_5 =>
				next_state <= S_BRA_6;
			when S_BRA_6 =>
				next_state <= S_FETCH_0;
			when others =>
				next_state <= S_FETCH_0;
		end case;
	end process;
	
	process(current_state)
	begin
		IR_LOAD <= '0';
		MAR_LOAD <= '0';
		PC_LOAD <= '0';
		PC_INC <= '0';
		A_LOAD <= '0';
		B_LOAD <= '0';
		ALU_SEL <= (others => '0');
		CCR_LOAD <= '0';
		S_PTR_LOAD <= '0';
		S_PTR_DEC <= '0';
		BUS1_SEL <= (others => '0');
		BUS2_SEL <= (others => '0');
		WRITE_EN <= '0';
		case current_state is
			when S_FETCH_0 =>
				BUS1_SEL <= "00";
				BUS2_SEL <= "01";
				MAR_LOAD <= '1';
			when S_FETCH_1 =>
				PC_INC <= '1';
			when S_FETCH_2 =>
				BUS2_SEL <= "10";
				IR_LOAD <= '1';
			when S_DECODE_3 =>
			
			when S_LDA_IMM_4 =>
				BUS1_SEL <= "00";
				BUS2_SEL <= "01";
				MAR_LOAD <= '1';
			when S_LDA_IMM_5 =>
				PC_INC <= '1';
			when S_LDA_IMM_6 =>
				BUS2_SEL <= "10";
				A_LOAD <= '1';
			
			when S_STA_DIR_4 =>
				BUS1_SEL <= "00";
				BUS2_SEL <= "01";
				MAR_LOAD <= '1';
			when S_STA_DIR_5 =>
				PC_INC <= '1';
			when S_STA_DIR_6 =>
				BUS2_SEL <= "10";
				MAR_LOAD <= '1';
			when S_STA_DIR_7 =>
				BUS1_SEL <= "01";
				WRITE_EN <= '1';
			
			when S_INCA_4 =>
				BUS1_SEL <= "01";
				ALU_SEL <= "101";
				BUS2_SEL <= "00";
				A_LOAD <= '1';
			
			when S_PUSHA_4 =>
				S_PTR_DEC <= '1';
			when S_PUSHA_5 =>
				BUS1_SEL <= "11";
				BUS2_SEL <= "01";
				MAR_LOAD <= '1';
			when S_PUSHA_6 =>
				BUS1_SEL <= "01";
				WRITE_EN <= '1';
			
			when S_BRA_4 =>
				BUS1_SEL <= "00";
				BUS2_SEL <= "01";
				MAR_LOAD <= '1';
			when S_BRA_5 =>
				-- NOP
			when S_BRA_6 =>
				BUS2_SEL <= "10";
				PC_LOAD <= '1';
			when others =>
				IR_LOAD <= '0';
				MAR_LOAD <= '0';
				PC_LOAD <= '0';
				PC_INC <= '0';
				A_LOAD <= '0';
				B_LOAD <= '0';
				ALU_SEL <= (others => '0');
				CCR_LOAD <= '0';
				BUS1_SEL <= (others => '0');
				BUS2_SEL <= (others => '0');
				WRITE_EN <= '0';
		end case;
		
	end process;
end architecture;