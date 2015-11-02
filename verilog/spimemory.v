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

	wire parallelDataOut, serialDataOut, parallelDataIn;
	shiftregister shiftRegister(
								.clk(clk),
								.peripheralClkEdge(positiveedgeSclk),
								.parallelLoad(#NOTDONE),
								.parallelDataIn(parallelDataIn),
								.serialDataIn(conditionedMosi),
								.parallelDataOut(parallelDataOut),
								.serialDataOut(serialDataOut)
							   );

	wire dataMemoryAddress;
	datamemory dataMemory(
						  .clk(clk),
						  .dataOut(parallelDataIn),
						  .address(dataMemoryAddress),
						  .writeEnable(#NOTDONE),
						  .dataIn(parallelDataOut)
						 );

	dff #(8) addressLatch(
						  .trigger(clk),
						  .enable(#NOTDONE),
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

	tristatebuffer misoBuffer(
							  .d(misoDffOut),
							  .q(miso_pin),
							  .enable(#NOTDONE)
							 );



endmodule
   
