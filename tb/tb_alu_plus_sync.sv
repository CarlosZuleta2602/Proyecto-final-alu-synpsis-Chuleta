
`timescale 1ns / 1ps

module tb_alu_plus_sync;

    localparam integer WIDTH = 16;

    logic clk;
    logic rst_n;
    logic [WIDTH-1:0] A;
    logic [WIDTH-1:0] B;
    logic [2:0] ALUControl;

    wire [WIDTH-1:0] Result;
    wire [2*WIDTH-1:0] ProductFull;
    wire N, Z, C, V;

    logic [WIDTH-1:0] esperado;
    logic [2*WIDTH-1:0] producto_esperado;
    logic [WIDTH:0] suma_ext;
    logic [WIDTH-1:0] resta_ref;
    logic n_esp, z_esp, c_esp, v_esp;

    integer pruebas = 0;
    integer errores = 0;

    alu_plus_sync #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .ProductFull(ProductFull),
        .N(N),
        .Z(Z),
        .C(C),
        .V(V)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic probar(
        input logic [WIDTH-1:0] a_test,
        input logic [WIDTH-1:0] b_test,
        input logic [2:0] op
    );
        begin
            @(negedge clk);
            A = a_test;
            B = b_test;
            ALUControl = op;

            producto_esperado =
                {{WIDTH{1'b0}}, a_test} *
                {{WIDTH{1'b0}}, b_test};

            suma_ext = {1'b0, a_test} + {1'b0, b_test};
            resta_ref = a_test - b_test;

            esperado = '0;
            c_esp = 1'b0;
            v_esp = 1'b0;

            case (op)
                3'b000: esperado = a_test & b_test;
                3'b001: esperado = a_test | b_test;

                3'b010: begin
                    esperado = suma_ext[WIDTH-1:0];
                    c_esp = suma_ext[WIDTH];
                    v_esp =
                        (~(a_test[WIDTH-1] ^ b_test[WIDTH-1])) &
                        (a_test[WIDTH-1] ^ esperado[WIDTH-1]);
                end

                3'b011: begin
                    esperado =
                        ($signed(a_test) < $signed(b_test))
                        ? {{(WIDTH-1){1'b0}}, 1'b1} : '0;

                    c_esp = (a_test >= b_test);
                    v_esp =
                        (a_test[WIDTH-1] ^ b_test[WIDTH-1]) &
                        (a_test[WIDTH-1] ^ resta_ref[WIDTH-1]);
                end

                3'b100: esperado = producto_esperado[WIDTH-1:0];
                3'b101: esperado = (b_test != 0) ? a_test / b_test : '0;
                3'b110: esperado = (b_test != 0) ? a_test % b_test : '0;
                3'b111: esperado = '0;
                default: esperado = '0;
            endcase

            n_esp = esperado[WIDTH-1];
            z_esp = (esperado == '0);

            @(posedge clk);
            @(negedge clk);

            @(posedge clk);
            #1;

            pruebas = pruebas + 1;

            if (Result !== esperado ||
                ProductFull !== producto_esperado ||
                {N,Z,C,V} !== {n_esp,z_esp,c_esp,v_esp}) begin

                errores = errores + 1;

                $display(
                    "ERROR OP=%b A=%0d B=%0d RESULT=%0d ESP=%0d NZCV=%b%b%b%b ESP=%b%b%b%b",
                    op, a_test, b_test, Result, esperado,
                    N, Z, C, V, n_esp, z_esp, c_esp, v_esp
                );
            end
            else begin
                $display(
                    "OK OP=%b A=%0d B=%0d RESULT=%0d NZCV=%b%b%b%b",
                    op, a_test, b_test, Result, N, Z, C, V
                );
            end
        end
    endtask

    initial begin
        A = '0;
        B = '0;
        ALUControl = 3'b111;
        rst_n = 1'b0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        $display("====================================");
        $display(" ALU PLUS SYNC - 16 BITS");
        $display("====================================");

        probar(16'd15, 16'd10, 3'b000);
        probar(16'd15, 16'd10, 3'b001);
        probar(16'd15, 16'd10, 3'b010);
        probar(16'd5, 16'd10, 3'b011);
        probar(16'd20, 16'd10, 3'b100);
        probar(16'd20, 16'd5, 3'b101);
        probar(16'd20, 16'd6, 3'b110);
        probar(16'd20, 16'd10, 3'b111);

        probar(16'hFFFF, 16'd1, 3'b010);
        probar(16'h7FFF, 16'd1, 3'b010);
        probar(16'h8000, 16'd1, 3'b011);
        probar(16'd100, 16'd0, 3'b101);
        probar(16'd100, 16'd0, 3'b110);

        for (int i = 0; i < 100; i++) begin
            probar($urandom, $urandom, $urandom_range(0,7));
        end

        $display("====================================");
        $display("TOTAL DE PRUEBAS: %0d", pruebas);
        $display("TOTAL DE ERRORES: %0d", errores);

        if (errores == 0)
            $display("TODAS LAS PRUEBAS PASARON");
        else
            $display("EXISTEN ERRORES");

        $display("====================================");

        $finish;
    end

endmodule
