module dnn(input logic clk, input logic rst_n,
           // slave (CPU-facing)
           output logic slave_waitrequest,
           input logic [3:0] slave_address,
           input logic slave_read, output logic [31:0] slave_readdata,
           input logic slave_write, input logic [31:0] slave_writedata,
           // master (SDRAM-facing)
           input logic master_waitrequest,
           output logic [31:0] master_address,
           output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
           output logic master_write, output logic [31:0] master_writedata);

   /* logic [31:0]                     dest_addr, src_addr, num_words; */

   /* The saved parameters */
   reg [31:0] bias_v_addr, weight_m_addr, activ_addr, out_activ_addr, activ_len, relu;

   /* on enable, do */
    /* relu( (weight_m_addr*)(activ_addr*) + (bias_v_addr*)) */

   /* dnn_master interface */
   logic                            operating, enable;
   /* enable goes high for one cycle if operating is 0 to start it */

     /* this module handles the master interface and the actual copying */
     dnn_master master(.clk(clk), .rst_n(rst_n),
       /* dnn parameters */
       .out_activ_addr( out_activ_addr[31:0] ), 
         .bias_v_addr(bias_v_addr[31:0] ),
         .weight_m_addr( weight_m_addr[31:0] ),
         .activ_addr( activ_addr[31:0] ),
         .out_activ_addr( out_activ_addr[31:0] ),
         .activ_len( activ_len[31:0] ),
         .relu( relu[31:0] ),
         /* control */
         .operation( operation ), .enable(enable),
           /* used only by this module */
           .master_waitrequest( master_waitrequest ),
             .master_address( master_address[31:0] ),
             .master_read( master_read ), .master_readdata( master_readdata[31:0] ),
             .master_readdatavalid( master_readdatavalid ),
             .master_write( master_write ), .master_writedata( master_writedata[31:0] ));

   /* state machine */
   localparam LISTEN = 4'h0; /* listen for new requests from user */
   localparam WRIVAR = 4'h1; /* write variables */
   localparam REAVAR = 4'h2; /* read variable */
   localparam CPYWAW = 4'h3; /* copywait, wait on dnn, write request variant */
   localparam CPYWAR = 4'h4; /* copywait, wait on dnn, read request variant */
   localparam ISSUEC = 4'h5; /* issue a dnn multiplication */
   localparam FINISH = 4'h6; /* finish */
   logic [3:0]                      st;
   logic [3:0]                      nst;

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
              if ( slave_write === 1) begin
                 nst = slave_address == 4'd0 ? CPYWAW : WRIVAR ;
              end else if ( slave_read === 1 ) begin
                 nst = slave_address == 4'd0 ? CPYWAR : REAVAR ;
              end else begin
                nst = LISTEN;
              end
           end
           WRIVAR: nst = FINISH;
           REAVAR: nst = FINISH;
           CPYWAW: nst = operating == 1 ? CPYWAW : ISSUEC ;
           ISSUEC: nst = FINISH;
           CPYWAR: nst = operating == 1 ? CPYWAR : FINISH ;
           FINISH: nst = ( 1 === (slave_read | slave_write )) ? FINISH : LISTEN;
           default : nst = st;
         endcase
      end
   end

   // if we are in a listening state, wait request follows listen | wait
   logic inflight;
   always @ (*) begin
      if (st == LISTEN) begin
         slave_waitrequest = ( ( slave_read | slave_write ) === 1 ) ? 1 : 0;
      end else begin
         slave_waitrequest = inflight;
      end
   end

   /* logic  */
   always@(posedge clk) begin
      // defaults
      inflight = 1;
      enable = 0;
      case (nst)
        LISTEN: begin
          /* see cl above */
           /* inflight = ( 1 === ( slave_read | slave_write ) ) ? 1 : 0; */
        end
        WRIVAR: begin
          case ( slave_address ) :
            32'h1 : bias_v_addr = slave_writedata;
            32'h2 : weight_m_addr = slave_writedata;
            32'h3 : activ_addr = slave_writedata;
            32'h4 : out_activ_addr = slave_writedata;
            32'h5 : activ_len = slave_writedata;
            32'h7 : relu = slave_writedata;
          endcase
        end
        REAVAR: begin
          case ( slave_address ) :
            32'h1 : slave_readdata = bias_v_addr ;
            32'h2 : slave_readdata= weight_m_addr;
            32'h3 : slave_readdata = activ_addr ;
            32'h4 : slave_readdata = out_activ_addr ;
            32'h5 : slave_readdata = activ_len ;
            32'h7 : slave_readdata = relu ;
          endcase
        end
        end
        ISSUEC: begin
           enable = 1;
        end
        FINISH: begin
           inflight = 0;
        end
        default: ;
      endcase
   end
endmodule: dnn
