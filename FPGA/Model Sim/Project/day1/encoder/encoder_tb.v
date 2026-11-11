
module encoder_tb;

    reg [7:0] in;
    wire [2:0] code_casez;
    wire valid_casez;

    wire [2:0] code_if;
    wire valid_if;

    integer i;
    integer expected_code;
    integer errors;

    // Instantiate casez encoder
    priority_encoder_casez DUT1 (
        .in(in),
        .code(code_casez),
        .valid(valid_casez)
    );

    // Instantiate if-else encoder
    priority_encoder_if DUT2 (
        .in(in),
        .code(code_if),
        .valid(valid_if)
    );

    // Find expected priority output
    function [3:0] reference_model;
        input [7:0] data;
        begin
            if      (data[7]) reference_model = {1'b1, 3'd7};
            else if (data[6]) reference_model = {1'b1, 3'd6};
            else if (data[5]) reference_model = {1'b1, 3'd5};
            else if (data[4]) reference_model = {1'b1, 3'd4};
            else if (data[3]) reference_model = {1'b1, 3'd3};
            else if (data[2]) reference_model = {1'b1, 3'd2};
            else if (data[1]) reference_model = {1'b1, 3'd1};
            else if (data[0]) reference_model = {1'b1, 3'd0};
            else              reference_model = {1'b0, 3'd0};
        end
    endfunction

    reg [3:0] expected;

    initial begin
        errors = 0;

        $display("--------------------------------------");
        $display("  8 TO 3 PRIORITY ENCODER TEST");
        $display("--------------------------------------");

        for (i = 0; i < 256; i = i + 1) begin

            in = i;
            expected = reference_model(in);

            #10;

            if ({valid_casez, code_casez} !== expected) begin
                $display("CASEZ FAIL: in=%b code=%d valid=%b expected=%b",
                         in, code_casez, valid_casez, expected);
                errors = errors + 1;
            end

            if ({valid_if, code_if} !== expected) begin
                $display("IF-ELSE FAIL: in=%b code=%d valid=%b expected=%b",
                         in, code_if, valid_if, expected);
                errors = errors + 1;
            end

        end

        $display("--------------------------------------");

        if (errors == 0)
            $display("ALL 256 TEST CASES PASSED!");
        else
            $display("TEST FAILED! Total errors = %0d", errors);

        $display("--------------------------------------");

        $finish;
    end

endmodule
