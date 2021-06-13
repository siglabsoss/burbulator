module top_tb (
        input wire          i_clk,
        input wire          i_rst_p,
        input wire [31:0]   i_seed,
        input wire          rand_valid,
        input wire          rand_ready
        );

    <% targets.map((t, ti) => { %>
        localparam DEPTH_${ti} = ${t.length};

        logic [${t.width}-1:0]              mem${ti} [DEPTH_${ti}-1:0]; // depth and width are controlled by template
        logic [$clog2(DEPTH_${ti}) : 0]     read_addr${ti};
        logic                               mem${ti}_valid; // can be generated using $rand()

        logic [31:0] random_valid${ti};

        logic [${t.width}-1:0]                t${ti}_data;
        logic                                 t${ti}_valid;
        logic                                 t${ti}_ready;
    <% }) %>

    <% initiators.map((i, ii) => { %>
        logic [DEPTH_0 - 1 : 0]               data_out_counter${ii};
        logic [7:0] idle_counter${ii};
        logic [${i.width}-1:0]                i${ii}_data;
        logic                                 i${ii}_valid;
        logic                                 i${ii}_ready;
        integer f${ii};

        logic [31:0] random_ready${ii};
    <% }) %>

        initial begin
        <% targets.map((t, ti) => { %>
                $readmemh ("${t.data}.mif", mem${ti});
        <% }) %>
        <% initiators.map((i, ii) => { %>
                f${ii} = $fopen("${i.data}.mif","w");
        <% }) %>
        end

        always_ff @(posedge i_clk) begin
        <% initiators.map((i, ii) => { %>
            i${ii}_ready <= (rand_ready) ? random_ready${ii}[0] : 1;
            if (i${ii}_ready && i${ii}_valid) begin
                $fwrite(f${ii},"%h\n",i${ii}_data);
            end
        <% }) %>
        end

        logic [31:0] counter1;
<% targets.map((t, ti) => { %>
/* verilator lint_off WIDTH */
    assign t${ti}_data = mem${ti}[read_addr${ti}];
    assign t${ti}_valid = mem${ti}_valid && (read_addr${ti} != DEPTH_${ti}) && (!i_rst_p);

    logic flag${ti};
    always_ff @(posedge i_clk) begin
        if (i_rst_p) begin
            random_valid${ti} <= 0;
            read_addr${ti} <= {$clog2(DEPTH_${ti}){1'b0}};
            mem${ti}_valid <= 0;
            flag${ti} <= 1;
        end else begin
            random_valid${ti} <= counter1 % (2 * ${ti} + 45);
            mem${ti}_valid <= (rand_valid && t${ti}_ready) ? random_valid${ti}[0] : 1;
            if (mem${ti}_valid && t${ti}_ready) begin
                read_addr${ti} <= read_addr${ti} + 1;
                flag${ti} <= 0;
            end

            if ((flag${ti} == 0) && (read_addr${ti} == DEPTH_${ti})) begin
                read_addr${ti} <= read_addr${ti};
            end


        end

    end
/* verilator lint_on WIDTH */
<% }) %>

<% initiators.map((i, ii) => { %>
    always_ff @(posedge i_clk) begin
        random_ready${ii} = counter1 % (5 * ${ii + 32});
    end


    // count the number of outputs
    always_ff @(posedge i_clk) begin
        if (i_rst_p) begin
            data_out_counter${ii} <= 0;
            idle_counter${ii} <= 0;
        end else begin
            idle_counter${ii} <= idle_counter${ii} + 1;
            if (i${ii}_ready && i${ii}_valid) begin
                data_out_counter${ii} <= data_out_counter${ii}+ 1;
                idle_counter${ii} <= 0;
            end

            if ((data_out_counter${ii} == DEPTH_0) || (idle_counter${ii} == 100))begin
                $finish;
            end
        end
    end
<% }) %>


        ${top} DUT (<%=
targets.map((t, ti) => (`
            .${t.data} (t${ti}_data),
            .${t.ready} (t${ti}_ready), // ready
            .${t.valid} (t${ti}_valid)`))
.concat(initiators.map((i, ii) => (`
            .${i.data} (i${ii}_data),
            .${i.ready} (i${ii}_ready), // ready
            .${i.valid} (i${ii}_valid)`)))
.concat(obj.clk ? [`
            .${clk}  (i_clk)`] : [])
.concat(obj.reset ? [`
            .${reset}  (i_rst_p)`] : [])
.concat(obj.reset_n ? [`
            .${reset_n}  (!i_rst_p)`] : [])
%>);


    typedef enum {
        ST_IDLE,         // switch from here
        PAT1_WORK        // pattern generation using a lfsr
    } genfsm_states_t;

    genfsm_states_t curr_state;
    genfsm_states_t next_state;


    // lfsr of 6 bits
    logic [5:0] lfsr_pattern;

    always_ff @(posedge i_clk) begin

        if (i_rst_p) begin
            curr_state <= ST_IDLE;
            next_state <= ST_IDLE;
            counter1 <= {32{1'b0}};

            lfsr_pattern <= {1'b1,{5{1'b0}}}; // initializing lfsr by 100000


        end else begin

            // curr_state <= ST_IDLE;

            // /* defaults */
            counter1 <= {32{1'b0}};


            // next_state
            curr_state <= next_state;

            case (curr_state)

                ST_IDLE: begin
                    next_state <= PAT1_WORK;
                    counter1 <= i_seed;
                end

                PAT1_WORK: begin
                    /*
                     * 20 bit lfsr -> x^20 + x^3 + 1 -> only 20bit output will be there. rest 12 bits won't toggle at all.
                     * 30 bit lfsr -> x^30 + x^16 + x^15 +1
                     * I am designing using a 32 bit adder and 6 bit lfsr so that all the bits toggle eventually. -> x^6 + x + 1
                     */

                    lfsr_pattern <= {lfsr_pattern[4:0],lfsr_pattern[5]}; //circular shift
                    lfsr_pattern[1] <= lfsr_pattern[0] ^ lfsr_pattern[5];
                    /* verilator lint_off WIDTH */
                    counter1 <= counter1 + lfsr_pattern;
                    /* verilator lint_on WIDTH */


                end
            endcase

        end // if i_reset
    end // always_ff i_clock


endmodule
