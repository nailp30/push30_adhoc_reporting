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

)
