// 1-bit full adder used by the ripple-carry adder/subtractor
module full_adder(input a,b,cin, output sum,cout);
    assign {cout,sum} = a + b + cin;
endmodule
