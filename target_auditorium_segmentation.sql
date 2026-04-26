--1st, 2nd, 3rd

with segment_1 as (

select 
x.user_id, x.firstname, x.lastname, x.email, x.company, x.periods, x.class, x.subscribed_at, x.sponsorship
from aze.dm_subscription_report x
where x.status in (1,5)
and x.periods = 'Monthly'
and  x.subscribed_at + interval '1 month' between current_date and '2026-05-31'
and x.class in ('Plus', 'Standard')


union all

select 
x.user_id, x.firstname, x.lastname, x.email, x.company, x.periods, x.class, x.subscribed_at, x.sponsorship
from aze.dm_subscription_report x
where x.status in (1,5)
and x.periods = 'Annual'
and  x.subscribed_at + interval '1 year' between current_date and '2026-05-31'
and x.class in ('Plus', 'Standard')
),




std_plus as (
select x.user_id,x.subscription_id  from aze.dm_subscription_report x
where x.status in (1,5)
and x.canceled_at is null
and x.class in ('Standard', 'Plus')
),


active_180 as (
select distinct a.user_id, a.firstname, a.lastname, a.phone, a.email, a.company_id 
from aze.dm_user_app_activity a 
inner join std_plus s on a.user_id = s.user_id
where action='user-qr-read'
and visit_day between current_date - interval '180 days' and current_date
),




segment_2 as (
select mm.* from active_180 mm
where mm.user_id not in 
(select distinct a.user_id from aze.dm_user_app_activity a 
where a.visit_day between current_date - interval '30 days' and current_date
and a.action= 'user-qr-read'
 )
 )



 select 
 distinct a.user_id, a.firstname, a.lastname, a.phone, a.email, a.company_id 
 
 from aze.dm_user_app_activity a
 inner join aze.dm_subscription_report rr on a.subscription_id = rr.subscription_id
 and rr.class in ('Standard', 'Plus')
 
 where a.user_id not in (select distinct user_id from segment_1)
 and a.user_id not in (select distinct user_id from segment_2)
 and a.visit_day between current_date - interval '180 days' and current_date;




--4th
select 
a.user_id, a.firstname, a.lastname, a.phone, a.email, a.company_id , max(visit_day) last_activity

from aze.dm_user_app_activity a 
inner join aze.dm_subscription_report rr on a.subscription_id = rr.subscription_id
and rr.class in ('Standard', 'Plus')
where a.action = 'user-qr-read'
group by 
a.user_id, a.firstname, a.lastname, a.phone, a.email, a.company_id 
having max(visit_day) < current_date - interval '6 months';



--5th

select a.user_id, a.firstname, a.lastname,  a.email, d.phone,  a.company_id,a.class, a.subscribed_at::date as subscribed_at 
from aze.dm_subscription_report a
inner join aze.dm_user_social_demographic d on a.user_id = d.user_id
where a.subscribed_at >= current_date - interval '60 days' 
and a.periods = 'Annual'
and a.class in ('Standard', 'Plus')



 
