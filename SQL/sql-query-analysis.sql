-- Query 1: KPI(key performance indicater ) Overview
SELECT 
    COUNT(txn_id)            AS total_transactions,
    SUM(txn_amount)          AS total_revenue,
    ROUND(AVG(txn_amount),2) AS avg_transaction_amount
FROM transactions
WHERE status = 'Success';

-- Query 2: monthly revenue 

select date_trunc('month',txn_date)::date as monthly_date,
round(sum(txn_amount),0) as total_revenue,
count(txn_id) as total_transaction
from transactions
where status='Success'
group by monthly_date
order by monthly_date;

-- Query 3:revenue by each product
select product,
count(txn_id) as total_transaction,
round(sum(txn_amount),0) as total_revenue
from transactions
where status ='Success'
group by product
order by total_revenue desc;


-- Query 4 :revenue by channel 
select channel,
round(sum(txn_amount),0) as total_revenue,
count(txn_id) as total_transaction
from transactions
where status='Success'
group by channel
order by total_revenue desc;

-- Query 5: Revenue breakdown by customer occupation
select c.occupation,
round(sum(t.txn_amount),0) as total_revenue,
count(t.txn_id) as total_transaction
from transactions as t 
left join customers as c 
on t.customer_id = c.customer_id
where t.status='Success'
group by c.occupation
order by total_revenue;

-- query 6 :revenue by city
select c.city,
round(sum(t.txn_amount),0) as total_revenue,
count(t.txn_id) as total_transaction
from transactions as t 
left join customers as c 
on t.customer_id = c.customer_id
where t.status='Success'
group by c.city
order by total_revenue desc;

-- Query 7:revenue by account type
select c.account_type,
round(sum(t.txn_amount),0) as total_revenue,
count(t.txn_id) as total_transaction
from transactions as t 
left join customers as c 
on t.customer_id = c.customer_id
where t.status='Success'
group by c.account_type
order by total_revenue desc;

--Query8:Loan Analysis by type and status
select loan_type,
loan_status,
count(loan_id) as total_loans,
sum(loan_amount) as total_amount,
round(avg(interest_rate),2) as avg_interest_rate
from loans
group by loan_type,loan_status
order by total_amount desc;

-- Query 9:Loan Default Risk
select case 
when missed_payments<=1 then 'low-risk'
when missed_payments between 1 and 4 then 'medium-risk'
else 'high-risk'
end as risk_level,
count(customer_id) as customer,
sum(loan_amount) as total_loan_amt
from loans
group by risk_level
order by customer ;


-- Query 10:Month over Month Growth
with month_revenue as (
select date_trunc('month',txn_date):: date as month,
sum(txn_amount) as total_revenue
from transactions
where status='Success'
group by month
)
select *,
lag(total_revenue,1) over (order by month) as previous_month_rev,
cast(((total_revenue-lag(total_revenue,1) over (order by month))/lag(total_revenue,1) over (order by month))*100 as int) as percentage_change
from month_revenue;



--Query 11: top customer by revenue 
select c.name,
sum(t.txn_amount) as total_revenue
from transactions as t
left join customers as c
on t.customer_id=c.customer_id
where t.status='Success'
group by c.name
order by total_revenue desc
limit 10;

--Query 12:RFM = Recency, Frequency, Monetary customer segmentation
select segment,
count(*) as total_customer
from(
with rfm as (
select c.name,
c.customer_id,
(select max(txn_date) from transactions)::date-max(t.txn_date)::date as recency_days,
count(t.txn_id) as frequency,
round(sum(t.txn_amount),0) as monetary
from transactions as t
left join customers  as c on
t.customer_id=c.customer_id
where status='Success'
group by c.customer_id,c.name
)

select *,
    case 
when recency_days <= 30  and frequency >= 20 and monetary >= 500000 then 'Champion'
when recency_days <= 60  and frequency >= 10 then 'Loyal'
when recency_days <= 90  then 'At Risk'
else 'Lost'
end as segment
from rfm
)
group by segment 
order by total_customer desc;