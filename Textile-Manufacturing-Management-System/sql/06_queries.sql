-- ============================================================
--  TEXTILE INDUSTRY DATABASE – SQL QUERY SCENARIOS
--  Schema: Textile_Industry  |  Dialect: PostgreSQL
--  Based on Bhavani Textiles sample dataset (Jan–Apr 2024)
-- ============================================================
SET SEARCH_PATH TO Textile_Industry;


-- ============================================================
-- SCENARIO 1: PROCUREMENT & SUPPLIER MANAGEMENT
-- Context: The Procurement department (DEPT01) manages 15 purchase
-- orders (PO001–PO015) placed with suppliers COMP01–COMP12 and
-- transport companies COMP17–COMP20. Invoices INV001–INV015 track
-- payment. Some are 'paid', some 'partial', some 'pending'.
-- ============================================================

-- Q1. Which companies supply raw materials to Bhavani Textiles,
--     and who is the contact person for each?
SELECT  c.Company_ID,
        c.Company_Name,
        ct.Company_Type,
        c.CP_Name,
        c.CP_Phone,
        c.CP_Email
FROM    Company c
JOIN    Company_Type ct ON ct.Company_ID = c.Company_ID
WHERE   ct.Company_Type IN ('Supplier', 'Vendor')
  AND   c.isActive = TRUE
ORDER   BY ct.Company_Type, c.Company_Name;


-- Q2. List all raw materials that each supplier provides,
--     along with the material category.
SELECT  c.Company_Name,
        ct.Company_Type,
        rm.Material_ID,
        rm.Material_Name,
        rm.Category,
        rm.Unit_Of_Measure
FROM    Company c
JOIN    Company_Type ct        ON ct.Company_ID  = c.Company_ID
JOIN    Company_RawMaterial crm ON crm.Company_ID = c.Company_ID
JOIN    RawMaterial rm         ON rm.Material_ID  = crm.Material_ID
WHERE   ct.Company_Type IN ('Supplier', 'Vendor')
ORDER   BY c.Company_Name, rm.Category;


-- Q3. Show every purchase order along with the supplier name,
--     employee who handled it, and the current PO status.
SELECT  po.Order_ID,
        po.Order_TS::DATE        AS Order_Date,
        po.Status,
        c.Company_Name           AS Supplier,
        e.FName || ' ' || e.LName AS Handled_By,
        e.Job_Title
FROM    PurchaseOrder po
JOIN    PO_Company poc  ON poc.Order_ID   = po.Order_ID
JOIN    Company c       ON c.Company_ID   = poc.Company_ID
JOIN    Employee e      ON e.Emp_ID       = c.Rep_Emp_ID
ORDER   BY po.Order_TS;


-- Q4. For each purchase order, list the raw materials ordered
--     and the unit price negotiated.
SELECT  po.Order_ID,
        po.Order_TS::DATE AS Order_Date,
        c.Company_Name,
        rm.Material_Name,
        rm.Category,
        porm.Unit_Price,
        rm.Unit_Of_Measure
FROM    PurchaseOrder po
JOIN    PO_Company poc              ON poc.Order_ID   = po.Order_ID
JOIN    Company c                   ON c.Company_ID   = poc.Company_ID
JOIN    PurchaseOrder_RawMaterial porm ON porm.Order_ID = po.Order_ID
JOIN    RawMaterial rm              ON rm.Material_ID  = porm.Material_ID
ORDER   BY po.Order_TS, rm.Category;


-- Q5. Show all invoices with their payment status,
--     which supplier they belong to, and how much tax was charged.
SELECT  oi.Invoice_ID,
        c.Company_Name,
        oi.Invoice_TS::DATE    AS Invoice_Date,
        oi.Invoice_Type,
        oi.Total_Amount,
        oi.Tax_Amount,
        oi.Discount,
        oi.Final_Amount,
        oi.Payment_Status,
        oi.Due_Date
FROM    OrderInvoice oi
JOIN    PO_Company poc  ON poc.Invoice_ID = oi.Invoice_ID
JOIN    Company c       ON c.Company_ID   = poc.Company_ID
ORDER   BY oi.Invoice_TS;


-- Q6. Which invoices are NOT fully paid yet (status = pending or partial)?
--     Show the supplier, amount due, and due date.
SELECT  oi.Invoice_ID,
        c.Company_Name,
        oi.Final_Amount,
        oi.Payment_Status,
        oi.Due_Date,
        po.Order_ID
FROM    OrderInvoice oi
JOIN    PO_Company poc  ON poc.Invoice_ID = oi.Invoice_ID
JOIN    Company c       ON c.Company_ID   = poc.Company_ID
JOIN    PurchaseOrder po ON po.Order_ID   = poc.Order_ID
WHERE   oi.Payment_Status IN ('pending', 'partial')
ORDER   BY oi.Due_Date;


-- Q7. How much has Bhavani Textiles spent per supplier in total
--     (sum of all final invoice amounts)?
SELECT  c.Company_Name,
        ct.Company_Type,
        COUNT(oi.Invoice_ID)       AS Invoice_Count,
        SUM(oi.Final_Amount)       AS Total_Invoiced,
        SUM(oi.Tax_Amount)         AS Total_Tax_Paid,
        SUM(oi.Discount)           AS Total_Discount
FROM    Company c
JOIN    Company_Type ct ON ct.Company_ID = c.Company_ID
JOIN    PO_Company poc  ON poc.Company_ID = c.Company_ID
JOIN    OrderInvoice oi ON oi.Invoice_ID  = poc.Invoice_ID
GROUP   BY c.Company_Name, ct.Company_Type
ORDER   BY Total_Invoiced DESC;


-- Q8. Which raw material has been purchased more than once
--     (appears in multiple POs), and at what price each time?
--     Useful for spotting price fluctuations across orders.
SELECT  rm.Material_Name,
        rm.Category,
        po.Order_ID,
        po.Order_TS::DATE AS Order_Date,
        c.Company_Name,
        porm.Unit_Price
FROM    PurchaseOrder_RawMaterial porm
JOIN    RawMaterial rm  ON rm.Material_ID  = porm.Material_ID
JOIN    PurchaseOrder po ON po.Order_ID    = porm.Order_ID
JOIN    PO_Company poc  ON poc.Order_ID    = po.Order_ID
JOIN    Company c       ON c.Company_ID    = poc.Company_ID
WHERE   porm.Material_ID IN (
            SELECT Material_ID
            FROM   PurchaseOrder_RawMaterial
            GROUP  BY Material_ID
            HAVING COUNT(DISTINCT Order_ID) > 1
        )
ORDER   BY rm.Material_Name, po.Order_TS;


-- Q9. Show each purchase order's expected completion date
--     versus when it was actually placed (order timestamp).
SELECT  po.Order_ID,
        po.Order_TS::DATE                AS Order_Placed,
        poc.Expected_Order_Completion    AS Expected_Completion,
        c.Company_Name,
        po.Status,
        poc.Expected_Order_Completion
            - po.Order_TS::DATE          AS Days_Given_To_Supplier
FROM    PurchaseOrder po
JOIN    PO_Company poc ON poc.Order_ID  = po.Order_ID
JOIN    Company c      ON c.Company_ID  = poc.Company_ID
ORDER   BY Days_Given_To_Supplier DESC;


