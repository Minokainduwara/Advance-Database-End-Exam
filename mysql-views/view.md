# MySQL Views

## 1. What Is a View?

A **view** in MySQL is a virtual table based on the result-set of an SQL statement. Unlike a base table, a view does not store data physically; it is a stored query that retrieves data from one or more underlying tables every time it is accessed. Because a view is executed against the live tables, it always reflects up-to-date data.

In essence:

- A view looks and behaves like a table (you can `SELECT` from it).
- A view contains no data of its own — it is a saved `SELECT` statement.
- Changes to the underlying tables are immediately visible through the view.

---

## 2. Why Use Views?

| Benefit | Description |
|---------|-------------|
| **Data Abstraction** | Hide complex joins, filters, and calculations behind a simple interface. |
| **Security** | Grant users access to specific columns or rows without exposing the entire table. |
| **Reusability** | Save frequently used queries and reuse them across applications. |
| **Consistency** | Ensure everyone uses the same definition of a report or calculation. |
| **Simplified Queries** | Complex multi-table queries become simple `SELECT * FROM view_name`. |

---

## 3. Creating a View

### Syntax

```sql
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

### Example — Simple View

Using the `pr01` database schema from `labsheet1.sql`, we can create a view that lists staff names and salaries:

```sql
USE pr01;

CREATE VIEW staff_salaries AS
SELECT l_id, l_name, l_desig, l_salary
FROM academic_staff;

-- Query the view like a regular table
SELECT * FROM staff_salaries;
```

**Output:**

| l_id | l_name | l_desig | l_salary |
|------|--------|---------|----------|
| l01 | Kasun | Lecturer | 35000.00 |
| l02 | Mahesh | Senior Lecturer | 45000.00 |
| l03 | Udaya | Professor | 62000.00 |
| l04 | Nadun | Senior Lecturer | 45000.00 |

---

## 4. View with JOIN

Views are especially useful for hiding multi-table joins. The `labsheet1.sql` file already defines an `all_projects` view:

```sql
CREATE VIEW all_projects AS
SELECT
    p.pr_id,
    p.pr_name,
    p.pr_budget,
    d.d_name
FROM project p
JOIN department d ON p.pr_d_id = d.d_id;

SELECT * FROM all_projects;
```

**Output:**

| pr_id | pr_name | pr_budget | d_name |
|-------|---------|-----------|--------|
| pr01 | Eagle Eye | 300000.00 | ICT |
| pr02 | Hill Climber | 250000.00 | ENT |
| pr03 | Glowing Fish | 400000.00 | BT |

---

## 5. View with Aggregation and Calculations

You can include aggregate functions, arithmetic expressions, and aliases in a view:

```sql
CREATE VIEW project_finance AS
SELECT
    p.pr_id,
    p.pr_name,
    p.pr_budget,
    p.pr_budget * 0.70 AS university_grant,
    p.pr_budget * 0.30 AS department_share
FROM project p;

SELECT * FROM project_finance;
```

---

## 6. Viewing View Definitions

To inspect how a view was created:

```sql
SHOW CREATE VIEW view_name\G
```

Example:

```sql
SHOW CREATE VIEW all_projects\G
```

To list all views in the current database:

```sql
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'pr01';
```


---

## 7. Modifying a View

### Using CREATE OR REPLACE VIEW

If a view already exists, you can redefine it without dropping it first:

```sql
CREATE OR REPLACE VIEW staff_salaries AS
SELECT l_id, l_name, l_desig, l_salary, l_allowance
FROM academic_staff;
```

### Using ALTER VIEW

```sql
ALTER VIEW staff_salaries AS
SELECT l_id, l_name, l_salary
FROM academic_staff
WHERE l_salary > 40000;
```

---

## 8. Dropping a View

```sql
DROP VIEW IF EXISTS view_name;
```

Example:

```sql
DROP VIEW IF EXISTS staff_salaries;
```

Dropping a view removes only the view definition; the underlying tables and data remain untouched.

---

## 9. Updatable Views

Some views are **updatable**, meaning you can `INSERT`, `UPDATE`, or `DELETE` through the view, and the changes propagate to the base table(s).

### Conditions for an Updatable View

A view is updatable only if:

- It references a single base table (no joins).
- It does not use aggregate functions (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`).
- It does not use `DISTINCT`, `GROUP BY`, `HAVING`, `UNION`, `LIMIT`, or subqueries in the SELECT list.
- It does not select only literal values or non-updatable expressions.

### Example — Updatable View

