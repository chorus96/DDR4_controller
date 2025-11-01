
module dual_clock_fifo
#(
   parameter                       DATA_WIDTH = 64,
   parameter                       DATA_DEPTH = 8
)
(
   input  logic                                    clk,
   input  logic                                    rst_n,
   //PUSH SIDE input
   input  logic [DATA_WIDTH-1:0]                   data_i,
   input  logic                                    clk_valid_i, // incr. iptr
   output logic                                    grant_o,  // not_full 
   //POP SIDE output
   output logic [DATA_WIDTH-1:0]                   data_o,
   output logic                                    valid_o, // not_empty
   input  logic                                    grant_i  // incr. optr
);


   // Local Parameter
   localparam  ADDR_DEPTH =  $clog2(DATA_DEPTH);

   
   // Internal Signals


   logic [ADDR_DEPTH-1:0]          opntr;
   logic [ADDR_DEPTH-1:0]          ipntr, ipntr_neg; // ipntr_syc;
   logic [DATA_WIDTH-1:0]          fifo_latches[DATA_DEPTH-1:0];
   integer                         i;

   assign grant_o = 1'b1;  //Not used!



   // ocntr - 
   always_ff @(negedge clk, negedge rst_n)
   begin
       if(rst_n == 1'b0)
       begin
           opntr <= {ADDR_DEPTH {1'b0}};
       //    ipntr_syc <= {ADDR_DEPTH {1'b0}};
       end
       else
       begin
       //    ipntr_syc <= ipntr_neg;
           opntr <= opntr;
           if(grant_i && valid_o)
           begin
               if (opntr == DATA_DEPTH-1)
              		opntr <= {ADDR_DEPTH {1'b0}};
               else
               		opntr <= opntr + 1'b1;
           end
       end
   end

   always_ff @(negedge clk, negedge rst_n)
   begin
       if(rst_n == 1'b0)
       begin
           ipntr_neg <= {ADDR_DEPTH {1'b0}};
       end
       else
       begin
           ipntr_neg <= ipntr;
       end
   end


   // opntr equal ipntr
   always_comb
   begin
      if (opntr == ipntr_neg) begin
         valid_o = 1'b0;
      end
      else begin 
         valid_o = 1'b1;
      end
   end // always_comb

   // icntr - 
   always_ff @(negedge clk_valid_i, negedge rst_n)
   begin
       if(rst_n == 1'b0)
       begin
               ipntr <= {ADDR_DEPTH {1'b0}};
       end
       else
       begin
           if (ipntr == DATA_DEPTH-1)
       		ipntr <= {ADDR_DEPTH {1'b0}};
           else
       		ipntr <= ipntr + 1'b1;
       end
   end


   // Fifo Latches
   
   always_ff @(negedge clk_valid_i, negedge rst_n)
   begin
      if(rst_n == 1'b0)
      begin
      for (i=0; i< DATA_DEPTH; i++)
         fifo_latches[i] <= {DATA_WIDTH {1'b0}};
      end
      else
      begin
            fifo_latches[ipntr] <= data_i;
      end
   end

   assign data_o = fifo_latches[opntr];

endmodule // dual_clock_fifo
