module falling_blocks_top (
    input  wire CLOCK_50,
    input  wire RESET_N,      // active low global reset

    input  wire KEY_LEFT,     // active low
    input  wire KEY_RIGHT,
    input  wire KEY_RESTART,
	 
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_CLK,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N
);

    //---------------------------------------------------------
    // INPUT SIGNAL NORMALIZATION
    //---------------------------------------------------------
    wire reset      = ~RESET_N;     // active-high internal reset
    wire move_left  = ~KEY_LEFT;    
    wire move_right = ~KEY_RIGHT;
    wire restart    = ~KEY_RESTART;

    //---------------------------------------------------------
    // PIXEL CLOCK: 50 → 25 MHz
    //---------------------------------------------------------
    reg pixel_clk_reg;
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset)
            pixel_clk_reg <= 1'b0;
        else
            pixel_clk_reg <= ~pixel_clk_reg;
    end

    assign VGA_CLK = pixel_clk_reg;

    //---------------------------------------------------------
    // VGA SYNC
    //---------------------------------------------------------
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire       display_on;

    vga_sync vga_inst (
        .clk        (pixel_clk_reg),
        .reset      (reset),
        .x          (pixel_x),
        .y          (pixel_y),
        .hsync      (VGA_HS),
        .vsync      (VGA_VS),
        .display_on (display_on)
    );

    // One tick per frame
    wire frame_tick = (pixel_x == 10'd0) && (pixel_y == 10'd0);

    //---------------------------------------------------------
    // RANDOM GENERATOR FOR BLOCK LANES
    //---------------------------------------------------------
    wire [7:0] rand_val;
    lfsr8 rng (
        .clk    (pixel_clk_reg),
        .reset  (reset),
        .enable (frame_tick),
        .value  (rand_val)
    );

    //---------------------------------------------------------
    // GAME LOGIC INSTANCE
    //---------------------------------------------------------
    wire [9:0] player_x, player_y;
    wire [9:0] block0_x, block0_y;
    wire [9:0] block1_x, block1_y;
    wire [9:0] block2_x, block2_y;
    wire [15:0] score;
    wire        game_over;

    // *** IMPORTANT: we add state output so renderer can draw title & game over ***
    wire [1:0] game_state;

    game_logic game (
        .clk        (pixel_clk_reg),
        .reset      (reset),
        .frame_tick (frame_tick),
        .move_left  (move_left),
        .move_right (move_right),
        .restart    (restart),
        .rand_val   (rand_val),

        .player_x   (player_x),
        .player_y   (player_y),

        .block0_x   (block0_x),
        .block0_y   (block0_y),
        .block1_x   (block1_x),
        .block1_y   (block1_y),
        .block2_x   (block2_x),
        .block2_y   (block2_y),

        .score      (score),
        .game_over  (game_over),

        // *** YOU MUST ADD THIS PORT TO game_logic.v ***
        .state      (game_state)
    );

    //---------------------------------------------------------
    // GAME RENDERER
    //---------------------------------------------------------
    wire [2:0] rgb;

    game_renderer renderer (
        .x          (pixel_x),
        .y          (pixel_y),
        .display_on (display_on),

        .player_x   (player_x),
        .player_y   (player_y),

        .block0_x   (block0_x),
        .block0_y   (block0_y),
        .block1_x   (block1_x),
        .block1_y   (block1_y),
        .block2_x   (block2_x),
        .block2_y   (block2_y),

        .game_over  (game_over),

        // *** NEW: Renderer needs FSM state for title/game over screens ***
        .state      (game_state),

        .rgb        (rgb)
    );

    //---------------------------------------------------------
    // VGA COLOR OUTPUT MAPPING
    //---------------------------------------------------------
    assign VGA_BLANK_N = display_on;
    assign VGA_SYNC_N  = 1'b0;

    assign VGA_R = display_on ? (rgb[2] ? 8'hFF : 8'h00) : 8'h00;
    assign VGA_G = display_on ? (rgb[1] ? 8'hFF : 8'h00) : 8'h00;
    assign VGA_B = display_on ? (rgb[0] ? 8'hFF : 8'h00) : 8'h00;

    //---------------------------------------------------------
    // SCORE → BCD → SEVEN SEGMENTS
    //---------------------------------------------------------
    wire [3:0] d0, d1, d2, d3;

    binary_to_bcd_4digit bcd (
        .binary(score),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3)
    );

    seven_segment s0(.digit(d0), .seg(HEX0));
    seven_segment s1(.digit(d1), .seg(HEX1));
    seven_segment s2(.digit(d2), .seg(HEX2));
    seven_segment s3(.digit(d3), .seg(HEX3));

endmodule
