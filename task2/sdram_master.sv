module sdram_master(input logic         clk, input logic rst_n,
                    /* parameters */
                    input logic [31:0]  dest_addr, input logic [31:0]src_addr ,
                    input logic [31:0]  num_words ,
                    /* control */
                    input logic         enable, output logic copying,
                    /* used only by this module */
                    input logic         master_waitrequest,
                    output logic [31:0] master_address,
                    output logic        master_read, input logic [31:0] master_readdata,
                    input logic         master_readdatavalid,
                    output logic        master_write, output logic [31:0] master_writedata );

   // states
   localparam RESET = 4'd0 ;
   localparam READ  = 4'd1 ;
   localparam WAITV = 4'd2 ;
   localparam WRITE = 4'd3 ;
   localparam LOOP  = 4'd4 ;

   // registers
   reg [3:0]                          st;
   reg [3:0]                          nst;

   logic [31:0]                         copied_words;
   logic [31:0]                         nxt_data;
   logic [31:0]                         b_index;

   /* snapshots of latest inputs, as they are subject to change throughout copyin */
  reg [31:0]  S_dest_addr, S_src_addr, S_num_words ;

   /* state transition combinational logic */
   always@(*) begin
      if ( ~rst_n ) begin
         nst = RESET ;
      end else begin
         case (st)
           RESET :  nst = enable == 1 ? READ : RESET ;
            READ :  nst = master_waitrequest ? READ : WAITV; /* wait until waitrequest goes down */
           WAITV :  nst = master_readdatavalid ? WRITE : WAITV ;
           WRITE :  nst = master_waitrequest ? WRITE : LOOP;
            LOOP :  nst = copied_words >= S_num_words ? RESET : READ ;
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
      // unless specified in a state, we are not writing or reading and we are in
      // the copying process
      master_read = 0;
      master_write = 0;
      copying = 1;

      case (nst)
        RESET : begin
          saved = 0;
           copying = 0;
           copied_words = 0;
           b_index = 0;
        end
        READ  :  begin
          /* save values */
          if ( saved === 0) begin
            saved = 1;
            S_dest_addr = dest_addr;
            S_src_addr = src_addr;
            S_num_words = num_words;
          end
           master_read = 1;
           master_address = S_src_addr + b_index ;
        end
        WRITE : begin
           nxt_data = master_readdata;
           master_write = 1;
           master_address = S_dest_addr + b_index;
           master_writedata = nxt_data;
        end
        LOOP :  begin // We stay here for 1 cycle at most
           copied_words = copied_words + 1;
           b_index = b_index + 4;
        end
        default: ;
      endcase
   end
endmodule: sdram_master
