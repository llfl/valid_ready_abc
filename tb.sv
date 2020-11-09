`include "valid_ready_std_if.svh"
`include "PISO.sv"
`default_nettype none

module tb_PISO;
reg clk;
reg rst_n;


valid_ready_std_if #(.DATAWIDTH(8)) piso_in();
valid_ready_std_if #(.DATAWIDTH(2)) piso_out();

PISO m1
(
    .rst_n (rst_n),
    .clk (clk),
    .din(piso_in.in),
    .dout(piso_out.out)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $fsdbDumpfile("tb_PISO.fsdb");
    $fsdbDumpvars(0, tb_PISO);
    // $fsdbDumpon();
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    piso_in.data <= 8'b0000_0000;
    piso_in.valid <= 0;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;piso_out.ready <= 0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    piso_in.data <= 8'b1100_1101;
    piso_in.valid <= 1;
    repeat(2) @(posedge clk);
    piso_in.data <= 8'b0010_0111;
    piso_out.ready <= 0;
    repeat(3) @(posedge clk);
    piso_out.ready <= 1;
    repeat(3) @(posedge clk);
    piso_out.ready <= 0;
    repeat(3) @(posedge clk);
    piso_out.ready <= 1;
    repeat(50) @(posedge clk);

    $finish(2);
end

endmodule
`default_nettype wire