# MySQL Indexing

## 1. What Is an Index?

An **index** in MySQL is a data structure that improves the speed of data retrieval operations on a table. It works similarly to an index in a book: instead of scanning every page (every row) to find a topic, you go directly to the index, locate the term, and jump to the relevant page.

Technically, a MySQL index is a separate structure that stores a copy of selected columns from a table, along with pointers (row locations) to the full rows. When you run a query with a `WHERE`, `JOIN`, `ORDER BY`, or `GROUP BY` clause on indexed columns, MySQL can use the index to locate matching rows quickly instead of performing a full table scan.

Key characteristics:

- An index speeds up **read** operations (`SELECT`).
- It adds overhead to **write** operations (`INSERT`, `UPDATE`, `DELETE`) because the index must be maintained.
- It consumes additional disk space.
- MySQL automatically creates indexes for `PRIMARY KEY`, `UNIQUE`, and `FOREIGN KEY` constraints.

---

## 2. Why Use Indexes?

| Benefit | Description |
|---------|-------------|
| **Faster SELECT queries** | Locates rows by index lookup instead of scanning the whole table. |
| **Faster JOINs** | Indexes on foreign key columns speed up joins between tables. |
| **Faster sorting and grouping** | Indexes provide pre-sorted data for `ORDER BY` and `GROUP BY`. |
| **Enforces uniqueness** | `UNIQUE` indexes prevent duplicate values in a column or column set. |
| **Better application performance** | Critical for large tables where full scans are expensive. |

---

## 3. Types of Indexes in MySQL

| Index Type | Description | Typical Use Case |
|------------|-------------|------------------|
| **Primary Key Index** | Automatically created when you define a `PRIMARY KEY`. Uniquely identifies each row. | `EmployeeID` column |
| **Unique Index** | Ensures all values in the indexed column(s) are unique. Allows one NULL per column (depending on storage engine). | `Email` column |
| **Composite Index** | Index on multiple columns. Order of columns matters. | `(DepartmentID, City)` |
| **Non-Unique (Regular) Index** | Basic index that speeds up lookups but allows duplicates. | `FirstName` |
| **Full-Text Index** | Indexes words within text columns for natural-language searches. | `VARCHAR`/`TEXT` content |
| **Spatial Index** | Indexes spatial data types like `GEOMETRY`, `POINT`. | GIS/location data |
| **Descending Index** | Index stored in descending order (MySQL 8.0+). | Recent-first ordering |

---

## 4. How Indexes Work Internally

MySQL (InnoDB storage engine) typically uses a **B+ Tree** structure for indexes:

1. The root page directs the search to intermediate pages.
2. Intermediate pages narrow down the range.
3. Leaf pages contain the indexed column values plus pointers to the full table rows (or the full row in the case of a clustered index).
4. A search traverses the tree from root to leaf, making lookups logarithmic (O(log n)) instead of linear (O(n)).

**Clustered vs. Non-Clustered:**

- **Clustered index**: The actual table data is stored in the leaf pages of the index. InnoDB uses the primary key as the clustered index. There can be only one clustered index per table.
- **Non-clustered (secondary) index**: A separate structure where leaf pages contain the indexed columns and a pointer to the clustered index key (primary key), which is then used to fetch the full row.

---

## 5. Creating Indexes

### 5.1 Syntax

```sql
-- Regular (non-unique) index
CREATE INDEX index_name
ON table_name (column1, column2, ...);

-- Unique index
CREATE UNIQUE INDEX index_name
ON table_name (column1, column2, ...);

-- Via ALTER TABLE
ALTER TABLE table_name
ADD INDEX index_name (column1);

-- Via column definition (at table creation)
CREATE TABLE table_name (
    column1 INT,
    INDEX index_name (column1)
);
```

### 5.2 Examples Based on `Index.sql` (`pr04` schema)

The `Index.sql` file already defines several indexes using the `pr04` database:

#### Non-clustered index on a single column

```sql
USE pr04;

CREATE INDEX idx_employee_firstname
ON Employee (FirstName);
```

This index speeds up queries like:

```sql
SELECT * FROM Employee WHERE FirstName = 'Kamal';
```

#### Unique index

```sql
CREATE UNIQUE INDEX idx_email
ON Employee (email);
```

This ensures no two employees share the same email address and speeds up email-based lookups.

#### Composite unique index

```sql
CREATE UNIQUE INDEX com_un_idx_dep
ON department (DepartmentName, Location);
```

This ensures the combination of department name and location is unique across the table.

#### Composite index (multiple columns)

```sql
CREATE INDEX idx_employee_dept_city
ON Employee (DepartmentID, City);
```

This helps queries that filter by `DepartmentID`, or by both `DepartmentID` and `City`. Column order matters: this index can be used for `WHERE DepartmentID = 1` but is less effective for `WHERE City = 'Colombo'` alone.

#### Index on a date column

```sql
CREATE INDEX idx_project_enddate
ON project (EndDate);
```

Useful for queries filtering or sorting by project end dates.

