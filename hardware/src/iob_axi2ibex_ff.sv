module iob_ibex2axi_ff #(
  parameter AXI_ID_W         = 0,
  parameter AXI_ADDR_W       = 0,
  parameter AXI_DATA_W       = 0,
  parameter AXI_LEN_W        = 0,
  parameter IBEX_ADDR_W      = 0,
  parameter IBEX_DATA_W      = 0,
  parameter IBEX_INTG_DATA_W = 0
) (

  // IBEX Ports
  input logic                            ibex_req_i, // Request - LSU requests access to the memory
  input logic                            ibex_we_i,  // Write enable: 1 = write, 0 = read
  input logic [3:0]                      ibex_be_i,  // Byte enable - Refers which bytes to access. Allows half-word, etc
  input logic [IBEX_ADDR_W -1:0]         ibex_addr_i, // Address from the LSU
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
  output logic [AXI_ADDR_W-2:0] awaddr_o,
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
  output logic                bready_o, //It's an input because Memory answers

  // AR Channel
  input                       arready_i,
  output logic                arvalid_o, //It's an output because CPU sends the Addr
  output logic [AXI_ADDR_W-2:0] araddr_o,
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

  // Internal signals
  logic req_granted;
  logic read_request;
  logic write_request;
  
  // LSU Protocol: LSU sends requests through 'ibex_req_i', specifying read/write with 'ibex_we_i'.
  // The load-store unit (LSU) interacts with memory, sending addresses and data, and expects
  // acknowledgment signals such as 'ibex_gnt_o' (grant) and 'ibex_rvalid_o' (data valid).

  assign read_request  = ibex_ & ~ibex_we_i;
  assign write_request = ibex_req_i & ibex_we_i;

  //--------------------- Write Address Channel ----------------------
  // Handles the address phase of write transactions on the AW channel.
  always_ff @(posedge ibex_req_i or posedge awready_i) begin
    if (write_request) begin
      awvalid_o <= 1'b1;
      awaddr_o  <= ibex_addr_i;
    end
    if (awready_i) awvalid_o <= 1'b0; // Handshake complete
  end

  //--------------------- Write Data Channel -------------------------
  // Transfers write data and byte enables on the W channel.
  always_ff @(posedge ibex_req_i or posedge wready_i) begin
    if (write_request) begin
      wvalid_o <= 1'b1;
      wdata_o  <= ibex_wdata_i;
      wstrb_o  <= ibex_be_i; // Byte enables
      wlast_o  <= 1'b1; // Single beat transaction
    end
    if (wready_i) wvalid_o <= 1'b0; // Handshake complete
  end

  //--------------------- Write Response Channel ---------------------
  // Monitors the write response (B channel) and detects errors.
  always_ff @(posedge bvalid_i) begin
    if (bvalid_i) begin
      bready_o <= 1'b1;
      ibex_err_o    <= (bresp_i != 2'b00); // AXI error check
    end else begin
      bready_o <= 1'b0;
    end
  end

  //--------------------- Read Address Channel -----------------------
  // Handles the address phase of read transactions on the AR channel.
  always_ff @(posedge ibex_req_i or posedge arready_i) begin
    if (read_request) begin
      arvalid_o <= 1'b1;
      araddr_o  <= ibex_addr_i;
    end
    if (arready_i) arvalid_o <= 1'b0; // Handshake complete
  end

  //--------------------- Read Data Channel --------------------------
  // Receives read data (R channel) and detects errors.
  always_ff @(posedge rvalid_i) begin
    if (rvalid_i) begin
      rready_o <= 1'b1;
      ibex_rdata_o  <= rdata_i; // Read data
      ibex_err_o    <= (rresp_i != 2'b00); // AXI error check
      ibex_rvalid_o <= 1'b1; // Signal IBEX with valid data
    end else begin
      rready_o <= 1'b0;
      ibex_rvalid_o <= 1'b0;
    end
  end

  //---------------------- Grant Logic --------------------------------
  // Generates the grant signal when AW or AR channels are ready.
  always_comb begin
    ibex_gnt_o = ibex_req_i & (awready_i | arready_i);
  end

  
  ibex_err_o = (bvalid_i && bresp_i != 2'b00) || (rvalid_i && rresp_i != 2'b00);

  //--------------------- Non-Implemented Ports -----------------------
  // Default assignments for unused AXI signals.
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

endmodule