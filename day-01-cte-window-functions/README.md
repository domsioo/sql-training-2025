\# Day 01 - CTEs, Window Functions \& Subqueries



\*\*Time spent:\*\* ~3 hours  

\*\*Goal:\*\*  

\- Get practice with:

&nbsp; - Subqueries in `WHERE`

&nbsp; - Common Table Expressions (CTEs)

&nbsp; - Window functions (`SUM() OVER`, `DENSE\_RANK()`, etc.)

\- Solve the same problem in multiple ways (subquery vs CTE vs window function)

\- Build a small, realistic practice example for my portfolio



All SQL for this mini-project is in the `.sql` file in this folder  

(e.g. `sql-cte-window-function.sql`).



---



\## Dataset \& Setup



I created a small test database to keep the focus on SQL logic:



\- \*\*Database:\*\* `cte\_window\_test\_db\_orders`

\- \*\*Tables:\*\*

&nbsp; - `employees` – basic employee data:

&nbsp;   - `employee\_id`, `employee\_name`, `department`, `yearly\_salary`

&nbsp; - `orders` – simple sales data:

&nbsp;   - `order\_id`, `employee\_id`, `sale\_amount`, `order\_date`, FK to `employees.employee\_id`



The data is tiny but good enough to test aggregations, joins, and window functions.



---



\## What I Practiced



\### 1. Subqueries



\- \*\*Filter by aggregate:\*\*  

&nbsp; - Find employees whose salary is \*\*above the average salary\*\* using a scalar subquery in the `WHERE` clause.

\- \*\*“Anti-join” style query:\*\*  

&nbsp; - Find employees who \*\*never made any sales\*\* using `WHERE employee\_id NOT IN (SELECT employee\_id FROM orders)`.



This was mainly to get comfortable using subqueries to:

\- Compare values to aggregated results

\- Filter based on existence / non-existence in another table



---



\### 2. CTEs (Common Table Expressions)



I used CTEs to structure multi-step logic more clearly:



\- Compute \*\*total sales per employee\*\*.

\- Compute \*\*total company sales\*\*.

\- Join those pieces to calculate \*\*each employee’s percentage of total sales\*\*.



I wrote \*\*multiple versions\*\* of this idea:

\- One with \*\*two CTEs\*\* (one for total company sales, one for per-employee sales).

\- One with a \*\*CTE + scalar subquery\*\* on the CTE to get the grand total.



The goal was not to “get the answer”, but to see how CTEs can:

\- Break a query into readable steps

\- Be reused within the same query



---



\### 3. Window Functions



I practiced several window function patterns:



\- \*\*Running total of sales over time:\*\*

&nbsp; - `SUM(sale\_amount) OVER (ORDER BY order\_date)` to show a running total of sales as dates progress.

\- \*\*Ranking salaries inside each department:\*\*

&nbsp; - `DENSE\_RANK() OVER (PARTITION BY department ORDER BY yearly\_salary DESC)`  

&nbsp;   to find the salary rank of each employee within their department.

\- \*\*Top earners per department:\*\*

&nbsp; - Use `DENSE\_RANK` in a CTE, then filter to `rank = 1` to get the \*\*highest earner in each department\*\*.

\- \*\*Highest single sale per department:\*\*

&nbsp; - Join `employees` and `orders`, then use `DENSE\_RANK` over `sale\_amount` partitioned by department to find the \*\*largest single order per department\*\*.



I also built a \*\*window function version\*\* of the sales-percentage problem:

\- Using `SUM(SUM(sale\_amount)) OVER ()` to get a total across grouped rows without a separate CTE.



---



\## How I Approached It



I intentionally tried \*\*multiple approaches to the same problems\*\*, for example:



\- Calculating `% of total sales`:

&nbsp; - Once with \*\*CTEs + joins\*\*

&nbsp; - Once with \*\*window functions\*\*

&nbsp; - Once combining \*\*CTE + scalar subquery\*\*



This was less about writing “perfect” SQL and more about:

\- Seeing how the same logic looks in different styles

\- Understanding trade-offs in readability and flexibility



---



\## Key Learnings



\- \*\*Subqueries\*\* are great for:

&nbsp; - “Compare to an aggregate” logic (e.g. above-average salary)

&nbsp; - “Has / has not” patterns like employees with no orders

\- \*\*CTEs\*\*:

&nbsp; - Make complex queries easier to read and reason about.

&nbsp; - Let me separate intermediate steps (per-employee totals, company totals).

\- \*\*Window functions\*\*:

&nbsp; - Simplify running totals and ranking problems.

&nbsp; - `DENSE\_RANK` is very useful for “top 1 per group” without messy `TOP` + `GROUP BY` hacks.

\- Solving the \*\*same problem in several ways\*\* (subquery vs CTE vs window function) helped me:

&nbsp; - Understand when each tool is most natural

&nbsp; - Recognize common SQL patterns I can reuse in real projects



---



\## Next Steps



\- Add more window function practice:

&nbsp; - Compare `ROW\_NUMBER`, `RANK`, and `DENSE\_RANK` with ties.

&nbsp; - Try `PARTITION BY` with multiple columns.

\- Add edge cases to the data:

&nbsp; - NULL salaries, missing employee IDs in orders, tied sales amounts.

\- Refine some of these queries into “before vs after” examples to show:

&nbsp; - Plain subquery/aggregation vs cleaner window function / CTE solutions

\- Build a “Day 02” folder focusing on:

&nbsp; - Cleaning Data



---



All of the actual SQL code for these exercises is in the `.sql` file in this folder.

This README is meant to explain what I was trying to learn and what each section of the script is doing.

