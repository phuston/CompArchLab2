//------------------------------------------------------------------------
// SPI Memory
//------------------------------------------------------------------------

module spiMemory
(
    input           clk,        // FPGA clock
    input           sclk_pin,   // SPI clock
    input           cs_pin,     // SPI chip select
    output          miso_pin,   // SPI master in slave out
    input           mosi_pin,   // SPI master out slave in
    input           fault_pin,  // For fault injection testing
    output [2:0]    leds        // LEDs for debugging
);
	
	// Instantiate input conditioner for MOSI input
	wire conditionedMosi;
	inputconditioner mosiConditioner(
									 .clk(clk),
									 .noisysignal(mosi_pin),
                                     .faultactive(fault_pin),
									 .conditioned(conditionedMosi),
									 .positiveedge(),
									 .negativeedge()
									);

	// Instantiate input conditioner for sClk input
	wire positiveedgeSclk, negativeedgeSclk;
	inputconditioner sclkConditioner(
									 .clk(clk),
									 .noisysignal(sclk_pin),
                                     .faultactive(fault_pin),
									 .conditioned(),
									 .positiveedge(positiveedgeSclk),
									 .negativeedge(negativeedgeSclk)
									);

	// Instantiate input conditioner for 'chip select'
	wire conditionedCs;
	inputconditioner csConditioner(
								   .clk(clk),
								   .noisysignal(cs_pin),
                                   .faultactive(fault_pin),
								   .conditioned(conditionedCs),
								   .positiveedge(),
								   .negativeedge()
								  );

	// Instantiate shift register
	wire[7:0] parallelDataOut
	wire serialDataOut, parallelDataIn, SR_WE;
	shiftregister shiftRegister(
								.clk(clk),
								.peripheralClkEdge(positiveedgeSclk),
								.parallelLoad(SR_WE),
								.parallelDataIn(parallelDataIn),
								.serialDataIn(conditionedMosi),
								.parallelDataOut(parallelDataOut),
								.serialDataOut(serialDataOut)
							   );

	// Instantiate data memory
	wire dataMemoryAddress, DM_WE;
	datamemory dataMemory(
						  .clk(clk),
						  .dataOut(parallelDataIn),
						  .address(dataMemoryAddress),
						  .writeEnable(DM_WE),
						  .dataIn(parallelDataOut)
						 );

	wire ADDR_WE;
	dff #(8) addressLatch(
						  .trigger(clk),
						  .enable(ADDR_WE),
						  .d(parallelDataOut),
						  .q(dataMemoryAddress)
						 );


	wire misoDffOut;
	dff #(1) misoDff(
					 .trigger(clk),
					 .enable(negativeedgeSclk),
					 .d(serialDataOut),
					 .q(misoDffOut)
					);

	wire MISO_BUFE;
	tristatebuffer misoBuffer(
							  .d(misoDffOut),
							  .q(miso_pin),
							  .enable(MISO_BUFE)
							 );

	// Instantiate finite state machine
	fsm Fsm(
          .sclk(positiveedgeSclk),
          .chipselect(conditionedCs),
          .readwrite(parallelDataOut[0]),
          .shiftRegWriteEnable(SR_WE),
          .dataMemWriteEnable(DM_WE),
          .addressLatchEnable(ADDR_WE),
          .misoEnable(MISO_BUFE)
         );

endmodule

