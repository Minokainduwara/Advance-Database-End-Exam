# MySQL Stored Procedures

## 1. What Is a Stored Procedure?

A **stored procedure** is a precompiled collection of one or more SQL statements stored under a name in the database. It can accept input parameters, return output parameters, perform logic (loops, conditionals, variable assignments), and execute multiple statements as a single unit.

Unlike a function, a stored procedure:
- Does **not** have to return a value.
- Is invoked with `CALL`, not used inline in expressions.
- Can return multiple result sets.
- Can use `OUT` and `INOUT` parameters to pass values back to the caller.

---

## 2. Why Use Stored Procedures?

| Benefit | Description |
|---------|-------------|
| **Encapsulation** | Groups related SQL logic into a single reusable unit. |
| **Modularity** | Applications call procedures instead of embedding complex SQL. |
| **Security** | Grant users permission to execute a procedure without giving direct table access. |
| **Reduced network traffic** | Multiple statements run on the server; only the call and result travel over the network. |
| **Performance** | Procedures are compiled once and cached; execution plans are reused. |
| **Maintainability** | Change logic in one place (the procedure) rather than in every application. |

---

## 3. Creating a Stored Procedure

### 3.1 Syntax

Because a procedure contains multiple statements (semicolons), you must temporarily change the statement delimiter using `DELIMITER`.

```sql
DELIMITER //

CREATE [OR REPLACE] PROCEDURE procedure_name (
    [IN | OUT | INOUT] param1 datatype,
    [IN | OUT | INOUT] param2 datatype,
    ...
)
BEGIN
    -- declarations
    DECLARE var1 datatype DEFAULT value;
    
    -- logic
    IF condition THEN
        ...
    END IF;
    
    -- statements
    SELECT ...;
    INSERT ...;
    ...
END //

DELIMITER ;
```

### Parameter Modes

| Mode | Description | Example Use |
|------|-------------|-------------|
| `IN` | Input value passed into the procedure (default). Cannot be changed to affect the caller. | Search criteria, IDs |
| `OUT` | Value returned from the procedure to the caller. Starts as NULL inside the procedure. | Returning a calculated result |
| `INOUT` | Both input and output; the caller passes a value and the procedure may modify and return it. | Counters, accumulators |

---

## 4. Examples Based on `labsheet.sql` (`pr03` schema)

The `labsheet.sql` file defines tables `Department`, `Role`, `Login`, `Employee`, and `studentMarks` with several stored procedures. Below are examples using that schema.

### Simple procedure — no parameters

```sql
USE pr03;

DELIMITER //

CREATE PROCEDURE sp_GetAllEmployees()
BEGIN
    SELECT * FROM Employee;
END //

DELIMITER ;

CALL sp_GetAllEmployees();
```

### Procedure with IN parameter

```sql
DELIMITER //

CREATE PROCEDURE sp_GetEmployeeByID(IN p_EID VARCHAR(10))
BEGIN
    SELECT EID, E_fname, E_lname, E_email, Age
    FROM Employee
    WHERE EID = p_EID;
END //

DELIMITER ;

CALL sp_GetEmployeeByID('E001');
```

### Procedure with OUT parameter

```sql
DELIMITER //

CREATE PROCEDURE sp_GetLastName(
    IN p_EID VARCHAR(10),
    OUT p_lName VARCHAR(100)
)
BEGIN
    SELECT E_lname INTO p_lName
    FROM Employee
    WHERE EID = p_EID;
END //

DELIMITER ;

-- Calling an OUT parameter procedure
CALL sp_GetLastName('E002', @lName);
SELECT @lName;
```

### Procedure with INOUT parameter

```sql
DELIMITER //

CREATE PROCEDURE sp_AdjustSalary(INOUT p_amount DECIMAL(10,2))
BEGIN
    SET p_amount = p_amount * 1.10;  -- 10% raise
END //

DELIMITER ;

SET @salary = 50000;
CALL sp_AdjustSalary(@salary);
SELECT @salary;  -- 55000.00
```


