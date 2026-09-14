SET SEARCH_PATH TO Textile_Industry;

-- 1. Raw materials currently below their reorder level, and by
--    how much, per warehouse. Used by Procurement/Warehouse
--    teams to decide what to reorder.
CREATE OR REPLACE VIEW vw_low_stock_raw_materials AS
SELECT  rm.Material_ID,
        rm.Material_Name,
        rm.Category,
        rw.Warehouse_ID,
        rw.Qty_Stock,
        rm.Reorder_Level,
        (rm.Reorder_Level - rw.Qty_Stock) AS Qty_Short
FROM    RawMaterial rm
JOIN    RawMaterial_Warehouse rw ON rw.Material_ID = rm.Material_ID
WHERE   rw.Qty_Stock < rm.Reorder_Level
ORDER   BY Qty_Short DESC;

-- 2. Active employee directory with department name and
--    supervisor's full name, instead of raw supervisor IDs.
CREATE OR REPLACE VIEW vw_employee_directory AS
SELECT  e.Emp_ID,
        e.FName || ' ' || COALESCE(e.MName || ' ', '') || e.LName AS Full_Name,
        e.Job_Title,
        d.Dept_Name,
        e.Company_Email,
        e.Phone,
        sup.FName || ' ' || sup.LName AS Supervisor_Name
FROM    Employee e
JOIN    Department d  ON d.Dept_ID = e.Dept_ID
LEFT JOIN Employee sup ON sup.Emp_ID = e.Supervisor_ID AND sup.Emp_ID <> e.Emp_ID
WHERE   e.isActive = TRUE;

-- 3. Invoices that still have money outstanding (pending or
--    partial), with the supplier/customer company attached via
--    PO_Company. Used by Accounts & Finance for collections.
CREATE OR REPLACE VIEW vw_pending_invoices AS
SELECT  oi.Invoice_ID,
        oi.Invoice_TS,
        oi.Invoice_Type,
        oi.Final_Amount,
        oi.Payment_Status,
        oi.Due_Date,
        c.Company_Name,
        po.Order_ID
FROM    OrderInvoice oi
JOIN    PO_Company poc ON poc.Invoice_ID = oi.Invoice_ID
JOIN    Company c      ON c.Company_ID   = poc.Company_ID
JOIN    PurchaseOrder po ON po.Order_ID  = poc.Order_ID
WHERE   oi.Payment_Status IN ('pending', 'partial')
ORDER   BY oi.Due_Date;

-- 4. Production order progress: how many of a production
--    order's phases are completed vs. total phases defined,
--    as a percentage. Used by Production Planning for a
--    quick status view without manually counting phases.
CREATE OR REPLACE VIEW vw_production_order_progress AS
SELECT  po.Order_ID,
        po.Status         AS Order_Status,
        fm.Product_Name,
        po.Start_Date,
        po.Expected_End_Date,
        COUNT(pe.Seq_No)                                            AS Total_Phases,
        COUNT(pe.Seq_No) FILTER (WHERE pe.Status = 'Completed')     AS Completed_Phases,
        ROUND(
            100.0 * COUNT(pe.Seq_No) FILTER (WHERE pe.Status = 'Completed')
            / NULLIF(COUNT(pe.Seq_No), 0), 1
        )                                                            AS Pct_Complete
FROM    ProductionOrder po
JOIN    FinalMaterial fm   ON fm.Product_ID = po.Product_ID
LEFT JOIN PhaseExecution pe ON pe.Order_ID  = po.Order_ID
GROUP   BY po.Order_ID, po.Status, fm.Product_Name, po.Start_Date, po.Expected_End_Date
ORDER   BY po.Order_ID;
