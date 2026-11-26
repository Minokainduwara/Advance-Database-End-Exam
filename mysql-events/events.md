# MySQL Events

A comprehensive guide to **MySQL Event Scheduler** — scheduled database tasks that run automatically at specific times or intervals. Examples are based on `labsheet.sql` in this folder.

---

## 1. What Is a MySQL Event?

A **MySQL event** (also called a **scheduled event**) is a stored program that runs automatically according to a schedule, rather than being invoked manually or fired by a data change. Events are managed by the **Event Scheduler**, a background thread that wakes up periodically to check for events that are due to execute.

Key characteristics:

- An event is associated with a specific schema (database).
- It executes a defined SQL statement or compound `BEGIN ... END` block.
- It can run **once** at a future point in time (`AT`) or **repeatedly** at fixed intervals (`EVERY`).
- Unlike triggers, events are **time-driven**, not data-change-driven.
- Events execute with the privileges of the definer (the user who created them).

---

## 2. Why Use Events?

| Benefit | Description |
|---------|-------------|
| **Scheduled maintenance** | Run cleanup, archiving, or summary jobs on a regular basis without external schedulers. |
| **Recurring business tasks** | Apply periodic calculations (e.g., interest, depreciation, rollups) automatically. |
| **Time-based operations** | Expire temporary records, purge old logs, or send reminders at exact dates/times. |
| **Reduced application load** | Move scheduled logic into the database so every client benefits consistently. |
| **Centralized scheduling** | Schedule is defined once inside MySQL rather than in cron jobs or application code. |

| Drawback | Description |
|----------|-------------|
| **Scheduler dependency** | Events only run if the Event Scheduler thread is enabled (`event_scheduler = ON`). |
| **Hidden execution** | Like triggers, events run implicitly and can be overlooked during debugging. |
| **Limited visibility** | A failing event may not surface errors clearly to application users. |
| **Privilege model** | Events run with definer privileges, which can lead to unexpected permission errors. |

**Rule of thumb:** Use events for recurring database maintenance and time-based calculations. Prefer external schedulers (cron, task schedulers) when you need fine-grained logging, alerting, or cross-system coordination.

---

## 3. Event Scheduler

The Event Scheduler is a MySQL thread that manages event execution. It is controlled by the `event_scheduler` system variable.

```sql
-- Check scheduler status
SHOW VARIABLES LIKE 'event_scheduler';

-- Enable the scheduler (requires SUPER or SYSTEM_VARIABLES_ADMIN privilege)
SET GLOBAL event_scheduler = ON;

-- Disable the scheduler
SET GLOBAL event_scheduler = OFF;

-- Persist across restarts (MySQL 8.0+)
SET PERSIST event_scheduler = ON;
```

| Value | Meaning |
|-------|---------|
| `ON` | Scheduler thread is running; scheduled events execute. |
| `OFF` | Scheduler thread is not running; events do not execute. |
| `DISABLED` | Scheduler cannot be changed at runtime (set at startup). |

To make the scheduler start automatically with the server, add to `my.cnf`/`my.ini`:

```ini
[mysqld]
event_scheduler=ON
```

**Privileges needed:** `EVENT` privilege on the schema (to create/alter/drop events), plus `SUPER` or `SYSTEM_VARIABLES_ADMIN` to start/stop the scheduler globally.

---

## 4. Creating an Event

### 4.1 Syntax

Because an event body may contain multiple statements, change the client delimiter with `DELIMITER`, then restore it afterward.

```sql
DELIMITER //

CREATE EVENT event_name
ON SCHEDULE schedule
[ON COMPLETION [NOT] PRESERVE]
[ENABLE | DISABLE | DISABLE ON SLAVE]
[COMMENT 'comment string']
DO
BEGIN
    -- event body: one or more SQL statements
END //

DELIMITER ;
```

| Clause | Meaning |
|--------|---------|
| `event_name` | Unique name for the event within the schema. |
| `ON SCHEDULE` | When and how often the event runs (see §4.2). |
| `ON COMPLETION PRESERVE` | Keep the event after its schedule expires (one-time events). Default is `DROP`. |
| `ENABLE` / `DISABLE` | Whether the event is active. |
| `DISABLE ON SLAVE` | Event is created on a replica but does not execute there (replication). |
| `COMMENT` | Descriptive text stored with the event. |
| `DO ... BEGIN ... END` | The SQL routine executed when the event fires. |