## 5. Variables and Control Flow

### Declaring Variables

Variables must be declared at the beginning of the `BEGIN...END` block, before any other statements.

```sql
DECLARE v_emp_count INT DEFAULT 0;
DECLARE v_avg_salary DECIMAL(10,2);
DECLARE v_done INT DEFAULT FALSE;
```

### SET vs SELECT ... INTO

```sql
SET v_emp_count = 10;

SELECT COUNT(*) INTO v_emp_count FROM Employee;
```

### IF / ELSEIF / ELSE

```sql
IF v_age < 30 THEN
    SET v_category = 'Junior';
ELSEIF v_age >= 30 AND v_age < 50 THEN
    SET v_category = 'Mid';
ELSE
    SET v_category = 'Senior';
END IF;
```

### CASE

```sql
CASE v_role
    WHEN 'SE Engineer' THEN SET v_level = 3;
    WHEN 'QA Engineer' THEN SET v_level = 2;
    ELSE SET v_level = 1;
END CASE;
```

### Loops

MySQL supports `WHILE`, `REPEAT`, and `LOOP` constructs.

```sql
-- WHILE loop
SET v_counter = 1;
WHILE v_counter <= 5 DO
    SET v_counter = v_counter + 1;
END WHILE;

-- REPEAT loop
REPEAT
    SET v_counter = v_counter + 1;
UNTIL v_counter > 5
END REPEAT;

-- LOOP with LEAVE
my_loop: LOOP
    SET v_counter = v_counter + 1;
    IF v_counter > 5 THEN
        LEAVE my_loop;
    END IF;
END LOOP my_loop;
```

### Cursors

Cursors allow row-by-row processing of a result set.

```sql
DECLARE v_fname VARCHAR(50);
DECLARE v_done INT DEFAULT FALSE;

DECLARE emp_cursor CURSOR FOR
    SELECT E_fname FROM Employee WHERE Age > 30;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

OPEN emp_cursor;

read_loop: LOOP
    FETCH emp_cursor INTO v_fname;
    IF v_done THEN
        LEAVE read_loop;
    END IF;
    -- process v_fname
END LOOP;

CLOSE emp_cursor;
```

---

## 6. Calling Procedures

```sql
-- No parameters
CALL sp_GetAllEmployees();

-- With IN parameter
CALL sp_GetEmployeeByID('E001');

-- With OUT parameter
CALL sp_GetLastName('E002', @lName);
SELECT @lName;

-- With INOUT parameter
SET @salary = 50000;
CALL sp_AdjustSalary(@salary);
SELECT @salary;
```

---

## 7. Viewing, Modifying, and Dropping Procedures

### Show a procedure's definition

```sql
SHOW CREATE PROCEDURE sp_GetAllEmployees\G
```

### List all procedures in a database

```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'pr03' AND routine_type = 'PROCEDURE';
```

### Show procedure status

```sql
SHOW PROCEDURE STATUS WHERE Db = 'pr03';
```

### Alter a procedure

MySQL does not support `ALTER PROCEDURE` for changing the body. To modify, drop and recreate:

```sql
DROP PROCEDURE IF EXISTS sp_GetAllEmployees;

DELIMITER //
CREATE PROCEDURE sp_GetAllEmployees()
BEGIN
    SELECT EID, E_fname, E_lname, E_email FROM Employee;
END //
DELIMITER ;
```

### Drop a procedure

```sql
DROP PROCEDURE IF EXISTS procedure_name;
```

Example:

```sql
DROP PROCEDURE IF EXISTS sp_GetEmployeeByID;

## 8. Error Handling in Stored Procedures

Error handling lets a procedure respond gracefully to problems such as duplicate keys, missing rows, divide-by-zero, or connection issues, instead of abruptly terminating.

### 8.1 DECLARE HANDLER Syntax

```sql
DECLARE {CONTINUE | EXIT | UNDO} HANDLER
    FOR {condition_value | condition_name | SQLSTATE [VALUE] sqlstate_value}
    handler_action
