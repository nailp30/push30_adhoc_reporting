with last_sub as (
select 
r.user_id,
r.subscribed_at::date as subscribed_at,
r.canceled_at::date as canceled_at,
coalesce(r.canceled_at, case when r.periods = 'Monthly' then r.subscribed_at::date + interval '30 days'
							 when r.periods = 'Annual' then r.subscribed_at::date + interval '365 days'
							 end
) as subscription_enddate,
r.periods,
r.subscription_id,
r.class,
r.user_payment,
r.budget,
r.sponsorship,
r.plan_price,
r.annual_discount,
row_number () over (partition by r.user_id order by r.subscribed_at desc) as rn
from uzb.dm_subscription_report r
where r.subscribed_at::date >= '2024-12-01'
),

active as (
select u.user_id from uzb.dm_subscription_report u where u.status in (1,5)

),



churned_users as (
select ls.* from last_sub ls
where ls.rn =1 
and not exists (select x.user_id from active x where ls.user_id = x.user_id)
and 
(case when ls.periods = 'Monthly'
then ls.subscription_enddate + interval '168 days' 
when ls.periods = 'Annual'
then ls.subscription_enddate + interval '74 days' 
end )< current_date
)


select cu.*, 
count(vr.user_id) as total_visit

from churned_users cu
left join uzb.dm_visit_report vr on cu.user_id = vr.user_id and vr.date_entered_at >= '2024-12-01'
group by 
cu.user_id,
cu.subscribed_at,
cu.canceled_at,
cu.subscription_enddate,
cu.periods,
cu.subscription_id, 
cu.class,
cu.user_payment,
cu.budget,
cu.sponsorship,
cu.plan_price,
cu.annual_discount,
cu.rn


