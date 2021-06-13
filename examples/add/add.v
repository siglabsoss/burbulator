module add (
    input        [31:0] t_0_dat,
    input               t_0_req,
    output logic        t_0_ack,

    input        [31:0] t_1_dat,
    input               t_1_req,
    output logic        t_1_ack,

    output logic [31:0] i_0_dat,
    output logic        i_0_req,
    input               i_0_ack
);

assign i_0_dat = t_0_dat + t_1_dat;

assign i_0_req = t_0_req & t_1_req;

assign t_0_ack = i_0_ack & t_1_req;
assign t_1_ack = i_0_ack & t_0_req;

endmodule
