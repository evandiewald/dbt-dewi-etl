

SELECT
    block,
    hash,
    type,

    -- fields specific to this txn
    fields->>'challenger' as challenger,
    fields->>'challenger_owner' as challenger_owner,
    fields->>'fee' as fee,
    fields->>'onion_key_hash' as onion_key_hash,
    fields->>'path' as path,
    fields->>'secret' as secret,

    to_timestamp(transactions.time) AS time
FROM
  {{ source('etl', 'transactions') }}
WHERE
  type = CAST('poc_receipts_v2' AS transaction_type)