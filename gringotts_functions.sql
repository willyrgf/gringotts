/*
The function show_scheduled_expenses, show all expenses 
between two dates, with the default:
from_date: start of the current month
to_date: end of the current month
 */
create or replace function gringotts.show_scheduled_expenses (
    from_date timestamp default date_trunc('month', (now())),
    to_date timestamp default date_trunc('month', (now()+'1 month'::interval))
)
returns table (
    id uuid,
    wallet text,
    label text,
    value numeric,
    type text,
    category text,
    billing_source text,
    responsible text,
    is_essential boolean,
    is_fixed boolean,
    installment numeric,
    total_installments numeric,
    interest numeric,
    fines numeric,
    is_paid boolean,
    schedule_to_pay_at timestamp,
    created_at timestamp
)
language plpgsql
as $$
begin
    return query (
        select
            e.id::uuid,
            e.wallet::text,
            e.label::text,
            e.value::numeric,
            e.type::text,
            e.category::text,
            e.billing_source::text,
            e.responsible::text,
            e.is_essential::boolean,
            e.is_fixed::boolean,
            e.installment::numeric,
            e.total_installments::numeric,
            e.interest::numeric,
            e.fines::numeric,
            e.is_paid::boolean,
            e.schedule_to_pay_at::timestamp,
            e.created_at::timestamp
        from
            gringotts.expenses e
        where
            true
            and e.schedule_to_pay_at >= from_date
            and e.schedule_to_pay_at < to_date
        order by
            e.schedule_to_pay_at asc
    );
end;
$$;


/*
The function show_scheduled_expenses_to_pay, show all expenses not paid
between two dates, with the default:
from_date: start of the current month
to_date: end of the current month
 */
create or replace function gringotts.show_scheduled_expenses_to_pay (
    from_date timestamp default date_trunc('month', (now())),
    to_date timestamp default date_trunc('month', (now()+'1 month'::interval))
)
returns table (
    id uuid,
    wallet text,
    label text,
    value numeric,
    type text,
    category text,
    billing_source text,
    responsible text,
    is_essential boolean,
    is_fixed boolean,
    installment numeric,
    total_installments numeric,
    interest numeric,
    fines numeric,
    is_paid boolean,
    schedule_to_pay_at timestamp,
    created_at timestamp
)
language plpgsql
as $$
begin
    return query (
        select
            e.*
        from
            gringotts.show_scheduled_expenses(from_date, to_date) e
        where
            true
            and e.is_paid = false
        order by
            e.schedule_to_pay_at asc
    );
end;
$$;

