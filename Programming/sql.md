# SQL

list of sql interview questions grouped by different difficulty level.

# Table of Contents

## Beginner

+ [q1?](#q1)
+ [q2?](#q2)

## Intermediate

+ [q3?](#q3)
+ [q4?](#q4)

## Advance

+ [q5?](#q5)
+ [q6?](#q6)

## 1. Write a query to find duplicate records in a customer table based on email addresses and explain how you'd handle them

```sql
SELECT email, COUNT(*) as count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;
```

[Table of Contents](#Table-of-Contents)

## 2. How would you calculate the Month-over-Month growth rate for orders? Write a query using the orders table with columns (order_date, order_amount)

[DDL](./sql/ddl/Q2.sql)

```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') as month,
    SUM(order_amount) as current_month_sales,
    LAG(SUM(order_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) as prev_month_sales,
    ((SUM(order_amount) - LAG(SUM(order_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))) / 
     LAG(SUM(order_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))) * 100 as growth_rate
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

## 3. Write a query to find the top 3 products by revenue in each category. Use tables: products(product_id, category_id, price) and sales(product_id, quantity)

```sql
SELECT 
    category_id,
    product_id,
    total_revenue,
    rank_num
FROM (
    SELECT 
        p.category_id,
        p.product_id,
        SUM(p.price * s.quantity) as total_revenue,
        RANK() OVER (PARTITION BY p.category_id ORDER BY SUM(p.price * s.quantity) DESC) as rank_num
    FROM products p
    JOIN sales s ON p.product_id = s.product_id
    GROUP BY p.category_id, p.product_id
) ranked
WHERE rank_num <= 3;
```

## 4. Design a query to identify customer purchasing patterns. Find customers who made purchases in consecutive months for at least 3 months. Use orders table with (customer_id, order_date)

```sql
WITH consecutive_months AS (
    SELECT 
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') as month,
        DATE_FORMAT(order_date, '%Y-%m') - 
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY DATE_FORMAT(order_date, '%Y-%m')) as grp
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
)
SELECT customer_id, COUNT(*) as consecutive_months
FROM consecutive_months
GROUP BY customer_id, grp
HAVING COUNT(*) >= 3;
```

## 5. Write a query to detect and handle slowly changing dimensions (SCD Type 2) for a customer address change. Include effective dates and current flag

```sql
INSERT INTO customer_address_history
SELECT 
    customer_id,
    new_address,
    CURRENT_TIMESTAMP as effective_start_date,
    '9999-12-31' as effective_end_date,
    'Y' as is_current
FROM new_customer_addresses
WHERE NOT EXISTS (
    SELECT 1 
    FROM customer_address_history
    WHERE customer_id = new_customer_addresses.customer_id
    AND address = new_customer_addresses.new_address
    AND is_current = 'Y'
);

UPDATE customer_address_history
SET effective_end_date = CURRENT_TIMESTAMP,
    is_current = 'N'
WHERE customer_id IN (SELECT customer_id FROM new_customer_addresses)
AND is_current = 'Y';
```

## 6. Create a query to calculate the running total of transactions and a 7-day moving average for each user. Handle missing days in the data

```sql
WITH date_spine AS (
    SELECT generate_series(
        (SELECT MIN(transaction_date) FROM transactions),
        (SELECT MAX(transaction_date) FROM transactions),
        INTERVAL '1 day'
    ) as date
),
daily_totals AS (
    SELECT 
        ds.date,
        user_id,
        COALESCE(SUM(amount), 0) as daily_amount
    FROM date_spine ds
    CROSS JOIN (SELECT DISTINCT user_id FROM transactions) u
    LEFT JOIN transactions t 
        ON ds.date = t.transaction_date 
        AND u.user_id = t.user_id
    GROUP BY ds.date, user_id
)
SELECT 
    date,
    user_id,
    SUM(daily_amount) OVER (PARTITION BY user_id ORDER BY date) as running_total,
    AVG(daily_amount) OVER (
        PARTITION BY user_id 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7d
FROM daily_totals;
```

## 7. Design a query to implement a sessionization algorithm that groups user events into sessions with a 30-minute inactivity timeout. Include logic to handle edge cases like midnight boundary crossing

```sql
WITH numbered_events AS (
    SELECT 
        user_id,
        event_timestamp,
        LAG(event_timestamp) OVER (
            PARTITION BY user_id 
            ORDER BY event_timestamp
        ) as prev_timestamp,
        CASE 
            WHEN EXTRACT(EPOCH FROM (
                event_timestamp - LAG(event_timestamp) OVER (
                    PARTITION BY user_id 
                    ORDER BY event_timestamp
                )
            )) > 1800 THEN 1
            ELSE 0
        END as is_new_session
    FROM user_events
),
session_groups AS (
    SELECT 
        user_id,
        event_timestamp,
        SUM(is_new_session) OVER (
            PARTITION BY user_id 
            ORDER BY event_timestamp
        ) as session_id
    FROM numbered_events
)
SELECT 
    user_id,
    MIN(event_timestamp) as session_start,
    MAX(event_timestamp) as session_end,
    COUNT(*) as events_in_session,
    EXTRACT(EPOCH FROM (
        MAX(event_timestamp) - MIN(event_timestamp)
    ))/60 as session_duration_minutes
FROM session_groups
GROUP BY user_id, session_id;
```

## 8. Create a query to implement a market basket analysis that finds products frequently bought together (support > 5%) and calculates confidence scores. Handle performance for large datasets

```sql
WITH product_pairs AS (
    SELECT 
        t1.product_id as product1,
        t2.product_id as product2,
        COUNT(DISTINCT t1.order_id) as pair_count,
        (SELECT COUNT(DISTINCT order_id) FROM orders) as total_orders
    FROM order_items t1
    JOIN order_items t2 
        ON t1.order_id = t2.order_id
        AND t1.product_id < t2.product_id
    GROUP BY t1.product_id, t2.product_id
    HAVING COUNT(DISTINCT t1.order_id)::float / 
           (SELECT COUNT(DISTINCT order_id) FROM orders) > 0.05
),
product_counts AS (
    SELECT 
        product_id,
        COUNT(DISTINCT order_id) as product_count
    FROM order_items
    GROUP BY product_id
)
SELECT 
    pp.product1,
    pp.product2,
    pp.pair_count,
    (pp.pair_count::float / pp.total_orders) as support,
    (pp.pair_count::float / pc1.product_count) as confidence_1_2,
    (pp.pair_count::float / pc2.product_count) as confidence_2_1
FROM product_pairs pp
JOIN product_counts pc1 ON pp.product1 = pc1.product_id
JOIN product_counts pc2 ON pp.product2 = pc2.product_id;
```

## 9. Write a query to implement a recommendation engine using collaborative filtering. Calculate user similarity scores and recommend products based on similar users' purchases. Include performance optimization strategies

```sql
WITH user_product_matrix AS (
    SELECT 
        user_id,
        product_id,
        COUNT(*) as purchase_count,
        AVG(COUNT(*)) OVER (PARTITION BY user_id) as user_avg_purchases
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY user_id, product_id
),
user_similarity AS (
    SELECT 
        u1.user_id as user1,
        u2.user_id as user2,
        CORR(
            (u1.purchase_count - u1.user_avg_purchases),
            (u2.purchase_count - u2.user_avg_purchases)
        ) as similarity_score
    FROM user_product_matrix u1
    JOIN user_product_matrix u2 
        ON u1.product_id = u2.product_id
        AND u1.user_id < u2.user_id
    GROUP BY u1.user_id, u2.user_id
    HAVING COUNT(*) >= 5
),
recommendations AS (
    SELECT 
        us.user1 as target_user,
        oi.product_id,
        SUM(us.similarity_score * upm.purchase_count) as weighted_score,
        COUNT(DISTINCT us.user2) as similar_users_count
    FROM user_similarity us
    JOIN orders o ON us.user2 = o.user_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN user_product_matrix upm 
        ON us.user2 = upm.user_id 
        AND oi.product_id = upm.product_id
    WHERE NOT EXISTS (
        SELECT 1 
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        WHERE o2.user_id = us.user1
        AND oi2.product_id = oi.product_id
    )
    GROUP BY us.user1, oi.product_id
)
SELECT 
    target_user,
    product_id,
    weighted_score,
    similar_users_count,
    RANK() OVER (
        PARTITION BY target_user 
        ORDER BY weighted_score DESC, similar_users_count DESC
    ) as recommendation_rank
FROM recommendations
WHERE similar_users_count >= 3;
```