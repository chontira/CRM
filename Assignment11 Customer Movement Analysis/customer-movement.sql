with monthly as (
SELECT distinct CUST_CODE,
 cast(SUBSTR(CAST(shop_date AS STRING),1,6) as NUMERIC) as year_month
FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES`
where cust_code is not null
order by year_month ASC),
 
monthly_next_last as (
select year_month,
  CUST_CODE, 
  lag(year_month) over(PARTITION BY CUST_CODE ORDER BY year_month ASC) as last_period,
  lead(year_month) over(PARTITION BY CUST_CODE ORDER BY year_month ASC) as next_period,
from monthly),
 
customer_movement as (
select CUST_CODE,year_month,
  case 
    when cast((year_month-last_period)-(FLOOR(year_month/100)-FLOOR(last_period/100))*88 as int64) = 1 then 'REPEAT'
    when cast((year_month-last_period)-(FLOOR(year_month/100)-FLOOR(last_period/100))*88 as int64) > 1 then 'REACTIVATED'
    when cast((year_month-last_period)-(FLOOR(year_month/100)-FLOOR(last_period/100))*88 as int64) is null then 'NEW'
  end as cust_type
from monthly_next_last
union all

select CUST_CODE,
  CAST((FLOOR(year_month/100)+(case when MOD(year_month,100) = 12 then 1 else 0 end))*100+(case when MOD(MOD(year_month+1,100),12) = 0 then 12 else MOD(MOD(year_month+1,100),12) end) as int64)  as yearmonth,
  case 
    when cast((next_period-year_month)-(FLOOR(next_period/100)-FLOOR(year_month/100))*88 as int64) > 1 then 'CHURNED' 
  end as cust_type
from monthly_next_last
where (cast((next_period-year_month)-(FLOOR(next_period/100)-FLOOR(year_month/100))*88 as int64) > 1) 
order by CUST_CODE,year_month)

select year_month,	
  cust_type, 
  case 
    when cust_type = 'CHURNED' then sum(-1) 
    else sum(1) 
  end as num_cust
from customer_movement
group by year_month,cust_type
order by year_month
