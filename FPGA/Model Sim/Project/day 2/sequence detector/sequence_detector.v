
module sequence_detector_moore(
    input clk,
    input rst,
    input in,
    output detected
);

    parameter S0 = 3'd0,
              S1 = 3'd1,
              S2 = 3'd2,
              S3 = 3'd3,
              S4 = 3'd4;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case(state)
            S0: next_state = in ? S1 : S0;
            S1: next_state = in ? S1 : S2;
            S2: next_state = in ? S3 : S0;
            S3: next_state = in ? S4 : S2;
            S4: next_state = in ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    // Moore output
    assign detected = (state == S4);

endmodule


module sequence_detector_mealy(
    input clk,
    input rst,
    input in,
    output reg detected
);

    parameter S0 = 2'd0,
              S1 = 2'd1,
              S2 = 2'd2,
              S3 = 2'd3;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next state and output logic
    always @(*) begin
        next_state = state;
        detected = 1'b0;

        case(state)
            S0: begin
                if(in) next_state = S1;
                else   next_state = S0;
            end

            S1: begin
                if(in) next_state = S1;
                else   next_state = S2;
            end

            S2: begin
                if(in) next_state = S3;
                else   next_state = S0;
            end

            S3: begin
                if(in) begin
                    detected = 1'b1;
                    next_state = S1;
                end
                else
                    next_state = S2;
            end

            default: next_state = S0;
        endcase
    end

endmodule
