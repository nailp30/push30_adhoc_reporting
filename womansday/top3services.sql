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

service_count as (
select count(*) as cnt, lower(r.service_name_en) as service from aze.dm_visit_report r
inner join female_users f on r.user_id = f.user_id
where r.date_entered_at between current_date - interval '1 year' and current_date
group by r.service_name_en
),

usage_stat as (

select cnt,
case when service like '%fitness%' then 'fitness'
	when service like '%pilates%' then 'pilates'
	when service like '%yoga%' then 'yoga'
	else   'else'
	end as service_usage
	from service_count
	)


	select sum(cnt), service_usage from usage_stat
	group by service_usage order by 1 desc;