-- Q10. Which transport companies carried consignments for
--      Bhavani Textiles, and how many consignments did each handle?
SELECT  c.Company_Name       AS Transport_Company,
        c.CP_Name            AS Contact_Person,
        c.CP_Phone,
        COUNT(cs.Consignment_ID) AS Consignments_Handled,
        COUNT(CASE WHEN cs.Status = 'Delivered' THEN 1 END) AS Delivered
FROM    Company c
JOIN    Vehicle v   ON v.Company_ID       = c.Company_ID
JOIN    Consignment cs ON cs.VehicleNo   = v.VehicleNo
GROUP   BY c.Company_Name, c.CP_Name, c.CP_Phone
ORDER   BY Consignments_Handled DESC;


-- Q11. For each delivered consignment, show what materials were
--      received, the quantity delivered, and which warehouse they
--      went to.
SELECT  cs.Consignment_ID,
        cs.Delivered_TS::DATE  AS Delivered_On,
        w.Zone                 AS Warehouse_Zone,
        rm.Material_Name,
        rm.Category,
        crm.Qty_Delivered,
        rm.Unit_Of_Measure
FROM    Consignment cs
JOIN    Consignment_RawMaterial crm ON crm.Consignment_ID = cs.Consignment_ID
JOIN    RawMaterial rm              ON rm.Material_ID      = crm.Material_ID
JOIN    Warehouse w                 ON w.Warehouse_ID      = cs.Warehouse_ID
WHERE   cs.Status = 'Delivered'
ORDER   BY cs.Delivered_TS, rm.Category;


-- Q12. Which consignments are currently In Transit or Pending
--      (not yet delivered)? Show the vehicle, driver, and
--      expected arrival.
SELECT  cs.Consignment_ID,
        cs.Status,
        cs.Expected_Arrival_Date,
        v.VehicleNo,
        v.VehicleType,
        v.Driver_Name,
        v.Driver_Phone,
        cs.Transport_CP_Name,
        cs.Transport_CP_Phone,
        po.Order_ID
FROM    Consignment cs
JOIN    Vehicle v       ON v.VehicleNo  = cs.VehicleNo
JOIN    PurchaseOrder po ON po.Order_ID = cs.Order_ID
WHERE   cs.Status IN ('In Transit', 'Pending')
ORDER   BY cs.Expected_Arrival_Date;


-- Q13. Which supplier has provided the most variety of raw
--      material categories?
SELECT  c.Company_Name,
        COUNT(DISTINCT rm.Category)  AS Category_Count,
        STRING_AGG(DISTINCT rm.Category, ', ' ORDER BY rm.Category)
                                     AS Categories_Supplied
FROM    Company c
JOIN    Company_RawMaterial crm ON crm.Company_ID = c.Company_ID
JOIN    RawMaterial rm          ON rm.Material_ID  = crm.Material_ID
GROUP   BY c.Company_Name
ORDER   BY Category_Count DESC;


-- Q14. Show each purchase order along with the payment mode
--      (invoice type) used to settle it.
SELECT  po.Order_ID,
        po.Order_TS::DATE    AS Order_Date,
        c.Company_Name,
        oi.Invoice_ID,
        oi.Invoice_Type      AS Payment_Mode,
        oi.Final_Amount,
        oi.Payment_Status
FROM    PurchaseOrder po
JOIN    PO_Company poc ON poc.Order_ID  = po.Order_ID
JOIN    Company c      ON c.Company_ID  = poc.Company_ID
JOIN    OrderInvoice oi ON oi.Invoice_ID = poc.Invoice_ID
ORDER   BY po.Order_TS;


-- Q15. Which raw material categories have been ordered most
--      frequently (across all POs), and what is the total spend
--      per category?
SELECT  rm.Category,
        COUNT(DISTINCT porm.Order_ID)  AS Times_Ordered,
        SUM(oi.Final_Amount)           AS Total_Spend
FROM    PurchaseOrder_RawMaterial porm
JOIN    RawMaterial rm  ON rm.Material_ID  = porm.Material_ID
JOIN    PurchaseOrder po ON po.Order_ID    = porm.Order_ID
JOIN    PO_Company poc  ON poc.Order_ID    = po.Order_ID
JOIN    OrderInvoice oi ON oi.Invoice_ID   = poc.Invoice_ID
GROUP   BY rm.Category
ORDER   BY Times_Ordered DESC;


-- ============================================================
-- SCENARIO 2: HUMAN RESOURCES & WORKFORCE MANAGEMENT
-- Context: 44 employees (EMP001–EMP044) across 12 departments.
-- Attendance records exist for January 2024 for EMP001, EMP013,
-- EMP021, EMP035. Dependents recorded for senior managers.
-- All employees are active. Shifts: SHF01=Morning, SHF02=Afternoon,
-- SHF03=Night, SHF04=General.
-- ============================================================

-- Q1. List every employee with their full name, department,
--     job title, and the shift they are assigned to.
SELECT  e.Emp_ID,
        e.FName || ' ' || COALESCE(e.MName || ' ', '') || e.LName
                                  AS Full_Name,
        d.Dept_Name,
        e.Job_Title,
        s.Shift_Name,
        s.Start_TS::TIME AS Shift_Start,
        s.End_TS::TIME   AS Shift_End
FROM    Employee e
JOIN    Department d       ON d.Dept_ID  = e.Dept_ID
JOIN    Employee_Shift es  ON es.Emp_ID  = e.Emp_ID
JOIN    Shift s            ON s.Shift_ID = es.Shift_ID
WHERE   e.isActive = TRUE
ORDER   BY d.Dept_Name, e.LName;


-- Q2. Show the reporting chain – each employee and their
--     direct supervisor's name and title.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName  AS Employee,
        e.Job_Title,
        d.Dept_Name,
        s.FName || ' ' || s.LName  AS Reports_To,
        s.Job_Title                AS Supervisor_Title
FROM    Employee e
JOIN    Department d ON d.Dept_ID = e.Dept_ID
JOIN    Employee s   ON s.Emp_ID  = e.Supervisor_ID
WHERE   e.isActive = TRUE
  AND   e.Emp_ID  <> e.Supervisor_ID   -- exclude top-level self-referencing managers
ORDER   BY d.Dept_Name, e.LName;


-- Q3. List all department managers together with their
--     department name, phone, and company email.
SELECT  d.Dept_ID,
        d.Dept_Name,
        e.FName || ' ' || e.LName AS Manager_Name,
        e.Job_Title,
        e.Phone,
        e.Company_Email
FROM    Department d
JOIN    Employee e ON e.Emp_ID = d.Manager_Emp_ID
ORDER   BY d.Dept_Name;


-- Q4. For January 2024, show the attendance summary
--     (Present / Absent / Half-Day / Leave count) for each
--     employee who has attendance records.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName                              AS Employee,
        d.Dept_Name,
        COUNT(CASE WHEN a.Status = 'Present'  THEN 1 END)      AS Present_Days,
        COUNT(CASE WHEN a.Status = 'Absent'   THEN 1 END)      AS Absent_Days,
        COUNT(CASE WHEN a.Status = 'Half-Day' THEN 1 END)      AS Half_Days,
        COUNT(CASE WHEN a.Status = 'Leave'    THEN 1 END)      AS Leave_Days,
        COUNT(a.Att_Date)                                       AS Total_Recorded
