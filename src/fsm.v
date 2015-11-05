module fsm
(
  input sclk,
  input chipselect,
  input readwrite,
  output reg shiftRegWriteEnable,
  output reg dataMemWriteEnable,
  output reg addressLatchEnable,
  output reg misoEnable
);

  parameter state_GET = 3'd0;
  parameter state_GOT = 3'd1;
  parameter state_READ1 = 3'd2;
  parameter state_READ2 = 3'd3;
  parameter state_READ3 = 3'd4;
  parameter state_WRITE1 = 3'd5;
  parameter state_WRITE2 = 3'd6;
  parameter state_DONE = 3'd7;

  reg[2:0] state;
  reg[3:0] counter;

  always @(posedge sclk) begin
      if (chipselect) begin
        state <= 0;
        counter <= 0;
      end
      else begin
        shiftRegWriteEnable <= 0;
        dataMemWriteEnable <= 0;
        addressLatchEnable <= 0;
        misoEnable <= 0;

        case (state)
          state_GET : begin // MOSI. read address bits
            if (counter === 4'd8) begin
              state <= state_GOT;
            end
            else begin
              counter <= counter + 1;
            end
          end

          state_GOT : begin // received address bits -- start read or write cycle
            counter <= 4'd0;
            addressLatchEnable <= 1;
            if (readwrite) begin
              state <= state_READ1;
            end
            else begin
              state <= state_WRITE1;
            end
          end

          state_READ1 : begin // wait a cycle to read the data at address from data memory
            state <= state_READ2;
          end

          state_READ2 : begin // store data at address in shift register (shift reg: parallel in)
            shiftRegWriteEnable <= 1;
            state <= state_READ3;
          end

          state_READ3 : begin // MISO. output data at address to master (shift reg: serial out)
            misoEnable <= 1;
            if (counter === 4'd8) begin
              state <= state_DONE;
            end
            else begin
              counter <= counter + 1;
            end
          end

          state_WRITE1 : begin // MOSI. store data to be written in shift register (shift reg: serial in)
            if (counter === 4'd8) begin
              state <= state_WRITE2;
            end
            else begin
              counter <= counter + 1;
            end
          end

          state_WRITE2 : begin // write data to data memory at address (shift reg: parallel out)
            dataMemWriteEnable <= 1;
            state <= state_DONE;
          end

          state_DONE : begin
            counter <= 0;
          end

          default : begin
            $display("Error in state %d", state);
          end

          endcase
      end
  end

endmodule
