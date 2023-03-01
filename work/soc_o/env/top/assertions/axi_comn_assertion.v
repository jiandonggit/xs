/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_comn_assertion.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 16:25:56
 * Description: 
 * 
 */

`ifndef __AXI_COMN_ASSERTION_V__
`define __AXI_COMN_ASSERTION_V__

module axi_comn_assertion (
        aclk ,
        areset_n ,
        awvalid ,
        awaddr ,
        awlen ,
        awsize ,
        awburst ,
        awlock ,
        awcache ,
        awprot ,
        awid ,
        awsideband ,
        awready ,

        wvalid ,
        wdata ,
        wstrb ,
        wid ,
        wsideband ,
        wready ,
        wlast ,

        bvalid ,
        bresp ,
        bid ,
        bsideband ,
        bready ,

        arvalid ,
        araddr ,
        arlen ,
        arsize ,
        arburst ,
        arlock ,
        arcache ,
        arprot ,
        arid ,
        arsideband ,
        arready ,

        rvalid ,
        rdata ,
        rstrb ,
        rid ,
        rsideband ,
        rready ,
        rlast 

    );

    parameter AXI_ADDR_WIDTH        = 32 ;
    parameter AXI_LENGTH_WIDTH      = 8;
    parameter AXI_SIZE_WIDTH        = 3;
    parameter AXI_BURST_TYPE_WIDTH  = 2 ;
    parameter AXI_LOCK_WIDTH        = 2;
    parameter AXI_CACHE_WIDTH       = 4;
    parameter AXI_PROT_WIDTH        = 3;
    parameter AXI_ID_WIDTH          = 16 ;
    parameter AXI_RESP_WIDTH        = 2 ;
    parameter AXI_DATA_WIDTH        = 64 ;
    parameter AXI_QOS_WIDTH         = 4 ;

    parameter MAX_LEN = 63 ;

    logic                           awvalid ;
    logic [`AXI_ADDR_WIDTH-1:0]     awaddr ;
    logic [`AXI_LENGTH_WIDTH-1:0]   awlen ;
    logic [`AXI_SIZE_WIDTH-1:0]     awsize ;
    logic [`AXI_BURST_WIDTH-1:0]    awburst ;
    logic [`AXI_LOCK_WIDTH-1:0]     awlock ;
    logic [`AXI_CACHE_WIDTH-1:0]    awcache ;
    logic [`AXI_PROT_WIDTH-1:0]     awprot ;
    logic [`AXI_ID_WIDTH-1:0]       awid ;
    logic                           awready ;

    logic                         wvalid ;
    logic [`AXI_DATA_WIDTH-1:0]   wdata ;
    logic [`AXI_DATA_WIDTH/8-1:0] wstrb ;
    logic [`AXI_ID_WIDTH-1:0]     wid ;
    logic                         wready ;
    logic                         wlast ;

    logic                       bvalid ;
    logic [`AXI_RESP_WIDTH-1:0] bresp ;
    logic [`AXI_ID_WIDTH-1:0]   bid ;
    logic                       bready ;

    logic                           arvalid ;
    logic [`AXI_ADDR_WIDTH-1:0]     araddr ;
    logic [`AXI_LENGTH_WIDTH-1:0]   arlen ;
    logic [`AXI_SIZE_WIDTH-1:0]     arsize ;
    logic [`AXI_BURST_WIDTH-1:0]    arburst ;
    logic [`AXI_LOCK_WIDTH-1:0]     arlock ;
    logic [`AXI_CACHE_WIDTH-1:0]    arcache ;
    logic [`AXI_PROT_WIDTH-1:0]     arprot ;
    logic [`AXI_ID_WIDTH-1:0]       arid ;
    logic                           arready ;

    logic                       rvalid ;
    logic [`AXI_DATA_WIDTH-1:0] rdata ;
    logic [`AXI_ID_WIDTH-1:0]   rid ;
    logic                       rready ;
    logic                       rlast ;

    event aw_trig ;
    event ar_trig ;
    event w_trig ;

    always @(posedge aclk ) begin
        if (awvalid && awready) begin
            -> aw_trig ;
        end
    end

    always @(posedge aclk ) begin
        if (arvalid && arready) begin
            -> ar_trig ;
        end
    end

    always @(posedge aclk ) begin
        if (wvalid && wready) begin
            -> w_trig ;
        end
    end

    covergroup axi_rw_grp ( 
        bit [AXI_SIZE_WIDTH-1:0]       asize,
        bit [AXI_BURST_TYPE_WIDTH-1:0] aburst,
        bit [AXI_LENGTH_WIDTH-1:0]     alen,
        bit [AXI_ID_WIDTH-1:0]         aid,
        bit [AXI_ADDR_WIDTH-1:0]       aaddr ) ;

        option.per_instance =1 ;

        cg_asize: coverpoint asize { 
            bins valid_size [] = {0, 1, 2, 3, 4} ;
            ignore_bins others [] = {[5:$]} ;
        }
        cg_aburst: coverpoint aburst { 
            bins valid_burst [] = {0, 1, 2} ;
            ignore_bins others [] = {[3:$]} ;
        }
        cg_alen: coverpoint alen{ 
            bins valid_len [] = {0, [1:MAX_LEN-1], MAX_LEN} ;
            ignore_bins others [] = {[MAX_LEN+1:$]} ;
        }
        cg_aid: coverpoint aid { 
            bins all_zero = {0} ;
            bins all_one = { {AXI_ID_WIDTH{1'b1}} } ;
        }
        cg_aaddr: coverpoint aaddr{ 
            //bins aligned = aaddr with (item % 2**asize == 0) ;
            //bins unaligned = aaddr with (item % 2**asize != 0) ;
            //ignore_bins other[] = default ;
        }

        cross_all : cross asize, aburst, alen {
            bins valid_cross = binsof(asize) && binsof(aburst) && binsof(alen) ;
        }

        // cross_addr_size : cross addr, asize { 
        //     bins valid_cross = binsof(aaddr.aligned) && binsof(aaddr.unaligned) ;
        //     }
    endgroup

    covergroup wstrb_grp ;
        cp_strb: covergroup wstrb {
            bins all_zero = {0} ;
            //generate 
            //    for (genvar idx = 0; idx < AXI_DATA_WIDTH/8; idx ++) begin
            //        bins $sformat("unique_strb_%d", idx) = { {(AXI_DATA_WIDTH/8-idx){1'b1}},{(idx){1'b0}} } ;
            //    end
            //endgenerate
            bins others[] = default ;
        }
    endgroup

    axi_rw_grp axi_write_grp ;
    axi_rw_grp axi_read_grp ;
    wstrb_grp u_wstrb_grp ;

    initial begin
        axi_write_grp = new(.asize(awsize), .aburst(awburst), .alen(awlen), .aid(awid), .aaddr(awaddr) ) ;
        forever begin
            @(aw_trig) begin
                axi_write_grp.sample() ;
            end
        end
    end

    initial begin
        axi_read_grp = new(.asize(arsize), .aburst(arburst), .alen(arlen), .aid(arid), .aaddr(araddr) ) ;
        forever begin
            @(ar_trig) begin
                axi_read_grp.sample() ;
            end
        end
    end

    initial begin
        u_wstrb_grp = new ;
        forever begin
            @(w_trig) begin
                u_wstrb_grp.sample() ;
            end
        end
    end

    property uncontinues_ach(valid, ready) ;
        @(posedge aclk) disable iff(!areset_n) valid |-> !ready ;
    endproperty
    property continues_ach(valid, ready) ;
        @(posedge aclk) disable iff(!areset_n) valid |-> ready ;
    endproperty
    aw_uncontinus : cover property(uncontinues_ach(awvalid, awready) ) ;
    aw_continus : cover property(continues_ach(awvalid, awready) ) ;
    ar_uncontinus : cover property(uncontinues_ach(arvalid, arready) ) ;
    ar_continus : cover property(continues_ach(arvalid, arready) ) ;
    
endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
