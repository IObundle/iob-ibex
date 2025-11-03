`timescale 1ns / 1ps
`include "iob_ibex_conf.vh"
`include "prim_assert.sv"

module iob_ibex import ibex_pkg::*; #(
   parameter AXI_ID_W         = `IOB_IBEX_AXI_ID_W,
   parameter AXI_ADDR_W       = `IOB_IBEX_AXI_ADDR_W,
   parameter AXI_DATA_W       = `IOB_IBEX_AXI_DATA_W,
   parameter AXI_LEN_W        = `IOB_IBEX_AXI_LEN_W,
   parameter IBEX_ADDR_W      = AXI_ADDR_W,
   parameter IBEX_DATA_W      = AXI_DATA_W,
   parameter IBEX_INTG_DATA_W = 7
) (
   // clk_en_rst_s
   input                       clk_i,
   input                       cke_i,
   input                       arst_i,
   // rst_i
   //input                       rst_i,
   // i_bus_m
   output [AXI_ADDR_W - 2-1:0] ibus_axi_araddr_o,
   output [             3-1:0] ibus_axi_arprot_o,
   output                      ibus_axi_arvalid_o,
   input                       ibus_axi_arready_i,
   input  [    AXI_DATA_W-1:0] ibus_axi_rdata_i,
   input  [             2-1:0] ibus_axi_rresp_i,
   input                       ibus_axi_rvalid_i,
   output                      ibus_axi_rready_o,
   output [      AXI_ID_W-1:0] ibus_axi_arid_o,
   output [     AXI_LEN_W-1:0] ibus_axi_arlen_o,
   output [             3-1:0] ibus_axi_arsize_o,
   output [             2-1:0] ibus_axi_arburst_o,
   output                      ibus_axi_arlock_o,
   output [             4-1:0] ibus_axi_arcache_o,
   output [             4-1:0] ibus_axi_arqos_o,
   input  [      AXI_ID_W-1:0] ibus_axi_rid_i,
   input                       ibus_axi_rlast_i,
   output [AXI_ADDR_W - 2-1:0] ibus_axi_awaddr_o,
   output [             3-1:0] ibus_axi_awprot_o,
   output                      ibus_axi_awvalid_o,
   input                       ibus_axi_awready_i,
   output [    AXI_DATA_W-1:0] ibus_axi_wdata_o,
   output [  AXI_DATA_W/8-1:0] ibus_axi_wstrb_o,
   output                      ibus_axi_wvalid_o,
   input                       ibus_axi_wready_i,
   input  [             2-1:0] ibus_axi_bresp_i,
   input                       ibus_axi_bvalid_i,
   output                      ibus_axi_bready_o,
   output [      AXI_ID_W-1:0] ibus_axi_awid_o,
   output [     AXI_LEN_W-1:0] ibus_axi_awlen_o,
   output [             3-1:0] ibus_axi_awsize_o,
   output [             2-1:0] ibus_axi_awburst_o,
   output                      ibus_axi_awlock_o,
   output [             4-1:0] ibus_axi_awcache_o,
   output [             4-1:0] ibus_axi_awqos_o,
   output                      ibus_axi_wlast_o,
   input  [      AXI_ID_W-1:0] ibus_axi_bid_i,
   // d_bus_m
   output [AXI_ADDR_W - 2-1:0] dbus_axi_araddr_o,
   output [             3-1:0] dbus_axi_arprot_o,
   output                      dbus_axi_arvalid_o,
   input                       dbus_axi_arready_i,
   input  [    AXI_DATA_W-1:0] dbus_axi_rdata_i,
   input  [             2-1:0] dbus_axi_rresp_i,
   input                       dbus_axi_rvalid_i,
   output                      dbus_axi_rready_o,
   output [      AXI_ID_W-1:0] dbus_axi_arid_o,
   output [     AXI_LEN_W-1:0] dbus_axi_arlen_o,
   output [             3-1:0] dbus_axi_arsize_o,
   output [             2-1:0] dbus_axi_arburst_o,
   output                      dbus_axi_arlock_o,
   output [             4-1:0] dbus_axi_arcache_o,
   output [             4-1:0] dbus_axi_arqos_o,
   input  [      AXI_ID_W-1:0] dbus_axi_rid_i,
   input                       dbus_axi_rlast_i,
   output [AXI_ADDR_W - 2-1:0] dbus_axi_awaddr_o,
   output [             3-1:0] dbus_axi_awprot_o,
   output                      dbus_axi_awvalid_o,
   input                       dbus_axi_awready_i,
   output [    AXI_DATA_W-1:0] dbus_axi_wdata_o,
   output [  AXI_DATA_W/8-1:0] dbus_axi_wstrb_o,
   output                      dbus_axi_wvalid_o,
   input                       dbus_axi_wready_i,
   input  [             2-1:0] dbus_axi_bresp_i,
   input                       dbus_axi_bvalid_i,
   output                      dbus_axi_bready_o,
   output [      AXI_ID_W-1:0] dbus_axi_awid_o,
   output [     AXI_LEN_W-1:0] dbus_axi_awlen_o,
   output [             3-1:0] dbus_axi_awsize_o,
   output [             2-1:0] dbus_axi_awburst_o,
   output                      dbus_axi_awlock_o,
   output [             4-1:0] dbus_axi_awcache_o,
   output [             4-1:0] dbus_axi_awqos_o,
   output                      dbus_axi_wlast_o,
   input  [      AXI_ID_W-1:0] dbus_axi_bid_i,
   // clint_cbus_s
   input                       clint_iob_valid_i,
   input  [            14-1:0] clint_iob_addr_i,
   input  [            32-1:0] clint_iob_wdata_i,
   input  [             4-1:0] clint_iob_wstrb_i,
   output                      clint_iob_rvalid_o,
   output [            32-1:0] clint_iob_rdata_o,
   output                      clint_iob_ready_o,
   // plic_cbus_s
   input                       plic_iob_valid_i,
   input  [            20-1:0] plic_iob_addr_i,
   input  [            32-1:0] plic_iob_wdata_i,
   input  [             4-1:0] plic_iob_wstrb_i,
   output                      plic_iob_rvalid_o,
   output [            32-1:0] plic_iob_rdata_o,
   output                      plic_iob_ready_o,
   // plic_interrupts_i
   input  [            32-1:0] plic_interrupts_i
);


   // cpu_reset
   wire                        cpu_reset_neg;
   wire                        cpu_reset;
   // data_
   wire                        data_req_o;
   wire                        data_we_o;
   wire [               4-1:0] data_be_o;
   wire [     IBEX_ADDR_W-2 -1:0] data_addr_o;
   wire [     IBEX_ADDR_W -1:0] data_addr_int; //Ibex sets addr with 32bits, IOB with 30bits
   wire [     IBEX_DATA_W-1:0] data_wdata_o;
   wire [IBEX_INTG_DATA_W-1:0] data_wdata_intg_o;
   wire                        data_gnt_i;
   wire                        data_rvalid_i;
   wire [     IBEX_DATA_W-1:0] data_rdata_i;
   wire [IBEX_INTG_DATA_W-1:0] data_rdata_intg_i;
   wire                        data_err_i;
   // instr_
   wire                        instr_req_o;
   wire                        instr_gnt_i;
   wire [     IBEX_ADDR_W -2-1:0] instr_addr_o;
   wire [     IBEX_ADDR_W -1:0] instr_addr_int; //Ibex sets addr with 32bits, IOB with 30bits
   wire                        instr_rvalid_i;
   wire [     IBEX_DATA_W-1:0] instr_rdata_i;
   wire [IBEX_INTG_DATA_W-1:0] instr_rdata_intg_i;
   wire                        instr_err_i;

   // full addresses
   wire [AXI_ADDR_W -1:0] ibus_axi_araddr_o_int;
   wire [AXI_ADDR_W -1:0] ibus_axi_awaddr_o_int;
   wire [AXI_ADDR_W -1:0] dbus_axi_araddr_o_int;
   wire [AXI_ADDR_W -1:0] dbus_axi_awaddr_o_int;

   // Instruction Bus
   iob_ibex2axi #(
      .AXI_ID_W        (AXI_ID_W),
      .AXI_ADDR_W      (AXI_ADDR_W),
      .AXI_DATA_W      (AXI_DATA_W),
      .AXI_LEN_W       (AXI_LEN_W),
      .IBEX_ADDR_W     (IBEX_ADDR_W),
      .IBEX_DATA_W     (IBEX_DATA_W),
      .IBEX_INTG_DATA_W(IBEX_INTG_DATA_W)
   ) iob2ibex (

      //Control
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),


      // IBEX Data Ports
      .ibex_data_req_i(data_req_o),  // Request - LSU requests access to the memory
      .ibex_data_we_i(data_we_o),  // Write enable: 1 = write, 0 = read
      .ibex_data_be_i(data_be_o),  // Byte enable - Refers which bytes to access. Allows half-word, etc
      .ibex_data_addr_i(data_addr_o),  // Address from the LSU
      .ibex_data_wdata_i(data_wdata_o),  // Write data
      .ibex_data_wdata_intg_i(data_wdata_intg_o),  // Extra parity/integrity bits

      .ibex_data_gnt_o       (data_gnt_i),         // Access Granted signal from memory
      .ibex_data_rvalid_o    (data_rvalid_i),      // Read data valid - There's data in rdata and/or err
      .ibex_data_rdata_o     (data_rdata_i),       // Read data output
      .ibex_data_rdata_intg_o(data_rdata_intg_i),  // Integrity-protected read data
      .ibex_data_err_o       (data_err_i),         // Error signal for LSU

      // IBEX Instruction Ports
      .ibex_instr_req_i(instr_req_o),  // Request - LSU requests access to the memory
      .ibex_instr_addr_i(instr_addr_o),  // Address from the LSU

      .ibex_instr_gnt_o       (instr_gnt_i),         // Access Granted signal from memory
      .ibex_instr_rvalid_o    (instr_rvalid_i),      // Read data valid - There's data in rdata and/or err
      .ibex_instr_rdata_o     (instr_rdata_i),       // Read data output
      .ibex_instr_rdata_intg_o(instr_rdata_intg_i),  // Integrity-protected read data
      .ibex_instr_err_o       (instr_err_i),         // Error signal for LSU


      // AXI Data Ports
      // AW Channel
      .dbus_awready_i(dbus_axi_awready_i),
      .dbus_awvalid_o(dbus_axi_awvalid_o),  //It's an output because CPU sends the Addr
      .dbus_awaddr_o (dbus_axi_awaddr_o),
      .dbus_awprot_o (dbus_axi_awprot_o),
      .dbus_awid_o   (dbus_axi_awid_o),
      .dbus_awlen_o  (dbus_axi_awlen_o),
      .dbus_awsize_o (dbus_axi_awsize_o),
      .dbus_awburst_o(dbus_axi_awburst_o),
      .dbus_awlock_o (dbus_axi_awlock_o),
      .dbus_awcache_o(dbus_axi_awcache_o),
      .dbus_awqos_o  (dbus_axi_awqos_o),

      // W Channel
      .dbus_wready_i(dbus_axi_wready_i),
      .dbus_wvalid_o(dbus_axi_wvalid_o),  //It's an output because CPU sends the Data
      .dbus_wdata_o (dbus_axi_wdata_o),
      .dbus_wstrb_o (dbus_axi_wstrb_o),
      .dbus_wlast_o (dbus_axi_wlast_o),

      // B Channel
      .dbus_bvalid_i(dbus_axi_bvalid_i),
      .dbus_bresp_i (dbus_axi_bresp_i),
      .dbus_bid_i   (dbus_axi_bid_i),
      .dbus_bready_o(dbus_axi_bready_o),  //It's an input because Memory answers

      // AR Channel
      .dbus_arready_i(dbus_axi_arready_i),
      .dbus_arvalid_o(dbus_axi_arvalid_o),  //It's an output because CPU sends the Addr
      .dbus_araddr_o (dbus_axi_araddr_o),
      .dbus_arprot_o (dbus_axi_arprot_o),
      .dbus_arid_o   (dbus_axi_arid_o),
      .dbus_arlen_o  (dbus_axi_arlen_o),
      .dbus_arsize_o (dbus_axi_arsize_o),
      .dbus_arburst_o(dbus_axi_arburst_o),
      .dbus_arlock_o (dbus_axi_arlock_o),
      .dbus_arcache_o(dbus_axi_arcache_o),
      .dbus_arqos_o  (dbus_axi_arqos_o),

      // R Channel
      .dbus_rvalid_i(dbus_axi_rvalid_i),  //It's an input because Memory sends the Data
      .dbus_rdata_i (dbus_axi_rdata_i),
      .dbus_rresp_i (dbus_axi_rresp_i),
      .dbus_rid_i   (dbus_axi_rid_i),
      .dbus_rlast_i (dbus_axi_rlast_i),
      .dbus_rready_o(dbus_axi_rready_o),

      // AXI Instruction Ports
      // AR Channel
      .ibus_arready_i(ibus_axi_arready_i),
      .ibus_arvalid_o(ibus_axi_arvalid_o),  //It's an output because CPU sends the Addr
      .ibus_araddr_o (ibus_axi_araddr_o),
      .ibus_arprot_o (ibus_axi_arprot_o),
      .ibus_arid_o   (ibus_axi_arid_o),
      .ibus_arlen_o  (ibus_axi_arlen_o),
      .ibus_arsize_o (ibus_axi_arsize_o),
      .ibus_arburst_o(ibus_axi_arburst_o),
      .ibus_arlock_o (ibus_axi_arlock_o),
      .ibus_arcache_o(ibus_axi_arcache_o),
      .ibus_arqos_o  (ibus_axi_arqos_o),

      // R Channel
      .ibus_rvalid_i(ibus_axi_rvalid_i),  //It's an input because Memory sends the Data
      .ibus_rdata_i (ibus_axi_rdata_i),
      .ibus_rresp_i (ibus_axi_rresp_i),
      .ibus_rid_i   (ibus_axi_rid_i),
      .ibus_rlast_i (ibus_axi_rlast_i),
      .ibus_rready_o(ibus_axi_rready_o)
   );



   // ---- Fetch-enable (multi-bit) and optional reset request
   ibex_mubi_t  fetch_enable_core;
   logic        core_reset_req;


   /*
   * Some parameters' definitions
   */

   parameter bit RV32E = 1'b0;
   parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MNone;
   parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone;
   parameter ibex_pkg::regfile_e RegFile = ibex_pkg::RegFileFPGA;
   parameter bit BranchTargetALU = 1'b0;
   parameter bit WritebackStage = 1'b0;
   parameter bit ICache = 1'b1;
   parameter bit ICacheECC = `FTM_ICACHE_ECC;
   parameter bit ICacheScramble = 1'b0;
   parameter bit BranchPredictor = 1'b0;
   parameter bit DbgTriggerEn = 1'b1;
   parameter bit SecureIbex = 1'b1;
   parameter bit PMPEnable = 1'b1;
   parameter int unsigned PMPGranularity = 0;
   parameter int unsigned PMPNumRegions = 16;
   parameter int unsigned MHPMCounterNum = 10;
   parameter int unsigned MHPMCounterWidth = 32;
   parameter SRAMInitFile = "";

   /**
 * Top level module of the ibex RISC-V core
 */
   ibex_top #(
      .PMPEnable       (PMPEnable),
      .PMPGranularity  (PMPGranularity),
      .PMPNumRegions   (PMPNumRegions),
      .MHPMCounterNum  (MHPMCounterNum),
      .MHPMCounterWidth(MHPMCounterWidth),
      .RV32E           (RV32E),
      .RV32M           (RV32M),
      .RV32B           (RV32B),
      .RegFile         (RegFile),
      .BranchTargetALU (BranchTargetALU),
      .WritebackStage  (WritebackStage),
      .ICache          (ICache),
      .ICacheECC       (ICacheECC),
      .BranchPredictor (BranchPredictor),
      .DbgTriggerEn    (DbgTriggerEn),
      .SecureIbex      (SecureIbex),
      .ICacheScramble  (ICacheScramble),
      .DmHaltAddr      ('0),
      .DmExceptionAddr ('0)
   ) u_top (
      .clk_i     (clk_i),
      .rst_ni    (cpu_reset_neg),

      .test_en_i  ('0),
      .scan_rst_ni('1),
      .ram_cfg_i  ('0),

      .hart_id_i  ('0),
      .boot_addr_i(32'h40000000),

      // Instruction memory interface
      .instr_req_o       (instr_req_o),
      .instr_gnt_i       (instr_gnt_i),
      .instr_rvalid_i    (instr_rvalid_i),
      .instr_addr_o      (instr_addr_int),
      .instr_rdata_i     (instr_rdata_i),
      .instr_rdata_intg_i(instr_rdata_intg_i),
      .instr_err_i       (instr_err_i),

      // Data memory interface
      .data_req_o       (data_req_o),
      .data_gnt_i       (data_gnt_i),
      .data_rvalid_i    (data_rvalid_i),
      .data_we_o        (data_we_o),
      .data_be_o        (data_be_o),
      .data_addr_o      (data_addr_int),
      .data_wdata_o     (data_wdata_o),
      .data_wdata_intg_o(data_wdata_intg_o),
      .data_rdata_i     (data_rdata_i),
      .data_rdata_intg_i(data_rdata_intg_i),
      .data_err_i       (data_err_i),

      .irq_software_i('0),
      .irq_timer_i   ('0),
      .irq_external_i('0),
      .irq_fast_i    ('0),
      .irq_nm_i      ('0),

      .scramble_key_valid_i('0),
      .scramble_key_i      ('0),
      .scramble_nonce_i    ('0),
      .scramble_req_o      (),

      .debug_req_i        ('0),

      // Fetch control (input) from fault manager
      .fetch_enable_i          (fetch_enable_core),

      // Alerts (outputs) to fault manager
      .alert_minor_o           (alert_minor),
      .alert_major_internal_o  (alert_major_internal),
      .alert_major_bus_o       (alert_major_bus),
      .double_fault_seen_o     (double_fault_seen),

      // Status (outputs) to fault manager
      .core_sleep_o            (core_sleep),
      .crash_dump_o            (crash_dump)
   );


   // No manager: keep core enabled, no reset request
   assign fetch_enable_core = IbexMuBiOn;
   assign core_reset_req    = 1'b0;

   assign instr_addr_o          = instr_addr_int[31:2];
   assign data_addr_o           = data_addr_int[31:2];

   //assign cpu_reset             = (rst_i) | (arst_i);
   assign cpu_reset             = (arst_i);
   assign cpu_reset_neg         = !(cpu_reset);

   assign ibus_axi_awvalid_o    = 1'b0;
   assign ibus_axi_awaddr_o     = {AXI_ADDR_W - 2{1'b0}};
   assign ibus_axi_awid_o       = 1'b0;
   assign ibus_axi_awlen_o      = {AXI_LEN_W{1'b0}};
   assign ibus_axi_awsize_o     = {3{1'b0}};
   assign ibus_axi_awburst_o    = {2{1'b0}};
   assign ibus_axi_awlock_o     = 1'b0;
   assign ibus_axi_awcache_o    = {4{1'b0}};
   assign ibus_axi_awqos_o      = {4{1'b0}};
   assign ibus_axi_awprot_o     = {3{1'b0}};
   assign ibus_axi_wvalid_o     = 1'b0;
   assign ibus_axi_wdata_o      = {AXI_DATA_W{1'b0}};
   assign ibus_axi_wstrb_o      = {AXI_DATA_W / 8{1'b0}};
   assign ibus_axi_wlast_o      = 1'b0;
   assign ibus_axi_bready_o     = 1'b0;

   //Integrer addresses
   assign ibus_axi_araddr_o_int = {ibus_axi_araddr_o, 2'b0};
   assign ibus_axi_awaddr_o_int = {ibus_axi_awaddr_o, 2'b0};
   assign dbus_axi_araddr_o_int = {dbus_axi_araddr_o, 2'b0};
   assign dbus_axi_awaddr_o_int = {dbus_axi_awaddr_o, 2'b0};

   // Connect unused CLINT interface to zero
   assign clint_iob_rvalid_o = 1'b0;
   assign clint_iob_rdata_o = 20'b0;
   assign clint_iob_ready_o = 1'b0;
   //clint_iob_valid_i,
   //clint_iob_addr_i,
   //clint_iob_wdata_i,
   //clint_iob_wstrb_i

   // Connect unused PLIC interface to zero
   assign plic_iob_rvalid_o = 1'b0;
   assign plic_iob_rdata_o = 14'b0;
   assign plic_iob_ready_o = 1'b0;
   //plic_iob_valid_i,
   //plic_iob_addr_i,
   //plic_iob_wdata_i,
   //plic_iob_wstrb_i,






endmodule
