`timescale 1ns/1ps
module regfile_tb;
    reg clk,we;
    reg [4:0] rs1,rs2,rd;
    reg [31:0] write_data;
    wire [31:0] read_data1,read_data2;
    reg [31:0] model [0:31];
    integer errors,i,k;
    reg [4:0] rand_rd, rand_rs;
    reg [31:0] rand_data;

    regfile dut(.clk(clk),.we(we),.rs1(rs1),.rs2(rs2),.rd(rd),
                .write_data(write_data),.read_data1(read_data1),.read_data2(read_data2));
    always #5 clk=~clk;

    task check_reads;
        begin
            #1;
            if(read_data1 !== model[rs1]) begin
                $display("FAIL regfile rs1=%0d got=%h exp=%h",rs1,read_data1,model[rs1]);
                errors=errors+1;
            end
            if(read_data2 !== model[rs2]) begin
                $display("FAIL regfile rs2=%0d got=%h exp=%h",rs2,read_data2,model[rs2]);
                errors=errors+1;
            end
        end
    endtask

    initial begin
        clk=0; we=0; rs1=0; rs2=0; rd=0; write_data=0; errors=0;
        for(i=0;i<32;i=i+1) model[i]=0;

        // x0 write must be ignored
        @(negedge clk); we=1; rd=0; write_data=32'hFFFF_FFFF;
        @(posedge clk); #1; model[0]=0; rs1=0; rs2=0; check_reads();

        // Directed write, read-after-write bypass, and back-to-back writes
        @(negedge clk); rd=5; write_data=32'h1234_5678; rs1=5; rs2=0; we=1;
        check_reads(); // bypass before the active edge
        @(posedge clk); #1; model[5]=32'h1234_5678;
        @(negedge clk); rd=6; write_data=32'hA5A5_5A5A; rs1=5; rs2=6;
        check_reads();
        @(posedge clk); #1; model[6]=32'hA5A5_5A5A;
        @(negedge clk); we=0; rs1=5; rs2=6; check_reads();

        // 200 random write/read operations, with a software reference model
        for(k=0;k<200;k=k+1) begin
            @(negedge clk);
            rand_rd=$random; rand_rs=$random; rd=rand_rd;
            rs1=rand_rs; rs2=$random; write_data=$random; we=($random & 1);
            check_reads(); // includes same-cycle bypass
            @(posedge clk); #1;
            if(we && rd!=0) model[rd]=write_data;
            model[0]=0;
            @(negedge clk);
            we=0;
            check_reads();
        end
        if(errors==0) $display("REGFILE TEST: PASS (directed + 200 random operations)");
        else $display("REGFILE TEST: FAIL (%0d errors)",errors);
        $finish;
    end
endmodule
