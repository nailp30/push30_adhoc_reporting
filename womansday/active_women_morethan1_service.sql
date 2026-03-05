with female_users as (
select
distinct c.*
from aze.dm_user_social_demographic c
left join aze.female_names_static f on lower(c.firstname) = f.female_name
where 
(c.gender in ('F', 'FEMALE') or
lower(c.lastname) like 'ova%' or
lower(c.lastname) like 'yeva%' or
lower(c.lastname) like 'eva%'
or f.female_name is not null
)
and coalesce(c.gender, 'X') not in ('M', 'MALE')

),
current_active as (
select r.user_id, r.subscribed_at::date as subdate from aze.dm_subscription_report r
inner join female_users u on r.user_id = u.user_id
where r.status in (1,5)
),


service_types as (
select
distinct r.user_id,
case when lower(r.service_name_en) like '%fitness%' then 'fitness'
	when lower(r.service_name_en) like '%pilates%' then 'pilates'
	when lower(r.service_name_en) like '%yoga%' then 'yoga'
	else   'else'
	end as service_usage

from aze.dm_visit_report r
inner join current_active c on r.user_id =c.user_id
and r.date_entered_at >= c.subdate
),

cnt as (
select count(user_id), user_id from service_types
group by user_id
having count(user_id)>1
)


select count(distinct user_id) from cnt
