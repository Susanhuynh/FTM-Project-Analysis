with token as (
    select address, label, 10 ^ divisor as divisor 
    from (
        select contract_address as address, symbol as label, cast(decimals as numeric) as divisor
        from erc20.tokens) a),
prices as (
    select date_trunc('day', minute) as day,
    avg(price) as price,
    symbol,
    contract_address
    from prices.usd
    group by 1,3,4
),
ftm_individual_tks as (
    select date_trunc('day', TIMESTAMP) as day,
    'Fantom Anyswap Bridge' as bridge,
    token_address,
    label,
    max(amount_raw) as token_amount,
    divisor
    from erc20.token_balances tb
    left join token t on tb.token_address = t.address
    where wallet_address = '\xC564EE9f21Ed8A2d8E7e76c085740d5e4c5FaFbE'
    group by 1,2,3,4,6
),
weth_ftm as (
    select day,
        'Fantom Anyswap Bridge' as bridge,
         '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' :: bytea as token_address,
         'WETH' as label,
         SUM(transfer) over (order by day) as token_amount,
         1 as divisor
    from (
        ---outbound transfer---
        select date_trunc('day',evt_block_time) as day,
            sum(-value/1e18) as transfer
            from erc20."ERC20_evt_Transfer" 
            where contract_address = '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'-- WETH Token Address  
            and "from" = '\xC564EE9f21Ed8A2d8E7e76c085740d5e4c5FaFbE' -- Fantom Bridge Contract Address
            group by 1
        
        UNION ALL
        
        -- inbound transfer---
         select date_trunc('day', evt_block_time) as day,
            sum(value/1e18) as transfer
            from erc20."ERC20_evt_Transfer" 
            where contract_address = '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'-- WETH Token Address  
            and "from" = '\xC564EE9f21Ed8A2d8E7e76c085740d5e4c5FaFbE' -- Fantom Bridge Contract Address
            group by 1
     ) a
),

tvl_total as (
    select day,
    bridge,
    token_address,
    label,
    sum(token_amount) as token_amount,
    divisor
    from ( 
        select * from ftm_individual_tks
        UNION ALL
        select * from weth_ftm
    ) b
    group by 1,2,3,4,6
),

tvl_total_usd as (
    select tt.day,
        bridge,
        token_address,
        label,
        token_amount * p.price/divisor as token_amount_usd
        from tvl_total tt
        left join prices p on tt.day = p.day and tt.label = p.symbol
)

select day, 
    sum(token_amount_usd) as tvl
    from tvl_total_usd
    group by day
