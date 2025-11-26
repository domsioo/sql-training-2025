CREATE DATABASE cte_window_test_db_orders
GO

USE cte_window_test_db_orders

CREATE TABLE employees (
	employee_id INT PRIMARY KEY,
	employee_name NVARCHAR(50),
	department NVARCHAR(50),
	yearly_salary INT
);

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
	employee_id INT,
	sale_amount DECIMAL(10,2),
	orde_date DATE,
	FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO employees VALUES 
(106, 'Martha', 'Sales', 80000),
(101, 'Alice', 'Sales', 50000),
(102, 'Bob', 'Sales', 60000),
(103, 'Charlie', 'IT', 70000),
(104, 'Diana', 'IT', 55000),
(105, 'Eve', 'Marketing', 45000);

INSERT INTO orders VALUES
(1, 101, 200.00, '2024-01-01'),
(2, 101, 300.00, '2024-01-15'),
(3, 102, 150.00, '2024-01-10'),
(4, 103, 400.00, '2024-01-20'),
(5, 101, 250.00, '2024-02-01'),
(6, 104, 500.00, '2024-02-05'),
(7, 102, 350.00, '2024-02-10'),
(8, 103, 200.00, '2024-02-15'),
(9, 105, 600.00, '2024-02-20');

SELECT * FROM employees 
SELECT * FROM orders

-- Find all employees who earn more than the average salary of all employees.

SELECT employee_id, employee_name, department, yearly_salary
FROM employees
WHERE yearly_salary > (
	SELECT AVG(yearly_salary)
	FROM employees
)

-- Find employees who have never made any sales.

SELECT employee_id, employee_name, department, yearly_salary 
FROM employees
WHERE employee_id NOT IN (
	SELECT employee_id FROM orders
)

--WHERE employee_id NOT IN (
--	SELECT e.employee_id
--	FROM orders o
--	INNER JOIN employees e
--	ON o.employee_id = e.employee_id
--)

-- Using a CTE, show each employee's name along with their total sales 
-- and the percentage their sales represent of the total company sales.

SELECT * FROM orders;

WITH sales_cte AS (
    -- total sales (one row)
    SELECT SUM(sale_amount) AS total_sale_amount
    FROM orders
),
employee_sales AS (
    -- sales per employee
    SELECT 
        employee_id,
        SUM(sale_amount) AS employee_sale_amount
    FROM orders
    GROUP BY employee_id
)
SELECT 
    e.employee_id,
    e.employee_name,
    es.employee_sale_amount,
    100.0 * es.employee_sale_amount / s.total_sale_amount AS percent_of_total_sales
FROM employee_sales es
CROSS JOIN sales_cte s          -- brings in the total
JOIN Employees e
    ON e.employee_id = es.employee_id;

-- same idea window func
SELECT
	SUM(sale_amount) AS employee_sale_amount,
	100.0 * SUM(sale_amount) / SUM(SUM(sale_amount)) OVER () AS percent_of_total_sales
FROM orders
GROUP BY employee_id;

-- simplest form
WITH employee_sales AS (
    SELECT 
        employee_id,
        SUM(sale_amount) AS employee_total
    FROM orders
    GROUP BY employee_id
)
SELECT 
    e.employee_name,
    es.employee_total,
    100.0 * es.employee_total / (SELECT SUM(employee_total) FROM employee_sales) AS percent_total
FROM employee_sales es
JOIN employees e ON es.employee_id = e.employee_id;

-- Show each employee's sales, along with a running total of sales ordered by date.
SELECT 
	order_id,
	employee_id,
	sale_amount,
	orde_date,
	SUM(sale_amount) OVER(ORDER BY orde_date) as running_total
FROM orders
ORDER BY orde_date

-- Rank employees within each department by their salary (highest salary gets rank 1). 
-- Show department, name, salary, and rank.

SELECT 
	employee_name, 
	department, 
	yearly_salary,
	DENSE_RANK() OVER(PARTITION BY department ORDER BY yearly_salary DESC) AS rnk
FROM employees;


-- TOP 1 HIGHEST EARNER
WITH cte_sales AS (
	SELECT 
		employee_id,
		department,
		DENSE_RANK() OVER(PARTITION BY department ORDER BY yearly_salary DESC) AS rnk
	FROM employees
)
SELECT e.employee_id, e.employee_name, e.yearly_salary, cte. department, cte.rnk
FROM cte_sales cte
INNER JOIN employees e
ON e.employee_id = cte.employee_id
WHERE rnk = 1

-- "find the employee with the highest single sale in each department"

WITH max_sale_per_dept_cte AS (
	SELECT 
		o.employee_id, 
		e.employee_name,
		o.sale_amount,
		e.department,
		DENSE_RANK() OVER(PARTITION BY e.department ORDER BY o.sale_amount DESC) as max_sale_rnk
	FROM orders o
	INNER JOIN employees e ON e.employee_id = o.employee_id
)
SELECT 
	employee_id, 
	employee_name,
	sale_amount,
	department
FROM max_sale_per_dept_cte
WHERE max_sale_rnk = 1
ORDER BY employee_id 