with block as (
    select date_trunc('day', time) as date,
        count(distinct number) as num_blocks_daily,
        sum(gas_used) as gas_used
    from fantom.blocks
    group by 1)

select date, num_blocks_daily, 
(gas_used/num_blocks_daily) as avg_gas_used,
sum(num_blocks_daily) over(ORDER by date ASC) as total_blocks
from block
    
