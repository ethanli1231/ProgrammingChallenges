#Schema Creation
create schema challenge;
use challenge;

#Table creation / Date importing
create table marketing_data (
 date datetime,
 campaign_id varchar(50),
 geo varchar(50),
 cost float,
 impressions float,
 clicks float,
 conversions float
);

LOAD DATA LOCAL INFILE "C:/Users/ethan/Downloads/marketing_performance.csv"
INTO TABLE `marketing_data`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


create table website_revenue (
 date datetime,
 campaign_id varchar(50),
 state varchar(2),
 revenue float
);

LOAD DATA LOCAL INFILE "C:/Users/ethan/Downloads/website_revenue.csv"
INTO TABLE `website_revenue`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


create table campaign_info (
 id int not null primary key auto_increment,
 name varchar(50),
 status varchar(50),
 last_updated_date datetime
);

LOAD DATA LOCAL INFILE "C:/Users/ethan/Downloads/campaign_info.csv"
INTO TABLE `campaign_info`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


#Question 1: Write a query to get the sum of impressions by day
select sum(impressions) as total_impressions, day(date) as day
from marketing_data
group by day
order by day;

#Question 2: Write a query to get the top three revenue-generating states in order of best to worst
select state, sum(revenue) as total_revenue
from website_revenue
group by state
order by total_revenue DESC
LIMIT 3;

#Based on first question 2 query, we can see that OH is 3rd best performing state in terms of revenue with total of 37577. 
#However, If we want to query for the 3rd state specifically, and not include the rows above, we can use the code shown below

#Question 2: How much revenue did the third best state generate?
SELECT state, SUM(revenue) AS total_revenue
FROM website_revenue
WHERE state = (SELECT state
			   FROM (SELECT state, RANK() OVER (ORDER BY SUM(revenue) DESC) as rnk
				     FROM website_revenue
				     GROUP BY state) AS RankedStates
			   WHERE rnk = 3)
GROUP BY state;


/*
Question 3: Write a query that shows total cost, impressions, clicks, and revenue of each campaign. 
#Make sure to include the campaign name in the output.
*/

select c.name as campaign_name, 
	   sum(m.cost) as total_cost,
       sum(m.impressions) as total_impressions,
       sum(m.clicks) as total_clicks,
       sum(w.revenue) as total_revenue
from marketing_data m
left join website_revenue w on m.campaign_id = w.campaign_id
join campaign_info c on m.campaign_id = c.id
group by campaign_name
order by campaign_name;

#Question 4: Write a query to get the number of conversions of Campaign5 by state. Which state generated the most conversions for this campaign?
select 
	c.name as campaign_name, 
	w.state, 
	sum(m.conversions) as num_conversions
from marketing_data m
join campaign_info c on c.id = m.campaign_id
join website_revenue w on m.campaign_id = w.campaign_id
where name = 'Campaign5'
group by c.name, w.state
order by num_conversions DESC;

#From the table, we can see that GA generated the most conversions with 3342
#If we want to just see the state which generated the most conversions for this campaign with code, we can just limit 1 at the end


#Question 5: In your opinion, which campaign was the most efficient, and why?
/*To make the most informed decisions I can possibly make, I want to compute some important KPI's
If we are coming from a pure revenue standpoint, campaign3 generated the most revenue by far. However, the question asked which campaign was the most efficient. When considering efficiency we should consider
things like how much it cost to generate that much revenue, conversion rate, return on add spend, cost per conversion, among other KPIs that can be thought of. All in all, it seems like campaign 3 had the most efficient campaign
Its net profit (revenue - costs) was far above the other campaigns, with its conversion rate being the highest among the other campaigns as well. Total clicks and total impressions were also above the other campaigns though the
cost was significantly higher, it seems like it was able to be converted to profit.

*/
SELECT 
    ci.name AS campaign_name,
    SUM(md.conversions) / SUM(md.cost) AS cost_per_conversion,
    SUM(wr.revenue) / SUM(md.cost) AS return_on_ad_spend,
    SUM(md.conversions) / SUM(md.clicks) AS conversion_rate,
    sum(wr.revenue - md.cost) as Profit
FROM marketing_data md
JOIN campaign_info ci ON md.campaign_id = ci.id
JOIN website_revenue wr ON md.campaign_id = wr.campaign_id 
GROUP BY ci.name;


/*
Bonus question
Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads.
With out additional context about the companies goals, it is not entirely straightforward to determine which day is categorically the best to run ads.
However, based on the metrics that I have defined below we can make a general assumption to be improved upon. Saturday, which has the lowest average cost per conversion rate, highest revenue, and relatively
high avg revenue, could be considered the best day to run ads. However, in my analysis of this table, I recommend proceeding with caution and taking into account the goals of the organization and any other key
metrics that might be able to be considered.
*/

select dayname(md.date) as day_of_week, 
	   avg(cost/clicks) as avg_cpc, 
       avg(conversions) as avg_conversions, 
       avg(wr.revenue) as avg_revenue
from marketing_data md
join website_revenue wr on md.date = wr.date and md.campaign_id = wr.campaign_id
group by day_of_week
Order by avg_cpc ASC, avg_conversions DESC, avg_revenue DESC;
 











