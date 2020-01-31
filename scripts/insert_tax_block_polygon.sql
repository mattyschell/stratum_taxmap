-- see DDL at 
-- https://github.com/mattyschell/stratum/blob/master/src/main/sql/definition/postgresql/schema-taxmap.sql
-- Check constraints, notably st_isvalid, likely need to be dropped in the scratch
--     working database while tinkering 
delete from tax_block_polygon;
insert into tax_block_polygon (
    boro
   ,block
   ,eop_overlap_flag
   ,jagged_st_flag
   ,created_date
   ,last_modified_date
   ,section_number
   ,volume_number
   ,shape
) select 
     boro
    ,block
    ,eop_overla
    ,jagged_st_
    ,created_da
    ,last_mod_1
    ,section_nu
    ,volume_num
    ,ST_SnapToGrid(ST_SimplifyVW(shape,.1), 0,0, 1,1) 
from tax_block_polygontemp where block > 0; --at least one production garbage block, add more
select 
    'tax_block_polygon objectid ' || objectid || 
    ' is invalid because ' || ST_IsValidReason(shape) as invalidreason
from 
    tax_block_polygon
where 
    st_isvalid(shape) <> true;
-- more QA reports go here, as needed