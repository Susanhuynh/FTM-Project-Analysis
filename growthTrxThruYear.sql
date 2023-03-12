/* Migration success :)

There are some cases such as unnest/sequence and array/json functions the migrator won't take care of for you 
(but we have examples of in the docs linked below!)

If you're still running into issues, check out the doc examples https://dune.com/docs/reference/dune-v2/query-engine/
or reach out to us in the Dune discord in the #dune-sql channel. 
 */
WITH
  year_trx AS (
    SELECT
      YEAR(
        CAST(
          SUBSTR(
            CAST(DATE_TRUNC('year', block_time) AS VARCHAR),
            1,
            10
          ) AS DATE
        )
      ) AS Year,
      COUNT(*) AS Number_of_transactions
    FROM
      fantom.transactions
    WHERE
      success = TRUE
      AND YEAR(
        CAST(
          SUBSTR(
            CAST(DATE_TRUNC('year', block_time) AS VARCHAR),
            1,
            10
          ) AS DATE
        )
      ) <= 2022
    GROUP BY
      1
    ORDER BY
      1
  )
SELECT
  Year,
  Number_of_transactions,
  (
    Number_of_transactions - LAG(Number_of_transactions) OVER (
      ORDER BY
        Year
    )
  ) / LAG(Number_of_transactions) OVER (
    ORDER BY
      Year
  ) * 100 AS Growth
FROM
  year_trx