`timescale 1ns/1ps
module adder_sub_tb;
    reg [7:0] a,b;
    reg mode;
    wire [7:0] result;
    wire carry_out,overflow;
    reg [7:0] expected;
    reg expected_ov;
    integer errors,i,j,m;
    adder_sub dut(.a(a),.b(b),.mode(mode),.result(result),
                  .carry_out(carry_out),.overflow(overflow));
    initial begin
        errors=0;
        for(m=0;m<2;m=m+1)
            for(i=0;i<256;i=i+1)
                for(j=0;j<256;j=j+1) begin
                    a=i; b=j; mode=m;
                    if(m==0) begin
                        expected=(i+j)&255;
                        expected_ov=((i[7]==j[7]) && (expected[7]!=i[7]));
                    end else begin
                        expected=(i-j)&255;
                        expected_ov=((i[7]!=j[7]) && (expected[7]!=i[7]));
                    end
                    #1;
                    if(result !== expected || overflow !== expected_ov) begin
                        if(errors<10) $display("FAIL adder_sub a=%h b=%h mode=%b result=%h exp=%h ov=%b expov=%b",
                            a,b,mode,result,expected,overflow,expected_ov);
                        errors=errors+1;
                    end
                end
        if(errors==0) $display("ADDER/SUBTRACTOR TEST: PASS (131072 cases)");
        else $display("ADDER/SUBTRACTOR TEST: FAIL (%0d errors)",errors);
        $finish;
    end
endmodule
