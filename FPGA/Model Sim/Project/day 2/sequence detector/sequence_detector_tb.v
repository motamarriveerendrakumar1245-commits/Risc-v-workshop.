
module sequence_detector_tb;

    reg clk, rst, in;

    wire moore_detected;
    wire mealy_detected;

    reg [6:0] stream;
    integer i;
    integer errors;
    reg expected;

    sequence_detector_moore DUT1(
        .clk(clk),
        .rst(rst),
        .in(in),
        .detected(moore_detected)
    );

    sequence_detector_mealy DUT2(
        .clk(clk),
        .rst(rst),
        .in(in),
        .detected(mealy_detected)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        in = 0;
        errors = 0;

        stream = 7'b1011011;

        repeat(2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        for(i = 0; i < 7; i = i + 1) begin

            @(negedge clk);
            in = stream[6-i];

            expected = (i == 3 || i == 6);

            // Check Mealy output before clock edge
            #1;
            if(mealy_detected !== expected) begin
                $display("MEALY FAIL at bit %0d", i);
                errors = errors + 1;
            end

            // Check Moore output after clock edge
            @(posedge clk);
            #1;
            if(moore_detected !== expected) begin
                $display("MOORE FAIL at bit %0d", i);
                errors = errors + 1;
            end

        end

        if(errors == 0)
            $display("SEQUENCE DETECTOR: ALL TESTS PASSED");
        else
            $display("SEQUENCE DETECTOR FAILED: %0d errors", errors);

        $finish;
    end

endmodule
