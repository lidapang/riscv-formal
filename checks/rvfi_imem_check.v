module rvfi_imem_check (
	input clk,
	input resetn,
	output [`RISCV_FORMAL_XLEN-1:0] imem_addr, 
	output [15:0] imem_data, 
	input [`RISCV_FORMAL_NRET                        - 1 : 0] rvfi_valid,
	input [`RISCV_FORMAL_NRET *                  8   - 1 : 0] rvfi_order,
	input [`RISCV_FORMAL_NRET *                 32   - 1 : 0] rvfi_insn,
	input [`RISCV_FORMAL_NRET *                  5   - 1 : 0] rvfi_rs1,
	input [`RISCV_FORMAL_NRET *                  5   - 1 : 0] rvfi_rs2,
	input [`RISCV_FORMAL_NRET *                  5   - 1 : 0] rvfi_rd,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_pre_pc,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_pre_rs1,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_pre_rs2,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_post_pc,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_post_rd,
	input [`RISCV_FORMAL_NRET                        - 1 : 0] rvfi_post_trap,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_mem_addr,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN/8 - 1 : 0] rvfi_mem_rmask,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN/8 - 1 : 0] rvfi_mem_wmask,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_mem_rdata,
	input [`RISCV_FORMAL_NRET * `RISCV_FORMAL_XLEN   - 1 : 0] rvfi_mem_wdata
);
	assign imem_addr = $anyconst & ~1;
	assign imem_data = $anyconst;
	reg [`RISCV_FORMAL_XLEN-1:0] pc;
	reg [31:0] insn;

	integer channel_idx;
	integer i;

	always @(posedge clk) begin
		for (channel_idx = 0; channel_idx < `RISCV_FORMAL_NRET; channel_idx=channel_idx+1) begin
			if (resetn && rvfi_valid[channel_idx]) begin
				pc = rvfi_pre_pc[channel_idx*`RISCV_FORMAL_XLEN +: `RISCV_FORMAL_XLEN];
				insn = rvfi_insn[channel_idx*32 +: 32];

				if (pc == imem_addr)
					assert(insn[15:0] == imem_data);

				if (insn[1:0] == 2'b11 && pc+2 == imem_addr)
					assert(insn[31:16] == imem_data);
			end
		end
	end
endmodule