#--------------------------------------Banking Analysis--------------------#
#*********DEMOGRAPHIC**********#
#1.Total Customers#
select count(*) from dim_customers;

#a)Female Customers#
select count(*) from dim_customers
where gender="female";

#b)Male Customers#
select count(*) from dim_customers
where gender="male";

#c)Married Customers#
select count(*) from dim_customers
where `marital status`="married";

#c)Single Customers#
select count(*) from dim_customers
where `marital status`="single";

#2a).Average Spent Per Txt#
select avg(avg_income) from dim_customers;

#b).Average Income #
select round(sum(spend)/count(spend)) from fact_spends;

#3-----Total_customer By Income_band-------#

select "Low" as income_band,
sum(case when avg_income>=24000 and avg_income<=45000 then 1 else 0 end ) as Total_Customers
from dim_customers
union
select "Medium" as income_band,
sum(case when avg_income>=45000 and avg_income<=65000 then 1 else 0 end ) as Total_Customers
from dim_customers
union
select "High" as income_band,
sum(case when avg_income>=65000 then 1 else 0 end ) as Total_Customers
from dim_customers;


#4----Total_Customer By Marital_Status----#
select "Single" as Marital_Status ,
sum(case when `marital status`="Single" then 1 else 0  end) as Total_Customer
from dim_customers
union
select "Married" as Marital_Status ,
sum(case when `marital status`="Married" then 1 else 0  end) as Total_Customer
from dim_Customers;

#5.)---------Avg_monthly_Spend and Avg_spend_per_Customer_by_Occupation------#
select d.occupation,round(sum(d.avg_income)/count(d.customer_id)) as avg_monthly_income_by_Occupation
,round((sum(f.spend)/count(distinct f.month))/count(distinct d.customer_id)) as Avg_Spend_per_Customer_by_Occupation
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by d.occupation
order by avg_monthly_income_by_Occupation desc;


#6.)-------------------Customer_Categorization_By_Age_Group------------------------#
SELECT 
    d.age_group,
    ROUND(SUM(CASE WHEN d.gender = 'female' THEN d.avg_income END) / COUNT(CASE WHEN d.gender = 'female' THEN d.customer_id END), 1) AS Female_Avg_Salary,
    ROUND(AVG(CASE WHEN d.gender = 'female' THEN f.spend END), 1) AS Female_Avg_Spend_Income,
    COUNT(DISTINCT CASE WHEN d.gender = 'female' THEN d.customer_id END) AS Female_Customer_Count,
    ROUND(SUM(CASE WHEN d.gender = 'male' THEN d.avg_income END) / COUNT(CASE WHEN d.gender = 'male' THEN d.customer_id END), 1) AS Male_Avg_Salary,
    ROUND(AVG(CASE WHEN d.gender = 'male' THEN f.spend END), 1) AS Male_Avg_Spend_Income,
    COUNT(DISTINCT CASE WHEN d.gender = 'male' THEN d.customer_id END) AS Male_Customer_Count
FROM dim_customers d
JOIN fact_spends f 
ON d.customer_id = f.customer_id
GROUP BY d.age_group
ORDER BY d.age_group;

#7.)--------------------Customer_And_Average_Income_per_City----------------------#
select d.city,
round(sum(case when d.gender="Female" then d.avg_income end)/count(case when d.gender="Female" then d.customer_id end),1)as Female_Avg_Salary
,count(case when d.gender="female" then d.customer_id end) as Female_Customer_count,
round(sum(case when d.gender="male" then d.avg_income end)/count(case when d.gender="male" then d.customer_id end),1) as Male_Avg_Income,
count(case when d.gender="male" then d.customer_id end) as Male_Custmoer_count
 from dim_customers d
group by d.city
order by d.city;

#**********Income_Utilization************#

#8a).-------Average_Monthly_Spend_Per_Customer--------------#
select round((sum(spend)/count(distinct month))/count(distinct customer_id))
from fact_spends;

#b).#-----------Avgerage_Monthly_Spend%----------#
select round(((sum(spend)/count(distinct month))/count(distinct customer_id))*100
/(select avg(avg_income)from dim_customers),2) as "Avg_Monthly_Spend%"
from fact_spends; 

#c).#-----------Male_Avgerage_Monthly_Spend%----------#

select round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/(select avg(avg_income)from dim_customers),2) as "Male_Avg_Monthly_Spend%"
from fact_spends f
join dim_customers d
on f.customer_id=d.customer_id
where d.gender="male"; 


#d).#-----------Female_Avgerage_Monthly_Spend%----------#

select concat(round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/(select avg(avg_income)from dim_customers),2),"%") as "Female_Avg_Monthly_Spend%"
from fact_spends f
join dim_customers d
on f.customer_id=d.customer_id
where d.gender="female"; 

