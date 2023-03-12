with orders as (
    SELECT
        date_trunc('month', block_time) as month, "from" as users
    FROM fantom.transactions
),
mau as (
    SELECT
        date_trunc('month', block_time) as month, COUNT(DISTINCT "from") as mau
    FROM fantom.transactions
    GROUP BY 1
),
buyer_cohort as (
    select users,
    min(month) as cohort
    from orders
    group by 1
),
cohort_agg as (
    select cohort,
    count(*) as cohort_size
    from buyer_cohort
    group by 1
),
comp_table as (
    select 
        c.cohort, c.cohort_size as new, m.mau - c.cohort_size as returning, m.mau as total_users
    from cohort_agg as c
    left join mau m on c.cohort = m.month
)
select c.cohort, c.new, c.returning, c.total_users,
    sum(new) OVER(order by cohort ASC) as Acc_new_users,
    sum(returning) OVER(order by cohort ASC) as Acc_returning_users,
    sum(total_users) OVER(order by cohort ASC) as Acc_total_users
from comp_table as c
order by cohort DESC