#### Composite index on junction table

```sql
CREATE INDEX idx_employeeprojects_project_emp
ON EmloyeeProjects (ProjectID, EmployeeID);
```

Speeds up queries joining employees to projects.


---

## 6. Viewing Indexes

### Show indexes on a table

```sql
SHOW INDEX FROM Employee;
SHOW INDEX FROM Employee FROM pr04;
```

Typical output columns:

| Column | Meaning |
|--------|---------|
| `Table` | Table name |
| `Non_unique` | 0 if unique index, 1 if not |
| `Key_name` | Name of the index |
| `Seq_in_index` | Position of column in the index (1-based) |
| `Column_name` | Indexed column name |
| `Collation` | Sort order (A = ascending, NULL = not sorted) |
| `Cardinality` | Estimated number of unique values |
| `Index_type` | Index algorithm (e.g., BTREE, FULLTEXT, HASH) |

### Show indexes using information_schema

```sql
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'pr04'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

### Describe a table (shows keys and indexes)

```sql
DESC Employee;
-- or
DESCRIBE Employee;
-- or
SHOW COLUMNS FROM Employee;
```

---

## 7. Modifying and Dropping Indexes

### Rename an index (MySQL 8.0+)

```sql
ALTER TABLE Employee
RENAME INDEX idx_employee_firstname TO idx_employee_first_name;
```

### Drop an index

```sql
DROP INDEX index_name ON table_name;
-- or via ALTER TABLE
ALTER TABLE table_name DROP INDEX index_name;
```

Examples:

```sql
DROP INDEX idx_employee_firstname ON Employee;
ALTER TABLE Employee DROP INDEX idx_email;
```

**Important:** Dropping a `PRIMARY KEY` or `UNIQUE` constraint index requires dropping the constraint first:

```sql
ALTER TABLE Employee DROP PRIMARY KEY;
```

---

## 8. Covering Indexes

A **covering index** is an index that contains all the columns needed by a query, so MySQL never needs to look up the full row in the table. This is the fastest possible index usage because the query is satisfied entirely from the index leaf pages.

### Example

Suppose you have:

```sql
CREATE INDEX idx_employee_name_id
ON Employee (FirstName, LastName, EmployeeID);
```

Then this query is covered by the index:

```sql
SELECT FirstName, LastName, EmployeeID
FROM Employee
WHERE FirstName = 'Kamal';
```

MySQL reads `FirstName`, `LastName`, and `EmployeeID` directly from the index without touching the table data pages.

**To verify a covering index**, use `EXPLAIN` and check that the `Extra` column says `Using index`:

```sql
EXPLAIN SELECT FirstName, LastName, EmployeeID
FROM Employee
WHERE FirstName = 'Kamal';
```

---

## 9. EXPLAIN — Analyzing Query Execution

`EXPLAIN` shows how MySQL executes a query and whether it uses indexes.

```sql
EXPLAIN SELECT * FROM Employee WHERE FirstName = 'Kamal';
EXPLAIN SELECT * FROM Employee WHERE DepartmentID = 1 AND City = 'Colombo';
EXPLAIN FORMAT=JSON SELECT * FROM Employee WHERE FirstName = 'Kamal';
```

Key columns in `EXPLAIN` output:

| Column | What to look for |
|--------|------------------|
| `type` | Join type: `const`, `ref`, `range`, `index`, `ALL` (full scan — avoid) |
| `possible_keys` | Indexes MySQL could use |
| `key` | The index MySQL actually chose |
| `key_len` | Length of the index key used |
| `rows` | Estimated rows to examine |
| `Extra` | `Using index` (covering), `Using where`, `Using filesort` (avoid if possible) |


---

## 10. When NOT to Use Indexes (Disadvantages)

Indexes are not free. Avoid or limit indexes in these situations:

| Situation | Reason |
|-----------|--------|
| **Small tables** | A full table scan is faster than traversing an index for very few rows. |
| **Frequent INSERT/UPDATE/DELETE** | Every write must update all indexes, slowing writes and increasing lock contention. |
| **Columns with low cardinality** | Columns with few distinct values (e.g., `gender`, `status` with 2–3 values) rarely benefit from indexing. |
| **Wide text columns indexed fully** | Indexing a long `VARCHAR` or `TEXT` column in full creates a large, slow index. Use a prefix index instead. |
| **Indexes never used in queries** | Unused indexes consume disk space and slow writes with no read benefit. |

### Write overhead example

```sql
-- Without index: INSERT writes one row to the table.
-- With 5 indexes: INSERT writes one row to the table + updates 5 index structures.
```

### Prefix index for long columns

```sql
-- Index only the first 20 characters of email
CREATE INDEX idx_email_prefix
ON Employee (email(20));
```

## 11. Best Practices

1. **Index columns used in `WHERE`, `JOIN`, `ORDER BY`, and `GROUP BY` clauses.**
2. **Choose column order carefully in composite indexes.** Put the most selective (most unique) column first, and order columns to match common query filters.
3. **Prefer `NOT NULL` columns for indexed columns** where possible — NULLs complicate index statistics.
4. **Use `EXPLAIN` regularly** to verify MySQL is actually using your indexes and not doing a full table scan (`type = ALL`).
5. **Drop unused indexes** to reduce write overhead and disk usage.
6. **Avoid over-indexing.** More indexes ≠ faster performance. Each index slows `INSERT`, `UPDATE`, and `DELETE`.
7. **Use covering indexes** for frequent read-heavy queries by including all selected columns in the index.
8. **Use prefix indexes** for long string columns to keep index size manageable.
9. **Monitor index cardinality.** Low cardinality indexes provide little benefit.
10. **Recreate indexes after bulk data loads** if performance degrades (e.g., `OPTIMIZE TABLE`).


## 12. Complete Working Example

Below is a self-contained script you can run against the `pr04` schema from `Index.sql`. It demonstrates creating, using, viewing, and cleaning up indexes.

```sql
USE pr04;

