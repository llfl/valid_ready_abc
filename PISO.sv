//  Module: PISO
//
`include "valid_ready_std_if.svh"
module PISO
    /*  package imports  */
    #(
        parameter DATAWIDTH = 8
    )(
        input clk,
        input rst_n,
        valid_ready_std_if.in din,
        valid_ready_std_if.out dout,
        output last
    );

    typedef enum bit [1:0] { IDLE=2'b00,
                             RECV=2'b01,
                             WAIT=2'b11,
                             SEND=2'b10 } states;

    reg [DATAWIDTH:0] tmp;

    states curr_state;
    states next_state;

    logic tmp_empty;
    assign tmp_empty = (tmp[DATAWIDTH:1] == 1) ? 1'b1 : 1'b0;

    assign din.ready  = tmp_empty & din.valid ;
    assign dout.valid = dout.ready | ~tmp_empty ;
    assign last = dout.valid & tmp_empty;

    always_ff @(posedge clk or negedge rst_n) begin: mainfunc
        if (~rst_n) begin
            curr_state <= RECV;
            tmp <= 2;
        end else begin
            curr_state <= next_state;
            if (dout.ready && dout.valid && ~tmp_empty) begin
                tmp <= {1'b0, tmp[DATAWIDTH:1]};
            end

            if (din.ready && din.valid) begin
                tmp <= {1'b1, din.data};
            end
        end

    end: mainfunc

    always_comb begin: processing_state
        case (curr_state)
            RECV : begin
                next_state = din.valid ? (dout.ready ? SEND : WAIT) : RECV;
            end
            WAIT : begin
                next_state = dout.ready ? SEND : WAIT;
            end
            SEND : begin
                next_state = tmp_empty ? RECV : (dout.ready ? SEND : WAIT);
            end
            default : begin
                next_state = RECV;
            end
        endcase
    end: processing_state

    assign dout.data[0] =  tmp[0] & dout.valid;
    assign dout.data[1] = ~tmp[0] & dout.valid;

endmodule: PISO