FROM    Attendance a
JOIN    Employee e   ON e.Emp_ID  = a.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   EXTRACT(MONTH FROM a.Att_Date) = 1
  AND   EXTRACT(YEAR  FROM a.Att_Date) = 2024
GROUP   BY e.Emp_ID, Employee, d.Dept_Name
ORDER   BY d.Dept_Name;


-- Q5. Calculate average daily working hours for each employee
--     from their check-in / check-out data in January 2024.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName  AS Employee,
        d.Dept_Name,
        ROUND(
            AVG((EXTRACT(EPOCH FROM (a.Check_Out_TS - a.Check_In_TS)) / 3600.0))::numeric
        , 2)                        AS Avg_Hours_Per_Day
FROM    Attendance a
JOIN    Employee e   ON e.Emp_ID  = a.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   a.Check_In_TS IS NOT NULL
  AND   a.Check_Out_TS IS NOT NULL
  AND   EXTRACT(MONTH FROM a.Att_Date) = 1
  AND   EXTRACT(YEAR  FROM a.Att_Date) = 2024
GROUP   BY e.Emp_ID, Employee, d.Dept_Name
ORDER   BY Avg_Hours_Per_Day DESC;


-- Q6. Which employees were on Leave at least once in January 2024?
SELECT  DISTINCT
        e.Emp_ID,
        e.FName || ' ' || e.LName  AS Employee,
        d.Dept_Name,
        e.Job_Title
FROM    Attendance a
JOIN    Employee e   ON e.Emp_ID  = a.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   a.Status = 'Leave'
  AND   EXTRACT(MONTH FROM a.Att_Date) = 1
  AND   EXTRACT(YEAR  FROM a.Att_Date) = 2024
ORDER   BY d.Dept_Name;


-- Q7. Show the salary breakdown by department – headcount,
--     minimum, maximum, and average salary.
SELECT  d.Dept_Name,
        COUNT(e.Emp_ID)        AS Headcount,
        MIN(e.Salary)          AS Min_Salary,
        MAX(e.Salary)          AS Max_Salary,
        ROUND(AVG(e.Salary),2)::numeric AS Avg_Salary,
        SUM(e.Salary)          AS Monthly_Payroll
FROM    Employee e
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   e.isActive = TRUE
GROUP   BY d.Dept_Name
ORDER   BY Monthly_Payroll DESC;


-- Q8. List every employee along with their date of joining,
--     years of service, blood group, and address details.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName         AS Employee,
        d.Dept_Name,
        eed.Date_Of_Joining,
        DATE_PART('year', AGE(eed.Date_Of_Joining::TIMESTAMP))
                                           AS Years_Of_Service,
        eed.Blood_Group,
        eed.Address_Details,
        eed.PIN
FROM    ExtraEmployeeDetails eed
JOIN    Employee e   ON e.Emp_ID  = eed.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
ORDER   BY eed.Date_Of_Joining;


-- Q9. Show all employee dependents with their relationship,
--     age, and the employee's department.
SELECT  e.FName || ' ' || e.LName  AS Employee,
        d.Dept_Name,
        dep.Dep_Name,
        dep.Relationship,
        dep.Date_Of_Birth,
        DATE_PART('year', AGE(dep.Date_Of_Birth::TIMESTAMP)) AS Dependent_Age
FROM    Dependent dep
JOIN    Employee e   ON e.Emp_ID  = dep.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
ORDER   BY e.LName, dep.Relationship;


-- Q10. Which employees work the Night Shift (SHF03)?
--      Show their department and job title.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName AS Employee,
        d.Dept_Name,
        e.Job_Title,
        s.Shift_Name
FROM    Employee_Shift es
JOIN    Employee e   ON e.Emp_ID  = es.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
JOIN    Shift s      ON s.Shift_ID = es.Shift_ID
WHERE   es.Shift_ID = 'SHF03'
ORDER   BY d.Dept_Name;


-- Q11. How many male and female employees are there per department?
SELECT  d.Dept_Name,
        COUNT(CASE WHEN e.Gender = 'Male'   THEN 1 END) AS Male,
        COUNT(CASE WHEN e.Gender = 'Female' THEN 1 END) AS Female,
        COUNT(e.Emp_ID)                                  AS Total
FROM    Employee e
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   e.isActive = TRUE
GROUP   BY d.Dept_Name
ORDER   BY Total DESC;


-- Q12. Show the top 10 highest-paid active employees along with
--      their department and shift.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName AS Employee,
        d.Dept_Name,
        e.Job_Title,
        e.Salary,
        s.Shift_Name
FROM    Employee e
JOIN    Department d       ON d.Dept_ID  = e.Dept_ID
JOIN    Employee_Shift es  ON es.Emp_ID  = e.Emp_ID
JOIN    Shift s            ON s.Shift_ID = es.Shift_ID
WHERE   e.isActive = TRUE
ORDER   BY e.Salary DESC
LIMIT   10;


-- Q13. Which employees joined between 2019 and 2021 (inclusive)?
--      Show their joining date, department, and document type.
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName AS Employee,
        d.Dept_Name,
        e.Job_Title,
        eed.Date_Of_Joining,
        eed.Doc_Type,
        eed.Doc_Number
FROM    ExtraEmployeeDetails eed
JOIN    Employee e   ON e.Emp_ID  = eed.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   eed.Date_Of_Joining BETWEEN '2019-01-01' AND '2021-12-31'
ORDER   BY eed.Date_Of_Joining;


-- Q14. For each manager (employees who are their own supervisor),
--      list how many direct reportees they have.
SELECT  mgr.Emp_ID                          AS Manager_ID,
        mgr.FName || ' ' || mgr.LName       AS Manager_Name,
        mgr.Job_Title,
        d.Dept_Name,
        COUNT(sub.Emp_ID)                   AS Direct_Reportees
FROM    Employee mgr
JOIN    Department d  ON d.Dept_ID   = mgr.Dept_ID
JOIN    Employee sub  ON sub.Supervisor_ID = mgr.Emp_ID
                     AND sub.Emp_ID        <> mgr.Emp_ID
GROUP   BY mgr.Emp_ID, Manager_Name, mgr.Job_Title, d.Dept_Name
ORDER   BY Direct_Reportees DESC;


-- Q15. Show the bank account and IFSC code details for all employees
--      in the Accounts & Finance department (for payroll reference).
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName AS Employee,
        eed.Account_Number,
        eed.IFSC_Code,
        eed.Policy_Number
FROM    ExtraEmployeeDetails eed
JOIN    Employee e ON e.Emp_ID  = eed.Emp_ID
WHERE   e.Dept_ID = 'DEPT08'
ORDER   BY e.Emp_ID;


-- ============================================================
-- SCENARIO 3: PRODUCTION & MANUFACTURING OPERATIONS
-- Context: 15 production orders (PROD001–PROD015). Each order
-- goes through 5 phases: Spinning(1) → Weaving(2) →
-- Dyeing & Finishing(3) → Quality Check(4) → Packing(5).
-- PROD001–PROD007, PROD009–PROD011 are Completed.
-- PROD008 and PROD012 are In Progress.
-- PROD013–PROD015 are Planned.
-- Phase execution, resource consumption, and time logs exist
-- for PROD001, PROD002, PROD005, PROD008, PROD009.
-- ============================================================

