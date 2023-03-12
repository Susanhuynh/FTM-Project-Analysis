with transactions as (
    select date_trunc('week', block_time) as week,
        sum(case WHEN success = FALSE then 1 else 0 END) as failed_transactions,
        sum(case when success = TRUE then 1 else 0 END) as successful_transactions
        from fantom.transactions
        group by 1)

select week, failed_transactions, successful_transactions,
    sum(failed_transactions) OVER(ORDER by week ASC) as Accumulative_failed_transactions,
    sum(successful_transactions) OVER(ORDER by week ASC) as Accumulative_successful_transactions,
    sum(failed_transactions + successful_transactions) OVER(ORDER by week ASC) as Accumulative_transactions
    from transactions
    