#9).--------------------City_Wise_Avg_INcome_Spending----------------------#
select  d.city,
round(avg(d.avg_income),2) as Avg_Income,
round((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id),2)as Avg_Monthly_Spent_Per_Cust,
concat(round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2),"%") as "Avg_Monthly_Spend%"
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by d.city
order by d.city;

#10.-------Average_Monthly_Spend% By Marital_Status_And_Gender---------------#
select "Female" as "Gender",
 CONCAT(ROUND(((SUM(CASE WHEN d.gender = 'female' and  `marital status` = 'married'  THEN f.spend ELSE 0 END) / COUNT(DISTINCT CASE WHEN d.gender = 'female'and `marital status`="married" THEN f.month END)
                ) / COUNT(DISTINCT case when d.gender="Female" and `marital status`="married" then  f.customer_id end)
            ) * 100 / AVG(case when d.gender="female" and `marital status`="married" then d.avg_income end), 2
        ), 
        '%'
    ) AS "Married_Avg_Month_Spend%",
     CONCAT(ROUND(((SUM(CASE WHEN d.gender = 'female' and  `marital status` = 'single'  THEN f.spend ELSE 0 END) / COUNT(DISTINCT CASE WHEN d.gender = 'female'and `marital status`="single" THEN f.month END)
                ) / COUNT(DISTINCT case when d.gender="Female" and `marital status`="single" then  f.customer_id end)
            ) * 100 / AVG(case when d.gender="female" and `marital status`="single" then d.avg_income end), 2
        ), 
        '%'
    ) AS "Single_Avg_Month_Spend%",
    "Male" as "Gender",
 CONCAT(ROUND(((SUM(CASE WHEN d.gender = 'male' and  `marital status` = 'married'  THEN f.spend ELSE 0 END) / COUNT(DISTINCT CASE WHEN d.gender = 'male'and `marital status`="married" THEN f.month END)
                ) / COUNT(DISTINCT case when d.gender="male" and `marital status`="married" then  f.customer_id end)
            ) * 100 / AVG(case when d.gender="male" and `marital status`="married" then d.avg_income end), 2
        ), 
        '%'
    ) AS "Married_Avg_Month_Spend%",
     CONCAT(ROUND(((SUM(CASE WHEN d.gender = 'male' and  `marital status` = 'single'  THEN f.spend ELSE 0 END) / COUNT(DISTINCT CASE WHEN d.gender = 'male'and `marital status`="single" THEN f.month END)
                ) / COUNT(DISTINCT case when d.gender="male" and `marital status`="single" then  f.customer_id end)
            ) * 100 / AVG(case when d.gender="male" and `marital status`="single" then d.avg_income end), 2
        ), 
        '%'
    ) AS "single_Avg_Month_Spend%"
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id;


#11--------------Average_Salary VS Average_Monthly_Spend%_By_Age_Group---------#
select d.age_group,
concat(round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2),"%") as "Avg_Monthly_Spend%",
round(avg(d.avg_income),2) as Avg_Salary
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by d.age_group;

#12---------Average_Monthly_Spend(Monthly_Spend_Per_customer % Per Txn) BY _Occupation-----#
select f.month,d.occupation,
round(((sum(f.spend)/count(distinct f.month))/count(distinct d.customer_id))*100
/avg(avg_income),1) as "Avg_Monthly_Spend%"from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by f.month,d.occupation
order by f.month;


#13.)-----------------Average_Monthly_Income_Across_Various_Category----------------#
select category,
round(sum(spend)/count(spend),1) as Average_Spend_Income,
round((sum(spend)/count(distinct month))/count(distinct customer_id),2) as Average_Monthly_Spend_Per_Customer
from fact_spends
group by category
order by category;


#14.)#-----------------City_Wise_Avg_Monthly_Spend%_By_Month-ANd_City---------------------#
select f.month,d.city, 
round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2) as "Avg_Monthly_Spend%"
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by f.month,d.city;

#15).-------------------Average_Monthly_Spend_per_Customer_By_PaymentType--------------------#
select payment_type,
round((sum(spend)/count(distinct month))/count(distinct customer_id),2) as Average_Monthly_Spend_Per_Customer
from fact_spends
group by payment_type
order by Average_Monthly_Spend_Per_Customer;


#16).--------------------Total_Amount_Spend_By_Payment_Method----------------------------------#
select payment_type,
concat(round(sum(spend)/1000000,2),"M") as Total_Amount_Spend
from fact_spends
group by payment_type;


#17).--------------------Average_Monthly_Spending%_By_Occupation----------------------#
select d.occupation,round(sum(d.avg_income)/count(d.customer_id)) as avg_monthly_income_by_Occupation
,round((sum(f.spend)/count(distinct f.month))/count(distinct d.customer_id)) as Avg_Spend_per_Customer_by_Occupation,
round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2) as "Avg_Monthly_Spend%"
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by d.occupation
order by avg_monthly_income_by_Occupation desc;

