`timescale 1ns/1ps

module tb_mmio;

  // -------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------
  localparam int TRACE_DEPTH = 256;
  localparam int RUN_CYCLES  = 20000;

  // MMIO ranges
  localparam logic [31:0] MMIO_LO = 32'h8000_0000;
  localparam logic [31:0] MMIO_HI = 32'h8000_0030;

  // -------------------------------------------------------------------
  // Clock & Reset
  // -------------------------------------------------------------------
  logic clk;
  logic rst_i;
  logic rst_cpu_i;

logic        rd_pending;
logic [31:0] rd_addr_latched;



  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // -------------------------------------------------------------------
  // AXI tie-offs (same as your working TB)
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

  logic [31:0] intr_i;

  // -------------------------------------------------------------------
  // DUT
  // -------------------------------------------------------------------
  riscv_tcm_top #(
    .BOOT_VECTOR        (32'h0000_0000),
    .CORE_ID            (0),
    .TCM_MEM_BASE       (32'h0000_0000),
    // MMIO must NOT be cacheable
    .MEM_CACHE_ADDR_MIN (32'h0000_0000),
    .MEM_CACHE_ADDR_MAX (32'h7fff_ffff),
    .TRACE_DEPTH        (TRACE_DEPTH)
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
  // AXI defaults
  // -------------------------------------------------------------------
  initial begin
    axi_i_awready_i = 1;
    axi_i_wready_i  = 1;
    axi_i_bvalid_i  = 0;
    axi_i_bresp_i   = 0;
    axi_i_arready_i = 1;
    axi_i_rvalid_i  = 0;
    axi_i_rdata_i   = 0;
    axi_i_rresp_i   = 0;

    axi_t_awvalid_i = 0;
    axi_t_awaddr_i  = 0;
    axi_t_awid_i    = 0;
    axi_t_awlen_i   = 0;
    axi_t_awburst_i = 2'b01;
    axi_t_wvalid_i  = 0;
    axi_t_wdata_i   = 0;
    axi_t_wstrb_i   = 0;
    axi_t_wlast_i   = 0;
    axi_t_bready_i  = 1;
    axi_t_arvalid_i = 0;
    axi_t_araddr_i  = 0;
    axi_t_arid_i    = 0;
    axi_t_arlen_i   = 0;
    axi_t_arburst_i = 2'b01;
    axi_t_rready_i  = 1;

    intr_i = 0;
  end

  // -------------------------------------------------------------------
  // Reset
  // -------------------------------------------------------------------
  initial begin
    rst_i     = 1;
    rst_cpu_i = 1;

    repeat (10) @(posedge clk);
    rst_i     = 0;
    rst_cpu_i = 0;

    repeat (RUN_CYCLES) @(posedge clk);
    $finish;
  end

  // -------------------------------------------------------------------
  // MMIO DISPLAY MONITOR (the whole point)
  // -------------------------------------------------------------------
  wire        mmio_rd   = u_dut.u_perf_mmio.core_rd_i;
  wire [3:0]  mmio_wr   = u_dut.u_perf_mmio.core_wr_i;
  wire [31:0] mmio_addr = u_dut.u_perf_mmio.core_addr_i;
  wire [31:0] mmio_wdat = u_dut.u_perf_mmio.core_data_wr_i;

  wire        mmio_acc  = u_dut.u_perf_mmio.core_accept_o;
  wire        mmio_ack  = u_dut.u_perf_mmio.core_ack_o;
  wire [31:0] mmio_rdat = u_dut.u_perf_mmio.core_data_rd_o;

  function automatic bit is_mmio(input logic [31:0] a);
    return (a >= MMIO_LO && a <= MMIO_HI);
  endfunction

  always @(posedge clk) begin
  if (rst_i) begin
    rd_pending <= 1'b0;
  end
  else begin
    // READ accepted
    if (mmio_acc && mmio_rd && is_mmio(mmio_addr)) begin
      rd_pending      <= 1'b1;
      rd_addr_latched <= mmio_addr;
      $display("[%0t] MMIO READ  addr=0x%08h", $time, mmio_addr);
    end

    // WRITE accepted
    if (mmio_acc && (mmio_wr != 4'b0000) && is_mmio(mmio_addr)) begin
      $display("[%0t] MMIO WRITE addr=0x%08h wdata=0x%08h ; %0d",
               $time, mmio_addr, mmio_wdat, mmio_wdat);
    end

    // READ response
    if (mmio_ack && rd_pending) begin
      $display("[%0t] MMIO RDATA addr=0x%08h rdata=0x%08h ; %0d",
               $time, rd_addr_latched, mmio_rdat, mmio_rdat);
      rd_pending <= 1'b0;
    end
  end
end


endmodule

