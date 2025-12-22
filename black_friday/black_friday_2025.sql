


with black_friday as (
select 
r.user_id, 
r.email,
r.sponsorship,
r.class,
r.subscribed_at, 
r.annual_discount

from aze.dm_subscription_report r
where r.subscribed_at between '2025-11-12'::timestamp and '2025-11-28'::timestamp
and r.periods = 'Annual'
and r.class in ('Standard', 'Plus')
and r.annual_discount = 40
and coalesce(lower(r.company), '-') not like '%gift%'
and r.company_id not in (24,30,2403)
and coalesce(r.promo_code, '-') <> 'PROMO50'

union all 

select 
r.user_id, 
r.email,
r.sponsorship,
r.class,
r.subscribed_at, 
50.00 as annual_discount

from aze.dm_subscription_report r
where r.subscribed_at between '2025-11-26'::timestamp and '2025-12-10'::timestamp
and r.periods = 'Annual'
and r.class in ('Standard', 'Plus')
and coalesce(lower(r.company), '-') not like '%gift%'
and r.company_id not in (24,30,2403)
and r.promo_code = 'PROMO50'

),

prev_subs as (
select 
rr.user_id, 
max(
case when rr.canceled_at is not null then rr.canceled_at
else (case when rr.periods = 'Monthly' then rr.subscribed_at + interval '1 Month'
		   when rr.periods = 'Annual'  then rr.subscribed_at + interval '1 Year' 
		   end
		   ) 
end) as last_subscription_end 






from aze.dm_subscription_report rr 
inner join black_friday bf on rr.user_id = bf.user_id
and rr.subscribed_at < bf.subscribed_at
where
 coalesce(lower(rr.company), '-') not like '%gift%'
and rr.company_id not in (24,30,2403)
group by rr.user_id

)

select bf.*, 
ps.last_subscription_end,
case when ps.last_subscription_end is null then 'New user'
	 when extract(DAY FROM (bf.subscribed_at - ps.last_subscription_end)) >= 72 then 'Churn back'
	 when extract(DAY FROM (bf.subscribed_at - ps.last_subscription_end)) < 72 then 'Renewal'
	 end as customer_type 
from black_friday bf
left join prev_subs ps on bf.user_id =ps.user_id
order by bf.subscribed_at asc
