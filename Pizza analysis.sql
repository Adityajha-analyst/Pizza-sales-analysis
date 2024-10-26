create database PIZZA_SALES;
USE PIZZA_SALES;

--Retrieve the total number of orders placed.
Select count(order_id) from orders;

--Calculate the total revenue generated from pizza sales.
SELECT SUM(PIZZAS.PRICE* ORDER_DETAILS.QUANTITY) AS "TOTAL SALES"
FROM pizzas 
JOIN order_details ON pizzas.PIZZA_ID = order_details.pizza_id;

--Identify the highest-priced pizza.
SELECT pizza_types.pizza_type_id , pizzas.price 
FROM PIZZAS 
JOIN pizza_types ON PIZZAS.pizza_type_id = pizza_types.PIZZA_TYPE_ID
ORDER BY PIZZAS.PRICE DESC ;

--Identify the most common pizza size ordered.
SELECT TOP 1 COUNT(ORDER_DETAILS.order_id) AS 'Frequency of order' , pizzas.size
FROM order_details 
JOIN PIZZAS ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
ORDER BY COUNT(ORDER_DETAILS.order_id) DESC;

--List the top 5 most ordered pizza types along with their quantities.
SELECT top 5 pizza_types.name , sum(order_details.quantity) AS 'Total quantity' 
from pizza_types  
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name  
order by sum(order_details.quantity) desc;

--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category , sum(order_details.quantity) as 'Total quantity'
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by pizza_types.category
order by sum(order_details.quantity) desc;

--Determine the distribution of orders by hour of the day.
SELECT DATEPART(HOUR, time) AS 'Timing of Orders' , count(order_id) as 'Number of order'
FROM orders
group by DATEPART(HOUR, time)
order by count(order_id) desc ;

--Join relevant tables to find the category-wise distribution of pizzas.
select count(name) as 'Total number of pizza' , category 
from pizza_types
group by category
order by count(name) desc;

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT  AVG(TOTAL_ORDER) AS 'AVERAGE ORDER PER DAY' FROM 
(select orders.date  AS 'ORDER_DATE', sum(order_details.quantity) as 'TOTAL_ORDER'
from orders 
join order_details on orders.order_id = order_details.order_id 
group by orders.date)
AS NEW_TABLE;

--Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 pizza_types.NAME , SUM(PIZZAS.PRICE * order_details.quantity) AS 'TOTAL REVENUE' 
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON PIZZAS.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.NAME 
ORDER BY SUM(PIZZAS.PRICE * order_details.quantity) DESC;


--Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category AS PIZZA_NAMES, 
    (SUM(pizzas.price * order_details.quantity) / 
        (SELECT SUM(pizzas.price * order_details.quantity) 
         FROM pizza_types 
         JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
         JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
        ) 
    ) * 100 AS PERCENTAGE
FROM 
    pizza_types 
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN 
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    PERCENTAGE DESC;


--Analyze the cumulative revenue generated over time.
SELECT  SUM(sales.[total revenue] ) over(order by sales.date) as "cumlative revenue" , SALES.date   from 
(SELECT orders.date , SUM(round (order_details.quantity * pizzas.price,0)) AS 'total revenue' 
from orders 
join order_details on orders.order_id = order_details.order_id 
join pizzas on order_details.pizza_id = pizzas.pizza_id 
group by orders.date 
) as SALES;

SELECT * fROM pizza_types;
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT NAME , CATEGORY , REVENUE , RANKING  FROM
(SELECT NAME, CATEGORY , REVENUE , RANK() OVER( PARTITION BY CATEGORY ORDER BY REVENUE DESC )  AS "RANKING"  FROM
(SELECT pizza_types.name , pizza_types.category , sum(pizzas.price * order_details.quantity) As "Revenue" 
FROM pizza_types 
JOIN PIZZAS ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
Group by pizza_types.name , pizza_types.category) AS PIZ ) AS TOP3_PIZZA
WHERE RANKING <= 3;
