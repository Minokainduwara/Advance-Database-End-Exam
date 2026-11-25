# MySQL Functions

## 1. What Is a Function?

A **function** in MySQL is a named routine that accepts zero or more input parameters, performs an operation, and returns a single value. Functions can be used inside SQL statements (`SELECT`, `WHERE`, `JOIN`, `SET`, etc.) wherever an expression is expected.

There are two main categories:

| Type | Description |
|------|-------------|
| **Built-in functions** | Predefined by MySQL (e.g., `CONCAT`, `NOW()`, `COUNT()`, `ROUND()`). |
| **User-defined (stored) functions** | Created by the user with `CREATE FUNCTION`; encapsulates custom logic. |

Unlike stored procedures, functions **must return a value** and can be invoked directly within expressions.

---

## 2. Built-In Functions

MySQL provides a rich set of built-in functions. Below are the most commonly used categories, with examples using the `pr02` schema from `labsheet2.sql` (`customers` and `Employee` tables).

### 2.1 String Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `CONCAT(str1, str2, ...)` | Joins strings together | `CONCAT(first_name, ' ', last_name)` |
| `CONCAT_WS(separator, str1, str2, ...)` | Joins with separator, skips NULLs | `CONCAT_WS(' ', first_name, last_name)` |
| `UPPER(str)` / `LOWER(str)` | Converts case | `UPPER(NAME)` |
| `TRIM(str)` / `LTRIM` / `RTRIM` | Removes spaces | `TRIM(phone)` |
| `LENGTH(str)` | Returns string length in bytes | `LENGTH(email)` |
| `SUBSTRING(str, pos, len)` | Extracts a substring | `SUBSTRING(zip_code, 1, 5)` |
| `REPLACE(str, from, to)` | Replaces occurrences | `REPLACE(state, 'NY', 'New York')` |

**Example:**

```sql
USE pr02;

SELECT
    customer_id,
    CONCAT_WS(' ', first_name, last_name) AS full_name,
    UPPER(state) AS state_upper,
    LENGTH(email) AS email_length
FROM customers
LIMIT 5;
```


### 2.2 Numeric Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `ROUND(x, d)` | Rounds to `d` decimal places | `ROUND(SALARY, 0)` |
| `CEIL(x)` / `FLOOR(x)` | Round up / down | `CEIL(AGE / 2)` |
| `ABS(x)` | Absolute value | `ABS(SALARY - 5000)` |
| `MOD(n, m)` | Modulo (remainder) | `MOD(ID, 2)` |
| `POWER(x, y)` | x raised to y | `POWER(AGE, 2)` |
| `RAND()` | Random value 0–1 | `RAND()` |
| `GREATEST(a, b, ...)` / `LEAST(...)` | Highest / lowest value | `GREATEST(SALARY, 3000)` |

**Example:**

```sql
SELECT
    ID,
    NAME,
    SALARY,
    ROUND(SALARY * 1.10, 2) AS salary_with_raise
FROM Employee;
```

### 2.3 Date and Time Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `NOW()` | Current date and time | `NOW()` |
| `CURDATE()` | Current date | `CURDATE()` |
| `CURTIME()` | Current time | `CURTIME()` |
| `YEAR(date)` / `MONTH(date)` / `DAY(date)` | Extract parts | `YEAR(NOW())` |
| `DATE_ADD(date, INTERVAL n unit)` | Add interval | `DATE_ADD(NOW(), INTERVAL 7 DAY)` |
| `DATEDIFF(date1, date2)` | Days between two dates | `DATEDIFF(NOW(), '2024-01-01')` |
| `DATE_FORMAT(date, fmt)` | Format date as string | `DATE_FORMAT(NOW(), '%Y-%m-%d')` |

### 2.4 Aggregate Functions

Aggregate functions operate on a set of rows and return a single summary value. They are commonly used with `GROUP BY`.

| Function | Purpose |
|----------|---------|
| `COUNT(*)` | Number of rows |
| `SUM(expr)` | Total of values |
| `AVG(expr)` | Average of values |
| `MIN(expr)` | Minimum value |
| `MAX(expr)` | Maximum value |

**Example:**

```sql
SELECT
    COUNT(*) AS total_employees,
    AVG(SALARY) AS avg_salary,
    MIN(SALARY) AS min_salary,
    MAX(SALARY) AS max_salary,
    SUM(SALARY) AS total_payroll
FROM Employee;
```

