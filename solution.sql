-- Question 1
select 
	product_name,
	unit_price
from northwind_company..products
where unit_price between 20 and 50
and discontinued = 0
order by unit_price desc
-----------------------------------------------------------------------------------

-- Question 2
with avg_days as (
select
	ship_country,
	avg(cast(DATEDIFF(day, order_date, shipped_date) as decimal(10,2))) as average_days_order_shipping,
	count(*) as total_number_orders

from northwind_company..orders
where year(order_date) = 1998
group by 
	ship_country
)
select * from avg_days
where average_days_order_shipping >= 5
and total_number_orders > 10
-----------------------------------------------------------------------------------

-- Question 3
select
	CONCAT(m.first_name, ' ', m.last_name) as employee_fullname,
	m.title as employee_title,
	DATEDIFF(year, m.birth_date, m.hire_date) as employee_age,
	CONCAT(e.first_name, ' ', e.last_name) as manager_fullname,
	e.title as manager_title
from northwind_company..employees as e
inner join northwind_company..employees as m
on e.employee_id = m.reports_to
order by 
	employee_age
-----------------------------------------------------------------------------------

-- Question 4
with freight as (
select 
	CONCAT(YEAR(order_date), '-', MONTH(order_date)) as year_month,
	count(*) as total_number_orders,
	round(sum(freight),0) as total_freight
from northwind_company..orders
where order_date > '1997-01-01'
group by 
	CONCAT(YEAR(order_date), '-', MONTH(order_date))
)
select * from freight
where total_number_orders > 35
order by total_freight desc
-----------------------------------------------------------------------------------

-- Question 5
with cte_price as (
select
	p.product_id,
	product_name,
	order_date,
	LEAD(d.unit_price) over (partition by product_name order by order_date) as current_price,
	lag(d.unit_price) over (partition by product_name order by order_date) as previous_price
from northwind_company..products as p
inner join northwind_company..order_details as d
on p.product_id = d.product_id
inner join northwind_company..orders as o
on o.order_id = d.order_id
)
select
	c.product_name,
	c.current_price,
	c.previous_price,
	round(100*(current_price - previous_price)/previous_price,2) as percentage_increase
from cte_price as c
inner join northwind_company..order_details as d
on c.product_id = d.product_id
where c.current_price != c.previous_price
group by 
	c.product_name,
	c.current_price,
	c.previous_price
having count(distinct order_id) > 10
and round(100*(current_price - previous_price)/previous_price,2) not between 20 and 30
-----------------------------------------------------------------------------------

-- Question 6
select 
	category_name,
	case
		when p.unit_price < 20 then '1.Below $20'
		when p.unit_price >= 20 and p.unit_price <= 50 then '2. $20 - $50'
		when p.unit_price > 50 then '3. Over $50'
		end as price_range,
	sum(d.unit_price * d.quantity) as total_amount,
	count(distinct d.order_id) as total_number_orders
from northwind_company..categories as c
inner join northwind_company..products as p
on c.category_id = p.category_id
inner join northwind_company..order_details as d
on p.product_id = d.product_id
group by 
	category_name,
	case
		when p.unit_price < 20 then '1.Below $20'
		when p.unit_price >= 20 and p.unit_price <= 50 then '2. $20 - $50'
		when p.unit_price > 50 then '3. Over $50'
		end
order by category_name, price_range
-----------------------------------------------------------------------------------

-- Question 7
select
	category_name,
	case
		when s.country in ('US', 'Brazil', 'Canada') THEN 'America'
		WHEN s.country IN ('Australia', 'Singapore', 'Japan' ) THEN 'Asia-Pacific'
		ELSE 'Europe'
		end as supplier_region,
	p.unit_in_stock,
	p.unit_on_order,
	p.reorder_level
from northwind_company..suppliers as s
inner join northwind_company..products as p
on s.supplier_id = p.supplier_id
inner join northwind_company..categories as c
on c.category_id = p.category_id
where s.region is not null
order by 
	supplier_region,
	c.category_name,
	p.unit_price;
-----------------------------------------------------------------------------------

