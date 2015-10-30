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
    initial begin
        $dumpfile("inputconditioner.vcd");
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


        $display("DUT passed: %d", dutpassed);
    end
    // Your Test Code
    // Be sure to test each of the three conditioner functions:
    // Synchronize, Clean, Preprocess (edge finding)

endmodule
