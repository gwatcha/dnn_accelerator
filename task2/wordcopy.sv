module wordcopy(input logic clk, input logic rst_n,
                // slave (CPU-facing)
                output logic        slave_waitrequest,
                input logic [3:0]   slave_address,
                input logic         slave_read, output logic [31:0] slave_readdata,
                input logic         slave_write, input logic [31:0] slave_writedata,
                // master (SDRAM-facing)
                input logic         master_waitrequest,
                output logic [31:0] master_address,
                output logic        master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
                output logic        master_write, output logic [31:0] master_writedata);

   /* The saved parameters */
   logic [31:0]                     dest_addr, src_addr, num_words;

   /* sdram_master interface */
   logic                            copying, enable;
   /* enable goes high for one cycle if copying is 0 to start it */


   /* this module handles the master interface and the actual copying */
   sdram_master master(.clk(clk), .rst_n(rst_n),
                       /* parameters */
                       .dest_addr( dest_addr[31:0] ), .src_addr( src_addr[31:0] ),
                       .num_words( num_words[31:0] ),
                       /* control */
                       .copying( copying ), .enable(enable),
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
   localparam CPYWAW = 4'h3; /* copywait, write request variant */
   localparam CPYWAR = 4'h4; /* copywait, read request variant */
   localparam ISSUEC = 4'h5; /* issue a copy to master */
   localparam FINISH = 4'h6; /* finish */
   logic [3:0]                      st;
   logic [3:0]                      nst;

   /* state block */
   always @(posedge clk, negedge rst_n) begin
      st = ~rst_n ? LISTEN : nst;
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
           CPYWAW: nst = copying === 1 ? CPYWAW : ISSUEC ;
           ISSUEC: nst = FINISH;
           CPYWAR: nst = copying === 1 ? CPYWAR : FINISH ;
           FINISH: nst = ( 1 === (slave_read | slave_write )) ? FINISH : LISTEN;
           default : nst = st;
         endcase
      end
   end

   // if we are in a listening state, wait request follows listen | wait
   always @ (*) begin
      if (st === LISTEN) begin
         slave_waitrequest = ( ( slave_read | slave_write ) === 1 ) ? 1 : 0;
      end else if (st === FINISH) begin
         slave_waitrequest = 0;
      end else begin
        slave_waitrequest = 1;
      end
   end

   /* logic  */
   always@(posedge clk, negedge rst_n) begin
      if (~rst_n) begin
         enable = 0;
         dest_addr = 0;
         src_addr  = 0;
         num_words = 0;
         slave_readdata = 32'hDEADBEEF;
      end else begin
         // unless specified in a state, we are not writing or reading and we are in
         // defaults
         enable = 0;
         case (nst)
           WRIVAR: begin
              dest_addr = slave_address == 1 ? slave_writedata : dest_addr;
              src_addr  = slave_address == 2 ? slave_writedata : src_addr;
              num_words = slave_address == 3 ? slave_writedata : num_words;
           end
           REAVAR: begin
              slave_readdata =
                              slave_address == 1 ? dest_addr :
                              slave_address == 2 ? src_addr  :
                              slave_address == 3 ? num_words : 32'b0;
           end
           ISSUEC: begin
              enable = 1;
           end
           FINISH: begin
             enable= 0;
           end
           default: ;
         endcase
      end
   end
endmodule: wordcopy
