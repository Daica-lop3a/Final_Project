# SmartWaste - Smart Waste Bin Monitoring and Collection System
## FPT University HCM - PRJ301 (Java Web Application Development) - Fall 2026
### Group 06 Project Documentation Package

---

## 📌 Introduction & Overview
**SmartWaste** is an enterprise-grade IoT-enabled waste monitoring and operational dispatch management system designed for **FPT University HCMC Campus (Saigon Hi-Tech Park)**. The system monitors trash bin fill levels via ultrasonic IoT telemetry sensors in real time, visualizes bin distribution on an interactive GIS map, automatically flags overflow warnings, optimizes collection routes for field operations, and provides comprehensive security audit trails and data discrepancy verification.

### Key Project Specifications:
- **Course**: PRJ301 - Java Web Application Development
- **Semester**: Fall 2026
- **Architecture**: MVC2 (Model-View-Controller 2) Pure Java EE (Servlet 3.1 + JSP + JSTL)
- **Database**: Microsoft SQL Server (18 Tables, Normalized Relational Schema)
- **Application Server**: Apache Tomcat 9.0.x
- **JDK Target**: Java SE 8 (1.8)
- **Security & RBAC**: Custom Authorization Filter (`AuthFilter`), PBKDF2 Password Hashing, Session Fixation Rotation, Cache-Control Protection
- **IoT Integration**: Ultrasonic HC-SR04 telemetry listener endpoint (`/api/bin/update-fill`) with real-time AJAX polling (3s interval)

---

## 📂 Documentation Directory Structure

This `docs/` folder contains the complete, official 5-part project documentation required for project defense and submission:

| File | Document Title | Description |
|---|---|---|
| [`01_INSTALLATION_GUIDE.md`](01_INSTALLATION_GUIDE.md) | **Installation & Setup Guide** | Step-by-step instructions to set up the database from clean SQL scripts, configure Tomcat/NetBeans, and launch the application. |
| [`02_ROLE_FUNCTIONAL_SPEC.md`](02_ROLE_FUNCTIONAL_SPEC.md) | **Role-Based Functional Specification** | Comprehensive breakdown of the 8 RBAC roles, permission matrix, and verified sample login credentials. |
| [`03_DATABASE_SCHEMA_ERD.md`](03_DATABASE_SCHEMA_ERD.md) | **Database Schema & Data Dictionary** | Complete description of all 18 database tables, primary/foreign keys, integrity constraints, and Mermaid ERD diagram. |
| [`04_DEMO_SCRIPT.md`](04_DEMO_SCRIPT.md) | **Step-by-Step Defense Demo Script** | Detailed click-by-click walkthrough for the final presentation, highlighting real-time IoT influx and automatic dispatch. |
| [`05_TEST_CASES_REPORT.md`](05_TEST_CASES_REPORT.md) | **Comprehensive Test Cases Report** | Formal QA test report covering 30+ test cases across authentication, CRUD, telemetry, data validation, and security. |

---

## 👥 Verified Sample Accounts (All Passwords: `123456`)

| Role Code | Role Name | Sample Email | Default Password | Primary Scope |
|---|---|---|---|---|
| `SAD` | Super Administrator | `superadmin@smartwaste.com` | `123456` | Full platform governance, RBAC roles, audit logs, system parameters |
| `ADM` | Campus Administrator | `admin@smartwaste.com` | `123456` | Bins, zones, user management, IoT devices, operational alerts |
| `MGR` | Area Manager | `manager@smartwaste.com` | `123456` | Supervise assigned zone (Area 1), approve tasks, oversee staff |
| `SUP` | Area Supervisor | `supervisor@smartwaste.com` | `123456` | Dispatch collection requests, schedule teams, verify citizen reports |
| `STF` | Collection Staff | `staff1@smartwaste.com` | `123456` | Complete physical garbage pickups, submit completion logs |
| `TEC` | Field Technician | `tech@smartwaste.com` | `123456` | Hardware repair, sensor maintenance, physical calibration |
| `AUD` | Independent Auditor | `auditor@smartwaste.com` | `123456` | Data quality scanner, cross-reconciliation, discrepancy cases |
| `USR` | Campus Citizen | `citizen1@smartwaste.com` | `123456` | Public live map, report overflowing or broken bins, track resolution |