-- ------------------------------------------------------------------
-- 1. Ensure tables and data exist (from Index.sql)
-- ------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID INT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    HireDate DATE,
    DepartmentID INT
);

INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, HireDate, DepartmentID) VALUES
(1, 'Kamal', 'Perera', 'kamal.perera@example.lk', '2021-05-12', 1),
(2, 'Nimal', 'Fernando', 'nimal.fernando@example.lk', '2020-08-23', 2),
(3, 'Sunil', 'Silva', 'sunil.silva@example.lk', '2019-11-05', 1),
(4, 'Chathura', 'Kumarasinghe', 'chathura.kumarasinghe@example.lk', '2022-02-14', 3),
(5, 'Dilshan', 'Jayawardena', 'dilshan.jayawardena@example.lk', '2021-07-29', 3),
(6, 'Aruna', 'Weerasinghe', 'aruna.weerasinghe@example.lk', '2023-01-11', 2),
(7, 'Malkanthi', 'Rathnayake', 'malkanthi.rathnayake@example.lk', '2020-09-18', 5),
(8, 'Ruwan', 'De Silva', 'ruwan.desilva@example.lk', '2018-06-30', 4),
(9, 'Saman', 'Senanayake', 'saman.senanayake@example.lk', '2021-04-10', 6),
(10, 'Indika', 'Karunaratne', 'indika.karunaratne@example.lk', '2019-12-25', 4);

ALTER TABLE Employee ADD PRIMARY KEY (EmployeeID);

-- ------------------------------------------------------------------
-- 2. Create indexes
-- ------------------------------------------------------------------
-- Single-column non-unique index
CREATE INDEX idx_employee_firstname
ON Employee (FirstName);

-- Unique index
CREATE UNIQUE INDEX idx_email
ON Employee (Email);

-- Composite index
CREATE INDEX idx_employee_dept_hiredate
ON Employee (DepartmentID, HireDate);

-- ------------------------------------------------------------------
-- 3. View indexes
-- ------------------------------------------------------------------
SHOW INDEX FROM Employee;

SELECT
    TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'pr04' AND TABLE_NAME = 'Employee'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- ------------------------------------------------------------------
-- 4. Use EXPLAIN to verify index usage
-- ------------------------------------------------------------------
EXPLAIN SELECT * FROM Employee WHERE FirstName = 'Kamal';
EXPLAIN SELECT * FROM Employee WHERE DepartmentID = 1 AND HireDate > '2020-01-01';

-- ------------------------------------------------------------------
-- 5. Covering index example
-- ------------------------------------------------------------------
CREATE INDEX idx_covering_name_id
ON Employee (FirstName, LastName, EmployeeID);

EXPLAIN SELECT FirstName, LastName, EmployeeID
FROM Employee
WHERE FirstName = 'Kamal';

-- ------------------------------------------------------------------
-- 6. Cleanup — drop indexes
-- ------------------------------------------------------------------
DROP INDEX idx_employee_firstname ON Employee;
DROP INDEX idx_email ON Employee;
DROP INDEX idx_employee_dept_hiredate ON Employee;
DROP INDEX idx_covering_name_id ON Employee;
```

## 13. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Create index | `CREATE INDEX idx_name ON table (col);` |
| Create unique index | `CREATE UNIQUE INDEX idx_name ON table (col);` |
| Create composite index | `CREATE INDEX idx_name ON table (col1, col2);` |
| Prefix index (first N chars) | `CREATE INDEX idx_name ON table (col(20));` |
| Show indexes | `SHOW INDEX FROM table;` |
| List all indexes (schema) | `SELECT * FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='db';` |
| Drop index | `DROP INDEX idx_name ON table;` or `ALTER TABLE table DROP INDEX idx_name;` |
| Rename index (MySQL 8.0+) | `ALTER TABLE table RENAME INDEX old TO new;` |
| Analyze query plan | `EXPLAIN SELECT ...;` |
| Check covering index | `EXPLAIN ...` → `Extra` column shows `Using index` |
| Drop primary key | `ALTER TABLE table DROP PRIMARY KEY;` |

