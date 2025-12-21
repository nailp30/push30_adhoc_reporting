with black_friday as (
select 
r.user_id, 
r.email,
r.sponsorship,
r.class,
r.subscribed_at, 
r.plan_price,
r.annual_discount

from aze.dm_subscription_report r
where r.subscribed_at between '2025-11-12'::timestamp and '2025-11-28'::timestamp
and r.periods = 'Annual'
and r.class in ('Standard', 'Plus')
and r.annual_discount = 40

union all 

select 
r.user_id, 
r.email,
r.sponsorship,
r.class,
r.subscribed_at, 
r.plan_price,
r.annual_discount

from aze.dm_subscription_report r
where r.subscribed_at between '2025-11-28'::timestamp and '2025-12-10'::timestamp
and r.periods = 'Annual'
and r.class in ('Standard', 'Plus')
and r.annual_discount = 50

),

prev_subs as (
select 
rr.user_id, max(rr.subscribed_at) as previous_subscription
from aze.dm_subscription_report rr 
inner join black_friday bf on rr.user_id = bf.user_id
and rr.subscribed_at < bf.subscribed_at
group by rr.user_id

)

select bf.*, 
ps.previous_subscription,
case when ps.previous_subscription is null then 'New user'
	 when extract(DAY FROM (bf.subscribed_at - ps.previous_subscription)) >= 72 then 'Churn back'
	 when extract(DAY FROM (bf.subscribed_at - ps.previous_subscription)) < 72 then 'Renewal'
	 end as customer_type 
from black_friday bf
left join prev_subs ps on bf.user_id =ps.user_id