### 2.5 Control Flow Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `IF(condition, val_true, val_false)` | Simple if-then-else | `IF(SALARY > 5000, 'High', 'Low')` |
| `CASE ... WHEN ... THEN ... ELSE ... END` | Searched case | `CASE WHEN AGE < 25 THEN 'Junior' ELSE 'Senior' END` |
| `COALESCE(val1, val2, ...)` | First non-NULL value | `COALESCE(phone, 'N/A')` |
| `NULLIF(val1, val2)` | NULL if equal, else val1 | `NULLIF(SALARY, 0)` |

**Example:**

```sql
SELECT
    NAME,
    SALARY,
    IF(SALARY >= 5000, 'High', 'Low') AS salary_band,
    COALESCE(phone, 'No phone on file') AS contact
FROM customers;
```


## 3. User-Defined (Stored) Functions

When built-in functions are not enough, you can create your own stored functions using `CREATE FUNCTION`.

### 3.1 Syntax

```sql
CREATE [OR REPLACE] FUNCTION function_name (param1 type1, param2 type2, ...)
RETURNS return_type
[function_characteristic]
BEGIN
    -- declarations and statements
    RETURN value;
END //
```

### Common Function Characteristics

| Characteristic | Meaning |
|----------------|---------|
| `DETERMINISTIC` | Always returns same result for same inputs (helps optimizer). |
| `NOT DETERMINISTIC` | May return different results (e.g., uses `NOW()`). |
| `READS SQL DATA` | Reads from tables but does not modify data. |
| `CONTAINS SQL` | Contains SQL but does not read/write tables. |
| `NO SQL` | Contains no SQL statements. |
| `MODIFIES SQL DATA` | Writes to tables (rarely used in functions). |

## 3.2 Examples Based on `labsheet2.sql`

The following stored functions are already defined in `labsheet2.sql` using the `pr02` schema.

### Scalar function — full name for one customer

```sql
DELIMITER //

CREATE FUNCTION fn_GetCustomerFullName(p_customer_id INT)
RETURNS VARCHAR(105)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_full_name VARCHAR(105);

    SELECT CONCAT_WS(' ', first_name, last_name) INTO v_full_name
    FROM customers
    WHERE customer_id = p_customer_id;

    RETURN v_full_name;
END //

DELIMITER ;

-- Usage
SELECT
    customer_id,
    fn_GetCustomerFullName(customer_id) AS Name
FROM customers
LIMIT 10;
```

### Scalar function — average employee salary

```sql
DELIMITER //

CREATE FUNCTION get_emp_avg()
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_salary DECIMAL(10,2);

    SELECT AVG(SALARY) INTO avg_salary
    FROM Employee;

    RETURN avg_salary;
END //

DELIMITER ;

-- Usage
SELECT get_emp_avg() AS AverageSalary;
```

The function can then be used inline in a query:

```sql
SELECT ID, NAME, SALARY
FROM Employee
WHERE SALARY >= get_emp_avg();
```

### Scalar function — compute a line total with discount

```sql
DELIMITER //

CREATE FUNCTION fn_ComputeLineTot(
    p_quantity   INT,
    p_unit_price DECIMAL(10,2),
    p_discount   DECIMAL(5,4)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN ROUND(p_quantity * p_unit_price * (1.0 - COALESCE(p_discount, 0.0)), 2);
END //

DELIMITER ;

-- Usage: Qty 3, Unit Price 25.00, 15% discount (0.15) -> 63.75
SELECT fn_ComputeLineTot(3, 25.00, 0.15) AS TotalPrice;
```


## 4. Calling and Using Functions

Stored functions can be used anywhere a scalar expression is allowed:

```sql
-- In a SELECT list
SELECT fn_GetCustomerFullName(customer_id) FROM customers;

-- In a WHERE clause
SELECT * FROM Employee WHERE SALARY >= get_emp_avg();

-- In a SET statement (within procedures/blocks)
SET @total = fn_ComputeLineTot(3, 25.00, 0.15);

-- In an INSERT / UPDATE
INSERT INTO order_lines (qty, unit_price, discount, line_total)
VALUES (3, 25.00, 0.15, fn_ComputeLineTot(3, 25.00, 0.15));
```

## 5. Viewing, Modifying, and Dropping Functions

### Show a function's definition

```sql
SHOW CREATE FUNCTION function_name\G
```

### List all user-defined functions in a database

```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'pr02' AND routine_type = 'FUNCTION';
```

### Alter / replace a function

MySQL does not have `ALTER FUNCTION`. To redefine a function, use `CREATE OR REPLACE FUNCTION` or drop and recreate:

```sql
CREATE OR REPLACE FUNCTION get_emp_avg()
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_salary DECIMAL(10,2);
    SELECT AVG(SALARY) INTO avg_salary FROM Employee;
    RETURN avg_salary;
END //
```

### Drop a function

```sql
DROP FUNCTION IF EXISTS function_name;
```

