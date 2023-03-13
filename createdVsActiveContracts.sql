select active_contract.Month, create_contract.created_contracts, active_contract.active_contracts,
    sum(create_contract.created_contracts) OVER(ORDER BY active_contract.Month ASC) as Acc_created_contract,
    sum(active_contract.active_contracts) OVER(ORDER BY active_contract.Month ASC) as Acc_active_contract
from (
    select date_trunc('month', block_time) as Month,
        count(*) as created_contracts from fantom.traces 
        where type in('create')
        group by 1) as create_contract
        
    INNER JOIN    
    (select date_trunc('month', ftrace.block_time) as Month,
        count(distinct ftrace.address) as active_contracts
        from fantom.traces ftrace
        INNER JOIN fantom.transactions ftrx
        On ftrace.address = ftrx.to
        group by 1) as active_contract
    ON create_contract.Month = active_contract.Month
         