module fsm
(
  input sclk,
  input chipselect,
  input readwrite,
  output shiftRegWriteEnable,
  output dataMemWriteEnable,
  output addressLatchEnable,
  output misoEnable
);

  parameter state_GET = 3'd0;
  parameter state_GOT = 3'd1;
  parameter state_READ1 = 3'd2;
  parameter state_READ2 = 3'd3;
  parameter state_READ3 = 3'd4;
  parameter state_WRITE1 = 3'd5;
  parameter state_WRITE2 = 3'd6;
  parameter state_DONE = 3'd7;

  reg[2:0] state, counter;

  always @(posedge clk) begin
      if (chipselect) begin
        state <= 0;
        counter <= 0;
      end
      else begin
        shiftRegWriteEnable <= 0;
        dataMemWriteEnable <= 0;
        addressLatchEnable <= 0;
        misoEnable <= 0;

        case ()
          state_GET: // MOSI. read address bits
            if (counter === 3'd8) begin
              state <= state_GOT;
            end
            else begin
              counter <= counter + 1;
            end

          state_GOT: // received address bits -- start read or write cycle
            counter <= 3'd0;
            addressLatchEnable <= 1;
            if (readwrite) begin
              state <= state_READ1;
            end
            else begin
              state <= state_WRITE1;
            end

          state_READ1: // wait a cycle to read the data at address from data memory
            state <= state_READ2;

          state_READ2: // store data at address in shift register (shift reg: parallel in)
            shiftRegWriteEnable <= 1;
            state <= state_READ3;

          state_READ3: // MISO. output data at address to master (shift reg: serial out)
            misoEnable <= 1;
            if (counter === 3'd8) begin
              state <= state_DONE;
            end
            else begin
              counter <= counter + 1;
            end

          state_WRITE1: // MOSI. store data to be written in shift register (shift reg: serial in)
            if (counter === 3'd8) begin
              state <= state_WRITE2;
            end
            else begin
              counter <= counter + 1;
            end

          state_WRITE2: // write data to data memory at address (shift reg: parallel out)
            dataMemWriteEnable <= 1;
            state <= state_DONE;

          state_DONE:
            counter <= 0;

          default:
            $display("Error in state %d", state);

      end
  end

endmodule
