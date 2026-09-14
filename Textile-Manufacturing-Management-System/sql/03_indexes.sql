SET SEARCH_PATH TO Textile_Industry;

-- Employee
CREATE INDEX IF NOT EXISTS idx_employee_dept_id        ON Employee (Dept_ID);
CREATE INDEX IF NOT EXISTS idx_employee_supervisor_id  ON Employee (Supervisor_ID);

-- Department
CREATE INDEX IF NOT EXISTS idx_department_manager_emp_id ON Department (Manager_Emp_ID);

-- Company
CREATE INDEX IF NOT EXISTS idx_company_rep_emp_id ON Company (Rep_Emp_ID);

-- Warehouse
CREATE INDEX IF NOT EXISTS idx_warehouse_dept_id ON Warehouse (Dept_ID);

-- Vehicle
CREATE INDEX IF NOT EXISTS idx_vehicle_company_id ON Vehicle (Company_ID);

-- PurchaseOrder
CREATE INDEX IF NOT EXISTS idx_purchaseorder_dept_id ON PurchaseOrder (Dept_ID);

-- Consignment
CREATE INDEX IF NOT EXISTS idx_consignment_vehicleno     ON Consignment (VehicleNo);
CREATE INDEX IF NOT EXISTS idx_consignment_warehouse_id  ON Consignment (Warehouse_ID);
CREATE INDEX IF NOT EXISTS idx_consignment_order_id      ON Consignment (Order_ID);

-- ProductionOrder
CREATE INDEX IF NOT EXISTS idx_productionorder_dept_id    ON ProductionOrder (Dept_ID);
CREATE INDEX IF NOT EXISTS idx_productionorder_product_id ON ProductionOrder (Product_ID);

-- PhaseExecution
CREATE INDEX IF NOT EXISTS idx_phaseexecution_dept_id    ON PhaseExecution (Dept_ID);
CREATE INDEX IF NOT EXISTS idx_phaseexecution_product_id ON PhaseExecution (Product_ID);

-- PhaseTimeLog
CREATE INDEX IF NOT EXISTS idx_phasetimelog_order_seq ON PhaseTimeLog (Order_ID, Seq_No);

-- PhaseResourceConsumption
CREATE INDEX IF NOT EXISTS idx_phaseresourceconsumption_order_seq
    ON PhaseResourceConsumption (Order_ID, Seq_No);

-- Worker
CREATE INDEX IF NOT EXISTS idx_worker_emp_id ON Worker (Emp_ID);

-- PackingBatch
CREATE INDEX IF NOT EXISTS idx_packingbatch_dept_id ON PackingBatch (Dept_ID);

-- Prod_Order_ID
CREATE INDEX IF NOT EXISTS idx_packingbatch_prodorder_phase
    ON PackingBatch (Prod_Order_ID, Phase_Seq_No);

-- FabricRoll
CREATE INDEX IF NOT EXISTS idx_fabricroll_packing_id   ON FabricRoll (Packing_ID);
CREATE INDEX IF NOT EXISTS idx_fabricroll_warehouse_id ON FabricRoll (Warehouse_ID);
CREATE INDEX IF NOT EXISTS idx_fabricroll_product_id   ON FabricRoll (Product_ID);

-- many to many tables
CREATE INDEX IF NOT EXISTS idx_company_rawmaterial_material_id
    ON Company_RawMaterial (Material_ID);
CREATE INDEX IF NOT EXISTS idx_rawmaterial_warehouse_warehouse_id
    ON RawMaterial_Warehouse (Warehouse_ID);
CREATE INDEX IF NOT EXISTS idx_rawmaterial_department_dept_id
    ON RawMaterial_Department (Dept_ID);
CREATE INDEX IF NOT EXISTS idx_consignment_rawmaterial_material_id
    ON Consignment_RawMaterial (Material_ID);
CREATE INDEX IF NOT EXISTS idx_purchaseorder_rawmaterial_material_id
    ON PurchaseOrder_RawMaterial (Material_ID);
CREATE INDEX IF NOT EXISTS idx_po_company_company_id
    ON PO_Company (Company_ID);
CREATE INDEX IF NOT EXISTS idx_prodorder_rawmat_wh_material_warehouse
    ON ProductionOrder_RawMaterial_Warehouse (Material_ID, Warehouse_ID);
CREATE INDEX IF NOT EXISTS idx_worker_department_dept_id
    ON Worker_Department (Dept_ID);
CREATE INDEX IF NOT EXISTS idx_workerdept_shift_shift_id
    ON WorkerDept_Shift (Shift_ID);
CREATE INDEX IF NOT EXISTS idx_worker_packingbatch_packing_id
    ON Worker_PackingBatch (Packing_ID);
CREATE INDEX IF NOT EXISTS idx_workerpacking_shift_shift_id
    ON WorkerPacking_Shift (Shift_ID);
CREATE INDEX IF NOT EXISTS idx_worker_warehouse_warehouse_id
    ON Worker_Warehouse (Warehouse_ID);
CREATE INDEX IF NOT EXISTS idx_workerwarehouse_shift_shift_id
    ON WorkerWarehouse_Shift (Shift_ID);

-- Employee_Shift
CREATE INDEX IF NOT EXISTS idx_employee_shift_shift_id
    ON Employee_Shift (Shift_ID);
