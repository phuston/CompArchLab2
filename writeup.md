### CompArch Lab 2 Writeup
###### Isaac Getto, Sarah Walters, Patrick Huston
###### 11.06.2015

#### Input Conditioning
1. Circuit diagram


    Shown below is our circuit diagram implementation for the input conditioning unit.
![Input Conditioning Circuit Diagram](img/circuit_diargam.jpg)
2. Clock Analysis
"If the main system clock is running at 50MHz, what is the maximum length input glitch that will be suppressed by this design for a waittime of 10?"

In the analysis of the case that the clock is running at 50MHz, the maximum length input glitch that will still be suppressed by the design for a waittime of 10 will be 259 'time units'.

Because:

Will take 3 clock cycles - 60 time units to pass data from noisysignal to synchronizer1, + 10 additional clock cycles - 200 time units. 

Has to do with noisysignal being changed right after a positive clock edge.

#### Shift Register
###### Testing Strategy
To test our shift register unit, we tested each of its use cases - serial data load, parallel data load, serial data read, and parallel data read. 

We did this by initially loading in an 8-bit number (10000000) into the shift register in parallel, triggering a clock edge to load the data into the shift register, and then verifying that the parallel data out from the shift register matched the data we originally sent in.

To test the serial load and read cases, we loaded an extra bit of data in serial, shifting the contents of the register to be '00000001'. At this point, we read the entire set of data out in parallel and in serial, verifying that the output was as expected - '00000001' for the parallel read, and '0' for the serial read.

Finally, we tested the functionality of the peripheral clock edge by setting the 'peripheralClkEdge' parameter to 0, and triggering another clock edge. If the 'peripheralClkEdge' were nonfunctional, another bit of data would have been loaded in serial into the shift register. We verified the output by checking for the same values - '00000001' for the parallel data read, and '0' for the serial read.

#### SPI Memory Testing Strategy
To test the SPI module, we iterated through all 2^7 addresses supported, and wrote twice the address value to that address. At this point, we read the values at each of the addresses written to, and ensured the value read matched the expected value that was written.

#### Fault Injection
This is where our section on describing fault injection will go.