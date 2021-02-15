# <img align="right" src="https://vignette.wikia.nocookie.net/harrypotter/images/e/e3/Potter_vault.jpg/revision/latest/scale-to-width-down/400" alt="RESTful API" title="RESTful API"> gringotts
gringotts is a pure PLpgSQL application for personal or enterprise financial management.


### INSTALLATION

#### Requirement
- PostgreSQL >= 9.5
- postgresql-contrib package

#### Download and install 
```sh
# download
git clone https://github.com/willyrgf/gringotts
cd gringotts
```
```sh
# to create the scheme and table
PGPASSWORD=postgrespass psql -Upostgresuser postgres < gringotts.sql

# to create the functions to help the usage
PGPASSWORD=postgrespass psql -Upostgresuser postgres < gringotts_functions.sql
```

### USAGE

#### Create a expense
```sql
/*
create a new expenses according the arguments passed,
all arguments can be ommited and we will use the default:
(https://github.com/willyrgf/gringotts/blob/42a855fcb0459d139894736319d12b010e57a030/gringotts_functions.sql#L271)
*/
select
  gringotts.create_expense(
    v_wallet => 'wr',
    v_label => 'digitalocean',
    v_value => 4094.28,
    v_type => 'work',
    v_category => 'company_investment',
    v_billing_source => 'cc_bank_x',
    v_responsible => 'cryp',
    v_is_essential => false,
    v_is_fixed => false,
    v_installment => 0,
    v_total_installments => 0,
    v_interest => 0,
    v_fines => 0,
    v_is_paid => false,
    v_schedule_to_pay_at => '2021-01-15'
  );
```

#### Show expenses
```sql
-- show all expenses to pay (not paid yet) in the current month
select
  *
from
  gringotts.show_scheduled_expenses_to_pay();

-- show all expenses to pay (not paid yet) between two dates
select
  *
from
  gringotts.show_scheduled_expenses_to_pay(
    v_from_date => '2021-01-01',
    v_to_date => '2021-01-15'
  );
```

```sql
-- show all expenses (paid or not) in the current month
select
  *
from
  gringotts.show_scheduled_expenses();

-- show all expenses (paid or not) between two dates
select
  *
from
  gringotts.show_scheduled_expenses(
    v_from_date => '2021-01-01',
    v_to_date => '2021-01-15'
  );
```

#### Start a new month
```sql
# brings all installmen and fixed expenses for the current month 
# this function valid repeated expenses and don't insert if then exist
select gringotts.start_new_month();
```

#### TODO
- create unique indexes to do not repeat any expense
- add currency on the expense table
- move to a migration system (using [goose](https://github.com/pressly/goose), maybe)
- add a function to copy the last expenses from label and fill with the new values
- adjust the gringotts.show_scheduled_expenses_to_pay to get all expenses to pay independent of the date and sort by the oldest schedule_to_pay_at

