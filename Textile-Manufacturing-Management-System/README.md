# 🏭 Textile Manufacturing Operations Management System

A comprehensive **Database Management System (DBMS)** designed to streamline the operations of a textile manufacturing company. This project models the complete workflow of a textile mill, from procurement of raw materials to production, quality control, warehouse management, sales, and logistics.

---

## 📖 Project Overview

The Textile Manufacturing Operations Management System provides a centralized database for managing every major department of a textile manufacturing enterprise. It enables efficient tracking of employees, inventory, production processes, customer orders, shipments, and warehouse operations.

The project is implemented using **PostgreSQL** with a normalized relational database schema (38 tables), including data-integrity constraints, foreign-key indexing, and reusable reporting views. Every SQL file in this repo has been run end-to-end against a live PostgreSQL 16 instance with zero errors.

---

## 🚀 Features

### 👨‍💼 Human Resource Management
- Employee Records
- Department Allocation
- Attendance Tracking
- Shift Management
- Employee Dependents
- Employee Banking & Personal Details

### 🏭 Production Management
- Production Orders
- Manufacturing Phases
- Resource Consumption
- Production Time Logs
- Worker Assignment

### 📦 Inventory Management
- Raw Material Inventory
- Finished Product Inventory
- Warehouse Management
- Fabric Roll Tracking
- Packing Batches
- Reorder-Level Monitoring (flagging stock below threshold)

### 🔍 Quality Control
- Dedicated Quality Control Department & Staff
- Quality Control as a Tracked Production Phase
- Phase-Level Event Logging (delays, defects, re-batching notes)

### 🚚 Logistics Management
- Purchase Orders
- Consignments
- Vehicle Management
- Shipment Tracking
- Delivery Status

### 🤝 Company & Supplier Management
- Customer Companies
- Company Locations
- Company Types
- Contact Representatives

### 💳 Financial Operations
- Order Invoices
- Payment Status
- Tax Calculation
- Discounts

---

## 🗂 Database Modules

- Department
- Employee
- Extra Employee Details
- Attendance
- Employee Shift
- Dependents
- Company
- Company Location
- Company Type
- Raw Material
- Final Material
- Warehouse
- Purchase Orders
- Production Orders
- Phase Execution
- Phase Time Logs
- Resource Consumption
- Packing Batch
- Fabric Roll
- Vehicle
- Consignment
- Worker
- Order Invoice

---

## 🛠 Tech Stack

- **Database:** PostgreSQL 16
- **Language:** SQL
- **Concepts Used**
  - Relational Database Design
  - Normalization (up to BCNF)
  - Primary & Foreign Keys, Composite Keys
  - `CHECK` Constraints for data integrity
  - Indexing strategy for foreign-key join performance
  - Views for reusable reporting queries
  - Cascading Operations (`ON DELETE CASCADE`)
  - Self-Joins (e.g. employee ↔ supervisor)
  - Complex multi-table SQL Queries (window functions, aggregation, subqueries, `HAVING`, `CASE WHEN`)

---

## 📂 Project Structure

```
Textile-Manufacturing-Management-System/
│
├── sql/
│   ├── 01_schema.sql       # Table definitions, PKs, FKs
│   ├── 02_constraints.sql  # CHECK constraints on Status columns
│   ├── 03_indexes.sql      # Indexes on FK columns for join performance
│   ├── 04_views.sql        # Reusable reporting views
│   ├── 05_data.sql         # Sample data (38 tables)
│   └── 06_queries.sql      # 1291 lines of scenario-based queries
│
├── docs/
│   └── ER_Diagram.dia      # Entity-relationship diagram
│
├── .gitignore
└── README.md
```

Run the files in `sql/` in numeric order — each one depends on the tables/data created by the one before it.

---

## 🗃 Database Design

The database consists of multiple interconnected entities representing different operational aspects of a textile manufacturing company.

Some major relationships include:

- Department ↔ Employee
- Employee ↔ Attendance
- Employee ↔ Shift
- Employee ↔ Dependents
- Production Order ↔ Phase Execution
- Warehouse ↔ Fabric Rolls
- Company ↔ Purchase Orders
- Vehicle ↔ Consignment
- Packing Batch ↔ Fabric Roll

The design follows normalization principles to minimize redundancy while maintaining efficient querying.

---

## 📊 Sample Functionalities

- Manage employees across departments
- Record attendance and work shifts
- Track raw material inventory, and flag materials below reorder level
- Monitor production workflow and phase-by-phase completion %
- Record production phase execution, including the Quality Control phase
- Track resource consumption
- Store finished products
- Manage warehouse inventory
- Generate invoices, and surface which are still pending/partial payment
- Track consignments and deliveries
- Maintain customer company records

---

## ▶️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Yash-Agarwal-3186/Textile-Manufacturing-Management-System
cd Textile-Manufacturing-Management-System
```

### 2. Create the database

```sql
CREATE DATABASE textile_industry;
```

### 3. Run the SQL files in order

```bash
psql -d textile_industry -f sql/01_schema.sql
psql -d textile_industry -f sql/02_constraints.sql
psql -d textile_industry -f sql/03_indexes.sql
psql -d textile_industry -f sql/04_views.sql
psql -d textile_industry -f sql/05_data.sql
```

### 4. (Optional) Run the scenario queries

```bash
psql -d textile_industry -f sql/06_queries.sql
```

### 5. Try a view

```sql
SET SEARCH_PATH TO Textile_Industry;
SELECT * FROM vw_low_stock_raw_materials;
SELECT * FROM vw_production_order_progress;
```

---


## 🎯 Learning Outcomes

This project demonstrates practical implementation of:

- Database Design & Entity Relationship Modeling
- Normalization (up to BCNF)
- SQL Constraints & Data Integrity
- Indexing strategy for query performance
- Relational Schema Design
- Real-world Industrial Database Modeling

---

## 👤 Author

**Yash Agarwal**

This project was independently designed and developed by **Yash Agarwal** as an academic DBMS project.

---

## 📄 License

This project is intended for **educational and academic purposes**.

---

## ⭐ If you found this project useful, consider giving it a star!
