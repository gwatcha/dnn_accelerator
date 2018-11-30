//Module for calculating Res = A*B
//Where A,B and C are 2 by 2 matrices.
module dnn_master (input logic clk, input logic rst_n,
                   /* dnn parameters */
                   input logic [31:0]  out_activ_addr,
                   input logic [31:0]  bias_v_addr,
                   input logic [31:0]  weight_m_addr,
                   input logic [31:0]  activ_addr,
                   input logic [31:0]  out_activ_addr,
                   input logic [31:0]  activ_len,
                   input logic [31:0]  relu,
                   /* control */
                   output logic        operating, input logic enable,
                   // master (SDRAM-facing)
                   input logic         master_waitrequest,
                   output logic [31:0] master_address,
                   output logic        master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
                   output logic        master_write, output logic [31:0] master_writedata);


   // /* dnn vars to read into */
   // logic [31:0]                        out_activ;
   // logic [31:0]                        bias_v;
   // logic [31:0]                        weight_m;
   // logic [31:0]                        activ;
   // logic [31:0]                        out_activ;
   // logic [31:0]                        activ_len;
   // logic [31:0]                        relu;
/* dnn parameters */
  input logic [31:0] out_activ_addr, 
  input logic [31:0] bias_v_addr,
  input logic [31:0] weight_m_addr,
  input logic [31:0] activ_addr,
  input logic [31:0] out_activ_addr,
  input logic [31:0] activ_len,
  input logic [31:0] relu,
  /* control */
  output logic operating, input logic enable,
    // master (SDRAM-facing)
    input logic master_waitrequest,
      output logic [31:0] master_address,
      output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
      output logic master_write, output logic [31:0] master_writedata);

    /* snapshots of inputs */
   logic [31:0] S_out_activ_addr; 
   logic [31:0] S_bias_v_addr;
   logic [31:0] S_weight_m_addr;
   logic [31:0] S_activ_addr;
   logic [31:0] S_out_activ_addr;
   logic [31:0] S_activ_len;
   logic [31:0] S_relu;

   /* dnn vars to read into */
   logic [31:0] out_activ; 
   logic [31:0] bias_v;
   logic [31:0] weight_m;
   logic [31:0] activ;
   logic [31:0] out_activ;
   logic [31:0] activ_len;
   logic [31:0] relu;

   // states
   localparam RESET = 4'd0 ;
   localparam READ  = 4'd1 ;
   localparam WAITV = 4'd2 ;
   localparam WRITE = 4'd3 ;
   localparam LOOP  = 4'd4 ;

   // registers
   reg [3:0]                          st;
   reg [3:0]                          nst;

   // used for states which may be called from multiple states
   logic [3:0]                        ret_st;
   logic [31:0]                       rdata;

   /* snapshots of inputs */
   logic [31:0]                        S_out_activ_addr;
   logic [31:0]                        S_bias_v_addr;
   logic [31:0]                        S_weight_m_addr;
   logic [31:0]                        S_activ_addr;
   logic [31:0]                        S_out_activ_addr;
   logic [31:0]                        S_activ_len;
   logic [31:0]                        S_relu;
   logic [31:0]                         copied_vars;
   logic [31:0]                         nxt_data;
   logic [31:0]                         b_index;

   /* snapshots of latest inputs, as they are subject to change throughout copyin */

   /* state transition combinational logic */
   always@(*) begin
      if ( ~rst_n ) begin
         nst = RESET ;
      end else begin
         case (st)
           RESET :  nst = enable == 1 ? START : RESET ;
           START :  nst = READ;

           // final state , write output activation
           WRITE :  nst = master_waitrequest ? WRITE : RESET;
           FINISH :  nst = RESET;
           // ----------- general purpose states which return to the ret_st var,
           READ :   nst = master_waitrequest ? READ : WAITV; /* wait until waitrequest goes down */
           WAITV :  nst = master_readdatavalid ? STORE : WAITV ;
           STORE :  nst =  ret_st ; // Stores read data into data var
           default : nst = st;
         endcase
      end
   end

   /* state */
   always @(posedge clk) begin
      st <= nst;
   end

   logic [31:0] i;

   /*  logic  */
   always @(posedge clk) begin
      // unless specified in a state, we are not writing or reading
      master_read = 0;
      master_write = 0;
      i = 0;

      case (nst)
        RESET : begin
           operating = 0;
        end
        /* snapshot of inputs and assert we are operating */
        START : begin
           operating = 1;
           S_bias_v_addr= bias_v_addr;
           S_weight_m_addr= weight_m_addr;
           S_out_activ_addr = out_activ_addr ;
           S_activ_addr= activ_addr;
           S_out_activ_addr= out_activ_addr;
           S_activ_len= activ_len;
           S_relu= relu;
        end
        READ  :  begin
           // loop
           // loop 
           // loop 
           // its input variables
           master_write = 1;
           master_address =
           master_writedata =
        end
        default: ;
      endcase
   end
endmodule: sdram_master
