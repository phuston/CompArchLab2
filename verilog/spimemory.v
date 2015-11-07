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
    output [3:0]    leds        // LEDs for debugging
);

	wire conditionedMosi;
	inputconditioner mosiConditioner(
									 .clk(clk),
									 .noisysignal(mosi_pin),
									 .conditioned(conditionedMosi),
									 .positiveedge(),
									 .negativeedge()
									);

	wire positiveedgeSclk, negativeedgeSclk;
	inputconditioner sclkConditioner(
									 .clk(clk),
									 .noisysignal(sclk_pin),
									 .conditioned(),
									 .positiveedge(positiveedgeSclk),
									 .negativeedge(negativeedgeSclk)
									);

	wire conditionedCs;
	inputconditioner csConditioner(
								   .clk(clk),
								   .noisysignal(cs_pin),
								   .conditioned(conditionedCs),
								   .positiveedge(),
								   .negativeedge()
								  );

	wire[7:0] parallelDataOut;
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

