// tb_alu.v
// Self-checking testbench for alu.v.
// Designed specifically to expose:
//   1. A sensitivity-list bug (op not in the always block's sensitivity list)
//   2. A blocking/non-blocking bug in the subtract path (stale intermediate
//      values because <= reads old values, not the ones just computed)

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  integer errors;
  reg  [3:0] expected;

  alu U1 (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Runs one vector, waits for combinational settling, checks result.
  task check;
    begin
      #1; // let combinational logic settle
      expected = t_op ? (t_a - t_b) : (t_a + t_b); // 4-bit modular arithmetic
      if (t_result !== expected) begin
        $display("FAIL at time %0t: a=%d b=%d op=%b  got result=%d  expected=%d",
                  $time, t_a, t_b, t_op, t_result, expected);
        errors = errors + 1;
      end else begin
        $display("PASS at time %0t: a=%d b=%d op=%b  result=%d",
                  $time, t_a, t_b, t_op, t_result);
      end
    end
  endtask

  initial begin
    errors = 0;

    // ---- Part A: general sweep of add and subtract ----
    t_a = 4'd5;  t_b = 4'd3;  t_op = 0; #5 check;  // 5+3
    t_a = 4'd9;  t_b = 4'd2;  t_op = 0; #5 check;  // 9+2
    t_a = 4'd7;  t_b = 4'd7;  t_op = 1; #5 check;  // 7-7
    t_a = 4'd10; t_b = 4'd3;  t_op = 1; #5 check;  // 10-3
    t_a = 4'd2;  t_b = 4'd9;  t_op = 1; #5 check;  // 2-9 (wraps in 4-bit)
    t_a = 4'd15; t_b = 4'd1;  t_op = 1; #5 check;  // 15-1
    t_a = 4'd4;  t_b = 4'd4;  t_op = 1; #5 check;  // 4-4, consecutive subs
                                                     // to expose staleness

    // ---- Part B: hold a,b fixed, toggle ONLY op ----
    // This is the specific case that exposes the missing "op" in the
    // sensitivity list -- if op isn't watched, result won't update here.
    t_a = 4'd6; t_b = 4'd2;
    t_op = 0; #5 check;   // expect 6+2=8
    t_op = 1; #5 check;   // expect 6-2=4  <- exposes bug 1 if op not sensed
    t_op = 0; #5 check;   // expect 6+2=8 again

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("%0d MISMATCH(ES) FOUND", errors);

    $finish;
  end

endmodule