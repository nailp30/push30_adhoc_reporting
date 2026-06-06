with max_sub as (
select a1.user_id, max(a1.subscribed_at) as max_subscribed_month from aze.dm_subscription_report a1
where a1.status <> 9
and a1.subscribed_at::date <= <<$enddate>>
and (case when a1.canceled_at is not null then a1.canceled_at
							else (
								(case when a1.periods = 'Monthly' then a1.subscribed_at + interval '30 days'
		   							  when a1.periods = 'Annual' then a1.subscribed_at + interval '1 year'
		   								end)
		   							) end)::date >= <<$begindate>>
group by a1.user_id


)


select
r.user_id, 
c.id as company_id,
r.firstname,
r.lastname,
sd.email,
sd.phone,
trim(c.name) as company,
r.subscribed_at,
r.sponsorship, 
r.periods, 
r.class,
r.user_payment,
r.status,
to_char(a.date_entered_at, 'YYYY-MM') as visit_month,
count(a.*) as visit_count
from aze.dm_subscription_report r
inner join max_sub ms on r.user_id = ms.user_id and r.subscribed_at = ms.max_subscribed_month
inner join aze.dm_companies c on r.company_id = c.id 
inner join aze.dm_user_social_demographic sd on r.user_id = sd.user_id
left join aze.dm_visit_report a on a.user_id=r.user_id 

and a.date_entered_at between <<$begindate>> and <<$enddate>>
--and a.date_entered_at >= r.subscribed_at
/*
and a.date_entered_at <= (case when r.canceled_at is not null then r.canceled_at
							else (
								(case when r.periods = 'Monthly' then r.subscribed_at + interval '30 days'
		   							  when r.periods = 'Annual' then r.subscribed_at + interval '1 year'
		   								end)
		   							) end)
									   */

where 

(case when r.canceled_at is not null then r.canceled_at
else (
(case when r.periods = 'Monthly' then r.subscribed_at + interval '30 days'
		   when r.periods = 'Annual' then r.subscribed_at + interval '1 year'
		   end)
		   ) end)
		   >= <<$begindate>>

and r.subscribed_at::date <= <<$enddate>>
and c.name <> 'Push30'
--and c.name = 'Azergold'
and r.status <> 9
--and r.user_id = 160
group by
r.user_id, 
c.id,
r.firstname,
r.lastname,
sd.email,
sd.phone,
c.name,
r.sponsorship, 
r.periods, 
r.class,
r.user_payment,
to_char(a.date_entered_at, 'YYYY-MM'),
r.subscribed_at,
r.status
