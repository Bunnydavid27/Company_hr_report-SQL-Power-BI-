#create database company;
use company;


select * from hr;

desc hr;

#data cleaning

alter table hr
change column ï»¿id emp_id varchar(20) NULL;

select birthdate from hr;

set sql_safe_updates = 0;

update hr
set birthdate = case
   when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
   when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
   else null
end;
select birthdate from hr;

alter table hr
modify column birthdate date;

update hr
set hire_date = case
   when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
   when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
   else null
end;

select hire_date from hr;

alter table hr 
modify column hire_date date;

select termdate from hr;



update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate IS NOT NULL AND termdate!='';


update hr
set termdate = CASE
WHEN termdate = 0000-00-00 THEN '0000-00-00' ELSE termdate 
END;

update hr
set termdate = case
   when termdate like '%-%' then date_format(str_to_date(termdate,'%Y-%m-%d'),'%Y-%m-%d')
end;


alter table hr
modify column termdate date;


   
select termdate from hr;


alter table hr
add column age int;

update hr 
set age = timestampdiff(YEAR, birthdate, CURDATE());

select birthdate, age from hr;

select 
min(age) as youngest,
max(age) as oldest
from hr;

#data exploring analysis

#gender no of emp
select gender, count(*) as count from hr
where age >=18 AND termdate = '0000-00-00'
group by gender;

#race ethinicity
select race,count(*) from hr
where age >=18 AND termdate = '0000-00-00'
group by race
order by count(*) DESC;

#age_dist
select age, count(*) from hr 
group by age;

select 
case 
when age>=18 and age<=35 then "18-35"
when age > 35 and age <=50 then "36-50"
when age>50 then "above 50"
else "below 18"
end as age_group, count(*) from hr
group by age_group
order by count(*);

#work remote and head quarters
select gender,location, count(*) from hr
group by location, gender 
order by count(*);  


#average length of terminated employment
select round(avg(datediff(termdate, hire_date))/365,0) as avg_term_time from hr
where termdate<= curdate() and termdate <> '0000-00-00' and age>=18;


#gender dist among departments and job titles
select gender,department, count(*) from hr
group by department, gender 
order by department;  

select gender, jobtitle, count(*) from hr
group by jobtitle, gender 
order by jobtitle;  


select department, total_count, terminated_count, terminated_count/total_count as turnover_rate from (select department, count(*) as total_count,
 sum(case when termdate <> '0000-00-00' and termdate <=curdate() then 1 else 0 end ) as terminated_count
 from hr 
 where age>= 18
 group by department) as subquery
 order by turnover_rate desc;

#employee distribution state and city
select location_state, count(*) as cnt 
from hr
group by location_state
order by cnt;


#employee count changed over the term and hire dates
SELECT 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year, 
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        hr
    WHERE age >= 18
    GROUP BY 
        YEAR(hire_date)
) subquery
ORDER BY 
    year ASC;