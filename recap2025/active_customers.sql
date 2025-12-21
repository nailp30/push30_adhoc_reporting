with customer_base as (
select 
'KAZ' as country,
s.user_id, s.email, d.phone, s.company,s.company_id,
case when s.status = 1 then 'active'
when s.status = 5 then 'scheduled to cancel'
end as status,
md5(d.user_id||d.device_id||d.client_token||d.ip||d.visit_date) as visit_token,
d.partner_id
from kaz.dm_subscription_report s
left join kaz.dm_user_app_activity d on s.user_id = d.user_id
and d.action = 'user-qr-read'
and d.visit_date between '2025-01-01'::timestamp and '2025-12-31'::timestamp
where s.status in (1,5)
and s.subscribed_at between '2025-01-01'::timestamp and '2025-12-31'::timestamp
)

select distinct country, user_id, email, phone,company, status,
count (visit_token) as total_checkin,
count(distinct partner_id) as visited_distinct_gyms
from customer_base 
where lower(company) not like '%gift%' and company <> 'push30'
group  by country, user_id, email, phone,company, status
order by user_id

-- Change schema to required country(AZE, UZB, KAZ)
