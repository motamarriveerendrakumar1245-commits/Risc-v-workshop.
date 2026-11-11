
module vending_machine_tb;

    reg clk, rst;
    reg coin5, coin10, cancel;

    wire dispense;
    wire [4:0] change;
    wire [4:0] refund;

    integer errors;

    vending_machine DUT(
        .clk(clk),
        .rst(rst),
        .coin5(coin5),
        .coin10(coin10),
        .cancel(cancel),
        .dispense(dispense),
        .change(change),
        .refund(refund)
    );

    always #5 clk = ~clk;

    // Task to insert coins or cancel
    task transaction;
        input c5, c10, can;
        input exp_dispense;
        input [4:0] exp_change;
        input [4:0] exp_refund;

        begin
            @(negedge clk);

            coin5 = c5;
            coin10 = c10;
            cancel = can;

            @(posedge clk);
            #1;

            if(dispense !== exp_dispense ||
               change !== exp_change ||
               refund !== exp_refund) begin

                $display("FAIL: coin5=%b coin10=%b cancel=%b",
                         c5, c10, can);

                $display("Expected: dispense=%b change=%d refund=%d",
                         exp_dispense, exp_change, exp_refund);

                $display("Actual: dispense=%b change=%d refund=%d",
                         dispense, change, refund);

                errors = errors + 1;
            end
            else begin
                $display("PASS: dispense=%b change=%d refund=%d",
                         dispense, change, refund);
            end
        end
    endtask

    initial begin

        clk = 0;
        rst = 1;
        coin5 = 0;
        coin10 = 0;
        cancel = 0;
        errors = 0;

        repeat(2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Test 1: ₹5 + ₹10 = ₹15
        transaction(1,0,0,0,0,0);
        transaction(0,1,0,1,0,0);

        // Test 2: ₹10 + ₹10 = ₹20
        transaction(0,1,0,0,0,0);
        transaction(0,1,0,1,5,0);

        // Test 3: ₹5 + ₹5 + ₹5 = ₹15
        transaction(1,0,0,0,0,0);
        transaction(1,0,0,0,0,0);
        transaction(1,0,0,1,0,0);

        // Test 4: Insert ₹5 and cancel
        transaction(1,0,0,0,0,0);
        transaction(0,0,1,0,0,5);

        if(errors == 0)
            $display("VENDING MACHINE: ALL TESTS PASSED");
        else
            $display("VENDING MACHINE FAILED: %0d errors", errors);

        $finish;

    end

endmodule
