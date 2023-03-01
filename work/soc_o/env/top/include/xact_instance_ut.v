/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_instance_ut.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 10:40:32
 * Description: 
 * 
 */

`ifndef __XACT_INSTANCE_UT_V__
`define __XACT_INSTANCE_UT_V__

`AHB_MASTER_INSTANTION(0, 1)
`AHB_XACT_INTF_INSTANTION(0, 1)

`AXI_MASTER_VIP_INSTANTION(0, _m0)
`AXI_XACT_INTF_INSTANTION(0, _m0, 0)

`AXI_MASTER_VIP_INSTANTION(0, _m1)
`AXI_XACT_INTF_INSTANTION(0, _m1, 1)

`AXI_MASTER_VIP_INSTANTION(0, _m2)
`AXI_XACT_INTF_INSTANTION(0, _m2, 2)

`AXI_MASTER_VIP_INSTANTION(0, _m3)
`AXI_XACT_INTF_INSTANTION(0, _m3, 3)

`AXI_MASTER_VIP_INSTANTION(0, _m4)
`AXI_XACT_INTF_INSTANTION(0, _m4, 4)

`endif

// vim: et:ts=4:sw=4:ft=sverilog
