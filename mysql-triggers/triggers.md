# MySQL Triggers

A comprehensive guide to **MySQL database triggers** — what they are, how to create and manage them, and best practices. Examples are based on `labsheet07.sql` in this folder.

---

## 1. What Is a Trigger?

A **trigger** is a stored program that MySQL automatically executes ("fires") in response to a specific data modification event on a table. Triggers are associated with a table and activate before or after:

- `INSERT` — a new row is added
- `UPDATE` — an existing row is modified
- `DELETE` — an existing row is removed

Unlike stored procedures (called explicitly with `CALL`) or functions (used in expressions), triggers are **event-driven**: they run automatically when the triggering event occurs.

Key characteristics:

- A trigger is bound to exactly one table.
- It activates `BEFORE` or `AFTER` the triggering statement, for each affected row (`FOR EACH ROW`).
- It cannot directly `SELECT` from or modify the same table that triggered it (the "mutating table" restriction).
- Triggers execute within the same transaction as the triggering statement.


---

## 2. Why Use Triggers?

| Benefit | Description |
|---------|-------------|
| **Automatic enforcement** | Business rules run automatically on every insert/update/delete, without relying on application code. |
| **Data integrity** | Validate or transform data before it is written (e.g., compute derived columns). |
| **Audit logging** | Record changes (who, what, when) into history/audit tables automatically. |
| **Cascading actions** | Perform related updates/deletes across tables (e.g., delete employees when a department is removed). |
| **Centralized logic** | Keep data modification rules inside the database so every client application follows them. |

| Drawback | Description |
|----------|-------------|
| **Hidden logic** | Triggers fire implicitly, which can make application behavior harder to trace and debug. |
| **Performance overhead** | Every trigger adds work to the DML statement; complex triggers slow down inserts/updates/deletes. |
| **Maintenance risk** | Changes to base tables can break triggers; they are easy to forget during schema refactoring. |
| **Debugging difficulty** | Errors inside a trigger abort the triggering statement, and stack traces can be harder to interpret. |

**Rule of thumb:** Use triggers for auditing, derived-column maintenance, and integrity rules that must be enforced at the database level. Avoid using them for complex business logic that belongs in the application layer.

---

## 3. Trigger Types

MySQL supports six trigger types per table:

| Timing | Event | Fires |
|--------|-------|-------|
| `BEFORE` | `INSERT` | Before a new row is inserted; often used to validate or modify `NEW` values. |
| `AFTER` | `INSERT` | After a new row is successfully inserted; often used for audit logging or cascading inserts. |
| `BEFORE` | `UPDATE` | Before a row is updated; can modify `NEW` values before they are written. |
| `AFTER` | `UPDATE` | After a row is updated; useful for logging old vs. new values. |
| `BEFORE` | `DELETE` | Before a row is deleted; can prevent deletion or archive `OLD` values. |
| `AFTER` | `DELETE` | After a row is deleted; often used for cleanup of related rows. |

Only **one trigger per timing-event combination** is allowed per table (e.g., one `BEFORE INSERT` trigger per table).

---

## 4. Creating a Trigger

### 4.1 Syntax

Because a trigger body contains multiple statements (each ending with `;`), change the client delimiter with `DELIMITER` before `CREATE TRIGGER`, then restore it afterward.

```sql
DELIMITER //

CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON table_name
FOR EACH ROW
BEGIN
    -- trigger body: one or more SQL statements
    IF condition THEN
        ...
    END IF;
END //

DELIMITER ;
```

| Clause | Meaning |
|--------|---------|
| `trigger_name` | Unique name for the trigger within the schema. |
| `BEFORE` / `AFTER` | When the trigger fires relative to the data change. |
| `INSERT` / `UPDATE` / `DELETE` | The DML event that activates the trigger. |
| `ON table_name` | The table the trigger is attached to. |
| `FOR EACH ROW` | Makes it a **row-level** trigger (fires once per affected row). MySQL requires this clause. |

### 4.2 The `NEW` and `OLD` Pseudorecords

