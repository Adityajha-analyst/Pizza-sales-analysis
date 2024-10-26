-- Create the database and use it
CREATE DATABASE PIZZA_SALES;
USE PIZZA_SALES;

-- Retrieve the total number of orders placed
SELECT COUNT(order_id) AS "Total Orders" 
FROM orders;

-- Calculate the total revenue generated from pizza sales
SELECT SUM(pizzas.price * order_details.quantity) AS "Total Sales"
FROM pizzas 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza
SELECT pizza_types.pizza_type_id, pizzas.price 
FROM pizzas 
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC 
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT TOP 1 COUNT(order_details.order_id) AS "Frequency of Order", pizzas.size
FROM order_details 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
ORDER BY COUNT(order_details.order_id) DESC;

-- List the top 5 most ordered pizza types along with their quantities
SELECT TOP 5 pizza_types.name, SUM(order_details.quantity) AS "Total Quantity" 
FROM pizza_types  
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name  
ORDER BY SUM(order_details.quantity) DESC;

-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT pizza_types.category, SUM(order_details.quantity) AS "Total Quantity"
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC;

-- Determine the distribution of orders by hour of the day
SELECT DATEPART(HOUR, time) AS "Order Hour", COUNT(order_id) AS "Number of Orders"
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY COUNT(order_id) DESC;

-- Join relevant tables to find the category-wise distribution of pizzas
SELECT COUNT(name) AS "Total Number of Pizzas", category 
FROM pizza_types
GROUP BY category
ORDER BY COUNT(name) DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT AVG(Total_Order) AS "Average Order Per Day" 
FROM (
    SELECT orders.date AS "Order Date", SUM(order_details.quantity) AS "Total Order"
    FROM orders 
    JOIN order_details ON orders.order_id = order_details.order_id 
    GROUP BY orders.date
) AS Daily_Order;

-- Determine the top 3 most ordered pizza types based on revenue
SELECT TOP 3 pizza_types.name, SUM(pizzas.price * order_details.quantity) AS "Total Revenue" 
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.name 
ORDER BY SUM(pizzas.price * order_details.quantity) DESC;

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category AS "Pizza Category", 
    (SUM(pizzas.price * order_details.quantity) / 
        (SELECT SUM(pizzas.price * order_details.quantity) 
         FROM pizza_types 
         JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
         JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
        ) 
    ) * 100 AS "Percentage Contribution"
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY "Percentage Contribution" DESC;

-- Analyze the cumulative revenue generated over time
SELECT SUM(sales.total_revenue) OVER(ORDER BY sales.date) AS "Cumulative Revenue", sales.date   
FROM (
    SELECT orders.date, SUM(ROUND(order_details.quantity * pizzas.price, 0)) AS "Total Revenue" 
    FROM orders 
    JOIN order_details ON orders.order_id = order_details.order_id 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id 
    GROUP BY orders.date 
) AS sales;

-- Display all pizza types
SELECT * FROM pizza_types;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, category, revenue, ranking  
FROM (
    SELECT name, category, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS "Ranking"  
    FROM (
        SELECT pizza_types.name, pizza_types.category, SUM(pizzas.price * order_details.quantity) AS "Revenue" 
        FROM pizza_types 
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
        GROUP BY pizza_types.name, pizza_types.category
    ) AS pizza_revenue
) AS ranked_pizzas
WHERE ranking <= 3;
