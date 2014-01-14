`timescale 1ns/100ps
module main;
   reg clock;
   reg[199:0] test;
   initial $hello;

   always begin
      #10 clock = 1;
      test = test * 2;
      #10 clock = 0;
      $display("test is %d", test);
   end

   initial begin
      test = 1;
      #10000 $finish;
   end
   
endmodule
