/*
 * Copyright 2026 EPFL
 * Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 *  
 * Info: Direct Memory Access (DMA) channel module.
 */


package x_dma_pkg;

    typedef enum logic [1:0] {
        DMA_DATA_TYPE_WORD,
        DMA_DATA_TYPE_HALF_WORD,
        DMA_DATA_TYPE_BYTE,
        DMA_DATA_TYPE_BYTE_
    } dma_data_type_t;

    typedef enum logic {
        OBI_DATA_REQ,
        OBI_WAIT_GNT
    } dma_obi_state_type_t;

    typedef enum logic [1:0] {
        WAIT_FOR_OUTSTANDING_IDLE,
        WAIT_FOR_OUTSTANDING_WAIT,
        WAIT_FOR_OUTSTANDING_COUNTER
    } dma_wait_for_state_type_t;

    //TODO this ones need their own package, but for now they are here
    typedef struct packed {
        logic pop;
        logic push;
        logic flush;
        logic [31:0] data;
    } fifo_req_t;

    typedef struct packed {
        logic empty;
        logic full;
        logic alm_full;
        logic [31:0] data;
    } fifo_rsp_t;

endpackage
