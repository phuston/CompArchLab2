module testMidpoint();

    reg btn;
    reg switch0;
    reg switch1;
    wire[7:0] parallelOut;
    wire serialOut;
    reg clk;
    reg dutpassed;

    midpoint #(8) dut(
                        .btn0(btn),
                        .switch0(switch0),
                        .switch1(switch1),
                        .clk(clk),
                        .parallelout(parallelOut),
                        .serialout(serialOut)
                    );

    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    initial begin
        $dumpfile("test/waveform.vcd");
        $dumpvars(0, testMidpoint);

        dutpassed = 1;

        // Test parallel in
        btn = 1; #150 btn = 0; #150
        if (parallelOut !== 8'hA5 && serialOut !== 1) begin
            dutpassed = 0;
            $display("Test Case 1 Failed");
        end

        // Test shifting
        switch0 = 0; #150
        switch1 = 1; #150
        if (parallelOut !== 8'h4A && serialOut !== 0) begin
            dutpassed = 0;
            $display("Test Case 2 Failed");
        end

        $display("dutpassed: %b", dutpassed);
    end
endmodule