### 4.2 Schedule Types

| Schedule | Description |
|----------|-------------|
| `AT timestamp` | Runs once at the given future date/time. |
| `AT CURRENT_TIMESTAMP + INTERVAL n UNIT` | Runs once after a relative delay. |
| `EVERY interval STARTS timestamp ENDS timestamp` | Repeats at fixed intervals within an optional window. |
| `EVERY interval` | Repeats indefinitely starting now. |

Common interval units: `SECOND`, `MINUTE`, `HOUR`, `DAY`, `WEEK`, `MONTH`, `QUARTER`, `YEAR`.

### 4.3 The `NEW`/`OLD` Pseudorecords

Not applicable — events do not respond to row changes and do not expose `NEW` or `OLD`. They execute standalone SQL logic.


---

## 5. Examples Based on `labsheet.sql`

The `labsheet.sql` file in this folder defines tables `accounts` and `interest_log`, seeds sample data, and creates a recurring event `add_interest` that credits 1% interest to accounts with a balance over 10,000 every minute.

### 5.1 Schema and seed data

```sql
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) NOT NULL,
    last_interest_time DATETIME NULL
);

CREATE TABLE IF NOT EXISTS interest_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    interest_added DECIMAL(10, 2) NOT NULL,
    log_time DATETIME NOT NULL
);

INSERT INTO accounts (account_id, customer_name, balance, last_interest_time) VALUES
(1, 'Kasun', 9500.00, NULL),
(2, 'Nimal', 12000.00, NULL),
(3, 'Ravi', 20000.00, NULL)
ON DUPLICATE KEY UPDATE balance = VALUES(balance), last_interest_time = VALUES(last_interest_time);
```

### 5.2 Recurring event — apply interest every minute

```sql
DROP EVENT IF EXISTS add_interest;

DELIMITER $$

CREATE EVENT add_interest
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    DECLARE v_log_time DATETIME;
    SET v_log_time = NOW();

    -- Log interest calculated on the original balance before updating
    INSERT INTO interest_log (account_id, interest_added, log_time)
    SELECT account_id, ROUND(balance * 0.01, 2), v_log_time
    FROM accounts
    WHERE balance > 10000;

    -- Apply interest and record when it was last credited
    UPDATE accounts
    SET balance = ROUND(balance * 1.01, 2),
        last_interest_time = v_log_time
    WHERE balance > 10000;
END$$

DELIMITER ;
```

What this does:

- Every minute, the event checks `accounts` for rows where `balance > 10000`.
- For each qualifying account, it inserts a row into `interest_log` recording the interest amount (`balance × 1%`) and the timestamp.
- It then increases the account `balance` by 1% and stamps `last_interest_time`.

**Before (sample):** Kasun 9,500.00 (not eligible), Nimal 12,000.00, Ravi 20,000.00  
**After one run:** Nimal 12,120.00, Ravi 20,200.00; `interest_log` gains two rows.

### 5.3 One-time event — run at a specific future time

```sql
DELIMITER //

CREATE EVENT purge_temp_records
ON SCHEDULE AT '2026-12-01 02:00:00'
DO
BEGIN
    DELETE FROM temp_uploads
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 DAY);
END//

DELIMITER ;
```

- Runs exactly once at 2:00 AM on December 1, 2026.
- After execution, the event is dropped automatically (default `ON COMPLETION DROP`).

### 5.4 Recurring event with start/end window

```sql
DELIMITER //

CREATE EVENT daily_summary
ON SCHEDULE EVERY 1 DAY
STARTS '2026-11-01 00:00:00'
ENDS '2026-12-31 23:59:59'
ON COMPLETION PRESERVE
ENABLE
COMMENT 'Generate end-of-day summary report'
DO
BEGIN
    CALL sp_generate_daily_summary();
END//

DELIMITER ;
```

- Runs every day between November 1 and December 31, 2026.
- `ON COMPLETION PRESERVE` keeps the event definition after the end date (useful for inspection).


---

## 6. Managing Events

### 6.1 View existing events

