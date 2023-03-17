with amt_holding as (
    select ft."from" as address,
        - cast(ft.value as DECIMAL) as amount
        from fantom.traces ft
        where success = TRUE
    UNION ALL
    select ft.to as address,
        cast (ft.value as DECIMAL) as amount
        from fantom.traces ft
        where success = TRUE),
holding as (
    select address,
        sum(amount)/pow(10,18) as holding
        from amt_holding
        group by address)
select (case when holding >= 10000000 then 'Wallets >=10M'
             when holding >= 1000000 then 'Wallets >=1M'
             when holding >= 500000 then 'Wallets >=500K'
             when holding >= 100000 then 'Wallets >=100K'
             when holding >= 1000 then 'Wallets >=1K'
             when holding >= 100 then 'Wallets >=100'
             when holding >= 10 then 'Wallets >=10'
             else 'Wallets < 1' END) as wallet_portfolio,
        count(address) as holder_count
from holding
group by 1
ORDER by 2 DESC
