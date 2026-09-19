// tb.v
// Starter testbench template -- YOU complete this file.

// tb_lut.v
// Testbench for the parameterized lut (ROM) module.
// Overrides WIDTH/DEPTH away from the module's own defaults, then loops
// sel through every valid address and checks dout against the expected
// i*i value.

module tb_lut;

  // t_sel must be wide enough for the largest DEPTH we test (DEPTH=8 -> 3 bits).
  reg  [2:0] t_sel;
  wire [7:0] t_dout;

  integer i;
  integer errors;

  // Parameter override: DEPTH=8, WIDTH=8 -- different from the module's
  // own defaults (WIDTH=8, DEPTH=4), demonstrating the #() override syntax.
  lut #(.WIDTH(8), .DEPTH(8)) U1 (
    .sel  (t_sel),
    .dout (t_dout)
  );

  initial begin
    errors = 0;

    for (i = 0; i < 8; i = i + 1) begin
      t_sel = i;
      #5; // let the combinational read settle

      if (t_dout !== i*i) begin
        $display("%0t FAIL: sel=%0d expected dout=%0d got dout=%0d",
                  $time, i, i*i, t_dout);
        errors = errors + 1;
      end else begin
        $display("%0t PASS: sel=%0d dout=%0d", $time, i, t_dout);
      end
    end

    if (errors == 0)
      $display("All 8 addresses matched expected i*i values.");
    else
      $display("%0d mismatch(es) found.", errors);

    $finish;
  end

  initial
    $monitor($time, " sel=%0d dout=%0d", t_sel, t_dout);

endmodule