// Day 1.5: 8-bit ripple-carry adder/subtractor.
// mode=0: A+B; mode=1: A-B (two's-complement using B XOR mode).
module adder_sub (
    input [7:0] a,b,
    input mode,
    output [7:0] result,
    output carry_out,
    output overflow
);
    wire [7:0] bx;
    wire [8:0] c;
    assign bx = b ^ {8{mode}};
    assign c[0] = mode;
    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin: FA
            full_adder u_fa(.a(a[i]),.b(bx[i]),.cin(c[i]),
                            .sum(result[i]),.cout(c[i+1]));
        end
    endgenerate
    assign carry_out = c[8];
    assign overflow = (a[7] == bx[7]) && (result[7] != a[7]);
endmodule
