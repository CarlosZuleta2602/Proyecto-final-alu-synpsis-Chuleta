
`timescale 1ns / 1ps

module alu_plus_sync #(
    parameter integer WIDTH = 16
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic [WIDTH-1:0]     A,
    input  logic [WIDTH-1:0]     B,
    input  logic [2:0]           ALUControl,
    output logic [WIDTH-1:0]     Result,
    output logic [2*WIDTH-1:0]   ProductFull,
    output logic                 N,
    output logic                 Z,
    output logic                 C,
    output logic                 V
);

    logic [WIDTH-1:0] A_reg;
    logic [WIDTH-1:0] B_reg;
    logic [2:0] ALUControl_reg;

    wire [WIDTH-1:0] Result_comb;
    wire [2*WIDTH-1:0] ProductFull_comb;
    wire N_comb;
    wire Z_comb;
    wire C_comb;
    wire V_comb;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg <= '0;
            B_reg <= '0;
            ALUControl_reg <= 3'b111;
        end
        else begin
            A_reg <= A;
            B_reg <= B;
            ALUControl_reg <= ALUControl;
        end
    end

    alu_plus #(
        .WIDTH(WIDTH)
    ) u_alu_plus (
        .A(A_reg),
        .B(B_reg),
        .ALUControl(ALUControl_reg),
        .Result(Result_comb),
        .ProductFull(ProductFull_comb),
        .N(N_comb),
        .Z(Z_comb),
        .C(C_comb),
        .V(V_comb)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Result <= '0;
            ProductFull <= '0;
            N <= 1'b0;
            Z <= 1'b1;
            C <= 1'b0;
            V <= 1'b0;
        end
        else begin
            Result <= Result_comb;
            ProductFull <= ProductFull_comb;
            N <= N_comb;
            Z <= Z_comb;
            C <= C_comb;
            V <= V_comb;
        end
    end

endmodule
