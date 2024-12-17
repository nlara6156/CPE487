LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ball IS
    PORT (
        clk : IN STD_LOGIC_VECTOR (20 DOWNTO 0); -- system clock in vector form
        clk_in : IN STD_LOGIC; -- system clock
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        mainball_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- main ball x position
        mainball_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- main ball y position
        start_game : IN STD_LOGIC; -- initiates serve
        sw : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- condition for switch
        score : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- display score
        timer : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- display timer
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC
    );
END ball;

ARCHITECTURE Behavioral OF ball IS
    SIGNAL mainbsize : INTEGER := 8; -- main ball size in pixels
    SIGNAL mainball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL game_on : STD_LOGIC_VECTOR (13 DOWNTO 0) := "00000000000000"; -- indicates whether balls are in play
    SIGNAL balls_on_screen : STD_LOGIC_VECTOR (12 DOWNTO 0):= (OTHERS => '0'); -- indicates whether balls appear on screen
    SIGNAL pos_x, pos_y : STD_LOGIC_VECTOR (10 DOWNTO 0); -- used for ball position randomization
    -- random balls starting x positions
    SIGNAL ball_x0 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(385, 11);
    SIGNAL ball_x1 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(568, 11);
    SIGNAL ball_x2 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
    SIGNAL ball_x3 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(45, 11);
    SIGNAL ball_x4 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(155, 11);
    SIGNAL ball_x5 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(750, 11);
    SIGNAL ball_x6 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(375, 11);
    SIGNAL ball_x7 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(58, 11);
    SIGNAL ball_x8 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(670, 11);
    SIGNAL ball_x9 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(163, 11);
    SIGNAL ball_x10 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(483, 11);
    SIGNAL ball_x11 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(262, 11);
    SIGNAL ball_x12 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(582, 11);
    -- random balls starting y positions
    SIGNAL ball_y0 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(45, 11);
    SIGNAL ball_y1 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(90, 11);
    SIGNAL ball_y2 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(135, 11);
    SIGNAL ball_y3 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(180, 11);
    SIGNAL ball_y4 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(225, 11);
    SIGNAL ball_y5 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(270, 11);
    SIGNAL ball_y6 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(315, 11);
    SIGNAL ball_y7 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(360, 11);
    SIGNAL ball_y8 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(405, 11);
    SIGNAL ball_y9 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    SIGNAL ball_y10 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(495, 11);
    SIGNAL ball_y11 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(540, 11);
    SIGNAL ball_y12 : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(585, 11);
    SIGNAL ball_on : STD_LOGIC_VECTOR (12 DOWNTO 0) := (OTHERS => '0'); --indicates whether each ball is at current pixel position
    SIGNAL size_change : STD_LOGIC_VECTOR (7 DOWNTO 0); -- used to change score
    SIGNAL bsize : INTEGER := 8; 
    SIGNAL counter : STD_LOGIC_VECTOR (7 DOWNTO 0); -- used to decrease timer
    SIGNAL clk_div : STD_LOGIC_VECTOR (26 DOWNTO 0) := (OTHERS => '0'); -- used to compute clock speed
    SIGNAL collision, flag, reset : STD_LOGIC; -- conditions to run certain code at specific times
    -- states for gameplay
    TYPE state IS (ENTER_GAME, SERVE, BALL_COLL, END_GAME); 
    SIGNAL ps_state, pr_state, nx_state : state; 
