
`timescale 1ns / 1ps

module prefix_adder #(
    parameter integer WIDTH = 8
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic             Cin,
    output logic [WIDTH-1:0] Sum,
    output logic             Cout
);

    localparam integer STAGES = $clog2(WIDTH);

    wire [WIDTH-1:0] p [0:STAGES];
    wire [WIDTH-1:0] g [0:STAGES];
    wire [WIDTH:0] carry;

    assign p[0] = A ^ B;
    assign g[0] = A & B;

    genvar s, i;

    generate
        for (s = 0; s < STAGES; s = s + 1) begin : stage
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_position
                if (i >= (1 << s)) begin : combine
                    assign g[s+1][i] =
                        g[s][i] |
                        (p[s][i] & g[s][i-(1 << s)]);

                    assign p[s+1][i] =
                        p[s][i] &
                        p[s][i-(1 << s)];
                end else begin : pass
                    assign g[s+1][i] = g[s][i];
                    assign p[s+1][i] = p[s][i];
                end
            end
        end
    endgenerate

    assign carry[0] = Cin;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_calc
            assign carry[i+1] =
                g[STAGES][i] |
                (p[STAGES][i] & Cin);
        end
    endgenerate

    assign Sum  = A ^ B ^ carry[WIDTH-1:0];
    assign Cout = carry[WIDTH];

endmodule

