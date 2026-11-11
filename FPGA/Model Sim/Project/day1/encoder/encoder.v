// Day 1.6: 8-to-3 priority encoders. Highest numbered input has priority.
module priority_encoder_casez(input [7:0] in, output reg [2:0] code, output reg valid);
    always @(*) begin
        valid=1'b1;
        casex(in)
            8'b1xxxxxxx: code=3'd7;
            8'b01xxxxxx: code=3'd6;
            8'b001xxxxx: code=3'd5;
            8'b0001xxxx: code=3'd4;
            8'b00001xxx: code=3'd3;
            8'b000001xx: code=3'd2;
            8'b0000001x: code=3'd1;
            8'b00000001: code=3'd0;
            default: begin code=3'd0; valid=1'b0; end
        endcase
    end
endmodule

module priority_encoder_if(input [7:0] in, output reg [2:0] code, output reg valid);
    always @(*) begin
        valid=1'b1;
        if      (in[7]) code=3'd7;
        else if (in[6]) code=3'd6;
        else if (in[5]) code=3'd5;
        else if (in[4]) code=3'd4;
        else if (in[3]) code=3'd3;
        else if (in[2]) code=3'd2;
        else if (in[1]) code=3'd1;
        else if (in[0]) code=3'd0;
        else begin code=3'd0; valid=1'b0; end
    end
endmodule
