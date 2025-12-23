`timescale 1ns/1ps

module tb_debug_tlm;

  localparam int TRACE_DEPTH    = 64;
  localparam int TRACE_PTR_BITS = $clog2(TRACE_DEPTH);

  // ------------------------------------------------------------
  // Clock & Reset
  // ------------------------------------------------------------
  reg clk;
  reg rst_i;
  reg rst_cpu_i;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk; // 100 MHz
  end

  // ------------------------------------------------------------
  // AXI (external side) – unused
  // ------------------------------------------------------------
  reg           axi_i_awready_i;
  reg           axi_i_wready_i;
  reg           axi_i_bvalid_i;
  reg  [1:0]    axi_i_bresp_i;
  reg           axi_i_arready_i;
  reg           axi_i_rvalid_i;
  reg  [31:0]   axi_i_rdata_i;
  reg  [1:0]    axi_i_rresp_i;

  wire          axi_i_awvalid_o;
  wire [31:0]   axi_i_awaddr_o;
  wire          axi_i_wvalid_o;
  wire [31:0]   axi_i_wdata_o;
  wire [3:0]    axi_i_wstrb_o;
  wire          axi_i_bready_o;
  wire          axi_i_arvalid_o;
  wire [31:0]   axi_i_araddr_o;
  wire          axi_i_rready_o;

  // ------------------------------------------------------------
  // AXI (TCM programming side) – idle
  // ------------------------------------------------------------
  reg           axi_t_awvalid_i;
  reg  [31:0]   axi_t_awaddr_i;
  reg  [3:0]    axi_t_awid_i;
  reg  [7:0]    axi_t_awlen_i;
  reg  [1:0]    axi_t_awburst_i;
  reg           axi_t_wvalid_i;
  reg  [31:0]   axi_t_wdata_i;
  reg  [3:0]    axi_t_wstrb_i;
  reg           axi_t_wlast_i;
  reg           axi_t_bready_i;
  reg           axi_t_arvalid_i;
  reg  [31:0]   axi_t_araddr_i;
  reg  [3:0]    axi_t_arid_i;
  reg  [7:0]    axi_t_arlen_i;
  reg  [1:0]    axi_t_arburst_i;
  reg           axi_t_rready_i;

  wire          axi_t_awready_o;
  wire          axi_t_wready_o;
  wire          axi_t_bvalid_o;
  wire [1:0]    axi_t_bresp_o;
  wire [3:0]    axi_t_bid_o;
  wire          axi_t_arready_o;
  wire          axi_t_rvalid_o;
  wire [31:0]   axi_t_rdata_o;
  wire [1:0]    axi_t_rresp_o;
  wire [3:0]    axi_t_rid_o;
  wire          axi_t_rlast_o;

  // ------------------------------------------------------------
  // Interrupts
  // ------------------------------------------------------------
  reg [31:0] intr_i;

  // ------------------------------------------------------------
  // DUT
  // ------------------------------------------------------------
  riscv_tcm_top #(
      .BOOT_VECTOR        (32'h0000_0000),
      .CORE_ID            (0),
      .TCM_MEM_BASE       (32'h0000_0000),
      .MEM_CACHE_ADDR_MIN (32'h8000_0000),
      .MEM_CACHE_ADDR_MAX (32'h8fff_ffff)
  ) u_dut (
      .clk_i           (clk),
      .rst_i           (rst_i),
      .rst_cpu_i       (rst_cpu_i),

      .axi_i_awready_i (axi_i_awready_i),
      .axi_i_wready_i  (axi_i_wready_i),
      .axi_i_bvalid_i  (axi_i_bvalid_i),
      .axi_i_bresp_i   (axi_i_bresp_i),
      .axi_i_arready_i (axi_i_arready_i),
      .axi_i_rvalid_i  (axi_i_rvalid_i),
      .axi_i_rdata_i   (axi_i_rdata_i),
      .axi_i_rresp_i   (axi_i_rresp_i),

      .axi_i_awvalid_o (axi_i_awvalid_o),
      .axi_i_awaddr_o  (axi_i_awaddr_o),
      .axi_i_wvalid_o  (axi_i_wvalid_o),
      .axi_i_wdata_o   (axi_i_wdata_o),
      .axi_i_wstrb_o   (axi_i_wstrb_o),
      .axi_i_bready_o  (axi_i_bready_o),
      .axi_i_arvalid_o (axi_i_arvalid_o),
      .axi_i_araddr_o  (axi_i_araddr_o),
      .axi_i_rready_o  (axi_i_rready_o),

      .axi_t_awvalid_i (axi_t_awvalid_i),
      .axi_t_awaddr_i  (axi_t_awaddr_i),
      .axi_t_awid_i    (axi_t_awid_i),
      .axi_t_awlen_i   (axi_t_awlen_i),
      .axi_t_awburst_i (axi_t_awburst_i),
      .axi_t_wvalid_i  (axi_t_wvalid_i),
      .axi_t_wdata_i   (axi_t_wdata_i),
      .axi_t_wstrb_i   (axi_t_wstrb_i),
      .axi_t_wlast_i   (axi_t_wlast_i),
      .axi_t_bready_i  (axi_t_bready_i),
      .axi_t_arvalid_i (axi_t_arvalid_i),
      .axi_t_araddr_i  (axi_t_araddr_i),
      .axi_t_arid_i    (axi_t_arid_i),
      .axi_t_arlen_i   (axi_t_arlen_i),
      .axi_t_arburst_i (axi_t_arburst_i),
      .axi_t_rready_i  (axi_t_rready_i),

      .axi_t_awready_o (axi_t_awready_o),
      .axi_t_wready_o  (axi_t_wready_o),
      .axi_t_bvalid_o  (axi_t_bvalid_o),
      .axi_t_bresp_o   (axi_t_bresp_o),
      .axi_t_bid_o     (axi_t_bid_o),
      .axi_t_arready_o (axi_t_arready_o),
      .axi_t_rvalid_o  (axi_t_rvalid_o),
      .axi_t_rdata_o   (axi_t_rdata_o),
      .axi_t_rresp_o   (axi_t_rresp_o),
      .axi_t_rid_o     (axi_t_rid_o),
      .axi_t_rlast_o   (axi_t_rlast_o),

      .intr_i          (intr_i)
  );

  // ------------------------------------------------------------
  // Default AXI behavior
  // ------------------------------------------------------------
  initial begin
    // External AXI always-ready, never returns data
    axi_i_awready_i = 1'b1;
    axi_i_wready_i  = 1'b1;
    axi_i_bvalid_i  = 1'b0;
    axi_i_bresp_i   = 2'b00;
    axi_i_arready_i = 1'b1;
    axi_i_rvalid_i  = 1'b0;
    axi_i_rdata_i   = 32'h0;
    axi_i_rresp_i   = 2'b00;

    // TCM programming port idle
    axi_t_awvalid_i = 1'b0;
    axi_t_awaddr_i  = 32'd0;
    axi_t_awid_i    = 4'd0;
    axi_t_awlen_i   = 8'd0;
    axi_t_awburst_i = 2'b01;
    axi_t_wvalid_i  = 1'b0;
    axi_t_wdata_i   = 32'd0;
    axi_t_wstrb_i   = 4'd0;
    axi_t_wlast_i   = 1'b0;
    axi_t_bready_i  = 1'b1;
    axi_t_arvalid_i = 1'b0;
    axi_t_araddr_i  = 32'd0;
    axi_t_arid_i    = 4'd0;
    axi_t_arlen_i   = 8'd0;
    axi_t_arburst_i = 2'b01;
    axi_t_rready_i  = 1'b1;
  end

  // ------------------------------------------------------------
  // Taps from top (wires in your riscv_tcm_top)
  // ------------------------------------------------------------
  wire [63:0] tlm_mcycle   = u_dut.tlm_mcycle_w;
  wire [63:0] tlm_minstret = u_dut.tlm_minstret_w;
  wire [63:0] tlm_stall    = u_dut.tlm_stall_w;

  wire                      trace_triggered = u_dut.trace_triggered_w;
  wire [TRACE_PTR_BITS-1:0] trace_wr_ptr    = u_dut.trace_wr_ptr_w;
  wire [31:0]               trace_rd_pc     = u_dut.trace_rd_pc_w;
  wire [31:0]               trace_rd_instr  = u_dut.trace_rd_instr_w;

  wire        dbg_retire_pulse = u_dut.dbg_retire_pulse_w;
  wire        dbg_stall_cycle  = u_dut.dbg_stall_cycle_w;
  wire        dbg_fetch_valid  = u_dut.dbg_fetch_valid_w;
  wire [31:0] dbg_fetch_pc     = u_dut.dbg_fetch_pc_w;
  wire [31:0] dbg_fetch_instr  = u_dut.dbg_fetch_instr_w;

  // ------------------------------------------------------------
  // Trace read address control (force the internal rd_addr wire)
  // ------------------------------------------------------------
  reg [TRACE_PTR_BITS-1:0] tb_trace_rd_addr;
  initial begin
    force u_dut.trace_rd_addr_w = tb_trace_rd_addr;
  end

  // ------------------------------------------------------------
  // 1) PROVE program.hex loading + start PC=0
  // ------------------------------------------------------------
  integer printed_fetches;
  always @(posedge clk) begin
    if (rst_i) begin
      printed_fetches = 0;
    end
    else if (dbg_fetch_valid && printed_fetches < 16) begin
      $display("[%0t] IFETCH[%0d]: PC=0x%08x INSTR=0x%08x",
               $time, printed_fetches, dbg_fetch_pc, dbg_fetch_instr);
      printed_fetches = printed_fetches + 1;
    end
  end

  // ------------------------------------------------------------
  // 2) Golden trace capture (RETIRE-based)
  // ------------------------------------------------------------
  reg [31:0] golden_pc    [0:TRACE_DEPTH-1];
  reg [31:0] golden_instr [0:TRACE_DEPTH-1];
  integer    golden_cnt;

  initial golden_cnt = 0;

  always @(posedge clk) begin
    if (!rst_i && dbg_retire_pulse && (golden_cnt < TRACE_DEPTH)) begin
      golden_pc[golden_cnt]    = dbg_fetch_pc;
      golden_instr[golden_cnt] = dbg_fetch_instr;
      golden_cnt               = golden_cnt + 1;
    end
  end

  // ------------------------------------------------------------
  // 3) Golden telemetry (MINSTRET + STALL)
  // ------------------------------------------------------------
  reg [63:0] gold_minstret;
  reg [63:0] gold_stall;

  always @(posedge clk) begin
    if (rst_i) begin
      gold_minstret <= 64'd0;
      gold_stall    <= 64'd0;
    end
    else begin
      if (dbg_retire_pulse)
        gold_minstret <= gold_minstret + 64'd1;

      if (dbg_stall_cycle)
        gold_stall <= gold_stall + 64'd1;
    end
  end

  // ------------------------------------------------------------
  // 4) Dump task
  // ------------------------------------------------------------
  task dump_telemetry_and_trace;
    integer i;
    reg [31:0] rdpc_d, rdinstr_d;
    begin
      $display("============== Telemetry (DUT vs GOLD) ==============");
      $display("MCYCLE   DUT=%0d", tlm_mcycle);
      $display("MINSTRET DUT=%0d  GOLD=%0d        %s",
               tlm_minstret, gold_minstret, (tlm_minstret===gold_minstret) ? "OK" : "MISMATCH");
      $display("STALL    DUT=%0d  GOLD=%0d        %s",
               tlm_stall, gold_stall, (tlm_stall===gold_stall) ? "OK" : "MISMATCH");

      $display("============== Trace ==============");
      $display("triggered=%0d wr_ptr=%0d golden_cnt=%0d",
               trace_triggered, trace_wr_ptr, golden_cnt);

      for (i = 0; i < TRACE_DEPTH; i = i + 1) begin
        tb_trace_rd_addr = i[TRACE_PTR_BITS-1:0];
        @(posedge clk); // 1-cycle latency
        rdpc_d    = trace_rd_pc;
        rdinstr_d = trace_rd_instr;

        $display("TRACE[%02d]: PC=0x%08x INSTR=0x%08x | GOLD: PC=0x%08x INSTR=0x%08x",
                 i, rdpc_d, rdinstr_d, golden_pc[i], golden_instr[i]);

        if (rdpc_d !== golden_pc[i] || rdinstr_d !== golden_instr[i])
          $display("** MISMATCH at index %0d **", i);
      end

      $display("=======================================");
    end
  endtask

  // ------------------------------------------------------------
  // Reset + run
  // ------------------------------------------------------------
  initial begin
    rst_i     = 1'b1;
    rst_cpu_i = 1'b1;
    intr_i    = 32'd0;

    repeat (10) @(posedge clk);
    rst_i     = 1'b0;
    rst_cpu_i = 1'b0;
    $display("[%0t] Reset deasserted", $time);

    repeat (30000) @(posedge clk);

    dump_telemetry_and_trace();
    $finish;
  end

endmodule