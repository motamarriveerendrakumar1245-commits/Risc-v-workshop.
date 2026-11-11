// Day 1.4: 32 x 32 register file; x0 is hardwired to zero.
// Combinational bypass returns write_data on a same-cycle read/write match.
module regfile (
    input clk,
    input we,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);
    reg [31:0] registers [0:31];
    integer i;
    initial begin
        for(i=0;i<32;i=i+1) registers[i]=0;
    end
    always @(posedge clk) begin
        if(we && (rd != 0))
            registers[rd] <= write_data;
        registers[0] <= 0;
    end
    assign read_data1 = (rs1==0) ? 32'b0 :
                        ((we && (rd==rs1)) ? write_data : registers[rs1]);
    assign read_data2 = (rs2==0) ? 32'b0 :
                        ((we && (rd==rs2)) ? write_data : registers[rs2]);
endmodule
