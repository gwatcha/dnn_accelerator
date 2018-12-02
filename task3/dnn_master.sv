//Module for calculating Res = A*B
//Where A,B and C are 2 by 2 matrices.
module dnn_master (input logic clk, input logic rst_n,
                   /* dnn parameters */
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

   /* snapshots of inputs */
   logic [31:0]                        S_bias_v_addr;
   logic [31:0]                        S_weight_m_addr;
   logic [31:0]                        S_activ_addr;
   logic [31:0]                        S_out_activ_addr;
   logic [31:0]                        S_activ_len;
   logic [31:0]                        S_relu;

   /* dnn vars */
   logic signed [31:0]                 bias;
   logic signed [31:0]                 nxt_weight;
   logic signed [31:0]                 nxt_activ;

   logic signed [63:0]                  mult_result;
   logic signed [31:0]                 sum;

   // states
   localparam LISTN = 4'd0 ;
   localparam START = 4'd1 ;

   // general states
   localparam GREAD = 4'd2;
   localparam WAITV = 4'd3;

   // loop states
   localparam RWEIG = 4'd4 ;
   localparam SWEIG = 4'd5 ;

   localparam RINAC = 4'd6 ;
   localparam SINAC = 4'd7 ;

   localparam NITER = 4'd8 ;

   // finishing states
   localparam RBIAS = 4'd10 ;
   localparam SBIAS = 4'd11 ;
   localparam ABIAS = 4'd12 ;

   localparam ARELU = 4'd13 ;

   // finish
   localparam WRITE = 4'd14 ;
   localparam NESUM = 4'd15 ;


   reg [3:0]                           st;
   reg [3:0]                           nst;
   // used for states which may be called from multiple states
   logic [3:0]                         ret_st;

   // loop counting
   logic [31:0]                        b_index;
   logic [31:0]                        iterations;

   // READ :  nst = master_waitrequest ? READ : WAITV; /* wait until waitrequest goes down */
   // WAITV :  nst = ( 1 === master_readdatavalid ) ? STORE : WAITV ;
   // STORE :  nst = WRITE;

   /* state transition combinational logic */
   always@(*) begin
      case (st)
        // ----------- general purpose states which return to the ret_st var,
        GREAD : nst = master_waitrequest ? GREAD : WAITV; /* wait until waitrequest goes down */
        WAITV : nst = master_readdatavalid ? ret_st : WAITV ;
        // reset state
        LISTN : nst = enable == 1 ? START : LISTN ;
        // start
        START : nst = RWEIG;
        RWEIG : nst = GREAD;
        SWEIG : nst = RINAC;
        RINAC : nst = GREAD;
        SINAC : nst = NESUM;

        // Q 16 danger
        NESUM : nst = NITER;

        NITER : nst = iterations < S_activ_len ? RWEIG : RBIAS ;
        // finishing states
        RBIAS : nst = GREAD;
        SBIAS : nst = ABIAS;
        ABIAS : nst = S_relu == 1 ? ARELU : WRITE;
        ARELU : nst = WRITE;
        // finish
        // final state , write output activation
        WRITE :  nst = master_waitrequest ? WRITE : LISTN;
        default : nst = st;
      endcase
   end

   /* state */
   always @(posedge clk, negedge rst_n) begin
      st <= ~rst_n ? LISTN : nst;
   end

   /*  logic  */
   always @(posedge clk, negedge rst_n) begin
      if (~rst_n) begin
         operating = 0;
         master_read = 0;
         master_write = 0;
         master_address = 0;
         master_writedata = 0;
         b_index = 0;
         iterations = 0;
         // dnn vars
         bias = 0;
         nxt_weight = 0;
         nxt_activ = 0;
         sum = 0;
         ret_st = LISTN;
         mult_result = 0;
      end else begin
         // defaults
         master_read = 0;
         master_write = 0;
         mult_result = 0;

         case (nst)
           // ----------- general purpose states which return to the ret_st var,
           GREAD :   begin
              master_read = 1;
           end
           WAITV :  begin
              // nothing
           end
           // default st
           LISTN : begin
              operating = 0;
           end
           /* snapshot of inputs and assert we are operating */
           START : begin
              b_index = 0;
              iterations = 0;
              operating = 1;
              S_bias_v_addr= bias_v_addr;
              S_weight_m_addr= weight_m_addr;
              S_out_activ_addr = out_activ_addr ;
              S_activ_addr= activ_addr;
              S_out_activ_addr= out_activ_addr;
              S_activ_len= activ_len;
              S_relu= relu;
              sum = 32'b0;
           end
           RWEIG : begin
              ret_st = SWEIG;
              master_address = S_weight_m_addr + b_index;
           end
           SWEIG : begin
              nxt_weight = master_readdata;
           end
           RINAC : begin
              ret_st = SINAC;
              master_address = S_activ_addr + b_index;
           end
           SINAC : begin
              nxt_activ = master_readdata;
           end
           NESUM : begin// Q16 DANGER ZONE
              mult_result[63:0] = ( nxt_activ *  nxt_weight) ;
              mult_result[63:0] = mult_result[63:0] >> 16;
              sum[31:0] =  sum[31:0] + (mult_result[31:0]);
           end
           NITER : begin
              b_index = b_index + 4;
              iterations = iterations + 1;
           end
           // finishing states
           RBIAS : begin
              ret_st = SBIAS;
              master_address = S_bias_v_addr;
           end
           SBIAS : begin
              bias = master_readdata;
           end
           ABIAS : begin
              sum[31:0] = sum[31:0] + bias[31:0];
           end
           ARELU : begin
              sum[31:0] = sum[31] ? 32'b0 : sum[31:0];
           end
           // final state , write output activation
           WRITE : begin
              master_address = S_out_activ_addr;
              master_write = 1;
              master_writedata = sum;
           end
         endcase
      end
   end
endmodule: dnn_master
