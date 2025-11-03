// fatori_features.svh
// SPDX-License-Identifier: MIT
//
// Centralized build-time switches for Ibex security / fault-tolerance features.
//


`ifndef FATORI_FEATURES_SVH
`define FATORI_FEATURES_SVH

// -----------------------------------------------------------------------------
// Small helper: define a macro only if it’s still undefined.
// -----------------------------------------------------------------------------
`define __FTM_DEF_IF_UNDEF(name, val) \
  `ifndef name \
    `define name val \
  `endif

// -----------------------------------------------------------------------------
// PER-FEATURE TOGGLES (edit/add features here)
// -----------------------------------------------------------------------------
// Each feature gets a default fallback (used only if not set by groups or CLI).

// Cross-cutting MuBi guards for control paths (fetch_enable, core_busy, response acceptance)
`__FTM_DEF_IF_UNDEF(FTM_SECURE_GUARDS, 1)

// Dual-core lockstep (shadow core + compare). Big area/power, strongest FI detect.
`__FTM_DEF_IF_UNDEF(FTM_LOCKSTEP,              1)

// Data-independent timing: logic present; SW controls via cpuctrl.data_ind_timing.
`__FTM_DEF_IF_UNDEF(FTM_DATA_INDEP_TIMING,     1)

// Dummy instruction insertion: logic present; SW via cpuctrl.dummy_instr_en.
// WARNING -  RV32M != ibex_pkg::RV32MNone
`__FTM_DEF_IF_UNDEF(FTM_DUMMY_INSTR,           1)

// Bus integrity checking (checkbits alongside I/D buses).
// This one might be confusing, it switches to MemECC in the RTL
// --------------------------------------------------------------
// NOT WORKING - DO NOT TURN ON
`__FTM_DEF_IF_UNDEF(FTM_BUS_INTEGRITY,         0)
// --------------------------------------------------------------

// Register file ECC (detect-only; raises major alert).
`__FTM_DEF_IF_UNDEF(FTM_RF_ECC,                1)

// Regfile write-enable glitch detection (one-hot).
`__FTM_DEF_IF_UNDEF(FTM_RF_WE_GLITCH,          1)

// Regfile read-address glitch detection (one-hot).
`__FTM_DEF_IF_UNDEF(FTM_RF_RADDR_GLITCH,       1)

// Instruction cache ECC (if I$ present).
`__FTM_DEF_IF_UNDEF(FTM_ICACHE_ECC,            1)

// Hardened PC (sequential flow consistency check).
`__FTM_DEF_IF_UNDEF(FTM_HARDENED_PC,           1)

// Shadow CSRs (complement mirror + consistency check). Typically OFF with lockstep.
`__FTM_DEF_IF_UNDEF(FTM_SHADOW_CSRS,           1)



// -----------------------------------------------------------------------------
// Wrapped Registers MACRO
// -----------------------------------------------------------------------------



// Wrapper for usual wrapped registers
// TMR_EN_i unused
`define IOB_REG_IBEX(DATA_W_i, RST_VAL_i, TMR_EN_i, RST, EN, DIN, DOUT, PREFIX) \
  localparam int PREFIX``_DW = $bits(DOUT);                                     \
  logic [PREFIX``_DW-1:0] PREFIX``_din_raw;                                     \
  logic [PREFIX``_DW-1:0] PREFIX``_dout_raw;                                    \
  assign PREFIX``_din_raw  = DIN;                                               \
  iob_reg_ibex #(.DATA_W(PREFIX``_DW), .RST_VAL(RST_VAL_i))                     \
  PREFIX``_reg_inst (                                                           \
    .clk_i     (clk_i),                                                         \
    .cke_i     (1'b1),                                                          \
    .arst_i    (RST),                                                           \
    .en_i      (EN),                                                            \
    .rst_i     (RST),                                                           \
    .data_i    (PREFIX``_din_raw),                                              \
    .data_o    (PREFIX``_dout_raw)                                              \
  );                                                                            \
  assign DOUT = PREFIX``_dout_raw;


// Enum-safe wrapper for wrapped registers.
// ENUM_T : the enum type (e.g., dbg_cause_e)
// RST_ENUM: the enum reset literal (e.g., DBG_CAUSE_NONE)
`define IOB_REG_IBEX_ENUM(ENUM_T, RST_ENUM, RST, EN, DIN_ENUM, DOUT_ENUM, PREFIX) \
  localparam int PREFIX``_DW = $bits(ENUM_T);                                     \
  typedef logic [PREFIX``_DW-1:0] PREFIX``_raw_t;                                 \
  PREFIX``_raw_t PREFIX``_din_raw;                                                \
  PREFIX``_raw_t PREFIX``_dout_raw;                                               \
  localparam PREFIX``_raw_t PREFIX``_RST_RAW = PREFIX``_raw_t'(RST_ENUM);         \
  assign PREFIX``_din_raw = PREFIX``_raw_t'(DIN_ENUM);                            \
  iob_reg_ibex #(.DATA_W(PREFIX``_DW), .RST_VAL(PREFIX``_RST_RAW))                \
  PREFIX``_reg_inst (                                                             \
    .clk_i     (clk_i),                                                           \
    .cke_i     (1'b1),                                                            \
    .arst_i    (RST),                                                             \
    .en_i      (EN),                                                              \
    .rst_i     (RST),                                                             \
    .data_i    (PREFIX``_din_raw),                                                \
    .data_o    (PREFIX``_dout_raw)                                             \
  );                                                                              \
  assign DOUT_ENUM = ENUM_T'(PREFIX``_dout_raw);



// -----------------------------------------------------------------------------
// Cleanup local helper
// -----------------------------------------------------------------------------
`undef __FTM_DEF_IF_UNDEF

`endif // FATORI_FEATURES_SVH