Inside the trigger body, MySQL provides row references:

| Pseudorecord | Available in | Contains |
|--------------|--------------|----------|
| `NEW` | `INSERT`, `UPDATE` | The new row values being inserted or updated. |
| `OLD` | `UPDATE`, `DELETE` | The old row values before the update or deletion. |

- In an `INSERT` trigger, only `NEW` exists.
- In a `DELETE` trigger, only `OLD` exists.
- In an `UPDATE` trigger, both exist: `OLD.column` is the value before change, `NEW.column` is the value after change.
- In a `BEFORE INSERT`/`BEFORE UPDATE` trigger, you can `SET NEW.column = ...` to modify the value being written.

---

## 5. Examples Based on `labsheet07.sql` (`pr07` schema)

The `labsheet07.sql` file in this folder defines tables `Student`, `Student_marks`, `Student_Trigger`, `tbl_product`, `tbl_proreorder`, `Department`, `Employee`, `Locations`, `LocationHist`, `book_det`, and `book_issue`, then creates triggers on them.

### 5.1 BEFORE INSERT — adjust a value before it is written

```sql
USE pr07;

DELIMITER //

CREATE TRIGGER trg_ad_m
BEFORE INSERT
ON student FOR EACH ROW
BEGIN
    SET NEW.Marks = NEW.Marks + 100;
END //

DELIMITER ;
```

- Fires before each row is inserted into `student`.
- Adds 100 to `Marks` before the row is stored.

### 5.2 BEFORE INSERT — compute derived columns

```sql
DELIMITER //

CREATE TRIGGER trg_calc_total_avg_before_insert
BEFORE INSERT
ON Student_marks FOR EACH ROW
BEGIN
    SET NEW.Total = NEW.m1 + NEW.m2 + NEW.m3;
    SET NEW.Average = NEW.Total / 3;
END //

DELIMITER ;
```

- Automatically calculates `Total` and `Average` from the component marks before insert.

### 5.3 BEFORE INSERT — total and percentage

```sql
DELIMITER //

CREATE TRIGGER trg_student_marks_before_insert
BEFORE INSERT ON Student_Trigger
FOR EACH ROW
BEGIN
    SET NEW.Student_TotalMarks =
        NEW.Student_EnglishMarks +
        NEW.Student_PhysicsMarks +
        NEW.Student_ChemistryMarks +
        NEW.Student_MathsMarks;

    SET NEW.Student_Percentage = (NEW.Student_TotalMarks / 400.0) * 100;
END //

DELIMITER ;
```

### 5.4 AFTER UPDATE — conditional cascading insert

```sql
DELIMITER //

CREATE TRIGGER trg_reorder_after_update
AFTER UPDATE ON tbl_product
FOR EACH ROW
BEGIN
    IF NEW.pro_qunatity = NEW.reorder_qty THEN
        INSERT INTO tbl_proreorder (pro_id, quantity)
        VALUES (NEW.pro_id, NEW.pro_qunatity);
    END IF;
END //

DELIMITER ;
```

- After a product stock update, if quantity equals the reorder threshold, a reorder record is inserted into `tbl_proreorder`.

### 5.5 AFTER DELETE — cascade deletes to related table

```sql
DELIMITER //

CREATE TRIGGER trg_delete_employees_after_dept_delete
AFTER DELETE ON Department
FOR EACH ROW
BEGIN
    DELETE FROM Employee
    WHERE Depid = OLD.Depid;
END //

DELIMITER ;
```

- When a department is deleted, all employees belonging to that department (`OLD.Depid`) are removed automatically.

### 5.6 AFTER UPDATE — audit log of changes

```sql
DELIMITER //

CREATE TRIGGER trg_locations_after_update
AFTER UPDATE ON Locations
FOR EACH ROW
BEGIN
    INSERT INTO LocationHist (LocationID, ModifiedDate)
    VALUES (NEW.LocationID, NOW());
END //

DELIMITER ;
```

- Every time a location is updated, a row is written to `LocationHist` recording which location changed and when.

