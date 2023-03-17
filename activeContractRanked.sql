with created_contract as (
    select min(block_time) as block_time,
    address 
    from fantom.traces
    where type = 'create'
    group by 2
),
active_contract as (
    select distinct ftrace.address as active_contracts
    from fantom.traces ftrace
    INNER JOIN fantom.transactions ftrxn
    on ftrxn.to = ftrace.address
),
created_active_contract as (
    select created_contract.address as created_active_contracts
    from created_contract 
    INNER JOIN active_contract
    on created_contract.address = active_contract.active_contracts
),
details as (
    select
    COALESCE(fc.namespace, cast(ft."to" as VARCHAR)) as contract,
    count(ft.hash) as num_trxn,
    count(distinct (ft."from")) as active_users,
    sum(gas_price/pow(10,18)*gas_used) as gas_used
    from fantom.transactions ft
    INNER JOIN created_active_contract cac
    on ft.to = cac.created_active_contracts
    LEFT JOIN fantom.contracts fc
    on cac.created_active_contracts = fc.address
    group by 1
    order by 2 DESC)

select concat('#', cast(Row_number() OVER (order by num_trxn DESC) as VARCHAR)) as Rank,
    contract,
    num_trxn,
    active_users,
    gas_used
    from details
    