```

- `CONTINUE` — after handling the error, execution continues with the next statement.
- `EXIT` — after handling the error, the procedure exits the current `BEGIN...END` block.
- `UNDO` — not supported in MySQL (reserved for future use).

### Handler Condition Types

| Condition Type | Meaning | Example |
|----------------|---------|---------|
| MySQL error code | Numeric error code | `1062` (duplicate entry) |
| SQLSTATE | Five-character SQLSTATE code | `'23000'` (integrity constraint violation) |
| `SQLEXCEPTION` | Any unhandled exception | Catches most runtime errors |
| `SQLWARNING` | Warnings (e.g., data truncation) | `01000` |
| `NOT FOUND` | No rows returned (`02000`) | Cursor end-of-set, `SELECT ... INTO` no row |
| Named condition | User-defined with `DECLARE ... CONDITION` | Custom business rule |

---

### 8.2 EXIT Handler Example (from `labsheet.sql`)

An `EXIT` handler terminates the current block when the error occurs. The statements after the error are **not** executed.

```sql
DELIMITER //

CREATE PROCEDURE spInsertStudentDataExit(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT COUNT(*) INTO rowCount FROM studentMarks;
        SELECT CONCAT('Error: Duplicate student ID ', p_studentId, ' cannot be inserted.') AS ErrorMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

DELIMITER ;
```

**Behavior:** If `stud_id = p_studentId` already exists (error 1062), the handler runs: it sets `rowCount` and returns an error message. The `INSERT` is skipped and the final `SELECT COUNT(*)` **does not run** because the EXIT handler leaves the block.

---

### 8.3 CONTINUE Handler Example (from `labsheet.sql`)

A `CONTINUE` handler lets execution resume after the error. The procedure continues with the next statement.

```sql
DELIMITER //

CREATE PROCEDURE spInsertStudentDataContinue(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SELECT CONCAT('Warning: Duplicate student ID ', p_studentId, ' skipped.') AS WarningMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

DELIMITER ;
```

**Behavior:** If the `INSERT` fails with error 1062, the handler runs (prints a warning), then execution **continues** to the next statement (`SELECT COUNT(*)`), so `rowCount` is still updated.

---

### 8.4 SQLEXCEPTION Handler

Catches any general SQL exception. Useful as a catch-all.

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    SELECT 'An unexpected error occurred.' AS ErrorMessage;
    ROLLBACK;
END;
```

---

### 8.5 SQLWARNING Handler

Catches warning conditions (non-fatal).

```sql
DECLARE CONTINUE HANDLER FOR SQLWARNING
BEGIN
    SELECT 'Warning occurred during execution.' AS WarningMessage;
END;
```

---

### 8.6 NOT FOUND Handler

Used primarily with cursors or `SELECT ... INTO` when no rows are returned.

```sql
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
```

---

### 8.7 Named Conditions

You can define your own named condition for readability.

```sql
DECLARE duplicate_key CONDITION FOR 1062;
DECLARE EXIT HANDLER FOR duplicate_key
BEGIN
    SELECT 'Duplicate key error handled via named condition.' AS Message;
END;
```

Or using SQLSTATE:

```sql
DECLARE duplicate_key CONDITION FOR SQLSTATE '23000';
DECLARE EXIT HANDLER FOR duplicate_key
BEGIN
    SELECT 'Integrity violation.' AS Message;
END;
```

---

### 8.8 Raising Errors: SIGNAL and RESIGNAL

MySQL lets you throw custom errors from within a procedure.

#### SIGNAL

Raise a new error condition:

```sql
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Custom error: Employee age must be 18 or older.';
```

`45000` is a generic unhandled user-defined SQLSTATE.

#### RESIGNAL

Re-throw the current condition inside a handler (often after logging or modifying it):

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    SELECT 'Logging error...' AS Info;
    RESIGNAL;  -- re-throw the original error to the caller
END;
```

#### Example — validation with SIGNAL

```sql
DELIMITER //

CREATE PROCEDURE sp_AddEmployee(
    IN p_EID VARCHAR(10),
    IN p_age INT
)
BEGIN
    IF p_age < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee must be at least 18 years old.';
    END IF;

    INSERT INTO Employee (EID, Age) VALUES (p_EID, p_age);
END //

DELIMITER ;
```

---

## 9. Transaction Handling in Procedures

Procedures can manage transactions explicitly with `START TRANSACTION`, `COMMIT`, and `ROLLBACK`.

```sql
DELIMITER //

CREATE PROCEDURE sp_TransferDepartment(
    IN p_EID VARCHAR(10),
    IN p_new_DID INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed. Transaction rolled back.' AS Message;
    END;

    START TRANSACTION;

    UPDATE Employee SET DID = p_new_DID WHERE EID = p_EID;

    -- additional logic here...

    COMMIT;
    SELECT 'Transfer completed successfully.' AS Message;
END //

DELIMITER ;
```


## 10. Complete Working Example

Below is a self-contained script for the `pr03` schema. It creates a table, several procedures (including error handling), and demonstrates calling them.

```sql
USE pr03;

-- ------------------------------------------------------------------
-- 1. Create a supporting table for demonstrations
-- ------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS studentMarks (
    stud_id INT PRIMARY KEY,
    total_marks INT,
    grade VARCHAR(5)
);

INSERT INTO studentMarks (stud_id, total_marks, grade) VALUES
(1, 450, 'A'),
(2, 380, 'B'),
(3, 320, 'C'),
(4, 250, 'D'),
(5, 410, 'A');

-- ------------------------------------------------------------------
-- 2. Procedure: get employee count by department (IN parameter)
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_GetEmpCountByDept(IN p_DID INT, OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM Employee
    WHERE DID = p_DID;
END //

DELIMITER ;

CALL sp_GetEmpCountByDept(1, @dept1_count);
SELECT @dept1_count AS Dept1EmployeeCount;

-- ------------------------------------------------------------------
-- 3. Procedure: adjust age (INOUT parameter)
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_AdjustAge(INOUT p_age INT)
BEGIN
    IF p_age < 30 THEN
        SET p_age = p_age + 5;
    ELSE
        SET p_age = p_age + 2;
    END IF;
END //

DELIMITER ;

SET @emp_age = 25;
CALL sp_AdjustAge(@emp_age);
SELECT @emp_age AS AdjustedAge;

-- ------------------------------------------------------------------
-- 4. Procedure: insert student with EXIT handler (duplicate key)
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE spInsertStudentExit(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT COUNT(*) INTO rowCount FROM studentMarks;
        SELECT CONCAT('Error: Duplicate student ID ', p_studentId, ' cannot be inserted.') AS ErrorMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

DELIMITER ;

CALL spInsertStudentExit(1, 500, 'A', @rc);
SELECT @rc AS RowCountAfterExit;

-- ------------------------------------------------------------------
-- 5. Procedure: insert student with CONTINUE handler (duplicate key)
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE spInsertStudentContinue(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SELECT CONCAT('Warning: Duplicate student ID ', p_studentId, ' skipped.') AS WarningMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

DELIMITER ;

CALL spInsertStudentContinue(1, 500, 'A', @rc2);
SELECT @rc2 AS RowCountAfterContinue;

-- ------------------------------------------------------------------
-- 6. Procedure: validate age with SIGNAL
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_AddEmployeeValidated(IN p_EID VARCHAR(10), IN p_age INT)
BEGIN
    IF p_age < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee must be at least 18 years old.';
    END IF;

    INSERT INTO Employee (EID, E_fname, E_lname, Age)
    VALUES (p_EID, 'New', 'Employee', p_age);

    SELECT 'Employee added successfully.' AS Message;
END //

DELIMITER ;

-- This will raise a custom error:
-- CALL sp_AddEmployeeValidated('E999', 16);

-- ------------------------------------------------------------------
-- 7. View all procedures
-- ------------------------------------------------------------------
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'pr03' AND routine_type = 'PROCEDURE';

-- ------------------------------------------------------------------
-- 8. Cleanup
-- ------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_GetEmpCountByDept;
DROP PROCEDURE IF EXISTS sp_AdjustAge;
DROP PROCEDURE IF EXISTS spInsertStudentExit;
DROP PROCEDURE IF EXISTS spInsertStudentContinue;
DROP PROCEDURE IF EXISTS sp_AddEmployeeValidated;

## 11. Best Practices

1. **Use meaningful names** — prefix procedures with `sp_` or `usp_` for clarity.
2. **Always specify parameter modes** (`IN`, `OUT`, `INOUT`) explicitly for readability.
3. **Handle errors explicitly** — use `DECLARE HANDLER` for expected errors (duplicate keys, missing rows) rather than letting procedures fail silently.
4. **Prefer `CONTINUE` handlers** when you want execution to resume; use `EXIT` handlers when the block should terminate on error.
5. **Use transactions** (`START TRANSACTION`/`COMMIT`/`ROLLBACK`) for multi-step data modifications to maintain consistency.
6. **Keep procedures focused** — one procedure should do one logical task. Avoid giant procedures with dozens of unrelated statements.
7. **Validate inputs early** — use `IF` checks and `SIGNAL` to reject invalid data before performing DML.
8. **Avoid cursors when set-based SQL works** — cursors are slower; prefer `INSERT...SELECT`, `UPDATE...JOIN`, etc.
9. **Close cursors** — always `CLOSE` a cursor after use to free resources.
10. **Test error paths** — verify that handlers behave correctly by intentionally triggering errors (e.g., inserting duplicate keys).
11. **Document OUT/INOUT parameters** — callers need to know which parameters return values.
12. **Drop and recreate to modify** — since `ALTER PROCEDURE` cannot change the body, use `DROP PROCEDURE IF EXISTS` + `CREATE PROCEDURE`.

## 12. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Create procedure | `CREATE PROCEDURE p(IN x INT) BEGIN ... END //` |
| Create or replace | `CREATE OR REPLACE PROCEDURE p(...) BEGIN ... END //` |
| Call procedure | `CALL p(arg1, @outVar);` |
| Show definition | `SHOW CREATE PROCEDURE p\G` |
| List procedures | `SELECT * FROM information_schema.routines WHERE routine_type='PROCEDURE' AND routine_schema='db';` |
| Drop procedure | `DROP PROCEDURE IF EXISTS p;` |
| Declare variable | `DECLARE v_name INT DEFAULT 0;` |
| Set variable | `SET v_name = 10;` |
| Select into variable | `SELECT COUNT(*) INTO v_name FROM table;` |
| IF statement | `IF cond THEN ... ELSEIF ... ELSE ... END IF;` |
| CASE statement | `CASE x WHEN 1 THEN ... ELSE ... END CASE;` |
| While loop | `WHILE cond DO ... END WHILE;` |
| Cursor handler | `DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;` |
| EXIT handler | `DECLARE EXIT HANDLER FOR 1062 BEGIN ... END;` |
| CONTINUE handler | `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN ... END;` |
| Named condition | `DECLARE dup_key CONDITION FOR 1062;` |
| Signal error | `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'msg';` |
| Resignal | `RESIGNAL;` (inside handler only) |
| Transaction | `START TRANSACTION; ... COMMIT;` / `ROLLBACK;` |
| Change delimiter | `DELIMITER // ... END // DELIMITER ;` |

