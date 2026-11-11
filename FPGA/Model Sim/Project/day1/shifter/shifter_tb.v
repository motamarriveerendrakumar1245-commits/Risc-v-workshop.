`timescale 1ns/1ps
module shifter_tb;
    reg [31:0] data_in;
    reg [4:0] shamt;
    reg [1:0] mode;
    wire [31:0] data_out;
    reg [31:0] expected;
    integer errors, m, s;
    shifter dut(.data_in(data_in),.shamt(shamt),.mode(mode),.data_out(data_out));
    initial begin
        errors=0;
        data_in=32'h8123_4567;
        for(m=0;m<3;m=m+1) begin
            mode=m;
            for(s=0;s<32;s=s+1) begin
                shamt=s;
                case(m)
                    0: expected=data_in << s;
                    1: expected=data_in >> s;
                    2: expected=$signed(data_in) >>> s;
                endcase
                #1;
                if(data_out !== expected) begin
                    $display("FAIL shifter mode=%0d amount=%0d got=%h exp=%h",m,s,data_out,expected);
                    errors=errors+1;
                end
            end
        end
        if(errors==0) $display("SHIFTER TEST: PASS (all 96 cases)");
        else $display("SHIFTER TEST: FAIL (%0d errors)",errors);
        $finish;
    end
endmodule
