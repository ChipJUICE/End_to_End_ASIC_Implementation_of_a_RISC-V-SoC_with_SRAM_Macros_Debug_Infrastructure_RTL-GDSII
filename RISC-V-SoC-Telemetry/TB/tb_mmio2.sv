`timescale 1ns/1ps

module tb_mmio2;

  // -------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------
  localparam int TRACE_DEPTH    = 256;
  localparam int TRACE_PTR_BITS = $clog2(TRACE_DEPTH);

  localparam int RUN_CYCLES = 20000;

  // MMIO base addresses (from your perf_mmio_adapter / spec)
  localparam logic [31:0] PERF_BASE  = 32'h8000_0000;
  localparam logic [31:0] PERF_LAST  = 32'h8000_0014;

  localparam logic [31:0] TRACE_BASE = 32'h8000_0020;
  localparam logic [31:0] TRACE_LAST = 32'h8000_002C; // only those 4 words

  // -------------------------------------------------------------------
  // Clock & Reset
  // -------------------------------------------------------------------
  logic clk;
  logic rst_i;
  logic rst_cpu_i;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;   // 100 MHz
  end

  // -------------------------------------------------------------------
  // AXI (external memory side) – tie off
  // -------------------------------------------------------------------
  logic        axi_i_awready_i;
  logic        axi_i_wready_i;
  logic        axi_i_bvalid_i;
  logic [1:0]  axi_i_bresp_i;
  logic        axi_i_arready_i;
  logic        axi_i_rvalid_i;
  logic [31:0] axi_i_rdata_i;
  logic [1:0]  axi_i_rresp_i;

  logic        axi_i_awvalid_o;
  logic [31:0] axi_i_awaddr_o;
  logic        axi_i_wvalid_o;
  logic [31:0] axi_i_wdata_o;
  logic [3:0]  axi_i_wstrb_o;
  logic        axi_i_bready_o;
  logic        axi_i_arvalid_o;
  logic [31:0] axi_i_araddr_o;
  logic        axi_i_rready_o;

  // -------------------------------------------------------------------
  // AXI (TCM programming side) – idle
  // -------------------------------------------------------------------
  logic        axi_t_awvalid_i;
  logic [31:0] axi_t_awaddr_i;
  logic [3:0]  axi_t_awid_i;
  logic [7:0]  axi_t_awlen_i;
  logic [1:0]  axi_t_awburst_i;
  logic        axi_t_wvalid_i;
  logic [31:0] axi_t_wdata_i;
  logic [3:0]  axi_t_wstrb_i;
  logic        axi_t_wlast_i;
  logic        axi_t_bready_i;
  logic        axi_t_arvalid_i;
  logic [31:0] axi_t_araddr_i;
  logic [3:0]  axi_t_arid_i;
  logic [7:0]  axi_t_arlen_i;
  logic [1:0]  axi_t_arburst_i;
  logic        axi_t_rready_i;

  logic        axi_t_awready_o;
  logic        axi_t_wready_o;
  logic        axi_t_bvalid_o;
  logic [1:0]  axi_t_bresp_o;
  logic [3:0]  axi_t_bid_o;
  logic        axi_t_arready_o;
  logic        axi_t_rvalid_o;
  logic [31:0] axi_t_rdata_o;
  logic [1:0]  axi_t_rresp_o;
  logic [3:0]  axi_t_rid_o;
  logic        axi_t_rlast_o;

  // -------------------------------------------------------------------
  // Interrupts
  // -------------------------------------------------------------------
  logic [31:0] intr_i;

  // -------------------------------------------------------------------
  // DUT: riscv_tcm_top
  // -------------------------------------------------------------------
  riscv_tcm_top #(
    .BOOT_VECTOR        (32'h0000_0000),
    .CORE_ID            (0),
    .TCM_MEM_BASE       (32'h0000_0000),
    .MEM_CACHE_ADDR_MIN (32'h8000_0000),
    .MEM_CACHE_ADDR_MAX (32'h8fff_ffff),
    .TRACE_DEPTH(256)
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

  // -------------------------------------------------------------------
  // Default AXI behaviour: always-ready, no external memory
  // -------------------------------------------------------------------
  initial begin
    // External AXI side
    axi_i_awready_i = 1'b1;
    axi_i_wready_i  = 1'b1;
    axi_i_bvalid_i  = 1'b0;
    axi_i_bresp_i   = 2'b00;
    axi_i_arready_i = 1'b1;
    axi_i_rvalid_i  = 1'b0;
    axi_i_rdata_i   = 32'h0000_0000;
    axi_i_rresp_i   = 2'b00;

    // TCM AXI interface (not used in this test)
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

  // -------------------------------------------------------------------
  // Reset + run
  // -------------------------------------------------------------------
  initial begin
    rst_i     = 1'b1;
    rst_cpu_i = 1'b1;
    intr_i    = 32'd0;

    repeat (10) @(posedge clk);
    rst_i     = 1'b0;
    rst_cpu_i = 1'b0;
    $display("[%0t] Reset deasserted", $time);

    // Let the core + hex program run
    repeat (RUN_CYCLES) @(posedge clk);

    // Post-run checks
    dump_telemetry();
    check_trace_buffer_view();
    final_report();
    $finish;
  end

  // -------------------------------------------------------------------
  // Telemetry taps (from riscv_tcm_top)
  // -------------------------------------------------------------------
  wire [63:0] tlm_mcycle   = u_dut.tlm_mcycle_w;
  wire [63:0] tlm_minstret = u_dut.tlm_minstret_w;
  wire [63:0] tlm_stall    = u_dut.tlm_stall_w;

  // -------------------------------------------------------------------
  // Trace taps (from riscv_tcm_top)
  // -------------------------------------------------------------------
  wire        trace_triggered = u_dut.trace_triggered_w;
  wire [5:0]  trace_wr_ptr    = u_dut.trace_wr_ptr_w;
  wire [31:0] trace_rd_pc     = u_dut.trace_rd_pc_w;
  wire [31:0] trace_rd_instr  = u_dut.trace_rd_instr_w;

  // -------------------------------------------------------------------
  // Golden MINSTRET based on retire_pulse from Debug_Telemetry
  // -------------------------------------------------------------------
  reg  [63:0] golden_minstret;
  wire        retire_pulse = u_dut.u_debug_telemetry.retire_pulse_i;

  initial golden_minstret = 64'd0;

  always @(posedge clk) begin
    if (rst_i) begin
      golden_minstret <= 64'd0;
    end
    else if (retire_pulse) begin
      golden_minstret <= golden_minstret + 1;
    end
  end

  // -------------------------------------------------------------------
  // MMIO monitor on core data bus
  //  - Checks PERF (counters) against tlm_*
  //  - Checks TRACE MMIO against trace_* wires
  // -------------------------------------------------------------------
  int     error_count = 0;
  integer mmio_read_count = 0;

  logic        mon_pending;
  logic [31:0] mon_addr;
  logic [31:0] mon_expected;
  logic        mon_expect_valid;

  // Core data bus (from riscv_tcm_top)
  wire        core_rd    = u_dut.core_d_rd_w;
  wire [31:0] core_addr  = u_dut.core_d_addr_w;
  wire [31:0] core_rdata = u_dut.core_d_data_rd_w;
  wire        core_ack   = u_dut.core_d_ack_w;
  wire [3:0]  core_wr    = u_dut.core_d_wr_w;

  // "Clean" read detect (no write strobes)
  wire core_is_read = core_rd && (core_wr == 4'b0000);

  // Is this address in PERF MMIO?
  function automatic bit is_perf_addr(input logic [31:0] a);
    return (a >= PERF_BASE) && (a <= PERF_LAST);
  endfunction

  // Is this address in TRACE MMIO?
  function automatic bit is_trace_addr(input logic [31:0] a);
    return (a >= TRACE_BASE) && (a <= TRACE_LAST);
  endfunction

  always @(posedge clk) begin
    if (rst_i) begin
      mon_pending      <= 1'b0;
      mon_expect_valid <= 1'b0;
      mon_addr         <= 32'h0;
      mon_expected     <= 32'h0;
      mmio_read_count  <= 0;
    end
    else begin
      // Phase 1: detect new MMIO read & compute expected value
      if (!mon_pending && core_is_read &&
          (is_perf_addr(core_addr) || is_trace_addr(core_addr))) begin

        mon_pending      <= 1'b1;
        mon_addr         <= core_addr;
        mon_expect_valid <= 1'b1; // By default, we have a golden expectation

        // -------------------------
        // PERF counters
        // -------------------------
        if (is_perf_addr(core_addr)) begin
		$display("HI FROM PERF");
          unique case (core_addr)
            32'h8000_0000: mon_expected <= tlm_mcycle[31:0];
            32'h8000_0004: mon_expected <= tlm_mcycle[63:32];
            32'h8000_0008: mon_expected <= tlm_minstret[31:0];
            32'h8000_000C: mon_expected <= tlm_minstret[63:32];
            32'h8000_0010: mon_expected <= tlm_stall[31:0];
            32'h8000_0014: mon_expected <= tlm_stall[63:32];
            default: begin
              mon_expected     <= 32'hDEAD_BEEF;
              mon_expect_valid <= 1'b0; // don't check unknown words
            end
          endcase
        end

        // -------------------------
        // TRACE MMIO
        // -------------------------
        else begin // is_trace_addr(core_addr)
		$display("HI FROM TRACE");
          unique case (core_addr)
            32'h8000_0020: mon_expected <= {31'b0, trace_triggered};
            32'h8000_0024: mon_expected <= {26'b0, trace_wr_ptr}; // zero-extend
            32'h8000_0028: mon_expected <= trace_rd_pc;
            32'h8000_002C: mon_expected <= trace_rd_instr;
            default: begin
              mon_expected     <= 32'hDEAD_BEEF;
              mon_expect_valid <= 1'b0;
            end
          endcase
        end
      end

      // Phase 2: on ACK, compare / log
      if (mon_pending && core_ack) begin
        mmio_read_count <= mmio_read_count + 1;

        if (mon_expect_valid) begin
          if (core_rdata !== mon_expected) begin
            $error("MMIO READ MISMATCH at addr %h: got %h, expected %h",
                   mon_addr, core_rdata, mon_expected);
            error_count <= error_count + 1;
          end
          else begin
            $display("MMIO READ OK: addr %h data %h", mon_addr, core_rdata);
          end
        end
        else begin
          $display("MMIO READ (no golden) addr %h data %h", mon_addr, core_rdata);
        end

        mon_pending <= 1'b0;
      end
    end
  end

  // -------------------------------------------------------------------
  // Telemetry dump + MINSTRET cross-check
  // -------------------------------------------------------------------
  task dump_telemetry;
    begin
      $display("============== Telemetry ==============");
      $display("MCYCLE   = %0d (0x%016h)", tlm_mcycle,   tlm_mcycle);
      $display("MINSTRET = %0d (0x%016h)", tlm_minstret, tlm_minstret);
      $display("GOLDEN_MINSTRET (retire_pulse) = %0d (0x%016h)",
               golden_minstret, golden_minstret);

      if (tlm_minstret !== golden_minstret) begin
        $error("** MINSTRET MISMATCH: tlm_minstret=%0d golden=%0d **",
               tlm_minstret, golden_minstret);
        error_count <= error_count + 1;
      end

      $display("STALL    = %0d (0x%016h)", tlm_stall,    tlm_stall);
      $display("=======================================");
    end
  endtask

  // -------------------------------------------------------------------
  // Trace buffer self-check:
  //   - Directly read u_trace_buf.mem[i]
  //   - Force the read address inside Debug_Telemetry to i
  //   - Check that trace_rd_pc/trace_rd_instr match the memory entry
  //
  // This validates:
  //   - Trace buffer write path (pc/instr store)
  //   - Read address muxing logic
  // -------------------------------------------------------------------
  task check_trace_buffer_view;
    int i;
    logic [63:0] mem_word;
    logic [31:0] mem_pc;
    logic [31:0] mem_instr;
    begin
      $display("============== Trace Buffer Check =====");
      $display("triggered = %0d, wr_ptr = %0d", trace_triggered, trace_wr_ptr);

      for (i = 0; i < TRACE_DEPTH; i++) begin
        // Read raw memory from trace buffer
        mem_word = u_dut.u_debug_telemetry.u_trace_buf.mem[i];
        mem_pc      = mem_word[63:32];
        mem_instr   = mem_word[31:0];

        // Skip purely uninitialized entries (all X)
        if (^mem_word === 1'bX) begin
          // Optionally print:
          // $display("TRACE_MEM[%0d] is uninitialized / X, skipping", i);
        end
        else begin
          // Force the trace read address to this index
          force u_dut.trace_rd_addr_w = i[TRACE_PTR_BITS-1:0];
          @(posedge clk); // allow signals to propagate

          if (trace_rd_pc   !== mem_pc ||
              trace_rd_instr !== mem_instr) begin
            $error("TRACE BUF VIEW MISMATCH @idx %0d: pc %h/%h instr %h/%h",
                   i, trace_rd_pc, mem_pc, trace_rd_instr, mem_instr);
            error_count <= error_count + 1;
          end
          else begin
            $display("TRACE[%0d] OK: PC=0x%08x INSTR=0x%08x",
                     i, trace_rd_pc, trace_rd_instr);
          end

          release u_dut.trace_rd_addr_w;
        end
      end

      $display("=======================================");
    end
  endtask

  // -------------------------------------------------------------------
  // Final report
  // -------------------------------------------------------------------
  task final_report;
    begin
      $display("============== FINAL REPORT ===========");
      $display("MMIO reads observed: %0d", mmio_read_count);
      $display("Total errors:        %0d", error_count);
      if (error_count == 0) begin
        $display("STATUS: TEST PASSED");
      end
      else begin
        $display("STATUS: TEST FAILED");
      end
      $display("=======================================");
    end
  endtask

endmodule

