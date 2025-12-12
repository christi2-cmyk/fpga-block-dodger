module lfsr8 (
    input  wire       clk,
    input  wire       reset,   // active high
    input  wire       enable,
    output reg  [7:0] value
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            value <= 8'h1;   // non-zero seed
        end else if (enable) begin
            // taps: 8,6,5,4
            value <= { value[6:0],
                       value[7] ^ value[5] ^ value[4] ^ value[3] };
        end
    end
endmodule