### 5.7 AFTER INSERT — decrement inventory on issue

```sql
DELIMITER //

CREATE TRIGGER trg_decrement_copies_after_issue
AFTER INSERT ON book_issue
FOR EACH ROW
BEGIN
    UPDATE book_det
    SET copies = copies - 1
    WHERE bid = NEW.bid;
END //

DELIMITER ;
```

- When a book is issued (inserted into `book_issue`), the available `copies` count in `book_det` is reduced by one.


---

## 6. Managing Triggers

### 6.1 View existing triggers

```sql
-- All triggers in the current schema
SHOW TRIGGERS;

-- Triggers for a specific schema
SHOW TRIGGERS FROM pr07;

-- Detailed metadata from the data dictionary
SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'pr07';

-- Show the full definition of a trigger
SHOW CREATE TRIGGER trg_reorder_after_update \G
```

### 6.2 Drop a trigger

```sql
DROP TRIGGER IF EXISTS trigger_name;
```

Example:

```sql
DROP TRIGGER IF EXISTS trg_reorder_after_update;
```

`DROP TRIGGER` removes only the trigger; the underlying table and data are unaffected.

---

## 7. Best Practices

1. **Keep trigger bodies short** — one logical task per trigger. Avoid long sequences of unrelated statements.
2. **Avoid triggers on the same table** — a trigger should generally not `INSERT`, `UPDATE`, or `DELETE` from the table that fired it; this can cause recursion or unpredictable behavior.
3. **Prefer `AFTER` for logging/auditing** — use `AFTER` triggers so the log entry is written only if the original statement succeeds.
4. **Prefer `BEFORE` for validation/defaults** — use `BEFORE` triggers to modify `NEW` values or reject invalid data.
5. **Use meaningful names** — prefix triggers with `trg_` and include table and event, e.g., `trg_student_marks_before_insert`.
6. **Handle errors explicitly** — a failed trigger aborts the entire DML statement; use `SIGNAL SQLSTATE` to raise clear errors.
7. **Document triggers in schema documentation** — because they fire implicitly, developers may not know they exist.
8. **Test all six timing/event combinations** — verify `BEFORE`/`AFTER` × `INSERT`/`UPDATE`/`DELETE` behavior with representative data.
9. **Avoid complex business logic** — heavy calculations or external calls belong in stored procedures or the application layer, not triggers.
10. **Drop and recreate to modify** — MySQL does not support `ALTER TRIGGER`; use `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER` to change a trigger.

---

## 8. Limitations & Restrictions

- A trigger cannot `CALL` a stored procedure that performs `COMMIT` or `ROLLBACK` (transaction control is not allowed inside triggers).
- `NEW` values are read-only in `AFTER` triggers; modify `NEW` only in `BEFORE` triggers.
- You cannot reference the triggering table directly in a way that causes the trigger to activate itself recursively.
- Only `FOR EACH ROW` (row-level) triggers are supported; MySQL does not support statement-level triggers.
- Triggers add overhead to every row affected by the triggering DML statement.

---

## 9. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Create trigger | `CREATE TRIGGER name BEFORE|AFTER INSERT|UPDATE|DELETE ON table FOR EACH ROW BEGIN ... END //` |
| Change delimiter | `DELIMITER //` ... `DELIMITER ;` |
| Reference new row | `NEW.column` (`INSERT`, `UPDATE`) |
| Reference old row | `OLD.column` (`UPDATE`, `DELETE`) |
| Modify new value | `SET NEW.column = value` (in `BEFORE` triggers only) |
| List triggers | `SHOW TRIGGERS [FROM db];` |
| Trigger metadata | `SELECT * FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='db';` |
| Show definition | `SHOW CREATE TRIGGER name \G` |
| Drop trigger | `DROP TRIGGER IF EXISTS name;` |
| Raise error | `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'message';` |
| Current timestamp | `NOW()` |

---

## 10. Related Files in This Folder

| File | Description |
|------|-------------|
| `labsheet07.sql` | SQL lab script creating the `pr07` schema and all trigger examples referenced above |