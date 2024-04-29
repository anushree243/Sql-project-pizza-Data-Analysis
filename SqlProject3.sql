create database pizzahut;

use pizzahut;

select * from order_details;
select * from orders;
select * from pizzas;
select * from pizza_types;


--Basic:
--Retrieve the total number of orders placed.
select count(*) as Total_Number_of_Orders_Placed from orders;


--Calculate the total revenue generated from pizza sales.
select ROUND(SUM(quantity*price),2) as total_revenue
from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id


--Identify the highest-priced pizza.
select pt.name, p.price from pizzas as p
join pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
where price=(select MAX(price) from pizzas)


--Identify the most common pizza size ordered.
select p.size, count(order_details_id) as order_count
from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id
group by p.size
order by order_count desc



--List the top 5 most ordered pizza types along with their quantities.
select TOP 5 pt.pizza_type_id,pt.name, sum(od.quantity) as Quantity_sum from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.pizza_type_id,pt.name
order by Quantity_sum desc



--Intermediate:

--Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category, sum(od.quantity) as total_quantity
from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id
join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id
group by pt.category



--Determine the distribution of orders by hour of the day.
select DATEPART(hour,time) as Hour, count(order_id) as Count
from orders
group by DATEPART(hour,time)



--Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category



--Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg_quantity from
(select o.date, sum(od.quantity) as quantity from orders as o
join order_details as od
on o.order_id=od.order_id
group by o.date) as order_quantity



--Determine the top 3 most ordered pizza types based on revenue.
select TOP 3 pt.name, sum(p.price*od.quantity) as revenue from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id
join pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.name 
order by revenue desc





--Advanced:

--Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, Round(SUM(od.quantity*p2.price)/
	(select ROUND(SUM(quantity*price),2) as total_revenue
		from order_details as od
		join pizzas as p
		on p.pizza_id=od.pizza_id)*100,2)
		as revenue
from pizza_types as pt
join pizzas as p2
on pt.pizza_type_id=p2.pizza_type_id
join order_details as od
on od.pizza_id=p2.pizza_id
group by pt.category
order by revenue desc



--Analyze the cumulative revenue generated over time.
with Temp
as (select orders.date,sum(order_details.quantity*pizzas.price) as revenue
	from order_details join pizzas
	on order_details.pizza_id=pizzas.pizza_id
	join orders
	on orders.order_id=order_details.order_id
	group by orders.date)

select date, sum(revenue) over(order by date) as cum_revenue
from Temp




--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue
from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name, SUM(p.price*od.quantity) as revenue from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as tabl) as tbl2
where rn<=3;
