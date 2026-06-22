with comp_count as(
select 
count(distinct id) as company_count
from aze.dm_companies x 
where lower(name) like '%joining%'
),


subscriptions_with_jf as (
select count(distinct user_id) as subscriptions_with_jf 
from aze.dm_subscription_report x 
where lower(company) like '%joining%'
and x.subscribed_at::date between '2026-01-01' and current_date
and x.status not in (3,8,9)
),

active_users as (
select count(distinct user_id) as active_users 
from aze.dm_subscription_report x 
where lower(company) like '%joining%'
and x.subscribed_at::date between '2026-01-01' and current_date
and status in (1,4)
),






subscription_income as (
select 
sum(round(plan_price*63::numeric (10,2)/100.00,2)) as user_payment
from aze.dm_subscription_report x
where lower(company) like '%joining%'
and subscribed_at::date between '2026-01-01' and current_date
and status not in (3,8,9)
),

total_user as (
select count(distinct user_id) as total_user from aze.dm_user_social_demographic x where lower(company) like '%joining%'
)


select a.company_count, b.subscriptions_with_jf, c.user_payment, e.active_users as current_active_users, f.total_user,
round(e.active_users::numeric(10,2)/f.total_user::numeric(10,2) *100,2) as activation_rate
from comp_count a, subscriptions_with_jf b, subscription_income c, active_users e, total_user f


