module binary_to_bcd_4digit(
    input  [15:0] binary,
    output reg [3:0] d0,
    output reg [3:0] d1,
    output reg [3:0] d2,
    output reg [3:0] d3
);
    integer i;

    // 32 bits = 16 bits binary + 4 BCD digits (4*4)
    reg [31:0] shift;

    always @* begin
        // clear and load binary into lower 16 bits
        shift = 32'd0;
        shift[15:0] = binary;

        // double dabble algorithm for 16-bit input
        for (i = 0; i < 16; i = i + 1) begin
            // if any BCD nibble >= 5, add 3
            if (shift[19:16] >= 5) shift[19:16] = shift[19:16] + 4'd3; // ones
            if (shift[23:20] >= 5) shift[23:20] = shift[23:20] + 4'd3; // tens
            if (shift[27:24] >= 5) shift[27:24] = shift[27:24] + 4'd3; // hundreds
            if (shift[31:28] >= 5) shift[31:28] = shift[31:28] + 4'd3; // thousands

            // shift left one bit
            shift = shift << 1;
        end

        // after 16 iterations, BCD digits are in the upper 16 bits
        d0 = shift[19:16];  // ones
        d1 = shift[23:20];  // tens
        d2 = shift[27:24];  // hundreds
        d3 = shift[31:28];  // thousands
    end
endmodule
