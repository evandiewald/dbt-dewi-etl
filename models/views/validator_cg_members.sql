
select actor as address,
count(actor_role) as cg_count
from {{ source('etl', 'transaction_actors') }}
where actor_role = 'consensus_member'
group by actor