-- Question 8
with avg_price as (
select 
	c.category_name,
	p.product_name,
	p.unit_price,
	round(avg(d.unit_price),2) as average_unit_price
	
from northwind_company..categories as c
inner join northwind_company..products as p
on c.category_id = p.category_id
inner join northwind_company..order_details as d
on d.product_id = p.product_id
where p.discontinued = 0
group by 
	c.category_name,
	p.product_name,
	p.unit_price
)
select *,
	round(PERCENTILE_CONT(0.5) within group (order by unit_price) over(partition by product_name),2) as median_unit_price,
	CASE
		WHEN unit_price > average_unit_price THEN 'Over Average'
		WHEN unit_price = average_unit_price THEN 'Equal Average'
		WHEN unit_price < average_unit_price THEN 'Below Average'
	END AS average_unit_price_position,
	CASE
		WHEN unit_price > PERCENTILE_CONT(0.5) within group (order by unit_price) over(partition by product_name)  THEN 'Over Average'
		WHEN unit_price = PERCENTILE_CONT(0.5) within group (order by unit_price) over(partition by product_name)  THEN 'Equal Average'
		WHEN unit_price < PERCENTILE_CONT(0.5) within group (order by unit_price) over(partition by product_name)  THEN 'Below Average'
	END AS median_unit_price_position
from avg_price
order by category_name, product_name
-----------------------------------------------------------------------------------

-- Question 9
with cte_kpi as (
select
	CONCAT(first_name, ' ', last_name) as employee_full_name,
	title as employee_title,
	round(sum(d.unit_price * d.quantity),2) as total_sale_amount_excluding_discount,
	count(distinct d.order_id) as total_number_orders,
	count(d.order_id) as total_number_entries,
	round(sum(d.discount * (d.quantity * d.unit_price)),2) as total_discount_amount,
	round(sum((1 - d.discount) * (d.quantity * d.unit_price)),2) as total_sale_amount_including_discount
from northwind_company..employees as e
inner join northwind_company..orders as o
on e.employee_id = o.employee_id
inner join northwind_company..order_details as d
on d.order_id = o.order_id 
group by 
	CONCAT(first_name, ' ', last_name),
	title
)
select 
	employee_full_name,
	employee_title,
	total_sale_amount_excluding_discount,
	total_number_orders,
	total_number_entries,
	total_discount_amount,
	total_sale_amount_including_discount,
	round(sum(total_sale_amount_excluding_discount/total_number_entries),2) as average_amount_per_entry,
	round(sum(total_sale_amount_excluding_discount/total_number_orders),2) as average_amount_per_entry,
	round(sum(100*(total_sale_amount_excluding_discount - total_sale_amount_including_discount)/
		total_sale_amount_excluding_discount),2) as total_discount_percentage
from cte_kpi
group by
	employee_full_name,
	employee_title,
	total_sale_amount_excluding_discount,
	total_number_orders,
	total_number_entries,
	total_discount_amount,
	total_sale_amount_including_discount
order by total_sale_amount_including_discount desc

-----------------------------------------------------------------------------------

-- Question 10
with cte_kpi as (
select 
	category_name,
	CONCAT(first_name, ' ', last_name) as employee_full_name,
	round(sum((1 - d.discount) * (d.quantity * d.unit_price)),2) as total_sale_amount_including_discount
from northwind_company..employees as e
inner join northwind_company..orders as o
on e.employee_id = o.employee_id
inner join northwind_company..order_details as d
on d.order_id = o.order_id
inner join northwind_company..products as p
on p.product_id = d.product_id
inner join northwind_company..categories as c
on c.category_id = p.category_id
group by 
	category_name,
	CONCAT(first_name, ' ', last_name)
)
select
	category_name,
	employee_full_name,
	total_sale_amount_including_discount,
	round(100*sum(total_sale_amount_including_discount)/
		sum(total_sale_amount_including_discount) over (partition by employee_full_name),2) as percentage_employee_sales,
	round(100*sum(total_sale_amount_including_discount)/
		sum(total_sale_amount_including_discount) over (partition by category_name),2) as percentage_category_sales
from cte_kpi
group by 
	category_name,
	employee_full_name,
	total_sale_amount_including_discount
order by 
	category_name,
	total_sale_amount_including_discount desc