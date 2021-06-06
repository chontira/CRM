CREATE OR REPLACE MODEL
    `nida-workshop.CustomerSingleView.6210412009_CLUSTERS` OPTIONS(model_type='kmeans', num_clusters=7) 
AS (
  SELECT 
    cust_code as CustomerID,  --1
    sum(quantity) as TotalQuantity,  --2
    round(sum(spend),2) as TotalSpend,  --3
    count(distinct basket_id) as NumVisit,  --4
    round(sum(spend)/count(distinct basket_id),2) as TicketSize,  --5
    
    PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)) as LastVisit,  --6
    PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)) as FirstVisit,  --7
    date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),day)+1 as AgeofUsage_day, --8
    date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),month)+1 as AgeofUsage_month, --9
    count(distinct substr(CAST(shop_date AS STRING),0,6)) as ActiveMonth, --10
    count(distinct shop_date) as ActiveDate, --11
    round((count(distinct substr(CAST(shop_date AS STRING),0,6))/(date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),month)+1))*100,2) as PercActiveMonth,  --12
    round(count(distinct shop_date)/(date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),day)+1)*100,2) as PercActiveDay,  --13
    (date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),day)+1)/(date_diff(PARSE_DATE('%Y%m%d', CAST(max(shop_date) AS STRING)), PARSE_DATE('%Y%m%d', CAST(min(shop_date) AS STRING)),month)+1) as ActiveDateperMonth,  --14
    count(distinct PROD_CODE) as NumProduct,  --15
    
    ifnull((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Fresh')
    group by cust_code, BASKET_DOMINANT_MISSION),0) as NumFresh,  --16
    ifnull((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Grocery')
    group by cust_code, BASKET_DOMINANT_MISSION),0) as NumGrocery,  --17
    ifnull((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Mixed')
    group by cust_code, BASKET_DOMINANT_MISSION),0) as NumMixed,  --18
    ifnull((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Non Food')
    group by cust_code, BASKET_DOMINANT_MISSION),0) as NumNonFood,  --19
    ifnull((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'XX')
    group by cust_code, BASKET_DOMINANT_MISSION),0) as NumXX,  --20
    
    ifnull(round((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Fresh')
    group by cust_code, BASKET_DOMINANT_MISSION)/count(distinct BASKET_ID)*100,4),0) as PercFresh,  --21
    ifnull(round((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Grocery')
    group by cust_code, BASKET_DOMINANT_MISSION)/count(distinct BASKET_ID)*100,4),0) as PercGrocery,  --22
    ifnull(round((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Mixed')
    group by cust_code, BASKET_DOMINANT_MISSION)/count(distinct BASKET_ID)*100,4),0) as PercMixed,  --23
    ifnull(round((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'Non Food')
    group by cust_code, BASKET_DOMINANT_MISSION)/count(distinct BASKET_ID)*100,4),0) as PercNonFood,  --24
    ifnull(round((SELECT count(distinct BASKET_ID) 
    FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
    where (T2.cust_code = T1.cust_code) and (T2.BASKET_DOMINANT_MISSION = 'XX')
    group by cust_code, BASKET_DOMINANT_MISSION)/count(distinct BASKET_ID)*100,4),0) as PercXX,  --25
    
    median.median_disc as TotalSpend_Median,  --26
    median.per75 as TotalSpend_Per75,  --27
    median.per25 as TotalSpend_Per25,  --28
    
    PurchaseTime.PurchaseWeekday as NumWeekday,  --29
    PurchaseTime.PurchaseWeekend as NumWeekend,  --30
    PurchaseTime.PurchaseMorning as NumMorning,  --31
    PurchaseTime.PurchaseAfternoon as NumAfternoon,  --32
    PurchaseTime.PurchaseEvening as NumEvening,  --33
    
    round(PurchaseTime.PurchaseWeekday*100/count(distinct basket_id),2) as PercWeekday,  --34
    round(PurchaseTime.PurchaseWeekend*100/count(distinct basket_id),2) as PercWeekend,  --35
    round(PurchaseTime.PurchaseMorning*100/count(distinct basket_id),2) as PercMorning,  --36
    round(PurchaseTime.PurchaseAfternoon*100/count(distinct basket_id),2) as PercAfternoon,  --37
    round(PurchaseTime.PurchaseEvening*100/count(distinct basket_id),2) as PercEvening  --38
    
  FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T1
  LEFT JOIN 
    (
      SELECT distinct CustomerID,
        PERCENTILE_disc(TotalSpend, 0.5) OVER(PARTITION BY CustomerID) AS median_disc,
        PERCENTILE_disc(TotalSpend, 0.75) OVER(PARTITION BY CustomerID) AS per75,
        PERCENTILE_disc(TotalSpend, 0.25) OVER(PARTITION BY CustomerID) AS per25
      from
      (
        SELECT cust_code as CustomerID, basket_id, round(sum(spend),2) as TotalSpend,  
        FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
        where cust_code is not null
        group by cust_code, basket_id
        order by cust_code
      )
    ) as median
    on median.CustomerID = T1.cust_code
  LEFT JOIN 
    (
      select
        CustomerID,
        COUNT(CASE WHEN SHOP_WEEKDAY BETWEEN 2 AND 6 THEN 1 END) AS PurchaseWeekday,
        COUNT(CASE WHEN SHOP_WEEKDAY IN (1,7) THEN 1 END) AS PurchaseWeekend,
        COUNT(CASE WHEN SHOP_HOUR < 12 THEN 1 END) AS PurchaseMorning,
        COUNT(CASE WHEN SHOP_HOUR BETWEEN 12 and 17 THEN 1 END) AS PurchaseAfternoon,
        COUNT(CASE WHEN SHOP_HOUR > 18 THEN 1 END) AS PurchaseEvening,
      from
      (
        SELECT cust_code as CustomerID,basket_id,SHOP_WEEKDAY,SHOP_HOUR,BASKET_DOMINANT_MISSION,BASKET_SIZE
        FROM `nida-workshop.SUPERMARKET.TRANSACTIONS_2STORES` as T2
        where cust_code is not null
        group by cust_code,basket_id, SHOP_WEEKDAY, SHOP_HOUR,BASKET_DOMINANT_MISSION,BASKET_SIZE
      )
      group by CustomerID
    ) as PurchaseTime
    on PurchaseTime.CustomerID = T1.cust_code
  where cust_code is not null
  group by cust_code, TotalSpend_Median, TotalSpend_Per75, TotalSpend_Per25, NumWeekday, NumWeekend, NumMorning, NumAfternoon, NumEvening
)
