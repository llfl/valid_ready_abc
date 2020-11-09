`ifndef __VALID_READY_STD_IF_SVH
`define __VALID_READY_STD_IF_SVH

//  Interface: valid_ready_std_if
//
interface valid_ready_std_if
    #(
        parameter DATAWIDTH = 8
    )();

    logic [DATAWIDTH-1:0] data;
    logic valid;
    logic ready;
    
    modport in (
        input valid,
        input data,
        output ready
    );

    modport out (
        output data,
        output valid,
        input ready
    );

endinterface: valid_ready_std_if


`endif