```sql
CREATE OR REPLACE VIEW senior_staff AS
SELECT l_id, l_name, l_desig, l_salary
FROM academic_staff
WHERE l_desig = 'Senior Lecturer';

-- Update through the view
UPDATE senior_staff
SET l_salary = 48000
WHERE l_id = 'l02';

-- Insert through the view (must satisfy the WHERE condition)
INSERT INTO senior_staff (l_id, l_name, l_desig, l_salary)
VALUES ('l05', 'Saman', 'Senior Lecturer', 47000);

-- Delete through the view
DELETE FROM senior_staff
WHERE l_id = 'l05';
```

---

## 10. WITH CHECK OPTION

When inserting or updating rows through a view, MySQL does not automatically verify that the new data still satisfies the view's `WHERE` condition unless you use `WITH CHECK OPTION`.

```sql
CREATE OR REPLACE VIEW senior_staff AS
SELECT l_id, l_name, l_desig, l_salary
FROM academic_staff
WHERE l_desig = 'Senior Lecturer'
WITH CHECK OPTION;
```

With `WITH CHECK OPTION`, an `UPDATE` that changes `l_desig` to something other than `'Senior Lecturer'` will be rejected because the row would no longer appear in the view.

- `WITH CHECK OPTION` — checks against this view's condition.
- `WITH LOCAL CHECK OPTION` — checks only this view's condition, not underlying views.

---

## 11. Non-Updatable Views

Views involving joins, aggregations, or `DISTINCT` are read-only. Attempting to modify data through them produces an error.

Example — Read-only view (join-based):

```sql
-- This view cannot be used for INSERT/UPDATE/DELETE
CREATE VIEW all_projects AS
SELECT
    p.pr_id,
    p.pr_name,
    p.pr_budget,
    d.d_name
FROM project p
JOIN department d ON p.pr_d_id = d.d_id;
```


---

## 12. Complete Working Example

Below is a self-contained script you can run against the `pr01` schema:

```sql
USE pr01;

-- 1. Simple view
CREATE VIEW staff_basic AS
SELECT l_id, l_name, l_desig
FROM academic_staff;

-- 2. View with calculated column
CREATE VIEW staff_compensation AS
SELECT
    l_id,
    l_name,
    l_salary,
    l_allowance,
    (l_salary + l_allowance) AS total_compensation
FROM academic_staff;

-- 3. View joining multiple tables
CREATE VIEW staff_projects AS
SELECT
    a.l_name,
    a.l_desig,
    p.pr_name,
    p.pr_budget
FROM academic_staff a
JOIN work w ON a.l_id = w.w_l_id
JOIN project p ON w.w_pr_id = p.pr_id;

-- 4. Aggregated view
CREATE VIEW dept_project_summary AS
SELECT
    d.d_name,
    COUNT(p.pr_id) AS project_count,
    SUM(p.pr_budget) AS total_budget
FROM department d
LEFT JOIN project p ON d.d_id = p.pr_d_id
GROUP BY d.d_id, d.d_name;

-- Query all views
SELECT * FROM staff_basic;
SELECT * FROM staff_compensation;
SELECT * FROM staff_projects;
SELECT * FROM dept_project_summary;

-- Cleanup
DROP VIEW IF EXISTS staff_basic;
DROP VIEW IF EXISTS staff_compensation;
DROP VIEW IF EXISTS staff_projects;
DROP VIEW IF EXISTS dept_project_summary;
```

---

## 13. Advantages and Disadvantages

### Advantages

- Simplifies complex queries for end users and applications.
- Provides a security layer by exposing only selected columns/rows.
- Encapsulates business logic (calculations, filters) in one place.
- Insulates applications from schema changes (the view definition can be adjusted while keeping the same column names).

### Disadvantages / Limitations

- Performance overhead: complex views may be slower than querying base tables directly.
- Not all views are updatable.
- Dependent on base tables; dropping or altering a base table can break views.
- MySQL does not support indexed/materialized views natively (unlike some other DBMSs); the view query runs each time.

---

## 14. Best Practices

1. Use views to encapsulate frequently reused, complex joins and calculations.
2. Prefer `CREATE OR REPLACE VIEW` when redefining existing views.
3. Use `WITH CHECK OPTION` when applications write data through updatable views.
4. Avoid nesting too many views (view on top of view), as it harms readability and performance.
5. Document the purpose of each view and the base tables it depends on.
6. Drop unused views to keep the schema clean.

---

## 15. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Create view | `CREATE VIEW v AS SELECT ... FROM ...;` |
| Create or replace | `CREATE OR REPLACE VIEW v AS SELECT ...;` |
| Alter view | `ALTER VIEW v AS SELECT ...;` |
| Drop view | `DROP VIEW IF EXISTS v;` |
| Show definition | `SHOW CREATE VIEW v\G` |
| List all views | `SELECT * FROM information_schema.views WHERE table_schema = 'db';` |
| Updatable + check | `CREATE VIEW v AS SELECT ... WHERE ... WITH CHECK OPTION;` |

