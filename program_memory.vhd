library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity program_memory is
	port(
		clk : in std_logic;
		address : in std_logic_vector(7 downto 0);
		
		data_out : out std_logic_vector(7 downto 0)
	);

end program_memory;

architecture arch of program_memory is
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
	

	type rom_array is array(0 to 127) of std_logic_vector(7 downto 0);
	constant ROM : rom_array := (
								-- Write program here --
								0 => LDA_IMM,
								1 => X"0F",
								2 => INCA,
								3 => STA_DIR,
								4 => x"E0",
								5 => PUSHA,
								6 => BRA,
								7 => x"00",
								others => x"00"
	);
	
	signal enable : std_logic;
	begin
	
	process(address)
	begin
		if(address >= x"00" and address <= x"7F") then
			enable <= '1';
		else
			enable <= '0';
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(enable = '1') then
				data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
	end process;

end architecture;