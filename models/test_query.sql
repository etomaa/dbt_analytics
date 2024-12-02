select * from dbt-tutorial.stripe.payment
where paymentmethod LIKE '%credit_card%'
