select
  *
from
  gringotts.expenses
where
  is_paid = false
  and schedule_to_pay_at < date_trunc('month',(now()+'1 month'::interval))
order by
  created_at desc

-- update
--   gringotts.expenses
-- set
--   is_paid = true
-- where
--   id = '8b8077fa-5a7d-40b5-a82f-ed5d0c90c5d6'
