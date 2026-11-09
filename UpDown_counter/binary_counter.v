module top(output reg Q, Q_b, output [2:0] out_bin, input S, R, clk);
    reg counter_clk=0; // A separate clock for the counter. I want to see the output, and hence will give a switch signal to the adder
                       // every 250ms
    reg [23:0] div_clk=24'd0; 
    /* 24 zeroes. we're essentially going from zero -> 13,500,000. Because, 27MHz -> 27,000,000 cycles per second. 
    but we'd like the number of cycles for 250 * 10^(-3) seconds (250ms), so, 250*10^(-3)*27000000 = 6750000 cycles
    after which, the counter clock must switch (up or down), indicating that the next addition can be performed, provided it was a 
    positive edge.
    */
    reg op_mode = 0;
    wire [2:0] inc;
    wire [2:0] dec; // a wire based variable of this type allows for continous reassignment as opposed to its "reg" counter part
                    // which is useful for storing only.
    parameter CYCLES_500_ms = 24'd6750000;
    reg [2:0] A = 3'b000;

    initial begin
        Q = 1;
    end

    always @(posedge clk) begin
        Q <= ~(R & Q_b);
        Q_b <= ~(Q & S);
        op_mode <= Q;

        if(div_clk > (CYCLES_500_ms-1)) begin
            div_clk <= 24'd0;
            counter_clk <= ~counter_clk;
        end else begin
            div_clk <= div_clk + 1'b1;
        end
    end

    always @(posedge counter_clk) begin
        A <= ~out_bin;
    end

    u3b_incrementer u3b_1(A, inc);
    u3b_decrementer u3b_d_1(A, dec);

    assign out_bin = (op_mode == 1'b1) ? inc : dec;

endmodule

// "Unsigned 3-bit binary adder"
// Problem: c_2 initially needs a default value set, if not entered (0)... how do we put that?
module u3b_incrementer(input [2:0] A, output [2:0] out_bin);
    wire c_0, c_1, c_2;
    // c_2 gets ignored as it is an overflow carry
    
    half_adder h1(A[0], 1, out_bin[0], c_0);
    half_adder h2(A[1], c_0, out_bin[1], c_1);
    half_adder h3(A[2], c_1, out_bin[2], c_2);
endmodule

module half_adder(input a, b, output reg sum, carry);
    // logic 0 -> LED turns on (see line 30 for how this is reassigned back to LED array "A")
    always @(*) begin
        sum = ~((a & ~b) | (~a & b));
        carry = (a & b);
    end
endmodule

module u3b_decrementer(input [2:0] A, output [2:0] out_bin);
    // here, b_2 is the third borrow after the 3rd full subtractor operation and will be an overflow bit if it is "1"
    wire b_0, b_1, b_2;

    full_subtractor f1(A[0], 1'b1, 1'b0, out_bin[0], b_0);
    full_subtractor f2(A[1], 1'b0, b_0, out_bin[1], b_1);
    full_subtractor f3(A[2], 1'b0, b_1, out_bin[2], b_2);
endmodule

module full_subtractor(input a, b, c_in, output reg diff, b_out);
    always @(*) begin
        diff = ~(a ^ b ^ c_in);
        b_out = (~a & b) | (~a & c_in) | (b & c_in);
    end
endmodule
