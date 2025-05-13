module fifo_controller #(
    parameter ADDR_WIDTH = 4
) (
    input logic     in_clk,
    input logic     in_rst,
    input logic     in_ren,
    input logic     in_wen,

    output logic    out_empty,
    output logic    out_full,
    output logic [ADDR_WIDTH-1:0] out_raddr,
    output logic [ADDR_WIDTH-1:0] out_waddr
);

    // MSB for loop detection
    logic [ADDR_WIDTH:0] raddr_ptr;
    logic [ADDR_WIDTH:0] waddr_ptr;
    logic rloop;
    logic wloop;

    assign rloop = raddr_ptr[ADDR_WIDTH];
    assign wloop = waddr_ptr[ADDR_WIDTH];

    assign out_raddr = raddr_ptr[ADDR_WIDTH-1:0];
    assign out_waddr = waddr_ptr[ADDR_WIDTH-1:0];

    assign out_empty    = (rloop == wloop) && (out_raddr == out_waddr);
    assign out_full     = (rloop != wloop) && (out_raddr == out_waddr);

    always @(posedge in_clk) begin
        if (in_rst) begin // Sync reset
            waddr_ptr = 0;
            raddr_ptr = 0;
        end else begin
            if (in_ren && !out_empty)
                raddr_ptr <= raddr_ptr + 1;
            if (in_wen && !out_full)
                waddr_ptr <= waddr_ptr + 1;
        end
    end

endmodule
        
