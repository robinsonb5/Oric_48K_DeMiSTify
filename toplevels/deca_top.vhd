library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- -----------------------------------------------------------------------

entity deca_top is
	port
	(
		ADC_CLK_10		:	 IN STD_LOGIC;
		MAX10_CLK1_50		:	 IN STD_LOGIC;
		MAX10_CLK2_50		:	 IN STD_LOGIC;
		KEY		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_CLK		:	 OUT STD_LOGIC;
		DRAM_CKE		:	 OUT STD_LOGIC;
		DRAM_ADDR		:	 OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA		:	 OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_DQ		:	 INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_LDQM		:	 OUT STD_LOGIC;
		DRAM_UDQM		:	 OUT STD_LOGIC;
		DRAM_CS_N		:	 OUT STD_LOGIC;
		DRAM_WE_N		:	 OUT STD_LOGIC;
		DRAM_CAS_N		:	 OUT STD_LOGIC;
		DRAM_RAS_N		:	 OUT STD_LOGIC;
		VGA_HS		:	 OUT STD_LOGIC;
		VGA_VS		:	 OUT STD_LOGIC;
		VGA_R		:	 OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		VGA_G		:	 OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		VGA_B		:	 OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- AUDIO
		SIGMA_R                     : OUT STD_LOGIC;
		SIGMA_L                     : OUT STD_LOGIC;
		-- PS2
		PS2_KEYBOARD_CLK            :    INOUT STD_LOGIC;
		PS2_KEYBOARD_DAT            :    INOUT STD_LOGIC;
		PS2_MOUSE_CLK               :    INOUT STD_LOGIC;
		PS2_MOUSE_DAT               :    INOUT STD_LOGIC;
		-- UART
		UART_RXD                    : IN STD_LOGIC;
		UART_TXD                    : OUT STD_LOGIC;
		-- SD Card
		sd_cs_n_o                      : out   std_logic := '1';
		sd_sclk_o                      : out   std_logic := '0';
		sd_mosi_o                      : out   std_logic := '0';
		sd_miso_i                      : in    std_logic;
		SD_SEL                         : out   std_logic := '0';   
		SD_CMD_DIR                     : out   std_logic := '1';  
		SD_D0_DIR                      : out   std_logic                                                               := '0';  
		SD_D123_DIR                    : out   std_logic   
	
--		CLK_I2C_SCL		:	 OUT STD_LOGIC;
--		CLK_I2C_SDA		:	 INOUT STD_LOGIC;
	);
END entity;

architecture RTL of deca_top is
   constant reset_cycles : integer := 131071;
	
-- System clocks

	signal locked : std_logic;
	signal reset_n : std_logic;

--	signal slowclk : std_logic;
--	signal fastclk : std_logic;
--	signal pll_locked : std_logic;

-- SPI signals

	signal sd_clk : std_logic;
	signal sd_cs : std_logic;
	signal sd_mosi : std_logic;
	signal sd_miso : std_logic;
	
-- internal SPI signals
	
	signal spi_toguest : std_logic;
	signal spi_fromguest : std_logic;
	signal spi_ss2 : std_logic;
	signal spi_ss3 : std_logic;
	signal spi_ss4 : std_logic;
	signal conf_data0 : std_logic;
	signal spi_clk_int : std_logic;

-- PS/2 Keyboard socket - used for second mouse
	signal ps2_keyboard_clk_in : std_logic;
	signal ps2_keyboard_dat_in : std_logic;
	signal ps2_keyboard_clk_out : std_logic;
	signal ps2_keyboard_dat_out : std_logic;

-- PS/2 Mouse
	signal ps2_mouse_clk_in: std_logic;
	signal ps2_mouse_dat_in: std_logic;
	signal ps2_mouse_clk_out: std_logic;
	signal ps2_mouse_dat_out: std_logic;

	
-- Video
	signal vga_red: std_logic_vector(7 downto 0);
	signal vga_green: std_logic_vector(7 downto 0);
	signal vga_blue: std_logic_vector(7 downto 0);
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;

-- RS232 serial
	signal rs232_rxd : std_logic;
	signal rs232_txd : std_logic;


	
-- IO

	signal joya : std_logic_vector(6 downto 0);
	signal joyb : std_logic_vector(6 downto 0);
	signal joyc : std_logic_vector(6 downto 0);
	signal joyd : std_logic_vector(6 downto 0);


COMPONENT  OricAtmos_MiST
	PORT
	(
		CLOCK_27 :	IN STD_LOGIC;
		--RESET_N :   IN std_logic;
		SDRAM_DQ		:	 INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SDRAM_A		:	 OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		SDRAM_DQML		:	 OUT STD_LOGIC;
		SDRAM_DQMH		:	 OUT STD_LOGIC;
		SDRAM_nWE		:	 OUT STD_LOGIC;
		SDRAM_nCAS		:	 OUT STD_LOGIC;
		SDRAM_nRAS		:	 OUT STD_LOGIC;
		SDRAM_nCS		:	 OUT STD_LOGIC;
		SDRAM_BA		:	 OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SDRAM_CLK		:	 OUT STD_LOGIC;
		SDRAM_CKE		:	 OUT STD_LOGIC;
		-- UART
		UART_TXD    :   OUT STD_LOGIC;
		UART_RXD    :   IN STD_LOGIC;
		SPI_DO		:	 OUT STD_LOGIC;
--		SPI_SD_DI	:	 IN STD_LOGIC;
		SPI_DI		:	 IN STD_LOGIC;
		SPI_SCK		:	 IN STD_LOGIC;
		SPI_SS2		:	 IN STD_LOGIC;
		SPI_SS3		:	 IN STD_LOGIC;
--		SPI_SS4		:	 IN STD_LOGIC;
		CONF_DATA0		:	 IN STD_LOGIC;
		VGA_HS		:	 OUT STD_LOGIC;
		VGA_VS		:	 OUT STD_LOGIC;
		VGA_R		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		VGA_G		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		VGA_B		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		AUDIO_L  : out std_logic;
		AUDIO_R  : out std_logic
	);