Example:

```sql
DROP FUNCTION IF EXISTS fn_GetCustomerFullName;
```

## 6. Functions vs. Stored Procedures

| Aspect | Stored Function | Stored Procedure |
|--------|----------------|------------------|
| Returns a value | **Yes** (`RETURN` required) | No (uses OUT parameters or result sets) |
| Can be used in SQL expressions | Yes | No |
| Can be called in SELECT/WHERE | Yes | No (use `CALL`) |
| Supports OUT/INOUT parameters | No | Yes |
| Typical use | Computations, lookups, formatting | Business logic, transactions, multi-step operations |


## 7. Complete Working Example

Below is a self-contained script you can run against the `pr02` schema. It creates and demonstrates several stored functions.

```sql
USE pr02;

-- 1. Function: customer full name
DELIMITER //

CREATE FUNCTION fn_GetCustomerFullName(p_customer_id INT)
RETURNS VARCHAR(105)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_full_name VARCHAR(105);
    SELECT CONCAT_WS(' ', first_name, last_name) INTO v_full_name
    FROM customers WHERE customer_id = p_customer_id;
    RETURN v_full_name;
END //

DELIMITER ;

-- 2. Function: average employee salary
DELIMITER //

CREATE FUNCTION get_emp_avg()
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_salary DECIMAL(10,2);
    SELECT AVG(SALARY) INTO avg_salary FROM Employee;
    RETURN avg_salary;
END //

DELIMITER ;

-- 3. Function: compute line total
DELIMITER //

CREATE FUNCTION fn_ComputeLineTot(
    p_quantity INT,
    p_unit_price DECIMAL(10,2),
    p_discount DECIMAL(5,4)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN ROUND(p_quantity * p_unit_price * (1.0 - COALESCE(p_discount, 0.0)), 2);
END //

DELIMITER ;

-- --- Demonstrations ---

-- Use functions in SELECT
SELECT
    customer_id,
    fn_GetCustomerFullName(customer_id) AS customer_name
FROM customers
LIMIT 5;

SELECT get_emp_avg() AS average_salary;

SELECT fn_ComputeLineTot(3, 25.00, 0.15) AS line_total;

-- Use a function inside a WHERE clause
SELECT ID, NAME, SALARY
FROM Employee
WHERE SALARY >= get_emp_avg();

-- Built-in function examples
SELECT
    ID,
    NAME,
    SALARY,
    ROUND(SALARY * 1.10, 2) AS raised_salary,
    IF(SALARY >= 5000, 'High', 'Low') AS salary_band
FROM Employee;

-- --- Cleanup ---
DROP FUNCTION IF EXISTS fn_GetCustomerFullName;
DROP FUNCTION IF EXISTS get_emp_avg;
DROP FUNCTION IF EXISTS fn_ComputeLineTot;
```

## 8. Best Practices

1. **Always declare `DETERMINISTIC`** when the function output depends only on its inputs; it helps the query optimizer.
2. **Use `READS SQL DATA`** for functions that only read tables; avoid `MODIFIES SQL DATA` in functions unless absolutely necessary.
3. **Keep functions small and single-purpose.** A function should do one thing well (e.g., compute a value, format a string).
4. **Handle NULLs explicitly** using `COALESCE` or `IFNULL` to avoid unexpected NULL propagation.
5. **Prefer built-in functions** over writing custom logic when a built-in exists (they are usually faster and better tested).
6. **Avoid functions on indexed columns in WHERE clauses** when possible, as they can prevent index usage (e.g., `WHERE YEAR(date_col) = 2024` may not use an index on `date_col`).
7. **Use `CREATE OR REPLACE FUNCTION`** to redefine existing functions cleanly.
8. **Drop unused functions** to keep the schema clean.

## 9. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Call built-in function | `SELECT UPPER(name), ROUND(salary, 2) FROM table;` |
| Create stored function | `CREATE FUNCTION f(p INT) RETURNS INT DETERMINISTIC BEGIN ... RETURN x; END //` |
| Create or replace | `CREATE OR REPLACE FUNCTION f(...) RETURNS ... BEGIN ... END //` |
| Show definition | `SHOW CREATE FUNCTION f\G` |
| List all functions | `SELECT * FROM information_schema.routines WHERE routine_type='FUNCTION' AND routine_schema='db';` |
| Drop function | `DROP FUNCTION IF EXISTS f;` |
| Change delimiter | `DELIMITER // ... END // DELIMITER ;` |
| Concatenate names | `CONCAT_WS(' ', first_name, last_name)` |
| First non-null | `COALESCE(phone, 'N/A')` |
| Conditional value | `IF(salary >= 5000, 'High', 'Low')` |

