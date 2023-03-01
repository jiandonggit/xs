# custom_uvm_field_by_name

**Example:**

> suppose afield path is "m_cfg.chip_rm.module_rm.some_reg.FIELD"
>
> custom_uvm_field_by_name field_by_name = new ("field_by_name", m_cfg.chip_rm) ;

```
    field_by_name.write("FIELD",value) ;
    field_by_name.write("some_reg.FIELD",value) ;
    field_by_name.write("module_rm.some_reg.FIELD",value) ;
    field_by_name.write("module_rm.*.FIELD,value) ;// glob match
    field_by_name.write("FIELD",value,m_cfg.chip_rm) ;
    field_by_name.write("FIELD",value,m_cfg.chip_rm.module_rm) ;
    field_by_name.write("FIELD",value,m_cfg.chip_rm.module_rm.some_reg) ;

# custom_uvm_reg_by_name

**Example:**

> suppose a reg path is "m_cfg.chip_rm.block_rm.module_rm.some_reg"
>
> custom_uvm_reg_by_name reg_by_name = new("reg_by_name"), m_cfg.chip_rm) ;

```
    reg_by_name.write("some_reg",value) ;
    reg_by_name.write("module_rm.some_reg,value) ;
    reg_by_name.write("block_rm.module_rm.some_reg",value) ;
    reg_by_name.write("*_rm.*.some_reg,value) ; // glob match
    reg_by_name.write("some_reg,value,m_cfg.chip_rm) ;
    reg_by_name.write("some_reg,value,m_cfg.chip_rm.block_rm) ;
    reg_by_name.write("some_reg,value,m_cfg.chip_rm.block_rm.module_rm) ;
```