END COMPONENT;

begin


-- SPI

sd_cs_n_o<=sd_cs;
sd_mosi_o<=sd_mosi;
--ARDUINO_IO(12)<='Z';
sd_miso<=sd_miso_i;
sd_sclk_o<=sd_clk;

--ARDUINO_IO(1) <= uart_txd;
--ARDUINO_IO(0) <= 'Z';
--uart_rxd <= ARDUINO_IO(0);


-- External devices tied to GPIOs

ps2_mouse_dat_in<=ps2_mouse_dat;
ps2_mouse_dat <= '0' when ps2_mouse_dat_out='0' else 'Z';
ps2_mouse_clk_in<=ps2_mouse_clk;
ps2_mouse_clk <= '0' when ps2_mouse_clk_out='0' else 'Z';

ps2_keyboard_dat_in <=ps2_keyboard_dat;
ps2_keyboard_dat <= '0' when ps2_keyboard_dat_out='0' else 'Z';
ps2_keyboard_clk_in<=ps2_keyboard_clk;
ps2_keyboard_clk <= '0' when ps2_keyboard_clk_out='0' else 'Z';
	
--UART_TXD<=rs232_txd;
--rs232_rxd<=UART_RXD;

joya<=(others=>'1');
joyb<=(others=>'1');
joyc<=(others=>'1');
joyd<=(others=>'1');


SD_SEL                          <= '0';  -- 0 = 3.3V at sdcard   
SD_CMD_DIR                      <= '1';  -- MOSI FPGA output
SD_D0_DIR                       <= '0';  -- MISO FPGA input     
SD_D123_DIR                     <= '1';  -- CS FPGA output  

--process(clk_sys)
--begin
--	if rising_edge(clk_sys) then
		VGA_R<=vga_red(7 downto 5);
		VGA_G<=vga_green(7 downto 5);
		VGA_B<=vga_blue(7 downto 5);
		VGA_HS<=vga_hsync;
		VGA_VS<=vga_vsync;
--	end if;
--end process;


-- Generate clocks

--assign DRAM clock
--asign DRAM clock enable

guest: COMPONENT  OricAtmos_MiST
	PORT map
	(
		CLOCK_27 => MAX10_CLK1_50,
		--RESET_N => reset_n,
		-- clocks
		SDRAM_DQ => DRAM_DQ,
		SDRAM_A => DRAM_ADDR,
		SDRAM_DQML => DRAM_LDQM,
		SDRAM_DQMH => DRAM_UDQM,
		SDRAM_nWE => DRAM_WE_N,
		SDRAM_nCAS => DRAM_CAS_N,
		SDRAM_nRAS => DRAM_RAS_N,
		SDRAM_nCS => DRAM_CS_N,
		SDRAM_BA => DRAM_BA,
		SDRAM_CLK => DRAM_CLK,
		SDRAM_CKE => DRAM_CKE,
		
		UART_TXD  => UART_TXD,
		UART_RXD  => UART_RXD,
		
--		SPI_SD_DI => sd_miso,
		SPI_DO => spi_fromguest,
		SPI_DI => spi_toguest,
		SPI_SCK => spi_clk_int,
		SPI_SS2	=> spi_ss2,
		SPI_SS3 => spi_ss3,
--		SPI_SS4	=> spi_ss4,
		
		CONF_DATA0 => conf_data0,

		VGA_HS => vga_hsync,
		VGA_VS => vga_vsync,
		VGA_R => vga_red(7 downto 2),
		VGA_G => vga_green(7 downto 2),
		VGA_B => vga_blue(7 downto 2),
		AUDIO_L => sigma_l,
		AUDIO_R => sigma_r
);

-- Pass internal signals to external SPI interface
sd_clk <= spi_clk_int;

controller : entity work.substitute_mcu
	generic map (
		sysclk_frequency => 500,
		debug => true
	)
	port map (
		clk => MAX10_CLK1_50,
		reset_in =>  KEY(0),
		reset_out => reset_n,

		-- SPI signals
		spi_miso => sd_miso,
		spi_mosi	=> sd_mosi,
		spi_clk => spi_clk_int,
		spi_cs => sd_cs,
		spi_fromguest => spi_fromguest,
		spi_toguest => spi_toguest,
		spi_ss2 => spi_ss2,
		spi_ss3 => spi_ss3,
		spi_ss4 => spi_ss4,
		conf_data0 => conf_data0,
		
		-- PS/2 signals
		ps2k_clk_in => ps2_keyboard_clk_in,
		ps2k_dat_in => ps2_keyboard_dat_in,
		ps2k_clk_out => ps2_keyboard_clk_out,
		ps2k_dat_out => ps2_keyboard_dat_out,
		ps2m_clk_in => ps2_mouse_clk_in,
		ps2m_dat_in => ps2_mouse_dat_in,
		ps2m_clk_out => ps2_mouse_clk_out,
		ps2m_dat_out => ps2_mouse_dat_out,

		buttons => (0=>KEY(0),1=>KEY(1),others=>'1'),

		-- UART
		rxd => rs232_rxd,
		txd => rs232_txd
);

end rtl;

