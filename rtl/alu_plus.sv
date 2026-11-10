
`timescale 1ns / 1ps

module alu_plus #(
    parameter integer WIDTH = 8
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [2:0] ALUControl,
    output logic [WIDTH-1:0] Result,
    output logic [2*WIDTH-1:0] ProductFull,
    output logic N,
    output logic Z,
    output logic C,
    output logic V
);

    wire [WIDTH-1:0] suma;
    wire carry_suma;
    wire [2*WIDTH-1:0] producto;

    wire resta;
    wire [WIDTH-1:0] b_arit;
    wire [WIDTH-1:0] resultado_slt;

    wire enable_and;
    wire enable_or;

    wire [WIDTH-1:0] a_and;
    wire [WIDTH-1:0] b_and;
    wire [WIDTH-1:0] a_or;
    wire [WIDTH-1:0] b_or;

    wire [WIDTH-1:0] resultado_and;
    wire [WIDTH-1:0] resultado_or;

    wire [WIDTH-1:0] cociente;
    wire [WIDTH-1:0] residuo;

    assign enable_and = (ALUControl == 3'b000);
    assign enable_or  = (ALUControl == 3'b001);

    assign a_and = enable_and ? A : {WIDTH{1'b0}};
    assign b_and = enable_and ? B : {WIDTH{1'b0}};

    assign a_or = enable_or ? A : {WIDTH{1'b0}};
    assign b_or = enable_or ? B : {WIDTH{1'b0}};

    assign resultado_and = a_and & b_and;
    assign resultado_or = a_or | b_or;

    assign resta = (ALUControl == 3'b011);

    assign b_arit = resta ? ~B : B;

    prefix_adder #(
        .WIDTH(WIDTH)
    ) u_adder (
        .A(A),
        .B(b_arit),
        .Cin(resta),
        .Sum(suma),
        .Cout(carry_suma)
    );

    multiplicador #(
        .WIDTH(WIDTH)
    ) u_mult (
        .A(A),
        .B(B),
        .Product(producto)
    );

    assign ProductFull = producto;

    assign resultado_slt =
        (A[WIDTH-1] != B[WIDTH-1])
        ? {{(WIDTH-1){1'b0}}, A[WIDTH-1]}
        : {{(WIDTH-1){1'b0}}, suma[WIDTH-1]};

    assign cociente =
        (B != 0) ? A / B : {WIDTH{1'b0}};

    assign residuo =
        (B != 0) ? A % B : {WIDTH{1'b0}};

    assign Result =
        (ALUControl == 3'b000) ? resultado_and :
        (ALUControl == 3'b001) ? resultado_or :
        (ALUControl == 3'b010) ? suma :
        (ALUControl == 3'b011) ? resultado_slt :
        (ALUControl == 3'b100) ? producto[WIDTH-1:0] :
        (ALUControl == 3'b101) ? cociente :
        (ALUControl == 3'b110) ? residuo :
        {WIDTH{1'b0}};

    assign N = Result[WIDTH-1];

    assign Z = (Result == {WIDTH{1'b0}});

    assign C = (ALUControl == 3'b010) ? carry_suma :
               (ALUControl == 3'b011) ? carry_suma :
               1'b0;

    assign V = (ALUControl == 3'b010) ?
               (~(A[WIDTH-1] ^ B[WIDTH-1]) &
                (A[WIDTH-1] ^ suma[WIDTH-1])) :
               (ALUControl == 3'b011) ?
               ((A[WIDTH-1] ^ B[WIDTH-1]) &
                (A[WIDTH-1] ^ suma[WIDTH-1])) :
               1'b0;

endmodule
