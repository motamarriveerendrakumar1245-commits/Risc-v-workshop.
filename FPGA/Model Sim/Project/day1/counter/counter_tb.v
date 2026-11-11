`timescale 1ns/1ps
module counter_tb;
    reg clk, reset, enable, up_down, load;
    reg [7:0] load_data;
    wire [7:0] count;
    integer errors;
    counter dut(.clk(clk),.reset(reset),.enable(enable),.up_down(up_down),
                .load(load),.load_data(load_data),.count(count));
    always #5 clk=~clk;

    task expect_count;
        input [7:0] exp;
        begin
            @(negedge clk);
            if (count !== exp) begin
                $display("FAIL counter got=%0d expected=%0d",count,exp);
                errors=errors+1;
            end
        end
    endtask

    initial begin
        clk=0; reset=0; enable=0; up_down=1; load=0; load_data=0; errors=0;
        reset=1; @(negedge clk); reset=0;
        enable=1; up_down=1; expect_count(1); expect_count(2);
        up_down=0; expect_count(1);
        enable=0; expect_count(1);
        load=1; load_data=8'd100; expect_count(100);
        load=0; enable=1; up_down=1; expect_count(101);
        reset=1; expect_count(0); reset=0;
        if(errors==0) $display("COUNTER TEST: PASS");
        else $display("COUNTER TEST: FAIL (%0d errors)",errors);
        $finish;
    end
endmodule
