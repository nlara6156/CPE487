# CPE487_Final_Project - Agar.io Game 
## Description
In the game agario, you control a main ball and move over the other balls on the screen. Each of the other balls could either increase or decrease your overall score. 

Goal: Grow your main ball size. 

Playing: 
  - Use BTNC to start the game.
  - Use BTNU to move up, BTND to move down, BTNR to move right, and BTNL to move left.
    
Scoring: When the ball has reached a certain size the game will end.

## Required Attachments
For game play, you will need the following
- Nexys A7-100T Board
- VGA to HDMI Adapter
- Monitor

## Steps to Run
Download the following files from this repository onto your computer
- `ball.vhd`
- `clk_wiz_0_clk_wiz.vhd`
- `clk_wiz_0.vhd`
- `leddec16.vhd`
- `vga_sync.vhd`
- `agario.xdc`
- `agario.vhd`

Once downloaded, follow these steps:
1. Create a new project on Vivado
2. Add all the `.vhd` files as source files to the project
3. Add the `.xdc` file as a constraint file to the project
4. Choose Nexys A7-100T board for the project
5. Run the synthesis
6. Run the implementation
7. Generate the bistream
8. Open the hardware manager and click
   - 'Open Target'
   - 'Auto Connect'
   - 'Program Device'
     
9. Push the BTNC button to start the game

## Inputs and Outputs
Inputs and Outputs in top level file `agario.vhd`
```
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

        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays

        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)

    );

END agario;
```

- clk_in : This input is the system clock
- VGA_red, VGA_green, VGA_blue, VGA_hsync, VGA_vsync: These are the outputes to display the code and color
- BTNL: This input corresponds to the button on the left so that the ball can move left (Input port P17)
- BTNR: This input corresponds to the button on the right so that the ball can move right (Input port M17)
- BTND: This input corresponds to the bottom button so that the ball can move down (Input port P18)
- BTNU: This input corresponds to the top button so that the ball can move up (Input port M18)
- BTN0: This input corresponds to the middle button so that the game can start (Input port N17)
- SEG7_anode: This output corresponds to the 8 different LED segments that will be lit up
- SEG7_seg: This output determines what will be displayed on each anode 

## Modifications

### `agario.xdc`
_This code originated from the `pong.xdc` file in Lab 6_

**Initial:**
```
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk_in}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_in}];

set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { VGA_hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { VGA_vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs

set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[1] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[2] }];
set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[3] }];
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[3] }];
set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[3] }];

set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L10N_T1_D15_14 Sch=btnr

set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[0]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[1]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[3]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[4]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[5]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[6]}]

set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[7]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[6]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[5]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[4]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[3]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[1]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[0]}]
```


**Modified:**

```
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk_in}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_in}];

set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { VGA_hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { VGA_vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs

set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[1] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[2] }];
set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[3] }];
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[3] }];
set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[3] }];

set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { btnu }];
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { btnd }];

set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[0]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[1]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[3]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[4]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[5]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[6]}]

set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[7]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[6]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[5]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[4]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[3]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[1]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {SEG7_anode[0]}]

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
```

- Added the button BTNU and BTND to allow the ball to move up and down (Shown on line 23 and 24)
- Added the switches (Shown on line 41 and 42)

### `agario.vhd`

**Initial:**

```
ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END pong;

```

**Modified:**

```
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

```

-


**Initial:**

```
ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0);
    SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
```

**Modified:**

```
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
```
-

**Initial:**

```
BEGIN
    pos : PROCESS (clk_in) is
    BEGIN
        if rising_edge(clk_in) then
            count <= count + 1;
            IF (btnl = '1' and count = 0 and batpos > 0) THEN
                batpos <= batpos - 10;
            ELSIF (btnr = '1' and count = 0 and batpos < 800) THEN
                batpos <= batpos + 10;
            END IF;
        end if;
    END PROCESS;
```

**Modified:**

```
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
```

### `ball.vhd`

**Initial:**

**Modified:**


## Process Summary 

### Responsibilities

Rebecca Kaspar:
- Contributed to GitHub repository
- Added the small ball randomization

Nadia Lara:
- Contributed to GitHub repository
- Added score counter 

### Difficulties

- Generating multiple balls in 'random' places
  

- Having the main ball increase when coming in contact with the other balls
    - The main ball score will not increase if not completely hovering the other ball

### Timeline

The project was completed in the last week with equal work being done by both parties. 
