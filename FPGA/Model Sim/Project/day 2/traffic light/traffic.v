
module traffic #(
    parameter GREEN_TIME  = 4,
    parameter YELLOW_TIME = 2,
    parameter RED_TIME    = 1,
    parameter WALK_TIME   = 3
)(
    input clk,
    input rst,
    input ped_request,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,

    output reg walk
);

    // FSM state declarations
    localparam NS_GREEN     = 3'd0;
    localparam NS_YELLOW    = 3'd1;
    localparam ALL_RED_EW   = 3'd2;
    localparam EW_GREEN     = 3'd3;
    localparam EW_YELLOW    = 3'd4;
    localparam ALL_RED_NS   = 3'd5;
    localparam WALK_TO_EW   = 3'd6;
    localparam WALK_TO_NS   = 3'd7;

    reg [2:0] state;
    reg [31:0] timer;

    // Remember pedestrian request
    reg ped_pending;

    // Sequential FSM
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            state <= NS_GREEN;
            timer <= 0;
            ped_pending <= 0;
        end

        else begin

            // Ignore requests during pedestrian walk
            if (ped_request &&
                state != WALK_TO_EW &&
                state != WALK_TO_NS)
                ped_pending <= 1;

            case(state)

                // North-South GREEN
                NS_GREEN: begin
                    if(timer == GREEN_TIME-1) begin
                        timer <= 0;
                        state <= NS_YELLOW;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // North-South YELLOW
                NS_YELLOW: begin
                    if(timer == YELLOW_TIME-1) begin
                        timer <= 0;

                        if(ped_pending || ped_request) begin
                            state <= WALK_TO_EW;
                            ped_pending <= 0;
                        end
                        else begin
                            state <= ALL_RED_EW;
                        end
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // All RED before East-West traffic
                ALL_RED_EW: begin
                    if(timer == RED_TIME-1) begin
                        timer <= 0;

                        if(ped_pending || ped_request) begin
                            state <= WALK_TO_EW;
                            ped_pending <= 0;
                        end
                        else begin
                            state <= EW_GREEN;
                        end
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // East-West GREEN
                EW_GREEN: begin
                    if(timer == GREEN_TIME-1) begin
                        timer <= 0;
                        state <= EW_YELLOW;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // East-West YELLOW
                EW_YELLOW: begin
                    if(timer == YELLOW_TIME-1) begin
                        timer <= 0;

                        if(ped_pending || ped_request) begin
                            state <= WALK_TO_NS;
                            ped_pending <= 0;
                        end
                        else begin
                            state <= ALL_RED_NS;
                        end
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // All RED before North-South traffic
                ALL_RED_NS: begin
                    if(timer == RED_TIME-1) begin
                        timer <= 0;

                        if(ped_pending || ped_request) begin
                            state <= WALK_TO_NS;
                            ped_pending <= 0;
                        end
                        else begin
                            state <= NS_GREEN;
                        end
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // Pedestrian crossing, then East-West GREEN
                WALK_TO_EW: begin
                    if(timer == WALK_TIME-1) begin
                        timer <= 0;
                        state <= EW_GREEN;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // Pedestrian crossing, then North-South GREEN
                WALK_TO_NS: begin
                    if(timer == WALK_TIME-1) begin
                        timer <= 0;
                        state <= NS_GREEN;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                default: begin
                    state <= NS_GREEN;
                    timer <= 0;
                    ped_pending <= 0;
                end

            endcase
        end
    end

    // Output logic
    always @(*) begin

        // Default: all vehicle signals RED
        ns_red = 1;
        ns_yellow = 0;
        ns_green = 0;

        ew_red = 1;
        ew_yellow = 0;
        ew_green = 0;

        walk = 0;

        case(state)

            NS_GREEN:
                begin
                    ns_red = 0;
                    ns_green = 1;
                end

            NS_YELLOW:
                begin
                    ns_red = 0;
                    ns_yellow = 1;
                end

            EW_GREEN:
                begin
                    ew_red = 0;
                    ew_green = 1;
                end

            EW_YELLOW:
                begin
                    ew_red = 0;
                    ew_yellow = 1;
                end

            WALK_TO_EW, WALK_TO_NS:
                begin
                    walk = 1;
                end

        endcase
    end

endmodule
