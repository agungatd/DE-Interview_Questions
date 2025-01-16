-- When you run your query against this sample data, you'll see:

-- Growth of 20% from January to February
-- Decline of 5% from February to March
-- Growth of 15% from March to April
-- Growth of 10% from April to May
-- Growth of 10% from May to June

-- The sample data includes:

-- 6 months of data (January through June 2024)
-- 4 orders per month to show realistic distribution
-- Varying order amounts to demonstrate real-world scenarios
-- A mix of growth and decline to test the growth rate calculation
-- --------------------------------------------------------------------------

-- Create the orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL
);

-- Insert sample data covering 6 months with varying growth patterns
INSERT INTO orders (order_date, order_amount) VALUES
    -- January data (total: 10000)
    ('2024-01-05', 2500.00),
    ('2024-01-12', 3000.00),
    ('2024-01-20', 2800.00),
    ('2024-01-28', 1700.00),
    
    -- February data (total: 12000, 20% growth)
    ('2024-02-03', 3200.00),
    ('2024-02-11', 3500.00),
    ('2024-02-19', 2800.00),
    ('2024-02-26', 2500.00),
    
    -- March data (total: 11400, -5% decline)
    ('2024-03-04', 2900.00),
    ('2024-03-12', 3100.00),
    ('2024-03-21', 2800.00),
    ('2024-03-29', 2600.00),
    
    -- April data (total: 13110, 15% growth)
    ('2024-04-05', 3500.00),
    ('2024-04-13', 3600.00),
    ('2024-04-21', 3210.00),
    ('2024-04-28', 2800.00),
    
    -- May data (total: 14421, 10% growth)
    ('2024-05-04', 3800.00),
    ('2024-05-12', 3721.00),
    ('2024-05-20', 3500.00),
    ('2024-05-27', 3400.00),
    
    -- June data (total: 15863.10, 10% growth)
    ('2024-06-03', 4100.00),
    ('2024-06-11', 4063.10),
    ('2024-06-19', 3900.00),
    ('2024-06-26', 3800.00);