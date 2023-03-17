with gas as (
        select date_trunc('day', block_time) as date,
            AVG(gas_price/pow(10,18)*gas_used) as avg_gas_used_ftm
            from fantom.transactions
            group by 1),
    price as (
        select date_trunc('day', minute) as date,
        max(price) as ftm_price
        from prices.usd
        where symbol = 'FTM'
        group by 1
    )
select
    avg(gas.avg_gas_used_ftm*price.ftm_price) as avg_gas_used_usd,
    avg(gas.avg_gas_used_ftm) as avg_gas_used_ftm
    from gas 
    LEFT JOIN price
    on gas.date = price.date