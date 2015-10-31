//------------------------------------------------------------------------
// Shift Register test bench
//------------------------------------------------------------------------

module testshiftregister();

    reg             clk;
    reg             peripheralClkEdge;
    reg             parallelLoad;
    wire[7:0]       parallelDataOut;
    wire            serialDataOut;
    reg[7:0]        parallelDataIn;
    reg             serialDataIn;
    reg             dutpassed;

    // Instantiate with parameter width = 8
    shiftregister #(8) dut(.clk(clk),
    		           .peripheralClkEdge(peripheralClkEdge),
    		           .parallelLoad(parallelLoad),
    		           .parallelDataIn(parallelDataIn),
    		           .serialDataIn(serialDataIn),
    		           .parallelDataOut(parallelDataOut),
    		           .serialDataOut(serialDataOut));

    initial begin
        $dumpfile("test/waveform.vcd");
        $dumpvars(0, testshiftregister);
        dutpassed = 1;
        peripheralClkEdge = 1;

        // Load initial data in parallel
        clk = 0;
        parallelLoad = 1;
        parallelDataIn = 8'b10000000;

        #5 clk = 1; #5 clk = 0;
        if (serialDataOut !== 1 && parallelDataOut !== 8'b10000000) begin
            dutpassed = 0;
            $display("Test 1 failed.");
        end

        // Load data in serial
        parallelLoad = 0;
        serialDataIn = 1;
        #5 clk = 1; #5 clk = 0;
        if (serialDataOut !== 0 && parallelDataOut !== 8'b1) begin
            dutpassed = 0;
            $display("Test 2 failed.");
        end

        // Test peripheral clock edge is functional
        peripheralClkEdge = 0;
        #5 clk = 1; #5 clk = 0;
        if (serialDataOut !== 0 && parallelDataOut !== 8'b1) begin
            dutpassed = 0;
            $display("Test 3 failed; peripheralClkEdge check nonfunctional.");
        end

        $display("DUT passed: %b", dutpassed);

    end

endmodule

