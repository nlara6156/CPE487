LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY agario IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        sw : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END agario;

ARCHITECTURE Behavioral OF agario IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL lfsr_reg : STD_LOGIC_VECTOR (15 DOWNTO 0) := "1100101010001101"; -- Initial seed
    SIGNAL feedback : STD_LOGIC;
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0);
    SIGNAL ballposx : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11); -- ball x position initalized to center
    SIGNAL ballposy : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11); -- ball y position initialized to center
    SIGNAL display1 : STD_LOGIC_VECTOR (7 DOWNTO 0); -- value to be displayed
    SIGNAL display2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    
    COMPONENT ball IS
        PORT (
            clk : IN STD_LOGIC_VECTOR (20 DOWNTO 0); 
            clk_in : IN STD_LOGIC;
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            start_game : IN STD_LOGIC;
            mainball_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            mainball_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            sw : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            score : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            timer : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC
        );
    END COMPONENT;
   
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data1 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data2 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    
BEGIN
    pos : PROCESS (clk_in) IS
    BEGIN
        IF rising_edge(clk_in) THEN
            count <= count + 1;
            IF (btnl = '1' AND count = 0 AND ballposx > 0) THEN
                ballposx <= ballposx - 10; -- move ball to the left
            ELSIF (btnr = '1' AND count = 0 AND ballposx < 800) THEN
                ballposx <= ballposx + 10; -- move ball to the right
            ELSIF (btnu = '1' AND count = 0 AND ballposy > 0) THEN
                ballposy <= ballposy - 10; -- move ball up
            ELSIF (btnd = '1' AND count = 0 AND ballposy < 600) THEN
                ballposy <= ballposy + 10; -- move ball down
            END IF;
        END IF;
        
    END PROCESS;
    led_mpx <= count(19 DOWNTO 17); -- 7-seg multiplexing clock    
    add_bb : ball
    PORT MAP(--instantiate ball component
        clk => count,
        clk_in => clk_in,
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        start_game => btn0, 
        mainball_x => ballposx,
        mainball_y => ballposy,
        timer => display1,
        score => display2,
        sw => sw,
        red => S_red, 
        green => S_green, 
        blue => S_blue
    );
    
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    led1 : leddec16
    PORT MAP(
      dig => led_mpx,
      data1 => display1, 
      data2 => display2, 
      anode => SEG7_anode, 
      seg => SEG7_seg
    );
END Behavioral;