BEGIN
    red <= NOT (mainball_on OR ball_on(0) OR ball_on(2) OR ball_on(4) OR ball_on(6) OR ball_on(8) OR ball_on(10) OR ball_on(12));
    green <= NOT (ball_on(1) OR ball_on(3) OR ball_on(5) OR ball_on(7) OR ball_on(9) OR ball_on(11));
    blue <= NOT (ball_on(0) OR ball_on(1) OR ball_on(2) OR ball_on(3) OR ball_on(4) OR ball_on(5) OR ball_on(6) OR ball_on(7) OR ball_on(8) OR ball_on(9) OR ball_on(10) OR ball_on(11) OR ball_on(12));
    score <= size_change; -- map score onto display
    timer <= counter; -- map timer onto display
    -- process to draw main ball
    mainballdraw : PROCESS (mainball_x, mainball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= mainball_x THEN -- vx = |ball_x - pixel_col|
            vx := mainball_x - pixel_col;
        ELSE
            vx := pixel_col - mainball_x;
        END IF;
        IF pixel_row <= mainball_y THEN -- vy = |ball_y - pixel_row|
            vy := mainball_y - pixel_row;
        ELSE
            vy := pixel_row - mainball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (mainbsize * mainbsize) THEN -- test if radial distance < bsize
            mainball_on <= game_on(0);
        ELSE
            mainball_on <= '0';
        END IF;
    END PROCESS;
    
    -- process to draw each random ball
    randballdraw : PROCESS (ball_x0, ball_x1, ball_x2, ball_x3, ball_x4, ball_x5, ball_x6, ball_x7, ball_x8, ball_x9, ball_x10, ball_x11, ball_x12, ball_y0, ball_y1, ball_y2, ball_y3, ball_y4, ball_y5, ball_y6, ball_y7, ball_y8, ball_y9, ball_y10, ball_y11, ball_y12, pixel_row, pixel_col) IS 
    BEGIN
        IF balls_on_screen(0) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x0))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y0))**2) <= (bsize*bsize) THEN
                ball_on(0) <= game_on(1);
           ELSE
                ball_on(0) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(1) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x1))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y1))**2) <= (bsize*bsize) THEN
                ball_on(1) <= game_on(2);
           ELSE
                ball_on(1) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(2) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x2))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y2))**2) <= (bsize*bsize) THEN
                ball_on(2) <= game_on(3);
           ELSE
                ball_on(2) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(3) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x3))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y3))**2) <= (bsize*bsize) THEN
                ball_on(3) <= game_on(4);
           ELSE
                ball_on(3) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(4) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x4))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y4))**2) <= (bsize*bsize) THEN
                ball_on(4) <= game_on(5);
           ELSE
                ball_on(4) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(5) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x5))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y5))**2) <= (bsize*bsize) THEN
                ball_on(5) <= game_on(6);
           ELSE
                ball_on(5) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(6) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x6))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y6))**2) <= (bsize*bsize) THEN
                ball_on(6) <= game_on(7);
           ELSE
                ball_on(6) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(7) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x7))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y7))**2) <= (bsize*bsize) THEN
                ball_on(7) <= game_on(8);
           ELSE
                ball_on(7) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(8) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x8))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y8))**2) <= (bsize*bsize) THEN
                ball_on(8) <= game_on(9);
           ELSE
                ball_on(8) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(9) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x9))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y9))**2) <= (bsize*bsize) THEN
                ball_on(9) <= game_on(10);
           ELSE
                ball_on(9) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(10) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x10))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y10))**2) <= (bsize*bsize) THEN
                ball_on(10) <= game_on(11);
           ELSE
                ball_on(10) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(11) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x11))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y11))**2) <= (bsize*bsize) THEN
                ball_on(11) <= game_on(12);
           ELSE
                ball_on(11) <= '0';
           END IF;
        END IF;
        IF balls_on_screen(12) = '1' THEN
           IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x12))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y12))**2) <= (bsize*bsize) THEN
                ball_on(12) <= game_on(13);
           ELSE
                ball_on(12) <= '0';
           END IF;
        END IF;
    END PROCESS;   
    -- process to start game (i.e., once every vsync pulse)
    mball : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        -- FSM for gameplay
        pr_state <= nx_state;
        CASE pr_state IS 
            WHEN SERVE => -- initializes/restarts game
                IF start_game = '1' THEN -- test for btn0 being pressed
                    game_on(0) <= '0'; -- remove main ball (if game is being restarted)
                    -- initalize random ball positions
                    ball_x0 <= CONV_STD_LOGIC_VECTOR(385, 11); 
                    ball_x1 <= CONV_STD_LOGIC_VECTOR(568, 11); 
                    ball_x2 <= CONV_STD_LOGIC_VECTOR(10, 11);  
                    ball_x3 <= CONV_STD_LOGIC_VECTOR(45, 11);  
                    ball_x4 <= CONV_STD_LOGIC_VECTOR(155, 11); 
                    ball_x5 <= CONV_STD_LOGIC_VECTOR(750, 11); 
                    ball_x6 <= CONV_STD_LOGIC_VECTOR(375, 11); 
                    ball_x7 <= CONV_STD_LOGIC_VECTOR(58, 11);  
                    ball_x8 <= CONV_STD_LOGIC_VECTOR(670, 11); 
                    ball_x9 <= CONV_STD_LOGIC_VECTOR(163, 11); 
                    ball_x10 <= CONV_STD_LOGIC_VECTOR(483, 11);
                    ball_x11 <= CONV_STD_LOGIC_VECTOR(262, 11);
                    ball_x12 <= CONV_STD_LOGIC_VECTOR(582, 11);   
                    ball_y0 <= CONV_STD_LOGIC_VECTOR(45, 11);  
                    ball_y1 <= CONV_STD_LOGIC_VECTOR(90, 11);  
                    ball_y2 <= CONV_STD_LOGIC_VECTOR(135, 11); 
                    ball_y3 <= CONV_STD_LOGIC_VECTOR(180, 11); 
                    ball_y4 <= CONV_STD_LOGIC_VECTOR(225, 11);  
                    ball_y5 <= CONV_STD_LOGIC_VECTOR(270, 11); 
                    ball_y6 <= CONV_STD_LOGIC_VECTOR(315, 11); 
                    ball_y7 <= CONV_STD_LOGIC_VECTOR(360, 11); 
                    ball_y8 <= CONV_STD_LOGIC_VECTOR(405, 11); 
                    ball_y9 <= CONV_STD_LOGIC_VECTOR(450, 11); 
                    ball_y10 <= CONV_STD_LOGIC_VECTOR(495, 11);
                    ball_y11 <= CONV_STD_LOGIC_VECTOR(540, 11);
                    ball_y12 <= CONV_STD_LOGIC_VECTOR(585, 11);
                    IF game_on(0) = '0' THEN -- if game is restarted
                       game_on(0) <= '1'; -- put main ball on screen
                       mainbsize <= 8; -- reset ball to original size
                    END IF;
                    IF sw(0) = '1' THEN -- if switch 0 is on
                       flag <= '1'; -- set flag to determine whether timer runs
                    ELSE
                       flag <= '0';
                    END IF;
                    size_change <= "00000000"; -- reset score
                    nx_state <= ENTER_GAME; -- continue to next state
                -- condition to allow balls to reappear after disappearing
                ELSIF (game_on(0) = '1' AND game_on(1) = '1' AND game_on(2) = '1' AND game_on(3) = '1' AND game_on(4) = '1' AND game_on(5) ='1' AND game_on(6) ='1' AND game_on(7) ='1' AND game_on(8) ='1' AND game_on(9) ='1' AND game_on(10) ='1' AND game_on(11) ='1' AND game_on(12) ='1' AND game_on(13) ='1') THEN
                    balls_on_screen(0) <= '1';
                    balls_on_screen(1) <= '1';
                    balls_on_screen(2) <= '1';
                    balls_on_screen(3) <= '1';
                    balls_on_screen(4) <= '1';
                    balls_on_screen(5) <= '1';
                    balls_on_screen(6) <= '1';
                    balls_on_screen(7) <= '1';
                    balls_on_screen(8) <= '1';
                    balls_on_screen(9) <= '1';
                    balls_on_screen(10) <= '1';
                    balls_on_screen(11) <= '1';
                    balls_on_screen(12) <= '1';
                    nx_state <= BALL_COLL;
                ELSE
                    nx_state <= ENTER_GAME; -- if balls are not in play, continue to this state to put them in play
                END IF;
             -- conditions to put balls in play and make them appear on screen
             IF (game_on(1) = '0' AND balls_on_screen(0) = '0' AND ps_state = BALL_COLL) THEN
                    game_on(1) <= '1';
                    balls_on_screen(0) <= '1';
                    nx_state <= BALL_COLL;
             END IF;      
             IF (game_on(2) = '0' AND balls_on_screen(1) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(2) <= '1';
                 balls_on_screen(1) <= '1';
                 nx_state <= BALL_COLL;
             END IF;                  
             IF (game_on(3) = '0' AND balls_on_screen(2) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(3) <= '1';
                 balls_on_screen(2) <= '1';
                 nx_state <= BALL_COLL;
             END IF;        
             IF (game_on(4) = '0' AND balls_on_screen(3) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(4) <= '1';
                 balls_on_screen(3) <= '1';
                 nx_state <= BALL_COLL;
             END IF;         
             IF (game_on(5) = '0' AND balls_on_screen(4) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(5) <= '1';
                 balls_on_screen(4) <= '1';
                 nx_state <= BALL_COLL;
             END IF;   
             IF (game_on(6) = '0' AND balls_on_screen(5) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(6) <= '1';
                 balls_on_screen(5) <= '1';
                 nx_state <= BALL_COLL;
             END IF;      
             IF (game_on(7) = '0' AND balls_on_screen(6) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(7) <= '1';
                 balls_on_screen(6) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(8) = '0' AND balls_on_screen(7) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(8) <= '1';
                 balls_on_screen(7) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(9) = '0' AND balls_on_screen(8) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(9) <= '1';
                 balls_on_screen(8) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(10) = '0' AND balls_on_screen(9) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(10) <= '1';
                 balls_on_screen(9) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(11) = '0' AND balls_on_screen(10) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(11) <= '1';
                 balls_on_screen(10) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(12) = '0' AND balls_on_screen(11) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(12) <= '1';
                 balls_on_screen(11) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
             IF (game_on(13) = '0' AND balls_on_screen(12) = '0' AND ps_state = BALL_COLL) THEN
                 game_on(13) <= '1';
                 balls_on_screen(12) <= '1';
                 nx_state <= BALL_COLL;
             END IF;
         WHEN ENTER_GAME => -- state to ensure balls are put into play 
             IF start_game = '0' THEN
                 game_on(1) <= '1';
                 game_on(2) <= '1';
                 game_on(3) <= '1';
                 game_on(4) <= '1';
                 game_on(5) <= '1';
                 game_on(6) <= '1';
                 game_on(7) <= '1';
                 game_on(8) <= '1';
                 game_on(9) <= '1';
                 game_on(10) <= '1';
                 game_on(11) <= '1';
                 game_on(12) <= '1';
                 game_on(13) <= '1';
                 nx_state <= SERVE; -- goes back to first state to test conditions again
             ELSE 
                 nx_state <= ENTER_GAME; -- returns to this state until balls are in play
             END IF;
         WHEN BALL_COLL => 
         -- conditions to test for main ball collision with other balls
             IF collision = '0' THEN -- flag to ensure collision is always tested
                 IF (mainball_x + mainbsize/2) >= (ball_x0 - bsize/2) AND
                    (mainball_x - mainbsize/2) <= (ball_x0 + bsize/2) AND
                    (mainball_y + mainbsize/2) >= (ball_y0 - bsize/2) AND
                    (mainball_y - mainbsize/2) <= (ball_y0 + bsize/2) THEN
                         balls_on_screen(0) <= '0'; -- remove ball from screen
                         collision <= '1'; -- switch flag
                         mainbsize <= mainbsize + 3; -- increase ball size
                         size_change <= size_change + 1; -- increase score
                         game_on(1) <= '0'; -- take ball out of play
                         ps_state <= pr_state; 
                         nx_state <= SERVE; -- return to first state
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x1 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x1 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y1 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y1 + bsize/2) THEN
                           balls_on_screen(1) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(2) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x2 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x2 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y2 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y2 + bsize/2) THEN
                           balls_on_screen(2) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(3) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x3 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x3 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y3 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y3 + bsize/2) THEN
                           balls_on_screen(3) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(4) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x4 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x4 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y4 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y4 + bsize/2) THEN
                           balls_on_screen(4) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(5) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x5 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x5 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y5 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y5 + bsize/2) THEN
                           balls_on_screen(5) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(6) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x6 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x6 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y6 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y6 + bsize/2) THEN
                           balls_on_screen(6) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(7) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x7 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x7 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y7 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y7 + bsize/2) THEN
                           balls_on_screen(7) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(8) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x8 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x8 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y8 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y8 + bsize/2) THEN
                           balls_on_screen(8) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(9) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x9 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x9 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y9 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y9 + bsize/2) THEN
                           balls_on_screen(9) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(10) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x10 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x10 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y10 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y10 + bsize/2) THEN
                           balls_on_screen(10) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(11) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x11 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x11 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y11 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y11 + bsize/2) THEN
                           balls_on_screen(11) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize - 3;
                           size_change <= size_change - 1;
                           game_on(12) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;
                 ELSIF (mainball_x + mainbsize/2) >= (ball_x12 - bsize/2) AND
                       (mainball_x - mainbsize/2) <= (ball_x12 + bsize/2) AND
                       (mainball_y + mainbsize/2) >= (ball_y12 - bsize/2) AND
                       (mainball_y - mainbsize/2) <= (ball_y12 + bsize/2) THEN
                           balls_on_screen(12) <= '0';
                           collision <= '1';
                           mainbsize <= mainbsize + 3;
                           size_change <= size_change + 1;
                           game_on(13) <= '0';
                           ps_state <= pr_state;
                           nx_state <= SERVE;     
                 END IF;
             END IF;
             IF nx_state = SERVE THEN
                    collision <= '0'; -- switch flag back so collision is continuously tested
             END IF;
             -- change ball position after collision
             IF game_on(1) = '0' THEN
                ball_x0 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y0 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(2) = '0' THEN
                ball_x1 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y1 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(3) = '0' THEN
                ball_x2 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y2 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(4) = '0' THEN
                ball_x3 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y3 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(5) = '0' THEN
                ball_x4 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y4 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(6) = '0' THEN
                ball_x5 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y5 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(7) = '0' THEN
                ball_x6 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y6 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(8) = '0' THEN
                ball_x7 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y7 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(9) = '0' THEN
                ball_x8 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y8 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(10) = '0' THEN
                ball_x9 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y9 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(11) = '0' THEN
                ball_x10 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y10 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(12) = '0' THEN
                ball_x11 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y11 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             ELSIF game_on(13) = '0' THEN
                ball_x12 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_x), 11);
                ball_y12 <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(pos_y), 11);
             END IF;
         IF mainbsize > 150 OR mainbsize < 8 OR counter = 0 THEN
            ps_state <= pr_state;
            nx_state <= END_GAME;
         ELSE
            ps_state <= pr_state;
            nx_state <= SERVE;
         END IF;
          WHEN END_GAME =>
             balls_on_screen <= "0000000000000"; -- turn off all balls except main ball
             -- take balls out of play
             game_on(1) <= '0'; 
             game_on(2) <= '0';
             game_on(3) <= '0';
             game_on(4) <= '0';
             game_on(5) <= '0';
             game_on(6) <= '0';
             game_on(7) <= '0';
             game_on(8) <= '0';
             game_on(9) <= '0';
             game_on(10) <= '0';
             game_on(11) <= '0';
             game_on(12) <= '0';
             game_on(13) <= '0';
             IF start_game = '1' THEN -- reset game
                nx_state <= ENTER_GAME; 
             END IF;
       END CASE;
    END PROCESS;
    
    -- process to compute random x and y positions for balls
    -- uses clock to make as random as possible
    -- XORs & mods ensure balls don't spawn off screen
    randomizer: PROCESS IS
    VARIABLE rand_x, rand_y : INTEGER;        
    BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand_x := CONV_INTEGER(CONV_STD_LOGIC_VECTOR(CONV_INTEGER(clk), 11) XOR mainball_x XOR pixel_row XOR pixel_col) mod 700;
        rand_y := CONV_INTEGER(CONV_STD_LOGIC_VECTOR(CONV_INTEGER(clk), 11) XOR mainball_y XOR pixel_row XOR pixel_col) mod 500;
        pos_x <= CONV_STD_LOGIC_VECTOR(rand_x,11);
        pos_y <= CONV_STD_LOGIC_VECTOR(rand_y,11);
    END PROCESS;
    
    -- process to convert clock timing so counter only decreases once every second
    PROCESS(clk_in, reset, start_game)
        BEGIN
             IF start_game = '1' THEN
                 reset <= '1'; 
             END IF;
             IF reset = '1' THEN 
                 counter <= "00011110"; 
                 clk_div <= (OTHERS => '0');
                 reset <= '0';
             ELSIF rising_edge(clk_in) THEN
                 IF flag = '1' THEN
                     IF clk_div = "101111101011110000011111110" THEN
                        clk_div <= (OTHERS => '0'); 
                        IF counter > 0 THEN
                            counter <= counter - 1;  
                        END IF; 
                     ELSE 
                        clk_div <= clk_div + 1; 
                     END IF; 
                 END IF; 
             END IF; 
    END PROCESS;
END Behavioral;
