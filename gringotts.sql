drop table if exists expenses;
create table expenses (
  id uuid default uuid_generate_v4(),
  wallet text not null default 'wr',
  label text default null,
  value numeric not null,
  type text default 'not_essential',
  category text default null,
  billing_source text default 'direct_invoice',
  reponsible text default 'wr',
  is_essential boolean default false,
  is_fixed boolean default false,
  installment numeric default 0,
  total_installments numeric default 0,
  interest numeric default 0,
  fines numeric default 0,
  is_paid boolean default false,
  schedule_to_pay_at timestamp with time zone default now(),
  created_at timestamp with time zone default now(),
  primary key (id)
);
