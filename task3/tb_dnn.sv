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
   dnn dut(.*);


   // mock test  moduel
   avl_interface_slave mock(
                       clk, rst_n,
                       master_waitrequest,
                       master_address,
                       master_read,
                       master_readdata,
                       master_readdatavalid,
                       master_write,
                       master_writedata);

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

      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      rst_n = 1'b1;
      #(`CLK*1);

      // Write the four variables

      // biasvector addr
      @(posedge clk);
      slave_address = 4'h1;
      slave_write = 1;
      slave_writedata = 32'd0;
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

      // write w matrix addr
      @(posedge clk);
      slave_address = 4'h2;
      slave_write = 1;
      slave_writedata = 32'd256;
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

      // write activations addr
      @(posedge clk);
      slave_address = 4'h3;
      slave_write = 1;
      slave_writedata = 32'd1256;
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

      // output activations addr
      @(posedge clk);
      slave_address = 4'h4;
      slave_write = 1;
      slave_writedata = 32'd10;
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

      // write in activat len
      @(posedge clk);
      slave_address = 4'h5;
      slave_write = 1;
      slave_writedata = 32'h00000002;
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

      // try relu
      @(posedge clk);
      slave_address = 4'h7;
      slave_write = 1;
      slave_writedata = 32'h00000001;
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


      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      rst_n = 1'b1;
      #(`CLK*1);

      // Write the four variables

      // biasvector addr
      @(posedge clk);
      slave_address = 4'h1;
      slave_write = 1;
      slave_writedata = 32'd256;
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

      // write w matrix addr
      @(posedge clk);
      slave_address = 4'h2;
      slave_write = 1;
      slave_writedata = 32'd256;
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

      // write activations addr
      @(posedge clk);
      slave_address = 4'h3;
      slave_write = 1;
      slave_writedata = 32'd1256;
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

      // output activations addr
      @(posedge clk);
      slave_address = 4'h4;
      slave_write = 1;
      slave_writedata = 32'd10;
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

      // write in activat len
      @(posedge clk);
      slave_address = 4'h5;
      slave_write = 1;
      slave_writedata = 32'h00000002;
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

      // no relu
      @(posedge clk);
      slave_address = 4'h7;
      slave_write = 1;
      slave_writedata = 32'h00000000;
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

      // Reset sequence
      rst_n = 1'b0;
      #(`CLK*1);
      rst_n = 1'b1;
      #(`CLK*1);

      // Write the four variables

      // biasvector addr
      @(posedge clk);
      slave_address = 4'h1;
      slave_write = 1;
      slave_writedata = 32'd260;
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

      // write w matrix addr
      @(posedge clk);
      slave_address = 4'h2;
      slave_write = 1;
      slave_writedata = 32'd256;
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

      // write activations addr
      @(posedge clk);
      slave_address = 4'h3;
      slave_write = 1;
      slave_writedata = 32'd1256;
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

      // output activations addr
      @(posedge clk);
      slave_address = 4'h4;
      slave_write = 1;
      slave_writedata = 32'd10;
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

      // write in activat len
      @(posedge clk);
      slave_address = 4'h5;
      slave_write = 1;
      slave_writedata = 32'h00000002;
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

      // yes relu
      @(posedge clk);
      slave_address = 4'h7;
      slave_write = 1;
      slave_writedata = 32'h00000001;
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

module avl_interface_slave(
                           input logic clk, input logic rst_n,
  output logic       master_waitrequest,
  input logic [31:0] master_address,
  input logic        master_read, output logic [31:0] master_readdata, output logic master_readdatavalid,
  input logic        master_write, input logic [31:0] master_writedata);

   /* state machine */
   localparam LISTEN = 4'h0; /* listen for new requests from user */
   localparam WRIVAR = 4'h1; /* write variables */
   localparam DONEWRITE = 4'h6; /* finish */
   localparam REAVAR = 4'h2; /* read variable */
   localparam REAVAL = 4'h3;
   localparam WAIT1 = 4'h4;

   int               count;


   logic [3:0]                 st;
   logic [3:0]                 nst;

   logic [31:0]                weights[9:0];
   logic [31:0]                in_activ[9:0];
   // test data
   assign weights[0] = -932;
   assign weights[1] = 516;
   assign in_activ[0] = -65136;
   assign in_activ[1] = -2516;

   /* state block */
   always @(posedge clk) begin
      st = nst;
   end

   /* state transition logic */
   always@(*) begin
      if ( ~rst_n ) begin
         nst = LISTEN ;
      end else begin
         case (st)
           LISTEN: begin
              if ( master_write === 1) begin
                 nst = WRIVAR;
              end else if ( master_read === 1 ) begin
                 nst = REAVAR;
              end else begin
                 nst = LISTEN;
              end
           end
           WRIVAR: nst = count < 10 ? WRIVAR : DONEWRITE;
           DONEWRITE: nst = LISTEN;
           REAVAR: nst = count < 10 ? REAVAR : WAIT1;
           WAIT1: nst = REAVAL;
           REAVAL: nst = LISTEN;
           default : nst = st;
         endcase
      end
   end

   // if we are in a listening state, wait request follows listen | wait
   logic inflight;
   always @ (*) begin
      if (st == LISTEN) begin
         master_waitrequest = ( ( master_read | master_write ) === 1 ) ? 1 : 0;
      end else begin
         master_waitrequest = inflight;
      end
   end

   /* logic  */
   always@(posedge clk) begin
      // defaults
      master_readdata = 32'bx;

      case (nst)
        LISTEN: begin
           /* see cl above */
           /* inflight = ( 1 === ( master_read | master_write ) ) ? 1 : 0; */
           count = 0;
           inflight = 1;
        end
        WRIVAR: begin
           inflight = 1;
           count = count + 1;
           assert(master_address == 32'd10);
           assert(master_write == 1);
        end
        DONEWRITE: begin
           inflight = 0;
        end
        REAVAR: begin
           count = count + 1;
           master_waitrequest = 1;
        end
        WAIT1: begin
           master_waitrequest = 0;
           inflight = 0;
        end
        REAVAL: begin
           inflight = 0;
           master_readdata = master_address == 0 ? 32'hFFFFF2AF :
                             ( master_address >= 256 && master_address < 1256 ) ? weights[(master_address-256)/4] :
                             master_address >= 1256 ? in_activ[( master_address-1256 )/4] : 32'bx;
           master_readdatavalid = 1'b1;
        end
      endcase
   end
endmodule
