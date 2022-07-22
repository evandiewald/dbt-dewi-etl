WITH second AS (
    WITH first AS (
        SELECT
			type,
        	fields->'state_channel'->'summaries' AS "sums",
        	to_timestamp(time) AS "time"
        FROM {{ source('etl', 'transactions') }}
        WHERE (type = CAST('state_channel_close_v1' AS "transaction_type"))
        LIMIT 1048576
    )
    SELECT
        "first"."sums" AS "summaries", date_trunc('day',"time") as "time"
    FROM "first"
)
SELECT
	second.time as "time",
  ((json_array_elements(to_json(second.summaries))->>'owner')) as "owner",
  ((json_array_elements(to_json(second.summaries))->>'client')) as "client",
  ((json_array_elements(to_json(second.summaries))->>'location')) as "location",
  ((json_array_elements(to_json(second.summaries))->>'num_dcs')::int) as "dcs",
  ((json_array_elements(to_json(second.summaries))->>'num_packets')::int) as "packets"
FROM second