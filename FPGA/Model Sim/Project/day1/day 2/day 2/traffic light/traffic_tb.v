
module traffic_tb;

    reg clk;
    reg rst;
    reg ped_request;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;
    wire walk;

    integer errors;

    // DUT with short timing values
    traffic #(
        .GREEN_TIME(4),
        .YELLOW_TIME(2),
        .RED_TIME(1),
        .WALK_TIME(3)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .ped_request(ped_request),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),

        .walk(walk)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        ped_request = 0;
        errors = 0;

        $display("--------------------------------");
        $display(" TRAFFIC LIGHT FSM TEST");
        $display("--------------------------------");

        // Reset
        repeat(2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Check NS GREEN
        #1;
        if(ns_green && ew_red)
            $display("PASS: NS GREEN");
        else begin
            $display("FAIL: NS GREEN");
            errors = errors + 1;
        end

        // Wait for NS YELLOW
        repeat(4) @(posedge clk);
        #1;

        if(ns_yellow && ew_red)
            $display("PASS: NS YELLOW");
        else begin
            $display("FAIL: NS YELLOW");
            errors = errors + 1;
        end

        // Wait for ALL RED
        repeat(2) @(posedge clk);
        #1;

        if(ns_red && ew_red && !walk)
            $display("PASS: ALL RED");
        else begin
            $display("FAIL: ALL RED");
            errors = errors + 1;
        end

        // Wait for EW GREEN
        repeat(1) @(posedge clk);
        #1;

        if(ew_green && ns_red)
            $display("PASS: EW GREEN");
        else begin
            $display("FAIL: EW GREEN");
            errors = errors + 1;
        end

        // Pedestrian request during EW GREEN
        @(negedge clk);
        ped_request = 1;

        @(negedge clk);
        ped_request = 0;

        $display("Pedestrian request received");

        // Wait for pedestrian WALK
        wait(walk == 1);
        #1;

        if(walk && ns_red && ew_red)
            $display("PASS: PEDESTRIAN WALK");
        else begin
            $display("FAIL: PEDESTRIAN WALK");
            errors = errors + 1;
        end

        // Give another request during WALK
        @(negedge clk);
        ped_request = 1;

        @(negedge clk);
        ped_request = 0;

        $display("Request during WALK sent");

        // Wait until NS GREEN resumes
        wait(ns_green == 1);
        #1;

        if(ns_green && !walk)
            $display("PASS: RETURN TO NS GREEN");
        else begin
            $display("FAIL: RETURN TO NS GREEN");
            errors = errors + 1;
        end

        // Check final result
        if(errors == 0)
            $display("ALL TRAFFIC LIGHT TESTS PASSED!");
        else
            $display("TEST FAILED: %0d errors", errors);

        $display("--------------------------------");

        $finish;

    end

endmodule
