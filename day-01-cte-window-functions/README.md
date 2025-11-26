# Day 01 - CTEs, Window Functions & Subqueries

**Time spent:** ~3 hours  
**Goal:**  
- Get practice with:
  - Subqueries in `WHERE`
  - Common Table Expressions (CTEs)
  - Window functions (`SUM() OVER`, `DENSE_RANK()`, etc.)
- Solve the same problem in multiple ways (subquery vs CTE vs window function)
- Build a small, realistic practice example for my portfolio

All SQL for this mini-project is in the `.sql` file in this folder  
(e.g. `sql-cte-window-function.sql`).

---

## Dataset & Setup

I created a small test database to keep the focus on SQL logic:

- **Database:** `cte_window_test_db_orders`
- **Tables:**
  - `employees` – basic employee data:
    - `employee_id`, `employee_name`, `department`, `yearly_salary`
  - `orders` – simple sales data:
    - `order_id`, `employee_id`, `sale_amount`, `order_date`, FK to `employees.employee_id`

The data is tiny but good enough to test aggregations, joins, and window functions.

---

## What I Practiced

### 1. Subqueries

- **Filter by aggregate:**  
  - Find employees whose salary is **above the average salary** using a scalar subquery in the `WHERE` clause.
- **“Anti-join” style query:**  
  - Find employees who **never made any sales** using `WHERE employee_id NOT IN (SELECT employee_id FROM orders)`.

This was mainly to get comfortable using subqueries to:
- Compare values to aggregated results
- Filter based on existence / non-existence in another table

---

### 2. CTEs (Common Table Expressions)

I used CTEs to structure multi-step logic more clearly:

- Compute **total sales per employee**.
- Compute **total company sales**.
- Join those pieces to calculate **each employee’s percentage of total sales**.

I wrote **multiple versions** of this idea:
- One with **two CTEs** (one for total company sales, one for per-employee sales).
- One with a **CTE + scalar subquery** on the CTE to get the grand total.

The goal was not to “get the answer”, but to see how CTEs can:
- Break a query into readable steps
- Be reused within the same query

---

### 3. Window Functions

I practiced several window function patterns:

- **Running total of sales over time:**
  - `SUM(sale_amount) OVER (ORDER BY order_date)` to show a running total of sales as dates progress.
- **Ranking salaries inside each department:**
  - `DENSE_RANK() OVER (PARTITION BY department ORDER BY yearly_salary DESC)`  
    to find the salary rank of each employee within their department.
- **Top earners per department:**
  - Use `DENSE_RANK` in a CTE, then filter to `rank = 1` to get the **highest earner in each department**.
- **Highest single sale per department:**
  - Join `employees` and `orders`, then use `DENSE_RANK` over `sale_amount` partitioned by department to find the **largest single order per department**.

I also built a **window function version** of the sales-percentage problem:
- Using `SUM(SUM(sale_amount)) OVER ()` to get a total across grouped rows without a separate CTE.

---

## How I Approached It

I intentionally tried **multiple approaches to the same problems**, for example:

- Calculating `% of total sales`:
  - Once with **CTEs + joins**
  - Once with **window functions**
  - Once combining **CTE + scalar subquery**

This was less about writing “perfect” SQL and more about:
- Seeing how the same logic looks in different styles
- Understanding trade-offs in readability and flexibility

---

## Key Learnings

- **Subqueries** are great for:
  - “Compare to an aggregate” logic (e.g. above-average salary)
  - “Has / has not” patterns like employees with no orders
- **CTEs**:
  - Make complex queries easier to read and reason about.
  - Let me separate intermediate steps (per-employee totals, company totals).
- **Window functions**:
  - Simplify running totals and ranking problems.
  - `DENSE_RANK` is very useful for “top 1 per group” without messy `TOP` + `GROUP BY` hacks.
- Solving the **same problem in several ways** (subquery vs CTE vs window function) helped me:
  - Understand when each tool is most natural
  - Recognize common SQL patterns I can reuse in real projects

---

## Next Steps

- Add more window function practice:
  - Compare `ROW_NUMBER`, `RANK`, and `DENSE_RANK` with ties.
  - Try `PARTITION BY` with multiple columns.
- Add edge cases to the data:
  - NULL salaries, missing employee IDs in orders, tied sales amounts.
- Refine some of these queries into “before vs after” examples to show:
  - Plain subquery/aggregation vs cleaner window function / CTE solutions
- Build a “Day 02” folder focusing on:
  - Cleaning Data

---

All of the actual SQL code for these exercises is in the `.sql` file in this folder.
This README is meant to explain what I was trying to learn and what each section of the script is doing.
