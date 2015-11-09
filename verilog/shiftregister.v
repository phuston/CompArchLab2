//------------------------------------------------------------------------
// Shift Register
//   Parameterized width (in bits)
//   Shift register can operate in two modes:
//      - serial in, parallel out
//      - parallel in, serial out
//------------------------------------------------------------------------

module shiftregister
#(parameter width = 8)
(
input               clk,                // FPGA Clock
input               peripheralClkEdge,  // Edge indicator
input               parallelLoad,       // 1 = Load shift reg with parallelDataIn
input  [width-1:0]  parallelDataIn,     // Load shift reg in parallel
input               serialDataIn,       // Load shift reg serially
output [width-1:0]  parallelDataOut,    // Shift reg data contents
output              serialDataOut       // Positive edge synchronized
);

    reg [width-1:0]      shiftregistermem;

    // Serial data out always presents the 
    // most significant bit of the shift register
	assign serialDataOut = shiftregistermem[width-1];

    // Parallel data out always presents the
    // entire contents of the shift register
	assign parallelDataOut = shiftregistermem;

    always @(posedge clk) begin

        // Load data in parallel
        if (parallelLoad === 1) begin
            shiftregistermem <= parallelDataIn;
        end

        // Load data in serially on clock edges
        else if (peripheralClkEdge === 1) begin
            shiftregistermem <= {shiftregistermem[width-2:0], serialDataIn};
	    end
    end
endmodule
