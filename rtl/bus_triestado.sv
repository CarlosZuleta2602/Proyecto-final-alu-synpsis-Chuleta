
`timescale 1ns / 1ps

module bus_triestado #(
    parameter integer WIDTH = 8
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [2:0] ALUControl,
    output tri [WIDTH-1:0] bus_and,
    output tri [WIDTH-1:0] bus_or
);

    wire enable_and;
    wire enable_or;

    assign enable_and = (ALUControl == 3'b000);
    assign enable_or  = (ALUControl == 3'b001);

    assign bus_and = enable_and ? (A & B) : {WIDTH{1'bz}};
    assign bus_or  = enable_or  ? (A | B) : {WIDTH{1'bz}};

endmodule
