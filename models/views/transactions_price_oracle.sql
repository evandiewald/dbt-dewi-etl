
SELECT
    block,
    hash,
    type,

    -- fields specific to this txn
    CAST(fields->>'fee' AS BIGINT) as fee,
    CAST(fields->>'price' AS BIGINT) as price,
    fields->>'public_key' as public_key,
    fields->>'block_height' as block_height, -- is this different from "block" above?

    to_timestamp(time) AS time
FROM
  {{ source('etl', 'transactions') }}
WHERE
  type = CAST('price_oracle_v1' AS transaction_type)