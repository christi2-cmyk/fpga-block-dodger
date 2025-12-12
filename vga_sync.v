`timescale 1ns / 1ps

module vga_sync
#(
    parameter H_VISIBLE = 640,
    parameter H_FRONT   = 16,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_VISIBLE = 480,
    parameter V_FRONT   = 10,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33
)
(
    input  wire       clk,         // pixel clock (~25 MHz)
    input  wire       reset,       // active high
    output wire [9:0] x,           // current pixel x (0..639)
    output wire [9:0] y,           // current pixel y (0..479)
    output reg        hsync,
    output reg        vsync,
    output wire       display_on   // 1 when in visible area
);

    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    assign x = h_count;
    assign y = v_count;

    assign display_on = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    always @* begin
        hsync = ~((h_count >= H_VISIBLE + H_FRONT) &&
                  (h_count <  H_VISIBLE + H_FRONT + H_SYNC));
        vsync = ~((v_count >= V_VISIBLE + V_FRONT) &&
                  (v_count <  V_VISIBLE + V_FRONT + V_SYNC));
    end

endmodule
