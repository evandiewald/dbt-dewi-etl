
SELECT
    block,
    hash,
    type,

    -- fields specific to this txn
    fields->>'buyer' as buyer,
    fields->>'seller' as seller,
    fields->>'gateway' as gateway,
    CAST(fields->>'buyer_nonce' AS INT) as buyer_nonce,
    CAST(fields->>'amount_to_seller' AS BIGINT) as amount_to_seller,

    to_timestamp(time) AS time
FROM
  {{ source('etl', 'transactions') }}
WHERE
  type = CAST('transfer_hotspot_v1' AS transaction_type)

