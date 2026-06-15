package Example;

typedef struct { UInt#(8) r; UInt#(8) g; UInt#(8) b; } Color
  deriving (Bits);

typedef enum { IDLE, SEND_COLOR, RESET} State 
  deriving(Bits, Eq);

(* synthesize *)

module mkExample (Empty);
  Reg#(Color) argb <- mkArgbDrive;
  Reg#(Color) c <- mkReg(unpack(24'h0f0f0f));

  rule colorTest;
    argb <= c;
    c <= unpack({pack(c.r+16),pack(c.g+16),pack(c.b+16)});
    if (pack(c) == 24'hffffff) begin
      $display("Sim Finished");
      $finish(0);
    end
  endrule: colorTest
endmodule: mkExample

module mkArgbDrive (Reg#(Color));

  Reg#(bit) s_led_out <- mkReg(0);
  Reg#(int) bit_count <- mkReg(0);
  Reg#(int) clock_count <- mkReg(0);

  Reg#(Color) current_color <- mkReg(unpack({8'd0,8'd0,8'd0}));
  Reg#(Color) latched_color <- mkReg(unpack({8'd0,8'd0,8'd0}));
  Reg#(Bool) valid <- mkReg(False);

  Reg#(State) state <- mkReg(IDLE);

  int zero_high = 40;
  int one_high = 85;
  int bit_end = 125;
  int reset_count = 5500;
  int num_bits = 24;

  rule stateIdle (state == IDLE && valid);
    $display("Setting color %06X",pack(current_color));
    latched_color <= current_color;
    bit_count <= 0;
    clock_count <= 0;
    s_led_out <= 0;
    state <= SEND_COLOR;
    valid <= False;
  endrule: stateIdle

  rule stateSendColor (state == SEND_COLOR);
    bit current_bit = pack(latched_color)[bit_count];
    if (current_bit == 0) begin
      if (clock_count < zero_high) begin
        s_led_out <= 1;
      end
      else begin
        s_led_out <= 0;
      end
    end
    else begin
      if (clock_count < one_high) begin
        s_led_out <= 1;
      end
      else begin
        s_led_out <= 0;
      end
    end

    if (clock_count < (bit_end - 1)) begin
      clock_count <= clock_count + 1;
    end
    else begin
      clock_count <= 0;
      if(bit_count == (num_bits - 1)) begin
        state <= RESET;
      end
      bit_count <= bit_count + 1;
    end
  endrule: stateSendColor

  rule stateReset (state == RESET);
    s_led_out <= 0;
    if (clock_count < reset_count) begin
      clock_count <= clock_count + 1;
    end
    else begin
      clock_count <= 0;
      state <= IDLE;
    end
  endrule: stateReset

  method Action _write (Color a) if (!valid);
    current_color <= a;
    valid <= True;
  endmethod: _write

  method Color _read();
    return current_color;
  endmethod: _read

endmodule: mkArgbDrive

endpackage: Example
