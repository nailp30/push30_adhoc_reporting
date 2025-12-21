/*
Segment 2 – Inactive users 
Kriteriya:
2025-ci ildə ən azı 3 check-in olub
Son ayda aktivlik yoxdur 
İstənilən:
user_id
total_checkins_2025 → mesajda {X}
unique_gyms_count → mesajda {Y}
last_checkin_date
user_status = inactive
phone number
email
 

*/


with active as (
select r.user_id from kaz.dm_subscription_report r
where r.status in (1,5) 
),

dec_checkin as(
select user_id from kaz.dm_user_app_activity d 
where d.action = 'user-qr-read' and d.visit_date between '2025-12-01'::timestamp and '2025-12-31'::timestamp
),


final_set as (
select
distinct 
s.user_id,
s.email, 
so.phone,
md5(d.user_id||d.device_id||d.client_token||d.ip||d.visit_date) as visit_token,
d.visit_day,
d.partner_id
from kaz.dm_subscription_report s
inner join kaz.dm_user_app_activity d on s.user_id = d.user_id
and d.action = 'user-qr-read' and d.visit_date between '2025-01-01'::timestamp and '2025-11-30'::timestamp
inner join kaz.dm_user_social_demographic so on s.user_id = so.user_id
where not exists (select 1 from active a where s.user_id = a.user_id)
and not exists (select 1 from dec_checkin m where s.user_id = m.user_id)
--and s.company_id not in (24,30,2403) and lower(so.company) not like '%gift%'
and s.company <> 'push30'
)


select user_id, email, phone, 
count(visit_token) as total_checkin, max(visit_day) as last_checkin, 
count(distinct partner_id) as visited_distinct_partners
from final_set
group  by user_id, email, phone
having count(visit_token)>=3
order by user_id


