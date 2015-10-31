//------------------------------------------------------------------------
// Input Conditioner test bench
//------------------------------------------------------------------------

module testConditioner();

    reg clk;
    reg pin;
    wire conditioned;
    wire rising;
    wire falling;
    reg dutpassed;

    inputconditioner dut(.clk(clk),
    			 .noisysignal(pin),
			 .conditioned(conditioned),
			 .positiveedge(rising),
			 .negativeedge(falling));


    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    integer synchronize_counter;
    integer clean_counter;
    initial begin
        $dumpfile("test/waveform.vcd");
        $dumpvars(0, testConditioner);
        dutpassed = 1;

        // set initial condition
        pin = 0; #120

        // test synchronize
        pin = 1;
        repeat (6) begin
            @ (posedge clk);
            if (conditioned !== 0) begin
                $display("Synchronization test failed in repeat block");
                dutpassed = 0;
            end
        end
        #1
        if (conditioned !== 1) begin
            $display("Synchronization test failed after repeat block");
            dutpassed = 0;
        end

        for (clean_counter = 0; clean_counter < 10; clean_counter = clean_counter + 1) begin
            #7 pin = !pin;
        end

        if (conditioned != 1) begin
            dutpassed = 0;
            $display("Debouncing failed");
        end

        // Test edge detection -- falling edge
        pin = 0;
        repeat (6) begin
            @ (posedge clk);
            if (falling !== 0) begin
                $display("Edge test failed in repeat block");
                dutpassed = 0;
            end
        end
        #1 // Wait a little bit, but not longer than a clock cycle

        if (falling !== 1) begin
            $display("Edge test failed -- signal never set");
            dutpassed = 0;
        end
        #20
        if (falling !== 0) begin
            $display("Edge test failed -- signal did not reset");
            dutpassed = 0;
        end

        // Test edge detection - rising edge
        pin = 1;
        repeat (6) begin
            @ (posedge clk);
            if (rising !== 0) begin
                $display("Edge test failed in repeat block");
                dutpassed = 0;
            end
        end
        #1 // Wait a little bit, but not longer than a clock cycle

        if (rising !== 1) begin
            $display("Edge test failed -- signal never set");
            dutpassed = 0;
        end
        #20
        if (rising !== 0) begin
            $display("Edge test failed -- signal did not reset");
            dutpassed = 0;
        end

        $display("DUT passed: %d", dutpassed);
    end
    // Your Test Code
    // Be sure to test each of the three conditioner functions:
    // Synchronize, Clean, Preprocess (edge finding)

endmodule
