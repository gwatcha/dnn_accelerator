//Module for calculating Res = A*B
//Where A,B and C are 2 by 2 matrices.
module dnn_master (input logic clk, input logic rst_n,
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

   /* CL ~~~~~~~~~~~~~~~~~~~~~ */
   /* TODO Size???  */
    //input and output ports.
    //The size 32 bits which is 2*2=4 elements,each of which is 8 bits wide.    
    input [31:0] A;
    input [31:0] B;
    output [31:0] Res;
    //internal variables    
    reg [31:0] Res;
    reg [7:0] A1 [0:1][0:1];
    reg [7:0] B1 [0:1][0:1];
    reg [7:0] Res1 [0:1][0:1]; 
    integer i,j,k;
    /* dnn cl block */
    always@(*) begin
      //Initialize the matrices-convert 1 D to 3D arrays
      {A1[0][0],A1[0][1],A1[1][0],A1[1][1]} = A;
      {B1[0][0],B1[0][1],B1[1][0],B1[1][1]} = B;
      i = 0;
      j = 0;
      k = 0;
      {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} = 32'd0; //initialize to zeros.
      //Matrix multiplication
      for(i=0;i < 2;i=i+1)
        for(j=0;j < 2;j=j+1)
          for(k=0;k < 2;k=k+1)
            Res1[i][j] = Res1[i][j] + (A1[i][k] * B1[k][j]);
          //final output assignment - 3D array to 1D array conversion.            
          Res = {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]};            
        end 
   /* CL ^^^^^^^^^^^^^^^^^^^^^ */

   // states
   localparam RESET = 4'd0 ;
   localparam READ  = 4'd1 ;
   localparam WAITV = 4'd2 ;
   localparam WRITE = 4'd3 ;
   localparam LOOP  = 4'd4 ;

   // registers
   reg [3:0]                          st;
   reg [3:0]                          nst;

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
            READ :  nst = master_waitrequest ? READ : WAITV; /* wait until waitrequest goes down */
           WAITV :  nst = master_readdatavalid ? WRITE : WAITV ;
            STORE :  nst = copied_vars >= S_num_words ? FINISH : READ ;
            FINISH :  nst = RESET:
           default : nst = st;
         endcase
      end
   end

   /* state */
   always @(posedge clk) begin
      st <= nst;
   end

   logic saved;
   /*  logic  */
   always @(posedge clk) begin
      // unless specified in a state, we are not writing or reading 
      master_read = 0;
      master_write = 0;

      case (nst)
        RESET : begin
          saved = 0;
           operating = 0;
           copied_vars = 0;
           b_index = 0;
        end
        /* snapshot of inputs and assert we are operating */
        START : begin
             operating = 1;
             S_out_activ_addr = out_activ_addr ; 
             S_bias_v_addr= bias_v_addr;
             S_weight_m_addr= weight_m_addr;
             S_activ_addr= activ_addr;
             S_out_activ_addr= out_activ_addr;
             S_activ_len= activ_len;
             S_relu= relu;
           end
        READ  :  begin 
           master_read = 1;
           master_address = S_src_addr + b_index ;
        end
        STORE :  begin // We stay here for 1 cycle at most
           nxt_data = master_readdata;
           master_write = 1;

           // TODO
           master_address = S_dest_addr + b_index;

           // loop 
           copied_vars = copied_vars + 1;
           b_index = b_index + 4;
        end
        WRITE :  begin // Write the NN CL output now that we have updated all
        // its input variables
           master_write = 1;
           master_address = S_dest_addr + b_index;
           master_writedata = nxt_data;
           copied_vars = copied_vars + 1;
           b_index = b_index + 4;
        end
        default: ;
      endcase
   end
endmodule: sdram_master
