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

/*
The function start_new_month get all fixed or installment expenses and bring
to this new month to start then
 */
create or replace function gringotts.start_new_month()
returns void
language plpgsql
as $$
begin

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
            e.wallet as wallet,
            e.label as label,
            e.value as value,
            e.type as type,
            e.category as category,
            e.is_essential as is_essential,
            e.is_fixed as is_fixed,
            e.billing_source as billing_source,
            e.installment + 1 as installment,
            e.total_installments as total_installments,
            e.interest as interest,
            e.fines as fines,
            false as is_paid,
            e.schedule_to_pay_at + '1 month' :: interval as schedule_to_pay_at,
            now() as created_at,
            e.responsible as responsible
        from
            gringotts.expenses e
        where
            true
            and e.total_installments > e.installment
            and e.schedule_to_pay_at >= date_trunc('month',(now()-'1 month'::interval))
            and e.schedule_to_pay_at < date_trunc('month',(now()))
            and not exists (
                select
                    1
                from
                    gringotts.expenses e2
                where
                    true
                    and coalesce(e2.wallet, 'none') = coalesce(e.wallet, 'none')
                    and coalesce(e2.label, 'none') = coalesce(e.label, 'none')
                    and coalesce(e2.value, 0) = coalesce(e.value, 0)
                    and coalesce(e2.type, 'none') = coalesce(e.type, 'none')
                    and coalesce(e2.category, 'none') = coalesce(e.category, 'none')
                    and coalesce(e2.billing_source, 'none') = coalesce(e.billing_source, 'none')
                    and e2.is_essential = e.is_essential
                    and e2.is_fixed = e.is_fixed
                    and e2.billing_source = e.billing_source
                    and e2.installment = e.installment + 1
                    and e2.total_installments = e.total_installments
                    and e2.interest = e.interest
                    and e2.fines = e.fines
                    and e2.schedule_to_pay_at = e.schedule_to_pay_at + '1 month'::interval
                    and e2.responsible = e.responsible
            )
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
    )
    (
        select
            e.wallet as wallet,
            e.label as label,
            e.value as value,
            e.type as type,
            e.category as category,
            e.is_essential as is_essential,
            e.is_fixed as is_fixed,
            e.billing_source as billing_source,
            e.installment as installment,
            e.total_installments as total_installments,
            e.interest as interest,
            e.fines as fines,
            false as is_paid,
            e.schedule_to_pay_at + '1 month' :: interval as schedule_to_pay_at,
            now() as created_at,
            e.responsible as responsible
        from
            gringotts.expenses e
        where
            true
            and e.schedule_to_pay_at >= date_trunc('month',(now()-'1 month'::interval))
            and e.schedule_to_pay_at < date_trunc('month',(now()))
            and e.is_fixed
            and not exists (
                select
                    1
                from
                    gringotts.expenses e2
                where
                    true
                    and coalesce(e2.wallet, 'none') = coalesce(e.wallet, 'none')
                    and coalesce(e2.label, 'none') = coalesce(e.label, 'none')
                    and coalesce(e2.value, 0) = coalesce(e.value, 0)
                    and coalesce(e2.type, 'none') = coalesce(e.type, 'none')
                    and coalesce(e2.category, 'none') = coalesce(e.category, 'none')
                    and coalesce(e2.billing_source, 'none') = coalesce(e.billing_source, 'none')
                    and e2.is_essential = e.is_essential
                    and e2.is_fixed = e.is_fixed
                    and e2.billing_source = e.billing_source
                    and e2.installment = e.installment
                    and e2.total_installments = e.total_installments
                    and e2.interest = e.interest
                    and e2.fines = e.fines
                    and e2.schedule_to_pay_at = e.schedule_to_pay_at + '1 month'::interval
                    and e2.responsible = e.responsible
            )
    );


end;
$$;

