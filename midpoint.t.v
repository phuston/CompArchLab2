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
        $dumpfile("waveform.vcd");
        $dumpvars(0, testMidpoint);

        btn = 1; #150 btn = 0; #150
        $display("Parallel Out: %b", parallelOut);
        $display("Serial Out: %b", serialOut);
        if (parallelOut !== 8'hA5 && serialOut !== 1) begin
            dutpassed = 0;
            $display("Test Case 1 Failed");
        end 
    end 
endmodule
