 // tb_comp2.v
// Self-checking testbench for comp2 (2-bit unsigned magnitude comparator).
// Independently computes expected GT/LT/EQ at the gate level (not by
// re-using the DUT's own formula) and checks every one of the 16 input
// combinations.

module tb;

  reg  [1:0] t_a;
  reg  [1:0] t_b;
  wire       t_GT;
  wire       t_LT;
  wire       t_EQ;

  comp2 U1 (
    .A  (t_a),
    .B  (t_b),
    .GT (t_GT),
    .LT (t_LT),
    .EQ (t_EQ)
  );

  // Independent (gate-level) expected-value logic
  wire x1, x0;
  assign x0 = ( ~t_a[0] & ~t_b[0] ) | ( t_a[0] & t_b[0] ); // a0 == b0
  assign x1 = ( ~t_a[1] & ~t_b[1] ) | ( t_a[1] & t_b[1] ); // a1 == b1

  wire exp_GT, exp_LT, exp_EQ;
  assign exp_EQ = x1 & x0;
  assign exp_GT = ( t_a[1] & ~t_b[1] ) | ( x1 & t_a[0] & ~t_b[0] );
  assign exp_LT = ( ~t_a[1] & t_b[1] ) | ( x1 & ~t_a[0] & t_b[0] );

  integer ta, tb;
  integer errors;

  initial begin
    errors = 0;

    for (ta = 0; ta < 4; ta = ta + 1) begin
      for (tb = 0; tb < 4; tb = tb + 1) begin
        t_a = ta;
        t_b = tb;
        #5; // let combinational logic settle before checking

        if ({t_GT, t_LT, t_EQ} !== {exp_GT, exp_LT, exp_EQ}) begin
          $display("FAIL at time %0t: A=%b B=%b  got GT=%b LT=%b EQ=%b  expected GT=%b LT=%b EQ=%b",
                    $time, t_a, t_b, t_GT, t_LT, t_EQ, exp_GT, exp_LT, exp_EQ);
          errors = errors + 1;
        end
      end
    end

    if (errors == 0)
      $display("All 16 combinations passed.");
    else
      $display("%0d mismatch(es) found.", errors);

    $finish;
  end

endmodule