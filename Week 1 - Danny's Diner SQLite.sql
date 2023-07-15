/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, menu.price AS total_amount_spent
FROM SALES JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.price;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id;
--DISTINCT is used to count a customer's multiple visits in a day as one visit

-- 3. What was the first item from the menu purchased by each customer?
SELECT customer_id, product_name
FROM sales JOIN menu ON sales.product_id = menu.product_id
WHERE order_date = 
 ( SELECT MIN(order_date)
   FROM sales
   WHERE customer_id = sales.customer_id )
 GROUP by sales.customer_id, menu.product_name
 
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT sales.customer_id, menu.product_name, COUNT(*) AS purchase_times
FROM sales JOIN menu ON sales.product_id = menu.product_id
WHERE menu.product_id =
   (
     SELECT product_id
     FROM 
      (
        SELECT product_id, COUNT (*) AS purchase_count
        FROM sales
        GROUP BY product_id
        ORDER BY purchase_count DESC
        LIMIT 1
      ) AS subquery
    )
 GROUP BY sales.customer_id;

-- 5. Which item was the most popular for each customer?
select sales.customer_id, 
       menu.product_name, 
       COUNT (*) AS purchase_times
FROM sales 
JOIN menu ON sales.product_id = menu.product_id
WHERE sales.product_id = 
      (
       SELECT subquery.product_id
       FROM 
        (  
           SELECT sales.customer_id, sales.product_id, COUNT(*) As purchase_count
           FROM sales
           GROUP BY sales.customer_id, sales.product_id
         ) As subquery
       WHERE subquery.customer_id = sales.customer_id
       ORDER BY subquery.purchase_count DESC 
       LIMIT 1
       )
GROUP BY sales.customer_id, menu.product_name;   

-- 6. Which item was purchased first by the customer after they became a member?
SELECT s.customer_id, m.product_name
FROM sales As s
JOIN menu AS m ON s.product_id = m.product_id
JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date
AND s.order_date =
     (
       SELECT MIN(order_date) 
       FROM sales as sub
       WHERE sub.customer_id = s.customer_id
       AND sub.order_date >= mem.join_date
      )
GROUP BY s.customer_id, m.product_name;


--7. Which item was purchased just before the customer became a member?
SELECT s.customer_id, m.product_name
FROM sales As s
JOIN menu AS m ON s.product_id = m.product_id
JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date <= mem.join_date
AND s.order_date =
     (
       SELECT MAX(order_date)
       FROM sales as sub
       WHERE sub.customer_id = s.customer_id
       AND sub.order_date <= mem.join_date
      )
GROUP BY s.customer_id, m.product_name;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(*) as total_items, SUM(m.price) AS total_amount_spent 
FROM sales As s
JOIN menu AS m ON s.product_id = m.product_id
JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id; 

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
       SUM(Case WHEN s.order_date >= '2021-01-01' AND s.order_datem.product_name = 'sushi' 
           THEN (m.price * 2 * 10) 
           ELSE (m.price * 10) END) 
           AS total_points
FROM sales as s
JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id;
           
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
       SUM(Case 
           WHEN s.order_date >= mem.join_date AND s.order_date <= date(mem.join_date, '+6 days') THEN (m.price * 2 * 10) -- first week after joining 
           WHEN s.order_date > date(mem.join_date, '+6 days') AND s.order_date <= '2021-01-31' THEN (m.price *10) -- rest of the month
           ELSE 0
        END) AS total_points
FROM sales as s
JOIN menu AS m ON s.product_id = m.product_id
JOIN members AS mem ON s.customer_id = mem.customer_id           
WHERE s.order_date <= '2021-01-31' -- End of january
AND mem.customer_id IN ('A', 'B') -- Replace with actual customer IDs
GROUP BY s.customer_id;