-- Q1. List all production orders with the product being made,
--     its fabric type, grade, and current status.
SELECT  po.Order_ID,
        po.Start_Date,
        po.Expected_End_Date,
        po.Status,
        fm.Product_Name,
        fm.Fabric_Type,
        fm.Grade,
        fm.Colour,
        po.Expected_Qty_Output
FROM    ProductionOrder po
JOIN    FinalMaterial fm ON fm.Product_ID = po.Product_ID
ORDER   BY po.Start_Date;


-- Q2. For completed production orders, compare expected quantity
--     output with actual quantity produced (from Phase 5 – Packing).
SELECT  po.Order_ID,
        fm.Product_Name,
        po.Expected_Qty_Output,
        pe.Qty_Produced          AS Actual_Produced,
        po.Expected_Qty_Output - pe.Qty_Produced AS Variance,
        ROUND(pe.Qty_Produced / po.Expected_Qty_Output * 100, 2)::numeric
                                 AS Achievement_Pct
FROM    ProductionOrder po
JOIN    FinalMaterial fm  ON fm.Product_ID = po.Product_ID
JOIN    PhaseExecution pe ON pe.Order_ID   = po.Order_ID
                          AND pe.Seq_No    = 5
WHERE   po.Status = 'Completed'
  AND   pe.Qty_Produced IS NOT NULL
ORDER   BY Achievement_Pct DESC;


-- Q3. Show the phase-by-phase breakdown for all orders that have
--     phase execution records – include department, input/output
--     quantities and status.
SELECT  pe.Order_ID,
        pe.Seq_No,
        d.Dept_Name              AS Phase_Department,
        pe.Qty_Input,
        pe.Qty_Output,
        pe.Status,
        pe.Start_TS::DATE        AS Phase_Start,
        pe.End_TS::DATE          AS Phase_End
FROM    PhaseExecution pe
JOIN    Department d ON d.Dept_ID = pe.Dept_ID
ORDER   BY pe.Order_ID, pe.Seq_No;


-- Q4. Calculate how many hours each completed phase took for
--     the orders that have full execution records.
SELECT  pe.Order_ID,
        pe.Seq_No,
        d.Dept_Name,
        pe.Start_TS,
        pe.End_TS,
        ROUND(
            (EXTRACT(EPOCH FROM (pe.End_TS - pe.Start_TS)) / 3600.0)::numeric
        , 2)                     AS Duration_Hours
FROM    PhaseExecution pe
JOIN    Department d ON d.Dept_ID = pe.Dept_ID
WHERE   pe.Start_TS IS NOT NULL
  AND   pe.End_TS   IS NOT NULL
ORDER   BY pe.Order_ID, pe.Seq_No;


-- Q5. Show all phase time-log events (machine breakdowns, pauses,
--     completions) with the reason where available.
SELECT  ptl.Log_ID,
        ptl.Order_ID,
        ptl.Seq_No,
        d.Dept_Name,
        ptl.Event,
        ptl.Event_TS,
        ptl.Reason
FROM    PhaseTimeLog ptl
JOIN    PhaseExecution pe ON pe.Order_ID = ptl.Order_ID
                          AND pe.Seq_No  = ptl.Seq_No
JOIN    Department d      ON d.Dept_ID   = pe.Dept_ID
ORDER   BY ptl.Order_ID, ptl.Seq_No, ptl.Event_TS;


-- Q6. Show only the incident/disruption events logged
--     during production (exclude 'Phase Started', 'Phase Completed',
--     'Phase Resumed' events).
SELECT  ptl.Log_ID,
        ptl.Order_ID,
        fm.Product_Name,
        ptl.Seq_No,
        d.Dept_Name,
        ptl.Event,
        ptl.Event_TS,
        ptl.Reason
FROM    PhaseTimeLog ptl
JOIN    PhaseExecution pe  ON pe.Order_ID = ptl.Order_ID
                           AND pe.Seq_No  = ptl.Seq_No
JOIN    Department d       ON d.Dept_ID   = pe.Dept_ID
JOIN    ProductionOrder po ON po.Order_ID = ptl.Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
WHERE   ptl.Event NOT IN ('Phase Started', 'Phase Completed', 'Phase Resumed')
ORDER   BY ptl.Event_TS;


-- Q7. Show the total electricity, water, steam, and diesel consumed
--     per production order across all phases.
SELECT  pe.Order_ID,
        fm.Product_Name,
        SUM(CASE WHEN rc.Resource_Type = 'Electricity'    THEN rc.Qty_Consumed ELSE 0 END) AS Electricity_kWh,
        SUM(CASE WHEN rc.Resource_Type = 'Water'          THEN rc.Qty_Consumed ELSE 0 END) AS Water_Litres,
        SUM(CASE WHEN rc.Resource_Type = 'Steam'          THEN rc.Qty_Consumed ELSE 0 END) AS Steam_kg,
        SUM(CASE WHEN rc.Resource_Type = 'Diesel'         THEN rc.Qty_Consumed ELSE 0 END) AS Diesel_Litres,
        SUM(CASE WHEN rc.Resource_Type = 'LPG'            THEN rc.Qty_Consumed ELSE 0 END) AS LPG_kg,
        SUM(CASE WHEN rc.Resource_Type = 'Compressed Air' THEN rc.Qty_Consumed ELSE 0 END) AS CompAir_m3
FROM    PhaseResourceConsumption prc
JOIN    ResourceConsumed rc        ON rc.Consumption_ID = prc.Consumption_ID
                                   AND rc.Order_ID      = prc.Order_ID
                                   AND rc.Seq_No        = prc.Seq_No
JOIN    PhaseExecution pe          ON pe.Order_ID       = prc.Order_ID
                                   AND pe.Seq_No        = prc.Seq_No
JOIN    ProductionOrder prod       ON prod.Order_ID     = pe.Order_ID
JOIN    FinalMaterial fm           ON fm.Product_ID     = prod.Product_ID
GROUP   BY pe.Order_ID, fm.Product_Name
ORDER   BY pe.Order_ID;


-- Q8. For the Dyeing phase (Seq_No = 3), which orders consumed
--     the most water and steam (dyeing is the heaviest resource phase)?
SELECT  pe.Order_ID,
        fm.Product_Name,
        fm.Colour,
        SUM(CASE WHEN rc.Resource_Type = 'Water' THEN rc.Qty_Consumed ELSE 0 END) AS Water_Litres,
        SUM(CASE WHEN rc.Resource_Type = 'Steam' THEN rc.Qty_Consumed ELSE 0 END) AS Steam_kg,
        SUM(CASE WHEN rc.Resource_Type = 'LPG'   THEN rc.Qty_Consumed ELSE 0 END) AS LPG_kg
FROM    PhaseExecution pe
JOIN    PhaseResourceConsumption prc ON prc.Order_ID = pe.Order_ID
                                     AND prc.Seq_No  = pe.Seq_No
JOIN    ResourceConsumed rc          ON rc.Consumption_ID = prc.Consumption_ID
                                     AND rc.Order_ID      = prc.Order_ID
                                     AND rc.Seq_No        = prc.Seq_No
