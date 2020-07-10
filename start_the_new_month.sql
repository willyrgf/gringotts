-- insert all expenses with installment valid to this month
insert into
  gringotts.expenses (
    wallet,
    label,
    value,
    type,
    category,
    is_essential,
    is_fixed,
    billing_source,
    installment,
    total_installments,
    interest,
    fines,
    is_paid,
    schedule_to_pay_at,
    created_at,
    responsible
  )
  (
    select
      wallet as wallet,
      label as label,
      value as value,
      type as type,
      category as category,
      is_essential as is_essential,
      is_fixed as is_fixed,
      billing_source as billing_source,
      installment + 1 as installment,
      total_installments as total_installments,
      interest as interest,
      fines as fines,
      false as is_paid,
      schedule_to_pay_at + '1 month' :: interval as schedule_to_pay_at,
      now() as created_at,
      responsible as responsible
    from
      gringotts.expenses
    where
      total_installments > installment
      and schedule_to_pay_at < date_trunc('month',(now()))
  );


-- insert all fixed expenses valid to the this month
insert into
  gringotts.expenses (
    wallet,
    label,
    value,
    type,
    category,
    is_essential,
    is_fixed,
    billing_source,
    installment,
    total_installments,
    interest,
    fines,
    is_paid,
    schedule_to_pay_at,
    created_at,
    responsible
  ) (
    select
      wallet as wallet,
      label as label,
      value as value,
      type as type,
      category as category,
      is_essential as is_essential,
      is_fixed as is_fixed,
      billing_source as billing_source,
      installment as installment,
      total_installments as total_installments,
      interest as interest,
      fines as fines,
      false as is_paid,
      schedule_to_pay_at + '1 month' :: interval as schedule_to_pay_at,
      now() as created_at,
      responsible as responsible
    from
      gringotts.expenses
    where
      is_fixed
      and total_installments = 0
      and schedule_to_pay_at < date_trunc('month',(now()))
  );
