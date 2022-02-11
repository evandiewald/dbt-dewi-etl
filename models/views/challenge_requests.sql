
SELECT
    block,
    hash,
    type,

    -- fields specific to this txn
    fields->>'block_hash' as block_hash,
    fields->>'challenger' as challenger,
    fields->>'challenger_location' as challenger_location,
    fields->>'challenger_owner' as challenger_owner,
    CAST(fields->>'fee' AS BIGINT) as fee,
    fields->>'onion_key_hash' as onion_key_hash,
    fields->>'secret_hash' as secret_hash,
    CAST(fields->>'version' AS INT) as version,

    to_timestamp(time) AS time
FROM
  {{ source('etl', 'transactions') }}
WHERE
  type = CAST('poc_request_v1' AS transaction_type)
