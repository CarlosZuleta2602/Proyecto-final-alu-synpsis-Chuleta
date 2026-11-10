
`timescale 1ns / 1ps

module monitor_ondas;

    initial begin
        $dumpfile("results/alu_plus_sync.vcd");
        $dumpvars(0, tb_alu_plus_sync);
    end

endmodule
