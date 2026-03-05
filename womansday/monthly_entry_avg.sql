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

monthly as (
select count(*) as cnt, c.month from aze.dm_visit_report r
inner join female_users f on r.user_id = f.user_id
inner join aze.calendar c on r.date_entered_at = c.date
where r.date_entered_at between '2025-09-01' and '2026-02-28'
group by c.month 
)

select avg(cnt) from monthly
