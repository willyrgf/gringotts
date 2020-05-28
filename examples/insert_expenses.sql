insert into
  expenses (
    wallet,
    label,
    value,
    type,
    category,
    is_essential,
    is_fixed,
    billing_source,
    responsible,
    installment,
    total_installments,
    interest,
    fines,
    is_paid,
    schedule_to_pay_at,
    created_at
  )
values
  (
    'wr',
    'ps4_games',
    57.56,
    'personal',
    null,
    false,
    false,
    'cc_santander',
    'wr',
    0,
    0,
    0,
    0,
    false,
    '2020-06-15' :: timestamp,
    now()
  );

insert into
  expenses (
    wallet,
    label,
    value,
    type,
    category,
    is_essential,
    is_fixed,
    billing_source,
    responsible,
    installment,
    total_installments,
    interest,
    fines,
    is_paid,
    schedule_to_pay_at,
    created_at
  )
values
  (
    'wr',
    'energy_supply',
    297.56,
    'home',
    null,
    true,
    false,
    'direct_invoice',
    'wr',
    0,
    0,
    1.50,
    2.00,
    false,
    '2020-06-07' :: timestamp,
    now()
  );

