// FIFO
// Write to full FIFO is blocked
// Read from empty FIFO return trash data

module fifo #(
    parameter DEPTH = 4,
    parameter DATA_WIDTH = 32
) 
(
    input logic                     in_clk, in_rst, in_wen, in_ren,
    input logic [DATA_WIDTH-1:0]    in_wdata,

    output logic [DATA_WIDTH-1:0]   out_rdata,
    output logic                    out_full, out_empty,            // Status of the FIFO
    output logic [ADDR_WIDTH:0]     out_count                 // Number of elements in the FIFO
);
    
    initial count = 0;
    initial out_rdata = 0;

    localparam ADDR_WIDTH   = $clog2(DEPTH);

    logic [ADDR_WIDTH:0]             count;

    logic [ADDR_WIDTH-1:0]             r_addr;
    logic [ADDR_WIDTH-1:0]             w_addr;

    // Memory
    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
   
    fifo_controller #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_controller (
        .in_clk(in_clk),
        .in_rst(in_rst),
        .in_ren(in_ren),
        .in_wen(in_wen),
        .out_empty(out_empty),
        .out_full(out_full),
        .out_raddr(r_addr),
        .out_waddr(w_addr)
     );

     assign out_count = count;

     always @(posedge in_clk) begin
         if (in_rst) begin // Sync reset
             for (int i = 0; i < DEPTH; i++) begin
                 mem[i] <= 0;
             end
             out_rdata = 0;
         end else begin
             if (in_wen && !out_full)
                 mem[w_addr] <= in_wdata;
             if (in_ren && !out_empty)
                out_rdata = mem[r_addr];
         end
     end

     always @(posedge in_clk) begin
         if (in_rst)
             count <= 0;
         else begin
             if (in_ren && !in_wen && count > 0)
                 count <= count - 1;
             if (in_wen && !in_ren && count < DEPTH)
                 count <= count + 1;
             end
         end

     `ifdef FORMAL

         logic [ADDR_WIDTH-1:0]             addr_diff;
         
         assign addr_diff = w_addr >= r_addr ? w_addr - r_addr : waddr + DEPTH - r_addr;

         // Formal tests
         // Assert reset on the first cycle
         always @(*) begin
             if ($initstate)
                 assume(!in_rst);
             else
                 assume(in_rst);
         end

         always @(posedge in_clk) begin
             if (!$initstate && !in_rst) begin

                // The element count should be equal the the difference between the pointers (Loop considered)
                assert (addr_diff == out_count);

                // Status flag should work as expected
                assert (!out_full || count == DEPTH);
                assert (!out_empty || count == 0);
            end
         end

     `endif

endmodule
         
