
module vending_machine(
    input clk,
    input rst,
    input coin5,
    input coin10,
    input cancel,

    output reg dispense,
    output reg [4:0] change,
    output reg [4:0] refund
);

    parameter IDLE = 2'd0,
              FIVE = 2'd1,
              TEN  = 2'd2;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin

        if(rst) begin
            state <= IDLE;
            dispense <= 0;
            change <= 0;
            refund <= 0;
        end

        else begin

            // Default outputs
            dispense <= 0;
            change <= 0;
            refund <= 0;

            // Cancellation has priority
            if(cancel) begin

                case(state)
                    FIVE: refund <= 5;
                    TEN:  refund <= 10;
                    default: refund <= 0;
                endcase

                state <= IDLE;
            end

            else begin

                case(state)

                    IDLE: begin
                        if(coin5 && !coin10)
                            state <= FIVE;

                        else if(coin10 && !coin5)
                            state <= TEN;
                    end

                    FIVE: begin
                        if(coin5 && !coin10)
                            state <= TEN;

                        else if(coin10 && !coin5) begin
                            dispense <= 1;
                            state <= IDLE;
                        end
                    end

                    TEN: begin
                        if(coin5 && !coin10) begin
                            dispense <= 1;
                            state <= IDLE;
                        end

                        else if(coin10 && !coin5) begin
                            dispense <= 1;
                            change <= 5;
                            state <= IDLE;
                        end
                    end

                    default: state <= IDLE;

                endcase
            end
        end
    end

endmodule
