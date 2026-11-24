//This is the backend for a AXI read unit.
//One channel contains both a READ unit, a WRITE unit, and a processing unit
//the read unit is responsibile for reading data from the axi bus
//after the configuration signal is provided
#include "idma_typedef.svh"

module dma_read_unit_axi
  import dma_reg_pkg::*;
  import axi_pkg::*;
    #(
    parameter int unsigned AxiDataWidth = 64,
    parameter int unsigned AxiAddrWidth = 32,
    parameter int unsigned AxiIdWidth   = 4,
    parameter type         axi_req_t    = logic,
    parameter type         axi_rsp_t    = logic,
    parameter type         idma_req_t   = logic,
    parameter type         idma_rsp_t   = logic);

    (
    input logic clk_i,
    input logic rst_ni,

    //------------------------------------------------------------------------
    // AXI bus interface (Master Read)
    //------------------------------------------------------------------------
    // AXI bus Request Master Read
    output core_v_mcu_pkg::axi_mst_req_t bus_req_o_r,  //this is a master read!
    // AXI bus response Master Read
    input  core_v_mcu_pkg::axi_mst_rsp_t bus_rsp_i_r,
    
    //to mid-end: using IDMA data structs
    // ------------------------------------------------------------------------
    // Read Unit: receives 1D read request (idma_req_t), returns 1D read response (idma_rsp_t)
    // ------------------------------------------------------------------------
    input idma_req_t              rd_req;
    input logic                   rd_req_valid;
    input logic                   rd_req_ready;

    output idma_rsp_t              rd_rsp;
    output logic                   rd_rsp_valid;
    output logic                   rd_rsp_ready;
    output logic            [63:0] memory_rdata;

    );

    //FSM state definition. Either read or IDLE. Idea is to send forward
    //memory response via idma_rsp_t as soon as it gets back from memory, without caring for the order. Mid-end will re-order/ 
    //mantain track of the reordering logic.
    enum logic {
        DMA_READ_UNIT_IDLE,
        DMA_READ_UNIT_ON_PENDING
    } dma_read_unit_state, dma_read_unit_n_state;

    // FSM state update
    always_ff @(posedge clk_i or negedge rst_ni) begin : proc_fsm_state
        if (~rst_ni) begin
        dma_read_addr_unit_state <= DMA_READ_UNIT_IDLE;
        end else begin
        dma_read_addr_unit_state <= dma_read_addr_unit_n_state;
        end
    end

    always_comb begin: proc_fsm_next_state_and_output_logic
        dma_read_addr_unit_n_state = dma_read_addr_unit_state;
        rd_rsp_valid = 1'b0;
        rd_rsp_ready = 1'b0;
        memory_rdata = '0;
        case (dma_read_addr_unit_state)
            DMA_READ_UNIT_IDLE: begin
                if (rd_req_valid) begin
                    dma_read_addr_unit_n_state = DMA_READ_UNIT_ON;
                end
            end
            DMA_READ_UNIT_ON_PENDING: begin //I issued a channel request (RID = x), still waiting for the
            //response. Ideally;i can either have N_Read unit(one for channel) that process transactions, 
            //or a single one. -> go for N_read units
            //since it allows for more parallelilsm
                if (bus_rsp_i_r.valid) begin //axi read response- obtained by demuxing the
                //axi_read_id and connecting it to the master bus
                    rd_rsp_valid = 1'b1;
                    rd_rsp_ready = 1'b1;    
                    memory_rdata = bus_rsp_i_r.rdata; //pass the data to the mid-end
                    dma_read_addr_unit_n_state = DMA_READ_UNIT_IDLE;
                end
            end
        endcase
    end

    always_comb begin: proc_AXI_read_req
        if((dma_read_addr_unit_state == DMA_READ_UNIT_ON_PENDING )) begin
            bus_req_o_r.valid = 1'b1;
            bus_req_o_r.addr = rd_req.addr;
            bus_req_o_r.len = rd_req.len;
            bus_req_o_r.size = rd_req.size;
            bus_req_o_r.burst = rd_req.burst;
            bus_req_o_r.id = rd_req.id; //pass the idma id to the axi id
        end else begin
            bus_req_o_r.valid = 1'b0;
            bus_req_o_r.addr = '0;
            bus_req_o_r.len = '0;
            bus_req_o_r.size = '0;
            bus_req_o_r.burst = '0;
            bus_req_o_r.id = '0;
        end
    end;
  
    



endmodule;


