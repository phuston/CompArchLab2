//------------------------------------------------------------------------
// Input Conditioner
//    1) Synchronizes input to clock domain
//    2) Debounces input
//    3) Creates pulses at edge transitions
//------------------------------------------------------------------------

module inputconditioner
(
input 	    clk,            // Clock domain to synchronize input to
input	    noisysignal,    // (Potentially) noisy input signal
input       faultactive,    // Wether or not inputconditioner is broken
output reg  conditioned,    // Conditioned output signal
output reg  positiveedge,   // 1 clk pulse at rising edge of conditioned
output reg  negativeedge    // 1 clk pulse at falling edge of conditioned
);

    parameter counterwidth = 3; // Counter size, in bits, >= log2(waittime)
    parameter waittime = 3;     // Debounce delay, in clock cycles

    // Create registers for counter and synchronizers
    reg[counterwidth-1:0] counter = 0;
    reg synchronizer0 = 0;
    reg synchronizer1 = 0;

    always @(posedge clk) begin
        // Set positiveedge and negativeedge to 0 to prevent flag from persisting past 1 clock cycle
        positiveedge <= 0;
        negativeedge <= 0;

        if(conditioned == synchronizer1)
            counter <= 0;
        else begin
            if(counter == waittime) begin
                counter <= 0;
                conditioned <= synchronizer1;
                // Set positiveedge & negativeedge
                positiveedge <= synchronizer1;
                negativeedge <= !synchronizer1;
            end
            else
                counter <= counter+1;
        end
        synchronizer0 <= !faultactive & noisysignal;
        synchronizer1 <= synchronizer0;
    end
endmodule
