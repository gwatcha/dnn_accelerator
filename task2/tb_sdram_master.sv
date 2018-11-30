module tb_sdram_master();
   /* Definitions */
`define CLK 10 /* Length of full clk cycle */

   /* Sim wires */
   logic err = 0; /* Goes high on test fail. */

   logic [31:0] dest_addr, src_addr ;
   logic [31:0] num_words ;
   /* control */
   logic        enable;
   logic        copying;

   logic        clk;
   logic        rst_n;

   // master (SDRAM-facing)
   logic        master_waitrequest;
   logic [31:0] master_address;
   logic        master_read;
   logic [31:0] master_readdata;
   logic        master_readdatavalid;
   logic        master_write;
   logic [31:0] master_writedata;


   /* Initialze module */
   sdram_master dut(.*);

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
      master_readdatavalid = 0;

      // Test 1, 2 word
      dest_addr = 32'h2222DDD0;
      src_addr = 32'h11110000;
      num_words = 32'h00000002;

      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      enable = 1;
      rst_n = 1'b1;

      // emulate a wait request
      @ (posedge( master_read | master_write));
      master_waitrequest = 1;
      enable = 0;
      @( posedge clk );
      #(`CLK*5);
      master_waitrequest = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);

      // emulate a readdata valid delay
      master_readdatavalid = 0;
      #(`CLK*5);
      master_readdatavalid = 1;
      master_readdata = 32'hCEECBEEF;
      @(posedge( ( master_read | master_write)));
      master_readdatavalid = 0;

      // should be getting write request now
      equal(master_write, 1 , 1 );
      equal(master_writedata, 32'hceecbeef, 2);
      master_waitrequest = 1;
      #(`CLK*10);
      master_waitrequest = 0;

      // next cycle

      @(posedge ( master_read | master_write));
      // emulate a wait request
      master_waitrequest = 1;
      enable = 0;
      @(posedge( (clk )));
      #(`CLK*1);
      master_waitrequest = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);

      // emulate a readdata valid delay
      master_readdatavalid = 0;
      $display("Hello?");
      #(`CLK*1);
      master_readdatavalid = 1;
      $display("Hello?");
      master_readdata = 32'hCEEAAAAA;

        @(posedge ( master_read | master_write));
      master_readdata = 32'hx;
      master_readdatavalid = 0;
      // should be getting write request now
      equal(master_writedata, 32'hCEEAAAAA, 2);
      master_waitrequest = 1;
      $display("Hello?");
      #(`CLK*30);
      master_waitrequest = 0;
      enable = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);
      #(`CLK*10);

      // default values
      master_waitrequest = 0;
      master_readdatavalid = 0;

      // Test 1, 2 word
      dest_addr = 32'h2222DDD0;
      src_addr = 32'h11110000;
      num_words = 32'h00000002;

      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      enable = 1;
      rst_n = 1'b1;

      // emulate a wait request
      @ (posedge( master_read | master_write));
      master_waitrequest = 1;
      enable = 0;
      @( posedge clk );
      #(`CLK*5);
      master_waitrequest = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);

      // emulate a readdata valid delay
      master_readdatavalid = 0;
      #(`CLK*5);
      master_readdatavalid = 1;
      master_readdata = 32'hCEECBEEF;
      @(posedge( ( master_read | master_write)));
      master_readdatavalid = 0;

      // should be getting write request now
      equal(master_write, 1 , 1 );
      equal(master_writedata, 32'hceecbeef, 2);
      master_waitrequest = 1;
      #(`CLK*10);
      master_waitrequest = 0;

      // next cycle

      @(posedge ( master_read | master_write));
      // emulate a wait request
      master_waitrequest = 1;
      enable = 0;
      @(posedge( (clk )));
      #(`CLK*1);
      master_waitrequest = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);

      // emulate a readdata valid delay
      master_readdatavalid = 0;
      $display("Hello?");
      #(`CLK*1);
      master_readdatavalid = 1;
      $display("Hello?");
      master_readdata = 32'hCEEAAAAA;

        @(posedge ( master_read | master_write));
      master_readdata = 32'hx;
      master_readdatavalid = 0;
      // should be getting write request now
      equal(master_writedata, 32'hCEEAAAAA, 2);
      master_waitrequest = 1;
      $display("Hello?");
      #(`CLK*30);
      master_waitrequest = 0;
      enable = 0;
      #(`CLK*2);
      equal(( master_read | master_write ), 0, 0);
      #(`CLK*10);

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
endmodule: tb_sdram_master
