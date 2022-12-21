use `case study`;
# Using import wizard to import the table, cleaning and exploring the data before visualisation in Tableau 
SELECT * FROM unicorn_companies;
# For columns 'Valuation' and 'Funding', I turn them into numbers in millions to calculate ratios
alter table unicorn_companies change column Valuation Valuation_m text null default null,
							  change column Funding Funding_m text null default null;
update unicorn_companies set Valuation_m=replace(Valuation_m, '$',''),
							 Funding_m=replace(Funding_m, '$','');
update unicorn_companies set Valuation_m=replace(Valuation_m, 'B','000'),
							 Funding_m=replace(Funding_m, 'B','000');        
update unicorn_companies set Funding_m=replace(Funding_m, 'M',''); 			
update unicorn_companies set Funding_m=replace(Funding_m, 'Unknown',''); 
alter table unicorn_companies change column Valuation_m Valuation_m int null default null,
							  change column Funding_m Funding_m int null default null;		
delete from unicorn_companies where Funding_m=''; 				
# add new column: customer_id	
alter table unicorn_companies add column company_id int primary key auto_increment first;

#for Column 'Select investors', I seperate the investers, in this case it is better to put it into a different table
create table unicorn_investors (company_id int, Investor VARCHAR(255));
insert into unicorn_investors 
select unicorn_companies.company_id,
	   substring_index(substring_index(unicorn_companies.Investors,',',n), ',', -1) as Investor
from (select 1 n union all select 2 union all select 3 union all select 4 union all select 5) as numbers 
	inner join unicorn_companies
	    on CHAR_LENGTH(unicorn_companies.Investors)- CHAR_LENGTH(REPLACE(unicorn_companies.Investors, ',', ''))+1>=numbers.n
order by company_id, n;
#trim the investor names so there is no space at the beginning
UPDATE unicorn_investors 
SET investor = TRIM(LEADING ' ' FROM investor);
#assign unique IDs to each investor
CREATE TABLE investors_list (investor VARCHAR(50));
INSERT INTO investors_list(investor) 
SELECT DISTINCT(investor) from unicorn_investors;
ALTER TABLE investors_list ADD investor_id INT PRIMARY KEY AUTO_INCREMENT;