JOIN    ProductionOrder prod         ON prod.Order_ID   = pe.Order_ID
JOIN    FinalMaterial fm             ON fm.Product_ID   = prod.Product_ID
WHERE   pe.Seq_No = 3
GROUP   BY pe.Order_ID, fm.Product_Name, fm.Colour
ORDER   BY Water_Litres DESC;


-- Q9. Show which raw materials and quantities were allocated
--     to each production order from which warehouse.
SELECT  porw.Order_ID,
        po.Status        AS Order_Status,
        fm.Product_Name,
        rm.Material_Name,
        rm.Category,
        w.Warehouse_ID,
        w.Zone,
        porw.Qty_Required,
        rm.Unit_Of_Measure
FROM    ProductionOrder_RawMaterial_Warehouse porw
JOIN    ProductionOrder po ON po.Order_ID    = porw.Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID  = po.Product_ID
JOIN    RawMaterial rm     ON rm.Material_ID  = porw.Material_ID
JOIN    Warehouse w        ON w.Warehouse_ID  = porw.Warehouse_ID
ORDER   BY porw.Order_ID, rm.Category;


-- Q10. For each production order's Spinning phase (Seq 1),
--      show the quantity input (raw fibre fed) and output (yarn produced),
--      and the wastage percentage.
SELECT  pe.Order_ID,
        fm.Product_Name,
        fm.Fabric_Type,
        pe.Qty_Input    AS Fibre_Input_KG,
        pe.Qty_Output   AS Yarn_Output_KG,
        ROUND((pe.Qty_Input - pe.Qty_Output) / pe.Qty_Input * 100, 2)::numeric
                        AS Wastage_Pct
FROM    PhaseExecution pe
JOIN    ProductionOrder po ON po.Order_ID   = pe.Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
WHERE   pe.Seq_No = 1
  AND   pe.Qty_Output IS NOT NULL
ORDER   BY Wastage_Pct DESC;


-- Q11. Show the packing batches linked to production orders –
--      how much was packed, in which department, and by which phase.
SELECT  pb.Packing_ID,
        pb.Packing_TS::DATE  AS Packing_Date,
        pb.Prod_Order_ID,
        fm.Product_Name,
        pb.Total_Qty_Packed,
        pb.Status,
        d.Dept_Name
FROM    PackingBatch pb
JOIN    ProductionOrder po  ON po.Order_ID  = pb.Prod_Order_ID
JOIN    FinalMaterial fm    ON fm.Product_ID = po.Product_ID
JOIN    Department d        ON d.Dept_ID     = pb.Dept_ID
ORDER   BY pb.Packing_TS;


-- Q12. Show each fabric roll stored in the warehouse – product,
--      colour, weight, length, storage rack, and current status.
SELECT  fr.Roll_ID,
        fm.Product_Name,
        fm.Colour,
        fm.Grade,
        fr.Length   AS Length_Meters,
        fr.Weight   AS Weight_KG,
        fr.Status,
        w.Warehouse_ID,
        w.Zone,
        fr.Storage_Rack,
        fr.Qty_Stored,
        pb.Packing_ID
FROM    FabricRoll fr
JOIN    FinalMaterial fm ON fm.Product_ID   = fr.Product_ID
JOIN    Warehouse w      ON w.Warehouse_ID  = fr.Warehouse_ID
JOIN    PackingBatch pb  ON pb.Packing_ID   = fr.Packing_ID
ORDER   BY w.Zone, fr.Storage_Rack;


-- Q13. Count how many fabric rolls are 'In Stock' vs 'Dispatched'
--      for each product.
SELECT  fm.Product_Name,
        fm.Colour,
        COUNT(CASE WHEN fr.Status = 'In Stock'    THEN 1 END) AS In_Stock_Rolls,
        COUNT(CASE WHEN fr.Status = 'Dispatched'  THEN 1 END) AS Dispatched_Rolls,
        SUM(CASE WHEN fr.Status = 'In Stock'    THEN fr.Qty_Stored ELSE 0 END) AS Stock_Qty,
        SUM(CASE WHEN fr.Status = 'Dispatched'  THEN fr.Qty_Stored ELSE 0 END) AS Dispatched_Qty
FROM    FabricRoll fr
JOIN    FinalMaterial fm ON fm.Product_ID = fr.Product_ID
GROUP   BY fm.Product_Name, fm.Colour
ORDER   BY fm.Product_Name;


-- Q14. Which production orders still have phases in
--      'In Progress' status? Show the phase, department, and
--      how long ago the phase started.
SELECT  pe.Order_ID,
        fm.Product_Name,
        pe.Seq_No,
        d.Dept_Name,
        pe.Start_TS,
        ROUND(
            (EXTRACT(EPOCH FROM (TIMESTAMP '2024-04-20 00:00:00' - pe.Start_TS)) / 3600.0)::numeric
        , 1)                    AS Hours_In_Progress
FROM    PhaseExecution pe
JOIN    ProductionOrder po ON po.Order_ID   = pe.Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
JOIN    Department d       ON d.Dept_ID     = pe.Dept_ID
WHERE   pe.Status = 'In Progress'
ORDER   BY pe.Start_TS;


-- Q15. For each completed production order, rank the phases
--      by duration (longest phase first) to identify bottlenecks.
SELECT  pe.Order_ID,
        fm.Product_Name,
        pe.Seq_No,
        d.Dept_Name,
        ROUND(
            (EXTRACT(EPOCH FROM (pe.End_TS - pe.Start_TS)) / 3600.0)::numeric
        , 2)                    AS Duration_Hours,
        RANK() OVER (
            PARTITION BY pe.Order_ID
            ORDER BY (pe.End_TS - pe.Start_TS) DESC
        )                       AS Phase_Rank
FROM    PhaseExecution pe
JOIN    ProductionOrder po ON po.Order_ID   = pe.Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
JOIN    Department d       ON d.Dept_ID     = pe.Dept_ID
WHERE   pe.Start_TS IS NOT NULL
  AND   pe.End_TS   IS NOT NULL
ORDER   BY pe.Order_ID, Phase_Rank;


-- ============================================================
-- SCENARIO 4: WAREHOUSE & INVENTORY MANAGEMENT
-- Context: 8 warehouses (WH001–WH008), all active, managed by
-- DEPT06 (Warehouse Management). WH001–WH002 store raw fibres,
-- WH003 stores dyes & chemicals, WH004–WH005 store finished goods,
-- WH006 stores packaging, WH007 stores consumables, WH008 is the
-- quarantine bay. Stock records exist for all 36 raw materials.
-- Fabric rolls are stored in WH004–WH005.
-- ============================================================

-- Q1. Show all warehouses with their zone, capacity, and which
--     department manages them.
SELECT  w.Warehouse_ID,
        w.Zone,
        w.Capacity,
        d.Dept_Name,
        e.FName || ' ' || e.LName AS Manager_Name,
        w.isActive
FROM    Warehouse w
JOIN    Department d ON d.Dept_ID = w.Dept_ID
JOIN    Employee e   ON e.Emp_ID  = d.Manager_Emp_ID
ORDER   BY w.Zone;


-- Q2. Show current stock levels for all raw materials in each
--     warehouse they are stored in.
SELECT  w.Warehouse_ID,
        w.Zone,
        rm.Material_ID,
        rm.Material_Name,
        rm.Category,
        rmw.Qty_Stock,
        rm.Unit_Of_Measure,
        rm.Reorder_Level
