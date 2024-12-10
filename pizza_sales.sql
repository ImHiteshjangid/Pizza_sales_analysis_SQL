-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pizza_id, size, price
FROM
    pizzas
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(*) AS count
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS order_hour, COUNT(*) AS order_count
FROM
    orders
GROUP BY order_hour
ORDER BY order_hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pt.category, COUNT(*) AS order_count
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    o.order_date, AVG(od.quantity) AS avg_pizzas_per_day
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name,
    SUM(od.quantity * p.price) AS revenue,
    (SUM(od.quantity * p.price) / (SELECT 
            SUM(od.quantity * p.price)
        FROM
            order_details od
                JOIN
            pizzas p ON od.pizza_id = p.pizza_id)) * 100 AS percentage_contribution
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;

-- Analyze the cumulative revenue generated over time.
SELECT o.order_date, SUM(od.quantity * p.price) AS daily_revenue, 
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;
