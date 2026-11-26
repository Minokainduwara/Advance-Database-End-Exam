# 🗄️ Advance Database — MySQL Labs Collection

A comprehensive collection of MySQL advanced database labs covering **Functions, Indexes, Stored Procedures, Triggers, Events, and Views**.  
Each topic lives in its own folder with theory, SQL scripts, and practical examples.

---

## 📂 Project Structure

| Folder | Description | Key Docs |
|--------|-------------|----------|
| `mysql-functions/` | Built-in & user-defined MySQL functions with examples | [function.md](mysql-functions/function.md) |
| `mysql-index/` | Index types, creation, optimization, and EXPLAIN plans | [index.md](mysql-index/index.md) |
| `mysql-procedures/` | Stored procedures, parameters, handlers, and transactions | [procedure.md](mysql-procedures/procedure.md) |
| `mysql-triggers/` | Database triggers labsheet | [triggers.md](mysql-triggers/triggers.md) |
| `mysql-events/` | Scheduled events and the Event Scheduler | [events.md](mysql-events/events.md) |
| `mysql-views/` | Views, updatable views, and best practices | [view.md](mysql-views/view.md) |

---

## 🚀 Quick Navigation

### 🔹 MySQL Functions
Learn about built-in functions (string, numeric, date, aggregate) and how to create your own stored functions.

👉 **[Go to mysql-functions/](mysql-functions/)**  
📄 [Read function.md](mysql-functions/function.md)  
📜 [View labsheet2.sql](mysql-functions/labsheet2.sql)

### 🔹 MySQL Indexes
Understand B+ Tree indexes, clustered vs non-clustered, composite/unique/full-text indexes, and query optimization with EXPLAIN.

👉 **[Go to mysql-index/](mysql-index/)**  
📄 [Read index.md](mysql-index/index.md)  
📜 [View Index.sql](mysql-index/Index.sql)

### 🔹 MySQL Stored Procedures
Create procedures with IN/OUT/INOUT parameters, error handlers, cursors, loops, and transactions.

👉 **[Go to mysql-procedures/](mysql-procedures/)**  
📄 [Read procedure.md](mysql-procedures/procedure.md)  
📜 [View labsheet.sql](mysql-procedures/labsheet.sql)

### 🔹 MySQL Triggers
Practice trigger creation and usage with the student database labsheet.

👉 **[Go to mysql-triggers/](mysql-triggers/)**  
📄 [Read triggers.md](mysql-triggers/triggers.md)  
📜 [View labsheet07.sql](mysql-triggers/labsheet07.sql)

### 🔹 MySQL Events
Create scheduled events that run automatically with the MySQL Event Scheduler.

👉 **[Go to mysql-events/](mysql-events/)**  
📄 [Read events.md](mysql-events/events.md)  
📜 [View labsheet.sql](mysql-events/labsheet.sql)

### 🔹 MySQL Views
Create simple, joined, aggregated, and updatable views. Learn about read-only views and best practices.

👉 **[Go to mysql-views/](mysql-views/)**  
📄 [Read view.md](mysql-views/view.md)  
📜 [View labsheet1.sql](mysql-views/labsheet1.sql)

---

## 🛠️ Getting Started

### Prerequisites
- [MySQL Server](https://dev.mysql.com/downloads/) 8.0+
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) or any MySQL client
- A MySQL user with privileges to create databases, tables, procedures, functions, triggers, events, and views

### How to Run
1. **Clone the repository**
   ```bash
   git clone https://github.com/Minokainduwara/Advance-Database-End-Exam.git
   cd Advance-Database-End-Exam
   ```

2. **Choose a topic folder** and open its `.sql` file (e.g., `mysql-functions/labsheet2.sql`).

3. **Execute the script** in MySQL Workbench or via command line:
   ```bash
   mysql -u your_username -p < mysql-functions/labsheet2.sql
   ```

4. **Read the accompanying `.md` file** for theory, examples, and best practices.

---

## 📖 Topic Overview

| Topic | What You'll Learn | SQL File |
|-------|-------------------|----------|
| **Functions** | Built-in functions, user-defined functions, `CREATE FUNCTION`, `RETURN` | `labsheet2.sql` |
| **Indexes** | B+ Tree, unique/composite/full-text indexes, `EXPLAIN`, covering indexes | `Index.sql` |
| **Procedures** | `CREATE PROCEDURE`, `IN/OUT/INOUT` params, handlers, transactions | `labsheet.sql` |
| **Triggers** | Trigger events (`BEFORE`/`AFTER` `INSERT`/`UPDATE`/`DELETE`) | [triggers.md](mysql-triggers/triggers.md), `labsheet07.sql` |
| **Events** | Scheduled events, `event_scheduler`, one-time and recurring execution | [events.md](mysql-events/events.md), `labsheet.sql` |
| **Views** | Virtual tables, updatable views, `WITH CHECK OPTION` | `labsheet1.sql` |

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Fix typos or improve documentation
- Add new SQL examples
- Suggest better practices

Please open an issue or submit a pull request.

---

## 📄 License

This project is for educational purposes as part of the Advanced Database coursework.

---

<div align="center">
  <b>⭐ Star this repo if you found it helpful!</b>
</div>