#18).-------------------------Average_Monthly_Spend%_By_Age_Group--------------#
select d.age_group ,
concat(round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2),"%") as "Avg_Monthly_Spend%"
from dim_customers d
join fact_spends f
on d.customer_id=f.customer_id
group by d.age_group 
order by d.age_group;


#------------------------Key_Insight_Credit_Card------------------------------------#

#19)a).->--------------------Total_Spend----------------------------------#

select concat(round(sum(spend)/1000000),"M") as Total_Spend from fact_spends
where payment_type="Credit Card";

#B).------------------------Average_Spend_Per_Txt-------------------------#

select round(sum(spend)/count(customer_id),1) as Average_Spend_Per_Txt
from fact_spends
where payment_type="Credit Card";

#C).------------------------Average_Monthly_Spend_per_Customer---------------#

select round((sum(spend)/count(distinct month))/count(distinct customer_id),1) as Average_Monthly_Spend_Per_Customer
from fact_spends
where payment_type="Credit Card";

#D).---------------------------Female_Total_Spend----------------------------#
SELECT CONCAT(ROUND(SUM(spend) / 1000000), 'M') AS Total_Spend 
FROM fact_spends 
WHERE payment_type = 'Credit Card' 
AND customer_id IN (SELECT customer_id FROM dim_customers WHERE gender = 'Female');


#E).---------------------------Male_Total_Spend----------------------------#
SELECT CONCAT(ROUND(SUM(spend) / 1000000), 'M') AS Total_Spend 
FROM fact_spends 
WHERE payment_type = 'Credit Card' 
AND customer_id IN (SELECT customer_id FROM dim_customers WHERE gender = 'male');

#F).---------------------------Married_total_Spend----------------------------#
SELECT CONCAT(ROUND(SUM(spend) / 1000000,1), 'M') AS Total_Spend 
FROM fact_spends 
WHERE payment_type = 'Credit Card' 
AND customer_id IN (SELECT customer_id FROM dim_customers WHERE `marital status` = 'married');

#F).---------------------------Single_total_Spend----------------------------#
SELECT CONCAT(ROUND(SUM(spend) / 1000000,1), 'M') AS Total_Spend 
FROM fact_spends 
WHERE payment_type = 'Credit Card' 
AND customer_id IN (SELECT customer_id FROM dim_customers WHERE `marital status` = 'Single');

#20).----------------------------Total_Amount_Spend_By_Occupation---------------------------#

select occupation,
Total_spend from (
select d.occupation,
concat(round(sum(f.spend)/1000000),"M") as Total_Spend,
sum(f.spend) as spend_numeric
 from dim_customers d
 join fact_spends f
 on d.customer_id=f.customer_id
 where f.payment_type="credit card"
group by d.occupation 
) as subquery
order by spend_numeric desc;

#21)---------------------------------By_Category---------------------------------------#
select f.category,
concat(round(((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id))*100
/avg(d.avg_income),2),"%") as "Avg_Monthly_Spend%",
round(sum(f.spend)/count(f.customer_id),1) as Average_Spend_Per_Txt,
concat(round(sum(f.spend)/1000000,2),"M") as Total_Spend
from fact_spends f
join dim_customers d
 on d.customer_id=f.customer_id
 where f.payment_type="credit card"
group by f.category
order by f.category;

#22)----------------------------------Customer_categorization_By_Age_Group--------
#*********************************FEMALE*****************************
select "Female" as categ,d.age_group ,
round(sum(f.spend)/count(f.customer_id),2) as Avg_spend_inc,
round((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id),2) as Avg_Monthly_Spend_Per_Cust,
concat(round(sum(f.spend)/1000000,3),"M") as Total_Spend
from fact_spends f
join dim_customers d
on d.customer_id=f.customer_id
where d.gender="female" and f.payment_type="credit card"
group by d.age_group
order by d.age_group;

#*********************************MALE*******************************
select "GENDER" as categ,d.age_group ,
round(sum(f.spend)/count(f.customer_id),2) as Avg_spend_inc,
round((sum(f.spend)/count(distinct f.month))/count(distinct f.customer_id),2) as Avg_Monthly_Spend_Per_Cust,
concat(round(sum(f.spend)/1000000,3),"M") as Total_Spend
from fact_spends f
join dim_customers d
on d.customer_id=f.customer_id
where d.gender="male" and f.payment_type="credit card"
group by d.age_group
order by d.age_group;


#23)----------------------------------TOTAL_AMOUNT_SPENT_BY_MONTH-------------------------#
select month,concat(round(sum(spend)/1000000),"M") as Total_Spend from fact_spends
where payment_type="Credit Card"
group by month
order by 
case 
when month="may" then 5
when month="June" then 6
when month="july" then 7
when month="august" then 8
when month="september" then 9
when month="october" then 10
else 99
end;



























