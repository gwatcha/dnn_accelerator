module tb_dnn();
   /* Definitions */
    `define CLK 10 /* Length of full clk cycle */

   /* Sim wires */
   logic err = 0; /* Goes high on test fail. */

   logic clk;
   logic rst_n;
   // slave (CPU-facing)
   logic slave_waitrequest;
   logic [3:0] slave_address;
   logic       slave_read;
   logic [31:0] slave_readdata;
   logic        slave_write;
   logic [31:0] slave_writedata;
   // master (SDRAM-facing)
   logic        master_waitrequest;
   logic [31:0] master_address;
   logic        master_read;
   logic [31:0] master_readdata;
   logic        master_readdatavalid;
   logic        master_write;
   logic [31:0] master_writedata;


   /* Initialze module */
   wordcopy dut(.*);

   /* Equality assertion function for testing, */
   /* A is actual, B is expected value. */
   function void equal(input integer A, input integer B,
                       input real test_num);
      if (!(A === B))
        begin
           err = 1;
           $display("(%5tps) Test #: %1.2f :: ASSERT FAIL: Actual: %0d | Expected: %0d", $time, test_num, A, B);
        end
   endfunction


   /* Clock cycler */
   initial begin
      clk=1'b0;
      forever begin
         #(`CLK/2); clk=1'b1;
         #(`CLK/2); clk=1'b0;
      end
   end

   /*                       0        CLK1      CLK2
    Cycles look like this: v        v         v
    _|****|____|****|____|****|        */

   /* ------------------TESTING BEGIN ---------------------- */
   initial begin

      // default values
      master_waitrequest = 0;
      master_readdata = 32'hFEFEFEFE;
      master_readdatavalid = 1;

      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      rst_n = 1'b1;
      #(`CLK*1);

      // Write the four variables

      // write src address test
      @(posedge clk);
      slave_address = 4'h1;
      slave_write = 1;
      slave_writedata = 32'hAAAA1110;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         slave_write = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // write dest address
      @(posedge clk);
      slave_address = 4'h2;
      slave_write = 1;
      slave_writedata = 32'hBBBB2220;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         slave_write = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // write num words to copy here
      @(posedge clk);
      slave_address = 4'h3;
      slave_write = 1;
      slave_writedata = 32'h00000100;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         slave_write = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // read variables test

      // read src address test
      @(posedge clk);
      slave_address = 4'h1;
      slave_read = 1;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         equal(32'hAAAA1110 , slave_readdata, 2);
         slave_read = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // read dest address
      @(posedge clk);
      slave_address = 4'h2;
      slave_read = 1;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         equal(32'hBBBB2220 , slave_readdata, 2);
         slave_read = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // read num words to copy here
      @(posedge clk);
      slave_address = 4'h3;
      slave_read = 1;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         equal(32'h00000100 , slave_readdata, 2);
         slave_read = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("Did not get wait request at %5tps", $time);
      end

      // start the copy
      @(posedge clk);
      slave_address = 4'h0;
      slave_write = 1;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         slave_write = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("did not get wait request at %5tps", $time);
      end

      // copy should be going
      #(`CLK*10);

      // wait for it to finish
      @(posedge clk);
      slave_address = 4'h0;
      slave_read = 1;
      #(`CLK*1);
      // adhere to wait request
      if ( slave_waitrequest ) begin
         @(negedge slave_waitrequest);
         @(posedge clk);
         slave_read = 0;
         #(`CLK*1);
      end else begin
         err = 1;
         $display("did not get wait request at %5tps", $time);
      end

      #(`CLK*1);


      /* -------------------TESTING END ------------------------ */
      /* Final Message */
      if (err === 0) begin
         $display("***************************************");
         $display("********** ALL CASES PASSED ***********");
         $display("***************************************");
      end else begin
         $display("***************************************");
         $display("********** A TEST CASE FAILED **********");
         $display("***************************************");
      end
      $stop;
   end
endmodule: tb_dnn
