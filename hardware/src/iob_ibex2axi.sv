module iob_ibex2axi #(
  parameter AXI_ID_W         = 0,
  parameter AXI_ADDR_W       = 32,
  parameter AXI_DATA_W       = 32,
  parameter AXI_LEN_W        = 8,
  parameter IBEX_ADDR_W      = 32,
  parameter IBEX_DATA_W      = 32,
  parameter IBEX_INTG_DATA_W = 7
) (

  // Genereral Ports
  input logic clk_i,
  input logic cke_i,
  input logic arst_i, 

  // IBEX Ports
  input logic                            ibex_req_i, // Request - LSU requests access to the memory
  input logic                            ibex_we_i,  // Write enable: 1 = write, 0 = read
  input logic [3:0]                      ibex_be_i,  // Byte enable - Refers which bytes to access. Allows half-word, etc
  input logic [IBEX_ADDR_W -2 -1:0]      ibex_addr_i, // Address from the LSU
  input logic [IBEX_DATA_W -1:0]         ibex_wdata_i, // Write data
  input logic [IBEX_INTG_DATA_W -1:0]    ibex_wdata_intg_i, // Extra parity/integrity bits

  output logic                            ibex_gnt_o, // Access Granted signal from memory
  output logic                            ibex_rvalid_o, // Read data valid - There's data in rdata and/or err
  output logic [IBEX_DATA_W -1:0]         ibex_rdata_o, // Read data output
  output logic [IBEX_INTG_DATA_W -1:0]    ibex_rdata_intg_o, // Integrity-protected read data
  output logic                            ibex_err_o, // Error signal for LSU

  // AXI Ports
  // AW Channel
  input                       awready_i,
  output logic                awvalid_o, //It's an output because CPU sends the Addr
  output logic [AXI_ADDR_W-2 -1:0] awaddr_o,
  output logic [2:0]          awprot_o, 
  output logic [AXI_ID_W-1:0] awid_o,
  output logic [AXI_LEN_W-1:0] awlen_o,
  output logic [2:0]          awsize_o,
  output logic [1:0]          awburst_o,
  output logic                awlock_o,
  output logic [3:0]          awcache_o,
  output logic [3:0]          awqos_o,

  // W Channel
  input                       wready_i,
  output logic                wvalid_o, //It's an output because CPU sends the Data
  output logic [AXI_DATA_W-1:0] wdata_o,
  output logic [AXI_DATA_W/8-1:0] wstrb_o,
  output logic                wlast_o,

  // B Channel
  input                       bvalid_i,
  input [1:0]                 bresp_i,
  input [AXI_ID_W-1:0]        bid_i, 
  output logic                bready_o, 

  // AR Channel
  input                       arready_i,
  output logic                arvalid_o, //It's an output because CPU sends the Addr
  output logic [AXI_ADDR_W-2-1:0] araddr_o,
  output logic [2:0]          arprot_o,
  output logic [AXI_ID_W-1:0] arid_o,
  output logic [AXI_LEN_W-1:0] arlen_o,
  output logic [2:0]          arsize_o,
  output logic [1:0]          arburst_o,
  output logic                arlock_o,
  output logic [3:0]          arcache_o,
  output logic [3:0]          arqos_o,

  // R Channel
  input                       rvalid_i, //It's an input because Memory sends the Data
  input [AXI_DATA_W-1:0]      rdata_i,
  input [1:0]                 rresp_i,
  input [AXI_ID_W-1:0]        rid_i,
  input                       rlast_i,
  output logic                rready_o 
);

  // Internal signals for stateful logic
  //AR

  //R

  //AW

  //W

  //B

  //IBEX
  wire [AXI_ADDR_W -1:0]    ibex_addr_int;
  wire [IBEX_INTG_DATA_W -1:0]    ibex_wdata_intg_wire;
  wire [IBEX_INTG_DATA_W -1:0]    ibex_rdata_intg_wire;

  assign arst_n = arst_i;

  assign ibex_addr_int = {ibex_addr_i,2'b0};
  assign ibex_wdata_intg_wire = ibex_wdata_intg_i; //not implemented
  
  
  // Assign final output 
   assign ibex_gnt_o = (arready_i & ~ibex_we_i) | (wready_i & ibex_we_i);
  //assign ibex_gnt_o = (arready_i & ~ibex_we_i) | (awready_i & wready_i & ibex_we_i);

  // WRITE Operation  
  // Ibex wants to write something
  // In AXI, a write consists in 3 steps: AW, W and then B.
  // In Ibex, it all happens at once. req_o is set, alongside the write address, write data
  // and we=1.
  // So, in terms of the AXI interface, the CPU's signals are all ready/valid
  // 
  // The main thing to take into consideration is that the granted must take into consideration
  // both arready and rvalid, and they can happen in different moments. See "Grant Logic"
  assign wstrb_o = ibex_be_i;

  assign awaddr_o = ibex_addr_i;
  assign awvalid_o = (ibex_req_i & ibex_we_i);

  assign wdata_o = ibex_wdata_i;
  assign wvalid_o  = (ibex_req_i & ibex_we_i);

  assign bready_o = (ibex_req_i & ibex_we_i);
  

  // READ Operation  
  // Ibex wants to read something
  // In AXI, a read consists in 2 steps: AR and R.
  // In Ibex, it all happens at once. req_o is set, alongside the read address, and we=0.
  // So, in terms of the AXI interface, the CPU's signals are all ready/valid
  // 
  // We have to consider that once each handshake is done, the intervening signals must be
  // turned off, or the memory will consider it a new interaction.
  //
  // The main thing to take into consideration is that the granted must take into consideration
  // both arready and rvalid, and they can happen in different moments. See "Grant Logic"
  assign arvalid_o = (ibex_req_i & ~ibex_we_i);

  assign araddr_o = ibex_addr_i;
  assign rready_o  = 1'b1;

  // IBEX rvalid, rdata and error handling
  // After the granted signal is sent, an ibex_rvalid signal should be set the next cycle, and be up for exactly 1 cycle.
  // Alongside with the ibex_rvalid signal, should go the read data or the ibex_error.

  // This ibex_rvalid signal must return to 0 if no other gnt signal was set, so that ibex_rvalid is only 1 for exactly 1 cycle.
  // In the case that there are multiple consecutive memory accesses, there will be consecutive gnt signals, and ibex_rvalid can't reset

  assign ibex_rdata_o = rdata_i;
  assign ibex_rvalid_o = rvalid_i | bvalid_i;
  assign ibex_err_o =  rvalid_i & (| rresp_i) | bvalid_i & (| bresp_i);

  assign ibex_rdata_intg_o = ibex_rdata_intg_wire; //not implemented


  // Default assignments for unused AXI signals
  assign awprot_o  = '0;
  assign awid_o    = '0;
  assign awlen_o   = '0;
  assign awsize_o  = '0;
  assign awburst_o = '0;
  assign awlock_o  = '0;
  assign awcache_o = '0;
  assign awqos_o   = '0;
  assign arprot_o  = '0;
  assign arid_o    = '0;
  assign arlen_o   = '0;
  assign arsize_o  = '0;
  assign arburst_o = '0;
  assign arlock_o  = '0;
  assign arcache_o = '0;
  assign arqos_o   = '0;
  assign wlast_o = '1;

endmodule