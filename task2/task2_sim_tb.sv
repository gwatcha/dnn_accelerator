// TODO delete me after
`timescale 1ps / 1ps
module task2_sim_tb();
   /* Definitions */
  `define CLK 10 /* Length of full clk cycle */

   /* Sim wires */
   logic CLOCK_50;
   logic [3:0] KEY;
   // KEY[3] is async active-low reset
   logic [9:0] SW;
   logic [9:0] LEDR;

   logic       DRAM_CLK;
   logic       DRAM_CKE;

   logic       DRAM_CAS_N;
   logic       DRAM_RAS_N;
   logic       DRAM_WE_N;

   logic [12:0] DRAM_ADDR;
   logic [1:0]  DRAM_BA;
   logic        DRAM_CS_N;

   wire [15:0] DRAM_DQ;
   logic              DRAM_UDQM;
   logic              DRAM_LDQM;

   logic [6:0]        HEX0;
   logic [6:0]        HEX1;
   logic [6:0]        HEX2;

   logic [6:0]        HEX3;
   logic [6:0]        HEX4;
   logic [6:0]        HEX5;

   /* Initialze module */
   task2 dut(.*);

   /* Clock cycler */
   initial begin
      CLOCK_50=1'b0;
      forever begin
         #(`CLK/2); CLOCK_50=1'b1;
         #(`CLK/2); CLOCK_50=1'b0;
      end
   end

      /*                       0        CLK1      CLK2
        Cycles look like this: v        v         v
                              _|****|____|****|____|****|        */

   /* ------------------TESTING BEGIN ---------------------- */
   initial begin
      $readmemh("program.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
   end
endmodule
