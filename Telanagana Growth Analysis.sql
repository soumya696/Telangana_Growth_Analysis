create database codebasics;
use codebasics;

select * from fact_stamps;
select * from fact_transport;
select * from fact_ts_ipass;

/*
1. How does the revenue generated from document registration vary across districts in Telangana? 
List down the top 5 districts that showed the highest document registration revenue growth between FY 2019 and 2022.
*/
select district, sum(documents_registered_cnt) total_cnt, sum(documents_registered_rev) total_rev from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
group by 1 order by 3 desc;

with cte as(
select district, sum(documents_registered_rev) as total_rev_2019 from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
where year(month) = 2019
group by 1
)
select district, total_rev_2019, sum(documents_registered_rev) total_rev_2022,
concat(round((sum(documents_registered_rev)/total_rev_2019)*100,1),'%') as 'change%' 
from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
inner join cte using (district)
where year(month) = 2022
group by 1 order by 4 desc limit 5;

/*
2. How does the revenue generated from document registration compare to the revenue generated from e-stamp challans across districts? 
List down the top 5 districts where e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022?
*/
select district, sum(documents_registered_rev) total_rev_doc,
sum(estamps_challans_rev) total_rev_estamps from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
group by 1;

with cte as(
select district, sum(documents_registered_rev) total_rev_doc,
sum(estamps_challans_rev) total_rev_estamps from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
where year(month) = 2022
group by 1
)
select district, round((total_rev_estamps-total_rev_doc)/total_rev_doc*100,2) as 'difference%'
from cte order by 2 desc limit 5;

/*
3. Is there any alteration of e-Stamp challan count and document registration count pattern since the implementation of e-Stamp challan?
If so, what suggestions would you propose to the government?
*/
select * from fact_stamps;

/*
4. Categorize districts into three segments based on their stamp registration revenue generation during the fiscal year 2021 to 2022.
*/
with cte as(
select district, sum(documents_registered_rev)+ sum(estamps_challans_rev) as total_rev
from fact_stamps a
inner join dim_districts b on a.dist_code = b.dist_code
where year(month) in (2021,2022)
group by 1
)
select district, total_rev,
case 
	when total_rev <= 1500000000 then 'low'
	when total_rev > 1500000000 and total_rev < 10000000000 then 'medium'
	else 'high'
	end as category
from cte order by 2 desc;

/*
5. Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. 
Are there any months or seasons that consistently show higher or lower sales rate, and if yes, what could be the driving factors? 
(Consider Fuel-Type category only)
*/
select month(month), sum(fuel_type_petrol), sum(fuel_type_diesel), sum(fuel_type_electric), sum(fuel_type_others)
from fact_transport
group by 1
order by 1;

/*
6. How does the distribution of vehicles vary by vehicle class (MotorCycle,MotorCar,AutoRickshaw,Agriculture) across different districts? 
Are there any districts with a predominant preference for a specific vehicle class? Consider FY 2022 for analysis.
*/
select * from fact_transport;
select district, sum(vehicleClass_MotorCycle), sum(vehicleClass_MotorCar), 
sum(vehicleClass_AutoRickshaw), sum(vehicleClass_Agriculture)
from fact_transport a
inner join dim_districts b on a.dist_code = b.dist_code
group by 1;

/*
7. List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to 
FY 2021? (Consider and compare categories: Petrol, Diesel and Electric)
*/
with cte1 as (
select district, sum(fuel_type_electric) as electric_2021
from fact_transport a
inner join dim_districts b on a.dist_code = b.dist_code
where year(month) = 2021
group by 1
),
cte2 as (
select district, sum(fuel_type_electric) as electric_2022
from fact_transport a
inner join dim_districts b on a.dist_code = b.dist_code
where year(month) = 2022
group by 1
)
select district, electric_2021, electric_2022, 
round((electric_2022 - electric_2021) / electric_2021*100,1) as 'change%'
from cte1
inner join cte2 using (district)
order by 4 limit 3;

/*
8. List down the top 5 sectors that have witnessed the most significant investments in FY 2022.
*/
select distinct sector, round(sum(investment_in_cr),2) as total_invest 
from fact_ts_ipass
where year(month) = 2022
group by 1 order by 2 desc limit 5;

/*
9. List down the top 3 districts that have attracted the most significant sector investments during FY 2019 to 2022? 
What factors could have led to the substantial investments in these particular districts?
*/
select district, round(sum(investment_in_cr),2) as total_invest_cr 
from fact_ts_ipass a
inner join dim_districts using(dist_code)
where year(month) between 2019 and 2022
group by 1 order by 2 desc limit 3;

/*
10. Is there any relationship between district investments, vehicles sales and stamps revenue within the same district between 
FY 2021 and 2022?
*/


/*
11. Are there any particular sectors that have shown substantial investment in multiple districts between FY 2021 and 2022?
*/
select sector, round(sum(investment_in_cr),0) as total_inv, count(distinct dist_code) as total_dis 
from fact_ts_ipass
group by 1 order by 3 desc;

/*
12. Can we identify any seasonal patterns or cyclicality in the investment trends for specific sectors? Do certain sectors
experience higher investments during particular months?
*/
select month(month), round(sum(investment_in_cr),2) as total_invest_cr 
from fact_ts_ipass
group by 1 order by 1;