FROM    RawMaterial_Warehouse rmw
JOIN    Warehouse   w  ON w.Warehouse_ID = rmw.Warehouse_ID
JOIN    RawMaterial rm ON rm.Material_ID = rmw.Material_ID
ORDER   BY w.Zone, rm.Category, rm.Material_Name;


-- Q3. Show the total stock quantity per warehouse across all
--     materials, compared to the warehouse's capacity.
SELECT  w.Warehouse_ID,
        w.Zone,
        w.Capacity,
        SUM(rmw.Qty_Stock)                                       AS Total_Stock,
        ROUND(SUM(rmw.Qty_Stock) / w.Capacity * 100, 2)::numeric        AS Utilization_Pct
FROM    Warehouse w
JOIN    RawMaterial_Warehouse rmw ON rmw.Warehouse_ID = w.Warehouse_ID
GROUP   BY w.Warehouse_ID, w.Zone, w.Capacity
ORDER   BY Utilization_Pct DESC;


-- Q4. Which raw materials are at or below their reorder level
--     right now? Show the shortfall.
SELECT  rm.Material_ID,
        rm.Material_Name,
        rm.Category,
        rm.Unit_Of_Measure,
        rm.Reorder_Level,
        rmw.Qty_Stock          AS Current_Stock,
        rm.Reorder_Level - rmw.Qty_Stock AS Shortfall
FROM    RawMaterial rm
JOIN    RawMaterial_Warehouse rmw ON rmw.Material_ID = rm.Material_ID
WHERE   rmw.Qty_Stock <= rm.Reorder_Level
ORDER   BY Shortfall DESC;


-- Q5. Show which departments use which raw materials
--     (mapping of materials to consuming departments).
SELECT  d.Dept_Name,
        rm.Material_Name,
        rm.Category,
        rm.Unit_Of_Measure
FROM    RawMaterial_Department rmd
JOIN    RawMaterial rm ON rm.Material_ID = rmd.Material_ID
JOIN    Department  d  ON d.Dept_ID      = rmd.Dept_ID
ORDER   BY d.Dept_Name, rm.Category;


-- Q6. Show all fabric rolls currently 'In Stock' in finished goods
--     warehouses (WH004, WH005), with product details and
--     storage rack location.
SELECT  fr.Roll_ID,
        fm.Product_Name,
        fm.Fabric_Type,
        fm.Colour,
        fm.Grade,
        fr.Length   AS Length_M,
        fr.Weight   AS Weight_KG,
        fr.Qty_Stored,
        w.Warehouse_ID,
        w.Zone,
        fr.Storage_Rack
FROM    FabricRoll fr
JOIN    FinalMaterial fm ON fm.Product_ID   = fr.Product_ID
JOIN    Warehouse w      ON w.Warehouse_ID  = fr.Warehouse_ID
WHERE   fr.Status = 'In Stock'
  AND   fr.Warehouse_ID IN ('WH004', 'WH005')
ORDER   BY w.Zone, fr.Storage_Rack;


-- Q7. Show how much packaging material (RM031–RM036) is currently
--     available in the packaging store (WH006).
SELECT  rm.Material_Name,
        rm.Category,
        rmw.Qty_Stock,
        rm.Unit_Of_Measure,
        rm.Reorder_Level,
        CASE
            WHEN rmw.Qty_Stock <= rm.Reorder_Level
            THEN 'REORDER NEEDED'
            ELSE 'Adequate'
        END                  AS Stock_Status
FROM    RawMaterial rm
JOIN    RawMaterial_Warehouse rmw ON rmw.Material_ID  = rm.Material_ID
WHERE   rm.Category = 'Packaging'
  AND   rmw.Warehouse_ID = 'WH006'
ORDER   BY rmw.Qty_Stock;


-- Q8. Which products have their total fabric roll stock
--     currently below their reorder level?
SELECT  fm.Product_ID,
        fm.Product_Name,
        fm.Fabric_Type,
        fm.Reorder_Level,
        SUM(fr.Qty_Stored) AS Total_Stock,
        fm.Reorder_Level - SUM(fr.Qty_Stored) AS Deficit
FROM    FinalMaterial fm
JOIN    FabricRoll fr ON fr.Product_ID = fm.Product_ID
GROUP   BY fm.Product_ID, fm.Product_Name, fm.Fabric_Type, fm.Reorder_Level
HAVING  SUM(fr.Qty_Stored) < fm.Reorder_Level
ORDER   BY Deficit DESC;


-- Q9. Show all consignments delivered to each warehouse –
--     what arrived, quantity, and on which date.
SELECT  w.Warehouse_ID,
        w.Zone,
        cs.Consignment_ID,
        cs.Delivered_TS::DATE AS Delivery_Date,
        rm.Material_Name,
        crm.Qty_Delivered,
        rm.Unit_Of_Measure
FROM    Consignment cs
JOIN    Consignment_RawMaterial crm ON crm.Consignment_ID = cs.Consignment_ID
JOIN    RawMaterial rm              ON rm.Material_ID      = crm.Material_ID
JOIN    Warehouse w                 ON w.Warehouse_ID      = cs.Warehouse_ID
WHERE   cs.Status = 'Delivered'
ORDER   BY w.Warehouse_ID, cs.Delivered_TS;


-- Q10. Show all workers assigned to each warehouse along with
--      their shift and daily wages.
SELECT  w.Warehouse_ID,
        w.Zone,
        wk.Worker_Name,
        wk.Worker_Role,
        s.Shift_Name,
        wws.Wages AS Daily_Wage
FROM    Worker_Warehouse ww
JOIN    Worker wk              ON wk.Worker_ID   = ww.Worker_ID
JOIN    Warehouse w            ON w.Warehouse_ID = ww.Warehouse_ID
JOIN    WorkerWarehouse_Shift wws ON wws.Worker_ID   = ww.Worker_ID
                                  AND wws.Warehouse_ID = ww.Warehouse_ID
JOIN    Shift s                ON s.Shift_ID     = wws.Shift_ID
ORDER   BY w.Zone, s.Shift_Name, wk.Worker_Name;


-- Q11. Estimate the stock value of each dye raw material in WH003
--      using the last known purchase unit price.
SELECT  rm.Material_Name,
        rm.Category,
        rmw.Qty_Stock,
        rm.Unit_Of_Measure,
        last_price.Unit_Price,
        ROUND(rmw.Qty_Stock * last_price.Unit_Price, 2)::numeric AS Estimated_Stock_Value
FROM    RawMaterial_Warehouse rmw
JOIN    RawMaterial rm ON rm.Material_ID = rmw.Material_ID
JOIN    (
    SELECT DISTINCT ON (porm.Material_ID)
           porm.Material_ID,
           porm.Unit_Price
    FROM   PurchaseOrder_RawMaterial porm
    JOIN   PurchaseOrder po ON po.Order_ID = porm.Order_ID
    ORDER  BY porm.Material_ID, po.Order_TS DESC
) last_price ON last_price.Material_ID = rmw.Material_ID
WHERE   rm.Category = 'Dye'
  AND   rmw.Warehouse_ID = 'WH003'
ORDER   BY Estimated_Stock_Value DESC;


