with companylist as (
select 
c.official_name as company_name,
l.*
from aze.company_list l

left join aze.dm_companies c on l.id = c.id
),

sub_count as (
select
company_id,
sponsorship,
count(distinct user_id) as user_count
from aze.dm_subscription_report x
group by company_id, sponsorship
),


user_count as (
select x.* ,
row_number () over(partition by company_id order by user_count desc ) as rn

from sub_count x
)

select co.*, m.sponsorship from companylist co
left join user_count m on co.id = m.company_id and m.rn=1





