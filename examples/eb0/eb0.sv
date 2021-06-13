module eb0 (
    input [127:0]           t_0_dat,
    input                   t_0_req,
    output logic            t_0_ack,

    output logic [127:0]    i_0_dat,
    output logic            i_0_req,
    input                   i_0_ack,

    input clock1, reset1
);

assign i_0_dat = t_0_dat;
assign i_0_req = t_0_req;
assign t_0_ack = i_0_ack;

endmodule
