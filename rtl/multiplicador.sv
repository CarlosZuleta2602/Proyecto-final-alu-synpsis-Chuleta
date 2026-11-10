
`timescale 1ns / 1ps

module multiplicador #(
    parameter integer WIDTH = 8
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    output logic [2*WIDTH-1:0] Product
);

    // Multiplicacion combinacional sin signo.
    // El resultado completo ocupa 2*WIDTH bits.

    assign Product = A * B;

endmodule
