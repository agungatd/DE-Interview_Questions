-- This sample data is structured to show clear rankings within each category:
-- Electronics (Category 1) top 3:

-- Smartphones (~$66,500 revenue)
-- Tablets (~$57,500 revenue)
-- Laptops (~$45,500 revenue)

-- Clothing (Category 2) top 3:

-- Winter Jackets (~$16,200 revenue)
-- Jeans (~$16,200 revenue)
-- Sneakers (~$7,200 revenue)

-- Books (Category 3) top 3:

-- Technical Books (~$9,500 revenue)
-- Cookbooks (~$8,700 revenue)
-- Fiction Novels (~$7,600 revenue)

-- Features of the sample data:

-- 3 distinct categories with 5 products each
-- Realistic price points for each category
-- Varying quantities sold to create clear rankings
-- Sales spread across two months
-- Added helpful columns (product_name, sale_date) for better data organization
-- Foreign key constraint for referential integrity
-- --------------------------------------------------------------------------

-- Create products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,  -- Added for clarity
    price DECIMAL(10,2) NOT NULL
);

-- Create sales table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL,  -- Added for data organization
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample product data
INSERT INTO products (product_id, category_id, product_name, price) VALUES
    -- Electronics (category_id = 1)
    (101, 1, 'Smartphone', 699.99),
    (102, 1, 'Laptop', 1299.99),
    (103, 1, 'Tablet', 499.99),
    (104, 1, 'Headphones', 199.99),
    (105, 1, 'Smartwatch', 299.99),
    
    -- Clothing (category_id = 2)
    (201, 2, 'Winter Jacket', 89.99),
    (202, 2, 'Jeans', 59.99),
    (203, 2, 'Sneakers', 79.99),
    (204, 2, 'T-Shirt', 24.99),
    (205, 2, 'Dress', 69.99),
    
    -- Books (category_id = 3)
    (301, 3, 'Fiction Novel', 19.99),
    (302, 3, 'Cookbook', 29.99),
    (303, 3, 'Technical Book', 49.99),
    (304, 3, 'Art Book', 39.99),
    (305, 3, 'Biography', 24.99);

-- Insert sample sales data
INSERT INTO sales (product_id, quantity, sale_date) VALUES
    -- Electronics sales
    (101, 50, '2024-01-15'),  -- Smartphone: 34,999.50
    (101, 45, '2024-02-15'),
    (102, 20, '2024-01-20'),  -- Laptop: 25,999.80
    (102, 15, '2024-02-20'),
    (103, 60, '2024-01-25'),  -- Tablet: 29,999.40
    (103, 55, '2024-02-25'),
    (104, 40, '2024-01-10'),  -- Headphones: 7,999.60
    (105, 30, '2024-02-10'),  -- Smartwatch: 8,999.70
    
    -- Clothing sales
    (201, 100, '2024-01-15'), -- Winter Jacket: 8,999
    (201, 80, '2024-02-15'),
    (202, 150, '2024-01-20'), -- Jeans: 8,998.50
    (202, 120, '2024-02-20'),
    (203, 90, '2024-01-25'),  -- Sneakers: 7,199.10
    (204, 200, '2024-02-25'), -- T-Shirt: 4,998
    (205, 70, '2024-01-10'),  -- Dress: 4,899.30
    
    -- Books sales
    (301, 200, '2024-01-15'), -- Fiction Novel: 3,998
    (301, 180, '2024-02-15'),
    (302, 150, '2024-01-20'), -- Cookbook: 4,498.50
    (302, 140, '2024-02-20'),
    (303, 100, '2024-01-25'), -- Technical Book: 4,999
    (303, 90, '2024-02-25'),
    (304, 80, '2024-01-10'),  -- Art Book: 3,199.20
    (305, 120, '2024-02-10'); -- Biography: 2,998.80