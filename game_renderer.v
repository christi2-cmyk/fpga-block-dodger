module game_renderer 
#(
    parameter PLAYER_W = 110,
    parameter PLAYER_H = 20,
    parameter BLOCK_W  = 110,
    parameter BLOCK_H  = 32
)
(
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       display_on,

    input  wire [9:0] player_x,
    input  wire [9:0] player_y,

    input  wire [9:0] block0_x,
    input  wire [9:0] block0_y,
    input  wire [9:0] block1_x,
    input  wire [9:0] block1_y,
    input  wire [9:0] block2_x,
    input  wire [9:0] block2_y,

    input  wire       game_over,
    input  wire [1:0] state,

    output reg  [2:0] rgb
);

    function box;
        input [9:0] x1, x2, y1, y2;
        begin
            box = (x >= x1 && x < x2 && y >= y1 && y < y2);
        end
    endfunction

    function draw_char;
        input [3:0] letter;
        input [9:0] ox, oy;
        reg hit;
        begin
            hit = 1'b0;

            case(letter)
                4'd0: begin // P
                    if (box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+10, oy,oy+60) ||
                        box(ox+30,ox+40, oy,oy+30))
                        hit = 1'b1;
                end
                4'd1: begin // R
                    if (box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+10, oy,oy+60) ||
                        box(ox+30,ox+40, oy,oy+30) ||
                        box(ox+10,ox+30, oy+30,oy+40))
                        hit = 1'b1;
                end
                4'd2: begin // E
                    if (box(ox,ox+10, oy,oy+60) ||
                        box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+40, oy+25,oy+35) ||
                        box(ox,ox+40, oy+50,oy+60))
                        hit = 1'b1;
                end
                4'd3: begin // S
                    if (box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+10, oy,oy+30) ||
                        box(ox,ox+40, oy+25,oy+35) ||
                        box(ox+30,ox+40, oy+30,oy+60) ||
                        box(ox,ox+40, oy+50,oy+60))
                        hit = 1'b1;
                end
                4'd4: begin // T
                    if (box(ox,ox+40, oy,oy+10) ||
                        box(ox+15,ox+25, oy,oy+60))
                        hit = 1'b1;
                end
                4'd5: begin // A
                    if (box(ox,ox+10, oy,oy+60) ||
                        box(ox+30,ox+40, oy,oy+60) ||
                        box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+40, oy+25,oy+35))
                        hit = 1'b1;
                end
                4'd6: begin // G
                    if (box(ox,ox+40, oy,oy+10) ||
                        box(ox,ox+10, oy,oy+60) ||
                        box(ox,ox+40, oy+50,oy+60) ||
                        box(ox+30,ox+40, oy+30,oy+60) ||
                        box(ox+10,ox+30, oy+30,oy+40))
                        hit = 1'b1;
                end
                4'd7: begin // O
                    if (box(ox,ox+40, oy,oy+60) &&
                       !box(ox+10,ox+30, oy+10,oy+50))
                        hit = 1'b1;
                end
                4'd8: begin // M
                    if (box(ox,ox+10, oy,oy+60) ||
                        box(ox+30,ox+40, oy,oy+60) ||
                        box(ox+15,ox+25, oy,oy+30))
                        hit = 1'b1;
                end
                4'd9: begin // V
                    if (box(ox,ox+10, oy,oy+40) ||
                        box(ox+30,ox+40, oy,oy+40) ||
                        box(ox+15,ox+25, oy+40,oy+60))
                        hit = 1'b1;
                end
            endcase

            draw_char = hit;
        end
    endfunction

    always @* begin
        if (!display_on) begin
            rgb = 3'b000;
        end

		 else if (state == 2'd0) begin
			 rgb = 3'b001; // blue background

			 // Anchor text at the known working coordinate (x=200,y=100)

			 // PRESS
			 if (draw_char(4'd0, x-200, y-100)) rgb = 3'b111; // P
			 if (draw_char(4'd1, x-150, y-100)) rgb = 3'b111; // R
			 if (draw_char(4'd2, x-100, y-100)) rgb = 3'b111; // E
			 if (draw_char(4'd3, x-50,  y-100)) rgb = 3'b111; // S
			 if (draw_char(4'd3, x-0,   y-100)) rgb = 3'b111; // S

			 // START
			 if (draw_char(4'd3, x-200, y-20)) rgb = 3'b111;  // S
			 if (draw_char(4'd4, x-150, y-20)) rgb = 3'b111;  // T
			 if (draw_char(4'd5, x-100, y-20)) rgb = 3'b111;  // A
			 if (draw_char(4'd1, x-50,  y-20)) rgb = 3'b111;  // R
			 if (draw_char(4'd4, x-0,   y-20)) rgb = 3'b111;  // T
		 end


        // GAME OVER SCREEN
       else if (game_over) begin
			 rgb = 3'b100; // red background

			 // Anchor also relative to (x=200,y=100)

			 // GAME
			 if (draw_char(4'd6, x-200, y-100)) rgb = 3'b111; // G
			 if (draw_char(4'd5, x-150, y-100)) rgb = 3'b111; // A
			 if (draw_char(4'd8, x-100, y-100)) rgb = 3'b111; // M
			 if (draw_char(4'd2, x-50,  y-100)) rgb = 3'b111; // E

			 // OVER
			 if (draw_char(4'd7, x-200, y-20)) rgb = 3'b111; // O
			 if (draw_char(4'd9, x-150, y-20)) rgb = 3'b111; // V
			 if (draw_char(4'd2, x-100, y-20)) rgb = 3'b111; // E
			 if (draw_char(4'd1, x-50,  y-20)) rgb = 3'b111; // R
		 end



        ////////////////////////////////////////////////////////
        //  NORMAL GAMEPLAY RENDERING
        ////////////////////////////////////////////////////////
        else begin
            if ( (x >= player_x) && (x < player_x+PLAYER_W) &&
                 (y >= player_y) && (y < player_y+PLAYER_H) )
                rgb = 3'b010;

            else if (
                (x >= block0_x && x < block0_x+BLOCK_W && y >= block0_y && y < block0_y+BLOCK_H) ||
                (x >= block1_x && x < block1_x+BLOCK_W && y >= block1_y && y < block1_y+BLOCK_H) ||
                (x >= block2_x && x < block2_x+BLOCK_W && y >= block2_y && y < block2_y+BLOCK_H)
            )
                rgb = 3'b100;

            else
                rgb = 3'b001;
        end
    end

endmodule