```sql
-- All events in the current schema
SHOW EVENTS;

-- Events for a specific schema
SHOW EVENTS FROM mydb;

-- Detailed metadata from the data dictionary
SELECT EVENT_NAME, EVENT_SCHEMA, STATUS, EVENT_TYPE, EXECUTE_AT, INTERVAL_VALUE, INTERVAL_FIELD
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'mydb';

-- Show the full definition of an event
SHOW CREATE EVENT add_interest \G
```

### 6.2 Alter an event

```sql
-- Change schedule and re-enable
ALTER EVENT add_interest
ON SCHEDULE EVERY 5 MINUTE
ENABLE;

-- Disable an event without dropping it
ALTER EVENT add_interest DISABLE;

-- Rename an event
ALTER EVENT add_interest RENAME TO add_monthly_interest;
```

### 6.3 Drop an event

```sql
DROP EVENT IF EXISTS event_name;

-- Example
DROP EVENT IF EXISTS add_interest;
```

`DROP EVENT` removes only the event definition; underlying tables and data are unaffected.

---

## 7. Best Practices

1. **Enable the scheduler first** — events never run unless `event_scheduler = ON`; verify with `SHOW VARIABLES LIKE 'event_scheduler';`.
2. **Test the logic separately** — run the event body as plain SQL first to confirm it behaves as expected before wrapping it in `CREATE EVENT`.
3. **Use meaningful names** — prefix with `evt_` and include purpose, e.g., `evt_daily_summary`, `evt_apply_interest`.
4. **Prefer `DISABLE` over `DROP` during debugging** — turn an event off temporarily instead of recreating it from scratch.
5. **Log what the event does** — write to an audit/log table (as `add_interest` writes to `interest_log`) so you can verify executions afterward.
6. **Handle errors inside the body** — use `DECLARE ... HANDLER` or `SIGNAL` where appropriate so a failing event body does not silently abort.
7. **Avoid long-running or heavy operations** — events run in the scheduler thread; very heavy jobs can block other scheduled events.
8. **Keep `ON COMPLETION` in mind** — one-time events are dropped after running by default; use `ON COMPLETION PRESERVE` if you need to inspect or reuse them.
9. **Use `STARTS`/`ENDS` for recurring events** — bound the active window so events do not run forever unintentionally.
10. **Document schedules** — because events run implicitly, record their schedule and purpose in schema documentation.

---

## 8. Limitations & Restrictions

- Events cannot reference `NEW` or `OLD` (they are not row-triggered).
- Event bodies cannot contain `LOCK TABLES`, `UNLOCK TABLES`, or certain transactional statements depending on context.
- Scheduling resolution is approximate; events may not fire at the exact millisecond.
- Events run with the privileges of the definer; ensure the definer has access to all referenced tables.
- An event that is disabled will not execute even when its schedule arrives.
- Only one event with a given name can exist per schema.
- The scheduler thread itself must be running; it is not enabled by default in some MySQL distributions.

---

## 9. Quick Reference Cheat Sheet

| Task | SQL |
|------|-----|
| Enable scheduler | `SET GLOBAL event_scheduler = ON;` |
| Check scheduler | `SHOW VARIABLES LIKE 'event_scheduler';` |
| Create one-time event | `CREATE EVENT e ON SCHEDULE AT 'ts' DO ...` |
| Create recurring event | `CREATE EVENT e ON SCHEDULE EVERY n UNIT DO ...` |
| Event with start/end | `... STARTS 'ts1' ENDS 'ts2'` |
| Preserve after completion | `ON COMPLETION PRESERVE` |
| Disable event | `ALTER EVENT e DISABLE;` |
| Enable event | `ALTER EVENT e ENABLE;` |
| List events | `SHOW EVENTS [FROM db];` |
| Event metadata | `SELECT * FROM information_schema.EVENTS WHERE EVENT_SCHEMA='db';` |
| Show definition | `SHOW CREATE EVENT e \G` |
| Drop event | `DROP EVENT IF EXISTS e;` |
| Change schedule | `ALTER EVENT e ON SCHEDULE EVERY ...;` |
| Change delimiter | `DELIMITER // ... END // DELIMITER ;` |

---

## 10. Related Files in This Folder

| File | Description |
|------|-------------|
| `labsheet.sql` | SQL lab script creating `accounts`/`interest_log` tables and the `add_interest` recurring event |
