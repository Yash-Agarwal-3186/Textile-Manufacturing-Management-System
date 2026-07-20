# 🏭 Textile Manufacturing Operations Management System

A comprehensive **Database Management System (DBMS)** designed to streamline the operations of a textile manufacturing company. This project models the complete workflow of a textile mill, from procurement of raw materials to production, quality inspection, warehouse management, sales, and logistics.

---

## 📖 Project Overview

The Textile Manufacturing Operations Management System provides a centralized database for managing every major department of a textile manufacturing enterprise. It enables efficient tracking of employees, inventory, production processes, customer orders, shipments, and warehouse operations.

The project is implemented using **PostgreSQL** with a normalized relational database schema, ensuring data consistency, integrity, and efficient query execution.

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

### 🔍 Quality Control
- Inspection Records
- Production Status Tracking
- Material Monitoring

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

# 🗂 Database Modules

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

# 🛠 Tech Stack

- **Database:** PostgreSQL
- **Language:** SQL
- **Concepts Used**
  - Relational Database Design
  - Normalization
  - Primary & Foreign Keys
  - Composite Keys
  - Constraints
  - Cascading Operations
  - Transactions
  - Complex SQL Queries

---

# 📂 Project Structure

```
Textile-Manufacturing-DBMS/
│
├── DDL_SCRIPT.sql          # Database Schema
├── DDL_INSERT.sql          # Sample Data
├── INTRODUCTION.pdf        # Project Documentation
├── README.md
```

---

# 🗃 Database Design

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

# 📊 Sample Functionalities

- Manage employees across departments
- Record attendance and work shifts
- Track raw material inventory
- Monitor production workflow
- Record production phase execution
- Track resource consumption
- Store finished products
- Manage warehouse inventory
- Generate invoices
- Track consignments and deliveries
- Maintain customer company records

---

# ▶️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/Textile-Manufacturing-DBMS.git
```

### 2. Create the database

```sql
CREATE DATABASE textile_industry;
```

### 3. Execute the schema

```bash
psql -d textile_industry -f DDL_SCRIPT.sql
```

### 4. Insert sample data

```bash
psql -d textile_industry -f DDL_INSERT.sql
```

---

# 📈 Future Improvements

- Web-based Admin Dashboard
- Role-Based Authentication
- Inventory Analytics
- Automatic Inventory Alerts
- Production Performance Dashboard
- Real-Time Shipment Tracking
- Report Generation
- Data Visualization
- REST API Integration

---

# 🎯 Learning Outcomes

This project demonstrates practical implementation of:

- Database Design
- Entity Relationship Modeling
- Normalization (up to BCNF)
- SQL Constraints
- Relational Schema Design
- Data Integrity
- Real-world Industrial Database Modeling

---

# 👥 Team Members

- Sujal Balva
- **Yash Agarwal**
- Raj Kachhadiya
- Madhav Parmar
- Parthiv Panchal

---

# 📄 License

This project is intended for **educational and academic purposes**.

---

## ⭐ If you found this project useful, consider giving it a star!
