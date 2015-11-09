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

    // Create the input conditioner that will be tested
    inputconditioner dut(.clk(clk),
    			 .noisysignal(pin),
                 .faultactive(0),
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

            // The conditioned output should not change for 6 cycles
            if (conditioned !== 0) begin
                $display("Synchronization test failed in repeat block");
                dutpassed = 0;
            end
        end

        // After waiting six full cycles, 
        // conditioned should hold the new value
        #1
        if (conditioned !== 1) begin
            $display("Synchronization test failed after repeat block");
            dutpassed = 0;
        end

        // Oscillate the input value rapidly
        for (clean_counter = 0; clean_counter < 10; clean_counter = clean_counter + 1) begin
            #7 pin = !pin;
        end

        // After rapidly changing the input value,
        // the conditioned output should not change
        if (conditioned != 1) begin
            dutpassed = 0;
            $display("Debouncing failed");
        end

        // Test edge detection -- falling edge
        pin = 0;
        repeat (6) begin
            @ (posedge clk);

            // The negative edge should remain zero for 6 cycles
            if (falling !== 0) begin
                $display("Edge test failed in repeat block");
                dutpassed = 0;
            end
        end
        #1 // Wait a little bit, but not longer than a clock cycle

        // After 6 full cycles, there should be a falling edge
        if (falling !== 1) begin
            $display("Edge test failed -- signal never set");
            dutpassed = 0;
        end
        #20

        // The falling edge should only last one cycle
        if (falling !== 0) begin
            $display("Edge test failed -- signal did not reset");
            dutpassed = 0;
        end

        // Test edge detection - rising edge
        pin = 1;
        repeat (6) begin
            @ (posedge clk);

            // The rising edge should remain zero for 6 cycles
            if (rising !== 0) begin
                $display("Edge test failed in repeat block");
                dutpassed = 0;
            end
        end
        #1 // Wait a little bit, but not longer than a clock cycle

        // After 6 full cycles, there should be a rising edge
        if (rising !== 1) begin
            $display("Edge test failed -- signal never set");
            dutpassed = 0;
        end
        #20

        // The rising edge should only last one cycle
        if (rising !== 0) begin
            $display("Edge test failed -- signal did not reset");
            dutpassed = 0;
        end

        $display("DUT passed: %d", dutpassed);
    end
endmodule