-- Q12. How many total fabric rolls (in-stock and dispatched) are
--      stored in each finished goods warehouse, and what is the
--      total stored quantity?
SELECT  w.Warehouse_ID,
        w.Zone,
        COUNT(fr.Roll_ID)      AS Total_Rolls,
        SUM(fr.Qty_Stored)     AS Total_Qty_Stored,
        SUM(fr.Length)         AS Total_Length_Meters,
        SUM(fr.Weight)         AS Total_Weight_KG
FROM    FabricRoll fr
JOIN    Warehouse w ON w.Warehouse_ID = fr.Warehouse_ID
GROUP   BY w.Warehouse_ID, w.Zone
ORDER   BY Total_Qty_Stored DESC;


-- Q13. Show the consignment delivery history for WH001
--      (Raw Cotton store) – what came in and from which PO.
SELECT  cs.Consignment_ID,
        po.Order_ID,
        c.Company_Name         AS Supplier,
        cs.Delivered_TS::DATE  AS Delivered_On,
        v.VehicleNo,
        v.Driver_Name,
        rm.Material_Name,
        crm.Qty_Delivered
FROM    Consignment cs
JOIN    PurchaseOrder po          ON po.Order_ID       = cs.Order_ID
JOIN    PO_Company poc            ON poc.Order_ID      = po.Order_ID
JOIN    Company c                 ON c.Company_ID      = poc.Company_ID
JOIN    Vehicle v                 ON v.VehicleNo       = cs.VehicleNo
JOIN    Consignment_RawMaterial crm ON crm.Consignment_ID = cs.Consignment_ID
JOIN    RawMaterial rm            ON rm.Material_ID    = crm.Material_ID
WHERE   cs.Warehouse_ID = 'WH001'
  AND   cs.Status = 'Delivered'
ORDER   BY cs.Delivered_TS;


-- Q14. Show the dye and chemical stock (WH003) along with
--      how much was consumed by completed production orders.
SELECT  rm.Material_Name,
        rm.Category,
        rmw.Qty_Stock              AS Current_Stock,
        rm.Unit_Of_Measure,
        SUM(crm.Qty_Delivered)     AS Total_Ever_Received,
        rm.Reorder_Level
FROM    RawMaterial rm
JOIN    RawMaterial_Warehouse rmw  ON rmw.Material_ID = rm.Material_ID
LEFT JOIN Consignment_RawMaterial crm ON crm.Material_ID = rm.Material_ID
WHERE   rm.Category IN ('Dye', 'Chemical')
  AND   rmw.Warehouse_ID = 'WH003'
GROUP   BY rm.Material_Name, rm.Category, rmw.Qty_Stock,
           rm.Unit_Of_Measure, rm.Reorder_Level
ORDER   BY rm.Category, rm.Material_Name;


-- Q15. List all vehicles registered with each transport company,
--      including driver details and vehicle type.
SELECT  c.Company_Name,
        v.VehicleNo,
        v.VehicleType,
        v.Driver_Name,
        v.Driver_Phone,
        v.License_Number
FROM    Vehicle v
JOIN    Company c ON c.Company_ID = v.Company_ID
ORDER   BY c.Company_Name, v.VehicleType;


-- ============================================================
-- SCENARIO 5: WORKER & SHIFT OPERATIONS
-- Context: 32 floor workers (WKR001–WKR032) across 5 departments:
-- Spinning (WKR001–WKR008, DEPT02), Weaving (WKR009–WKR015, DEPT03),
-- Dyeing (WKR016–WKR022, DEPT04), Packing (WKR023–WKR027, DEPT05),
-- Warehouse (WKR028–WKR032, DEPT06). All workers are active.
-- Workers are supervised by senior employees (e.g., EMP014, EMP018, etc.)
-- Packing workers participated in PK001–PK005.
-- Warehouse workers are assigned to WH001–WH008.
-- ============================================================

-- Q1. List all floor workers with their role, department,
--     and the employee who supervises them.
SELECT  w.Worker_ID,
        w.Worker_Name,
        w.Worker_Role,
        d.Dept_Name,
        e.FName || ' ' || e.LName AS Supervised_By,
        e.Job_Title               AS Supervisor_Title
FROM    Worker w
JOIN    Worker_Department wd ON wd.Worker_ID = w.Worker_ID
JOIN    Department d         ON d.Dept_ID    = wd.Dept_ID
JOIN    Employee e           ON e.Emp_ID     = w.Emp_ID
WHERE   w.isActive = TRUE
ORDER   BY d.Dept_Name, w.Worker_Role;


-- Q2. Show the shift schedule and daily wages for every worker
--     in each department.
SELECT  d.Dept_Name,
        w.Worker_Name,
        w.Worker_Role,
        s.Shift_Name,
        s.Start_TS::TIME AS Shift_Start,
        s.End_TS::TIME   AS Shift_End,
        wds.Wages        AS Daily_Wage
FROM    WorkerDept_Shift wds
JOIN    Worker w     ON w.Worker_ID  = wds.Worker_ID
JOIN    Department d ON d.Dept_ID    = wds.Dept_ID
JOIN    Shift s      ON s.Shift_ID   = wds.Shift_ID
ORDER   BY d.Dept_Name, s.Shift_Name, w.Worker_Name;


-- Q3. Which shift has the most workers assigned across all departments?
SELECT  s.Shift_Name,
        s.Start_TS::TIME AS Start_Time,
        s.End_TS::TIME   AS End_Time,
        COUNT(DISTINCT wds.Worker_ID) AS Worker_Count,
        SUM(wds.Wages)                AS Total_Daily_Wages
FROM    WorkerDept_Shift wds
JOIN    Shift s ON s.Shift_ID = wds.Shift_ID
GROUP   BY s.Shift_Name, s.Start_TS, s.End_TS
ORDER   BY Worker_Count DESC;


-- Q4. What is the average and total daily wage per department
--     for all workers in that department's shifts?
SELECT  d.Dept_Name,
        COUNT(DISTINCT wds.Worker_ID)  AS Workers_In_Shifts,
        ROUND(AVG(wds.Wages), 2)::numeric       AS Avg_Daily_Wage,
        SUM(wds.Wages)                 AS Total_Daily_Wages
FROM    WorkerDept_Shift wds
JOIN    Department d ON d.Dept_ID = wds.Dept_ID
GROUP   BY d.Dept_Name
ORDER   BY Total_Daily_Wages DESC;


-- Q5. Who are the packing workers, and in which packing
--     batches did each worker participate?
SELECT  w.Worker_Name,
        w.Worker_Role,
        pb.Packing_ID,
        pb.Packing_TS::DATE  AS Packing_Date,
        pb.Total_Qty_Packed,
        pb.Status,
        fm.Product_Name
FROM    Worker_PackingBatch wpb
JOIN    Worker w        ON w.Worker_ID   = wpb.Worker_ID
JOIN    PackingBatch pb ON pb.Packing_ID = wpb.Packing_ID
JOIN    ProductionOrder po ON po.Order_ID = pb.Prod_Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
ORDER   BY pb.Packing_TS, w.Worker_Name;


-- Q6. Show the wages paid to each packing worker per batch
--     (from WorkerPacking_Shift), including which shift they
--     worked.
SELECT  w.Worker_Name,
        pb.Packing_ID,
        fm.Product_Name,
        s.Shift_Name,
        wps.Wages             AS Wages_For_Batch
