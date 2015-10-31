`timescale 1ns / 1ps

// D flip-flop with parameterized bit width (default: 1-bit)
// Parameters in Verilog: http://www.asic-world.com/verilog/para_modules1.html
module dff #( parameter W = 1 )
(
    input trigger,
    input enable,
    input      [W-1:0] d,
    output reg [W-1:0] q
);
    always @(posedge trigger) begin
        if(enable) begin
            q <= d;
        end
    end
endmodule

// JK flip-flop
module jkff1
(
    input trigger,
    input j,
    input k,
    output reg q
);
    always @(posedge trigger) begin
        if(j && ~k) begin
            q <= 1'b1;
        end
        else if(k && ~j) begin
            q <= 1'b0;
        end
        else if(k && j) begin
            q <= ~q;
        end
    end
endmodule

// Two-input MUX with parameterized bit width (default: 1-bit)
module mux2 #( parameter W = 1 )
(
    input[W-1:0]    in0,
    input[W-1:0]    in1,
    input           sel,
    output[W-1:0]   out
);
    // Conditional operator - http://www.verilog.renerta.com/source/vrg00010.htm
    assign out = (sel) ? in1 : in0;
endmodule


//  Usage:
//     btn0 - load parallel data from hard-coded 8'hA5
//     btn1 - display parallelout[3:0] on LEDs
//     btn2 - display parallelout[7:4] on LEDs
//     sw0  - serialin
//     sw1  - shift left by 1

module midpoint_wrapper
(
    input        clk,
    input  [1:0] sw,
    input  [2:0] btn,
    output [3:0] led
);

    wire[3:0] res0, res1;     // Output display options
    wire res_sel;             // Select between display options
    wire [7:0] parallelout;
    wire serialout;

    // Capture button input to switch which MUX input to LEDs
    jkff1 src_sel(.trigger(clk), .j(btn[2]), .k(btn[1]), .q(res_sel));
    mux2 #(4) output_select(.in0(res0), .in1(res1), .sel(res_sel), .out(led));

    midpoint m(.btn0(btn[0]), .switch0(sw[0]), .switch1(sw[1]), .clk(clk), .parallelout(parallelout), .serialout(serialout));

    // Assign output options
    assign res0 = parallelout[3:0];
    assign res1 = parallelout[7:4];

endmodule
