{{
    config(
        materialized='incremental', unlogged=True
    )
}}

with data1 as
(
    SELECT      a.block, a.hash, a.time, b.value as cpath
    FROM        {{ ref('challenge_receipts') }} a, json_array_elements(a.path::json) b
    {% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    WHERE a.block > COALESCE((select max(block) from public.challenge_receipts_parsed), (select max(height) - 1440*30 from {{ source('etl', 'blocks') }}))

    {% else %}

    WHERE a.block > COALESCE((select max(block) from public.challenge_receipts_parsed), (select max(height) - 1440*30 from {{ source('etl', 'blocks') }}))

    {% endif %}
    
),
data2 as (
    select  a.block, a.hash, a.time,
        cpath::json->>'challengee' as challengee,
        cpath::json->>'receipt' as receipt,
        cpath::json->>'witnesses' as witnesses
    FROM    data1 a
),
data_r1 as (
    SELECT  block, hash, time, challengee,
            receipt::json->>'gateway' as challengee_gateway,
            receipt::json->>'origin' as origin
    FROM    data2
),
data_w1 as (
    SELECT  a.block, a.hash, a.challengee,
            b.value::json->>'owner' as witness_owner,
            b.value::json->>'gateway' as witness_address,
            b.value::json->>'is_valid' as witness_is_valid,
            b.value::json->>'invalid_reason' as witness_invalid_reason,
            b.value::json->>'signal' as witness_signal,
            b.value::json->>'snr' as witness_snr,
            b.value::json->>'channel' as witness_channel,
            b.value::json->>'datarate' as witness_sf,
            b.value::json->>'frequency' as witness_frequency,
            b.value::json->>'location' as witness_location,
            b.value::json->>'timestamp' as witness_timestamp
    from    data2 a, json_array_elements(a.witnesses::json) b
),
hotspot1 as (
    select  address, name
    from    gateway_inventory
)

select  a.block, a.hash, a.time, h.name as transmitter_name, a.challengee_gateway as transmitter_address, a.origin,
        b.witness_owner, wt.name as witness_name, b.witness_address, COALESCE(b.witness_is_valid, 'No Witness') as witness_is_valid,
        b.witness_invalid_reason, b.witness_signal, b.witness_snr, b.witness_channel, b.witness_sf, b.witness_frequency,
        b.witness_location, b.witness_timestamp
from    data_r1 a
join    hotspot1 h
    on  a.challengee_gateway = h.address
left join    data_w1 b
    on  a.block = b.block
    and a.hash = b.hash
    and a.challengee = b.challengee
left join   gateway_inventory wt
    on  b.witness_address = wt.address