# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "version": "0.1",
        "confs": [
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 4,
            },
            {
                "name": "IBEX_ADDR_W",
                "descr": "IBEX address bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "IBEX_DATA_W",
                "descr": "IBEX data bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "IBEX_INTG_DATA_W",
                "descr": "IBEX parity data bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 7,
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "descr": "Clock, clock enable and reset",
                "signals": {"type": "clk_en_rst"},
            },
            {
                "name": "rst_i",
                "descr": "Synchronous reset",
                "signals": [
                    {
                        "name": "rst_i",
                        "descr": "CPU synchronous reset",
                        "width": "1",
                    },
                ],
            },
            {
                "name": "i_bus_m",
                "descr": "iob-picorv32 instruction bus",
                "signals": {
                    "type": "axi",
                    "prefix": "ibus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W - 2",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
            {
                "name": "d_bus_m",
                "descr": "iob-picorv32 data bus",
                "signals": {
                    "type": "axi",
                    "prefix": "dbus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W - 2",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
        ],
        "wires": [
            {
                "name": "cpu_reset",
                "descr": "cpu reset signal",
                "signals": [
                    {"name": "cpu_reset", "width": "1"},
                ],
            },
            {
                "name": "data_",
                "descr": "IBEX data bus signals",
                "signals": [
                    {"name": "data_req_o", "width": "1"},
                    {"name": "data_we_o", "width": "1"},
                    {"name": "data_be_o", "width": "4"},
                    {"name": "data_addr_o", "width": IBEX_ADDR_W},
                    {"name": "data_wdata_o", "width": IBEX_DATA_W},
                    {"name": "data_wdata_intg_o", "width": IBEX_INTG_DATA_W},
                    {"name": "data_gnt_i", "width": "1"},
                    {"name": "data_rvalid_i", "width": "1"},
                    {"name": "data_rdata_i", "width": IBEX_DATA_W},
                    {"name": "data_rdata_intg_i", "width": IBEX_INTG_DATA_W},
                    {"name": "data_err_i", "width": "1"},
                ],
            },
            {
                "name": "instr_",
                "descr": "IBEX instruction bus signals",
                "signals": [
                    {"name": "instr_req_o", "width": "1"},
                    {"name": "instr_gnt_i", "width": "1"},
                    {"name": "instr_addr_o", "width": IBEX_ADDR_W},
                    {"name": "instr_rvalid_i", "width": "1"},
                    {"name": "instr_rdata_i", "width": IBEX_DATA_W},
                    {"name": "instr_rdata_intg_i", "width": IBEX_INTG_DATA_W},
                    {"name": "instr_err_i", "width": "1"},
                ],
            },
        ],
        "blocks": [],
        "snippets": [
            {
                "verilog_code": """

`include "prim_assert.sv"

/*
 * AXI to Ibex LSU Protocol
 */

 // Data Bus
 iob_ibex2axi_ff #(
  .AXI_ID_W         (AXI_ID_W),
  .AXI_ADDR_W       (AXI_ADDR_W),
  .AXI_DATA_W       (AXI_DATA_W),
  .AXI_LEN_W        (AXI_LEN_W),
  .IBEX_ADDR_W      (IBEX_ADDR_W),
  .IBEX_DATA_W      (IBEX_DATA_W),
  .IBEX_INTG_DATA_W (IBEX_INTG_DATA_W)
) data_iob2ibex (

  // IBEX Ports
  .ibex_req_i       (data_req_o), // Request - LSU requests access to the memory
  .ibex_we_i        (data_we_o),  // Write enable: 1 = write, 0 = read
  .ibex_be_i        (data_be_o),  // Byte enable - Refers which bytes to access. Allows half-word, etc
  .ibex_addr_i      (data_addr_o), // Address from the LSU
  .ibex_wdata_i     (data_wdata_o), // Write data
  .ibex_wdata_intg_i(data_wdata_intg_o), // Extra parity/integrity bits

  .ibex_gnt_o       (data_gnt_i), // Access Granted signal from memory
  .ibex_rvalid_o    (data_rvalid_i), // Read data valid - There's data in rdata and/or err
  .ibex_rdata_o     (data_rdata_i), // Read data output
  .ibex_rdata_intg_o(data_rdata_intg_i), // Integrity-protected read data
  .ibex_err_o       (data_err_i), // Error signal for LSU

  // AXI Ports
  // AW Channel
  .awready_i        (dbus_axi_awready_i),
  .awvalid_o        (dbus_axi_awvalid_o), //It's an output because CPU sends the Addr
  .awaddr_o         (dbus_axi_awaddr_o),
  .awprot_o         (dbus_axi_awprot_o), 
  .awid_o           (dbus_axi_awid_o),
  .awlen_o          (dbus_axi_awlen_o),
  .awsize_o         (dbus_axi_awsize_o),
  .awburst_o        (dbus_axi_awburst_o),
  .awlock_o         (dbus_axi_awlock_o),
  .awcache_o        (dbus_axi_awcache_o),
  .awqos_o          (dbus_axi_awqos_o),

  // W Channel
  .wready_i         (dbus_axi_wready_i),
  .wvalid_o         (dbus_axi_wvalid_o), //It's an output because CPU sends the Data
  .wdata_o          (dbus_axi_wdata_o),
  .wstrb_o          (dbus_axi_wstrb_o),
  .wlast_o          (dbus_axi_wlast_o),

  // B Channel
  .bvalid_i         (dbus_axi_bvalid_i),
  .bresp_i          (dbus_axi_bresp_i),
  .bid_i            (dbus_axi_bid_i), 
  .bready_o         (dbus_axi_bready_o), //It's an input because Memory answers

  // AR Channel
  .arready_i        (dbus_axi_arready_i),
  .arvalid_o        (dbus_axi_arvalid_o), //It's an output because CPU sends the Addr
  .araddr_o         (dbus_axi_araddr_o),
  .arprot_o         (dbus_axi_arprot_o),
  .arid_o           (dbus_axi_arid_o),
  .arlen_o          (dbus_axi_arlen_o),
  .arsize_o         (dbus_axi_arsize_o),
  .arburst_o        (dbus_axi_arburst_o),
  .arlock_o         (dbus_axi_arlock_o),
  .arcache_o        (dbus_axi_arcache_o),
  .arqos_o          (dbus_axi_arqos_o),

  // R Channel
  .rvalid_i         (dbus_axi_rvalid_i), //It's an input because Memory sends the Data
  .rdata_i          (dbus_axi_rdata_i),
  .rresp_i          (dbus_axi_rresp_i),
  .rid_i            (dbus_axi_rid_i),
  .rlast_i          (dbus_axi_rlast_i),
  .rready_o         (dbus_axi_rready_o) 
);

// Instruction Bus
 iob_ibex2axi_ff #(
  .AXI_ID_W         (AXI_ID_W),
  .AXI_ADDR_W       (AXI_ADDR_W),
  .AXI_DATA_W       (AXI_DATA_W),
  .AXI_LEN_W        (AXI_LEN_W),
  .IBEX_ADDR_W      (IBEX_ADDR_W),
  .IBEX_DATA_W      (IBEX_DATA_W),
  .IBEX_INTG_DATA_W (IBEX_INTG_DATA_W)
) instr_iob2ibex (

  // IBEX Ports
  .ibex_req_i       (instr_req_o), // Request - LSU requests access to the memory
  .ibex_we_i        ('b0),  // Write enable: 1 = write, 0 = read
  .ibex_be_i        ('b0),  // Byte enable - Refers which bytes to access. Allows half-word, etc
  .ibex_addr_i      (instr_addr_o), // Address from the LSU
  .ibex_wdata_i     ('b0), // Write data
  .ibex_wdata_intg_i('b0), // Extra parity/integrity bits

  .ibex_gnt_o       (instr_gnt_i), // Access Granted signal from memory
  .ibex_rvalid_o    (instr_rvalid_i), // Read data valid - There's data in rdata and/or err
  .ibex_rdata_o     (instr_rdata_i), // Read data output
  .ibex_rdata_intg_o(instr_rdata_intg_i), // Integrity-protected read data
  .ibex_err_o       (instr_err_i), // Error signal for LSU

  // AXI Ports
  // AW Channel
  .awready_i        ('b0),
  .awvalid_o        (), //It's an output because CPU sends the Addr
  .awaddr_o         (),
  .awprot_o         (), 
  .awid_o           (),
  .awlen_o          (),
  .awsize_o         (),
  .awburst_o        (),
  .awlock_o         (),
  .awcache_o        (),
  .awqos_o          (),

  // W Channel
  .wready_i         ('b0),
  .wvalid_o         (), //It's an output because CPU sends the Data
  .wdata_o          (),
  .wstrb_o          (),
  .wlast_o          (),

  // B Channel
  .bvalid_i         ('b0),
  .bresp_i          ('b0),
  .bid_i            ('b0), 
  .bready_o         (), //It's an input because Memory answers

  // AR Channel
  .arready_i        (ibus_axi_arready_i),
  .arvalid_o        (ibus_axi_arvalid_o), //It's an output because CPU sends the Addr
  .araddr_o         (ibus_axi_araddr_o),
  .arprot_o         (ibus_axi_arprot_o),
  .arid_o           (ibus_axi_arid_o),
  .arlen_o          (ibus_axi_arlen_o),
  .arsize_o         (ibus_axi_arsize_o),
  .arburst_o        (ibus_axi_arburst_o),
  .arlock_o         (ibus_axi_arlock_o),
  .arcache_o        (ibus_axi_arcache_o),
  .arqos_o          (ibus_axi_arqos_o),

  // R Channel
  .rvalid_i         (ibus_axi_rvalid_i), //It's an input because Memory sends the Data
  .rdata_i          (ibus_axi_rdata_i),
  .rresp_i          (ibus_axi_rresp_i),
  .rid_i            (ibus_axi_rid_i),
  .rlast_i          (ibus_axi_rlast_i),
  .rready_o         (ibus_axi_rready_o) 
);


/*
 * Some parameters' definitions
 */

  parameter bit                 SecureIbex               = 1'b0;
  parameter bit                 ICacheScramble           = 1'b0;
  parameter bit                 PMPEnable                = 1'b0;
  parameter int unsigned        PMPGranularity           = 0;
  parameter int unsigned        PMPNumRegions            = 4;
  parameter int unsigned        MHPMCounterNum           = 0;
  parameter int unsigned        MHPMCounterWidth         = 40;
  parameter bit                 RV32E                    = 1'b0;
  parameter ibex_pkg::rv32m_e   RV32M                    = ibex_pkg::RV32MNone;
  parameter ibex_pkg::rv32b_e   RV32B                    = ibex_pkg::RV32BNone;
  parameter ibex_pkg::regfile_e RegFile                  = ibex_pkg::RegFileFF;
  parameter bit                 BranchTargetALU          = 1'b0;
  parameter bit                 WritebackStage           = 1'b0;
  parameter bit                 ICache                   = 1'b0;
  parameter bit                 DbgTriggerEn             = 1'b0;
  parameter bit                 ICacheECC                = 1'b0;
  parameter bit                 BranchPredictor          = 1'b0;
  //parameter                     SRAMInitFile             = "";

/**
 * Top level module of the ibex RISC-V core
 */
ibex_top_tracing #(
      .PMPEnable        (PMPEnable         ),
      .PMPGranularity   (PMPGranularity    ),
      .PMPNumRegions    (PMPNumRegions     ),
      .MHPMCounterNum   (MHPMCounterNum    ),
      .MHPMCounterWidth (MHPMCounterWidth  ),
      .RV32E            (RV32E             ),
      .RV32M            (RV32M             ),
      .RV32B            (RV32B             ),
      .RegFile          (RegFile           ),
      .BranchTargetALU  (BranchTargetALU   ),
      .WritebackStage   (WritebackStage    ),
      .ICache           (ICache            ),
      .ICacheECC        (ICacheECC         ),
      .BranchPredictor  (BranchPredictor   ),
      .DbgTriggerEn     (DbgTriggerEn      ),
      .SecureIbex       (SecureIbex        ),
      .ICacheScramble   (ICacheScramble    ),
      .DmHaltAddr       (32'h00000000      ),
      .DmExceptionAddr  (32'h00000000      )
    ) u_top (
      .clk_i                  (clk_sys              ),
      .rst_ni                 (cpu_reset            ),

      .test_en_i              ('b0                  ),
      .scan_rst_ni            (1'b1                 ),
      .ram_cfg_i              ('b0                  ),

      .hart_id_i              (32'b0                ),
      // First instruction executed is at 0x0 + 0x80
      .boot_addr_i            (32'h00000000         ),

      // Instruction memory interface
     .instr_req_o          (instr_req_o),
     .instr_gnt_i          (instr_gnt_i),
     .instr_rvalid_i       (instr_rvalid_i),
     .instr_addr_o         (instr_addr_o),
     .instr_rdata_i        (instr_rdata_i),
     .instr_rdata_intg_i   (instr_rdata_intg_i),
     .instr_err_i          (instr_err_i),

    // Data memory interface
     .data_req_o           (data_req_o),
     .data_gnt_i           (data_gnt_i),
     .data_rvalid_i        (data_rvalid_i),
     .data_we_o            (data_we_o),
     .data_be_o            (data_be_o),
     .data_addr_o          (data_addr_o),
     .data_wdata_o         (data_wdata_o),
     .data_wdata_intg_o    (data_wdata_intg_o),
     .data_rdata_i         (data_rdata_i),
     .data_rdata_intg_i    (data_rdata_intg_i),
     .data_err_i           (data_err_i),

      .irq_software_i         (1'b0                 ),
      .irq_timer_i            (1'b0                 ),
      .irq_external_i         (1'b0                 ),
      .irq_fast_i             (15'b0                ),
      .irq_nm_i               (1'b0                 ),

      .scramble_key_valid_i   ('0                   ),
      .scramble_key_i         ('0                   ),
      .scramble_nonce_i       ('0                   ),
      .scramble_req_o         (                     ),

      .debug_req_i            ('b0                  ),
      .crash_dump_o           (                     ),
      .double_fault_seen_o    (                     ),

      .fetch_enable_i         (ibex_pkg::IbexMuBiOn ),
      .alert_minor_o          (                     ),
      .alert_major_internal_o (                     ),
      .alert_major_bus_o      (                     ),
      .core_sleep_o           (                     )
    );

    
   assign cpu_reset = rst_i | arst_i;

   assign ibus_axi_awvalid_o = 1'b0;
   assign ibus_axi_awaddr_o = {AXI_ADDR_W-2{1'b0}};
   assign ibus_axi_awid_o = 1'b0;
   assign ibus_axi_awlen_o = {AXI_LEN_W{1'b0}};
   assign ibus_axi_awsize_o = {3{1'b0}};
   assign ibus_axi_awburst_o = {2{1'b0}};
   assign ibus_axi_awlock_o = 1'b0;
   assign ibus_axi_awcache_o = {4{1'b0}};
   assign ibus_axi_awqos_o = {4{1'b0}};
   assign ibus_axi_awprot_o = {3{1'b0}};
   assign ibus_axi_wvalid_o = 1'b0;
   assign ibus_axi_wdata_o = {AXI_DATA_W{1'b0}};
   assign ibus_axi_wstrb_o = {AXI_DATA_W / 8{1'b0}};
   assign ibus_axi_wlast_o = 1'b0;
   assign ibus_axi_bready_o = 1'b0;


"""
            }
        ],
    }

    return attributes_dict