FROM    WorkerPacking_Shift wps
JOIN    Worker w        ON w.Worker_ID   = wps.Worker_ID
JOIN    PackingBatch pb ON pb.Packing_ID = wps.Packing_ID
JOIN    ProductionOrder po ON po.Order_ID = pb.Prod_Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
JOIN    Shift s         ON s.Shift_ID    = wps.Shift_ID
ORDER   BY pb.Packing_ID, w.Worker_Name;


-- Q7. For each packing batch, calculate the total labour cost
--     (sum of all worker wages) and how many workers participated.
SELECT  pb.Packing_ID,
        fm.Product_Name,
        pb.Packing_TS::DATE          AS Packing_Date,
        pb.Total_Qty_Packed,
        COUNT(DISTINCT wps.Worker_ID) AS Workers_Used,
        SUM(wps.Wages)               AS Total_Labour_Cost
FROM    WorkerPacking_Shift wps
JOIN    PackingBatch pb ON pb.Packing_ID = wps.Packing_ID
JOIN    ProductionOrder po ON po.Order_ID = pb.Prod_Order_ID
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
GROUP   BY pb.Packing_ID, fm.Product_Name, pb.Packing_TS, pb.Total_Qty_Packed
ORDER   BY pb.Packing_TS;


-- Q8. Which packing worker earned the highest total wages
--     across all the batches they worked on?
SELECT  w.Worker_Name,
        w.Worker_Role,
        COUNT(DISTINCT wps.Packing_ID) AS Batches_Worked,
        SUM(wps.Wages)                 AS Total_Wages_Earned
FROM    WorkerPacking_Shift wps
JOIN    Worker w ON w.Worker_ID = wps.Worker_ID
GROUP   BY w.Worker_Name, w.Worker_Role
ORDER   BY Total_Wages_Earned DESC;


-- Q9. Show warehouse workers, which warehouses they are assigned
--     to, and their shift wages at each warehouse.
SELECT  wk.Worker_Name,
        wk.Worker_Role,
        w.Warehouse_ID,
        w.Zone,
        s.Shift_Name,
        wws.Wages AS Daily_Wage
FROM    WorkerWarehouse_Shift wws
JOIN    Worker wk       ON wk.Worker_ID   = wws.Worker_ID
JOIN    Warehouse w     ON w.Warehouse_ID = wws.Warehouse_ID
JOIN    Shift s         ON s.Shift_ID     = wws.Shift_ID
ORDER   BY wk.Worker_Name, w.Zone;


-- Q10. Which warehouse worker covers the most warehouses?
--      (multi-warehouse coverage)
SELECT  wk.Worker_Name,
        wk.Worker_Role,
        COUNT(DISTINCT ww.Warehouse_ID)   AS Warehouses_Covered,
        STRING_AGG(w.Zone, ', ' ORDER BY w.Zone) AS Zones
FROM    Worker_Warehouse ww
JOIN    Worker wk    ON wk.Worker_ID   = ww.Worker_ID
JOIN    Warehouse w  ON w.Warehouse_ID = ww.Warehouse_ID
GROUP   BY wk.Worker_Name, wk.Worker_Role
ORDER   BY Warehouses_Covered DESC;


-- Q11. Show the weaving department workers by shift –
--      who works Morning, Afternoon, and Night in DEPT03?
SELECT  w.Worker_Name,
        w.Worker_Role,
        s.Shift_Name,
        wds.Wages AS Daily_Wage
FROM    WorkerDept_Shift wds
JOIN    Worker w    ON w.Worker_ID  = wds.Worker_ID
JOIN    Shift s     ON s.Shift_ID   = wds.Shift_ID
WHERE   wds.Dept_ID = 'DEPT03'
ORDER   BY s.Shift_Name, w.Worker_Name;


-- Q12. Show the dyeing department's highest-paid worker per shift
--      (Night shift gets higher wages due to difficulty).
SELECT  s.Shift_Name,
        w.Worker_Name,
        w.Worker_Role,
        wds.Wages AS Daily_Wage,
        RANK() OVER (PARTITION BY wds.Shift_ID ORDER BY wds.Wages DESC)
                  AS Wage_Rank
FROM    WorkerDept_Shift wds
JOIN    Worker w ON w.Worker_ID  = wds.Worker_ID
JOIN    Shift  s ON s.Shift_ID   = wds.Shift_ID
WHERE   wds.Dept_ID = 'DEPT04'
ORDER   BY s.Shift_Name, Wage_Rank;


-- Q13. How many workers does each supervisor (employee) manage?
SELECT  e.Emp_ID,
        e.FName || ' ' || e.LName  AS Supervisor_Name,
        e.Job_Title,
        d.Dept_Name,
        COUNT(w.Worker_ID)         AS Workers_Managed
FROM    Worker w
JOIN    Employee e   ON e.Emp_ID  = w.Emp_ID
JOIN    Department d ON d.Dept_ID = e.Dept_ID
WHERE   w.isActive = TRUE
GROUP   BY e.Emp_ID, Supervisor_Name, e.Job_Title, d.Dept_Name
ORDER   BY Workers_Managed DESC;


-- Q14. Show a consolidated view of all spinning department workers
--      with their role, supervisor, shift, and daily wage.
SELECT  w.Worker_ID,
        w.Worker_Name,
        w.Worker_Role,
        e.FName || ' ' || e.LName AS Supervisor,
        s.Shift_Name,
        wds.Wages                 AS Daily_Wage
FROM    Worker_Department wd
JOIN    Worker w    ON w.Worker_ID  = wd.Worker_ID
JOIN    Shift s     ON TRUE
JOIN    WorkerDept_Shift wds ON wds.Worker_ID = wd.Worker_ID
                             AND wds.Dept_ID  = wd.Dept_ID
                             AND wds.Shift_ID = s.Shift_ID
JOIN    Employee e  ON e.Emp_ID = w.Emp_ID
WHERE   wd.Dept_ID = 'DEPT02'
ORDER   BY s.Shift_Name, w.Worker_Name;


-- Q15. Show the total quantity packed per product across all
--      packing batches, along with the number of workers and
--      total labour cost.
SELECT  fm.Product_Name,
        fm.Colour,
        fm.Fabric_Type,
        COUNT(DISTINCT pb.Packing_ID)   AS Packing_Batches,
        SUM(pb.Total_Qty_Packed)        AS Total_Qty_Packed,
        COUNT(DISTINCT wpb.Worker_ID)   AS Unique_Workers,
        SUM(wps.Wages)                  AS Total_Labour_Cost
FROM    PackingBatch pb
JOIN    ProductionOrder po  ON po.Order_ID  = pb.Prod_Order_ID
JOIN    FinalMaterial fm    ON fm.Product_ID = po.Product_ID
JOIN    Worker_PackingBatch wpb ON wpb.Packing_ID = pb.Packing_ID
JOIN    WorkerPacking_Shift wps ON wps.Packing_ID = pb.Packing_ID
                                AND wps.Worker_ID = wpb.Worker_ID
GROUP   BY fm.Product_Name, fm.Colour, fm.Fabric_Type
ORDER   BY Total_Qty_Packed DESC;