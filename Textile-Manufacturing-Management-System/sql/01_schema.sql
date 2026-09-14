CREATE SCHEMA Textile_Industry;
SET SEARCH_PATH TO Textile_Industry;

CREATE TABLE Department (
    Dept_ID         VARCHAR(20)     PRIMARY KEY,
    Dept_Name       VARCHAR(100)    NOT NULL UNIQUE
);

CREATE TABLE Employee (
    Emp_ID          VARCHAR(20)     PRIMARY KEY,
    FName           VARCHAR(50)     NOT NULL,
    MName           VARCHAR(50),
    LName           VARCHAR(50)     NOT NULL,
    Phone           VARCHAR(15)     NOT NULL,
    Personal_Email  VARCHAR(100),
    Company_Email   VARCHAR(100)    NOT NULL UNIQUE,
    Date_Of_Birth   DATE            NOT NULL,
    Salary          NUMERIC(12,2)   NOT NULL,
    Gender          VARCHAR(10)     NOT NULL
                    CHECK (Gender IN ('Male', 'Female', 'Other')),
    Job_Title       VARCHAR(100)    NOT NULL,
    isActive        BOOLEAN         NOT NULL DEFAULT TRUE,
    Dept_ID         VARCHAR(20)     NOT NULL,
    Date_Assigned   DATE            NOT NULL,
    Supervisor_ID   VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Dept_ID)       REFERENCES Department(Dept_ID),
    FOREIGN KEY (Supervisor_ID) REFERENCES Employee(Emp_ID)
);

CREATE TABLE Company 
(
    Company_ID      VARCHAR(20)     PRIMARY KEY,
    Company_Name    VARCHAR(100)    NOT NULL,
    Company_Email   VARCHAR(100)    NOT NULL UNIQUE,
    GSTIN           VARCHAR(15)     NOT NULL UNIQUE,
    isActive        BOOLEAN         NOT NULL DEFAULT TRUE,
    CP_Name         VARCHAR(100)    NOT NULL,
    CP_Phone        VARCHAR(15)     NOT NULL,
    CP_Email        VARCHAR(100)    NOT NULL,
    Rep_Emp_ID      VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Rep_Emp_ID) REFERENCES Employee(Emp_ID)
);

CREATE TABLE Company_Type 
(
    Company_ID      VARCHAR(20)     NOT NULL,
    Company_Type    VARCHAR(50)     NOT NULL,
    PRIMARY KEY (Company_ID, Company_Type),
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID) ON DELETE CASCADE
);

CREATE TABLE Company_Location (
    Company_ID      VARCHAR(20)     NOT NULL,
    PIN             VARCHAR(10)     NOT NULL,
    PRIMARY KEY (Company_ID, PIN),
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID) ON DELETE CASCADE
);

CREATE TABLE Shift (
    Shift_ID        VARCHAR(20)     PRIMARY KEY,
    Shift_Name      VARCHAR(50)     NOT NULL,
    Start_TS        TIMESTAMP       NOT NULL,
    End_TS          TIMESTAMP       NOT NULL
);

CREATE TABLE OrderInvoice (
    Invoice_ID      VARCHAR(20)     PRIMARY KEY,
    Invoice_TS      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Invoice_Type    VARCHAR(30)     NOT NULL,
    Total_Amount    NUMERIC(12,2)   NOT NULL,
    Tax_Amount      NUMERIC(12,2)   NOT NULL DEFAULT 0,
    Discount        NUMERIC(12,2)   NOT NULL DEFAULT 0,
    Final_Amount    NUMERIC(12,2)   NOT NULL,
    Payment_Status  VARCHAR(10)     NOT NULL DEFAULT 'pending'
                    CHECK (Payment_Status IN ('pending', 'partial', 'paid')),
    Due_Date        DATE            NOT NULL
);

CREATE TABLE RawMaterial (
    Material_ID         VARCHAR(20)     PRIMARY KEY,
    Material_Name       VARCHAR(100)    NOT NULL,
    Category            VARCHAR(50)     NOT NULL,
    Unit_Of_Measure     VARCHAR(20)     NOT NULL,
    Reorder_Level       NUMERIC(10,2)   NOT NULL DEFAULT 0
);

CREATE TABLE Warehouse (
    Warehouse_ID    VARCHAR(20)     PRIMARY KEY,
    Zone            VARCHAR(50)     NOT NULL,
    isActive        BOOLEAN         NOT NULL DEFAULT TRUE,
    Capacity        NUMERIC(10,2)   NOT NULL,
    Dept_ID         VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE Vehicle 
(
    VehicleNo       VARCHAR(20)     PRIMARY KEY,
    VehicleType     VARCHAR(30)     NOT NULL,
    Driver_Name     VARCHAR(100)    NOT NULL,
    License_Number  VARCHAR(30)     NOT NULL UNIQUE,
    Driver_Phone    VARCHAR(15)     NOT NULL,
    Company_ID      VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID)
);

CREATE TABLE PurchaseOrder (
    Order_ID        VARCHAR(20)     PRIMARY KEY,
    Order_TS        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status          VARCHAR(30)     NOT NULL,
    Dept_ID         VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE Consignment (
    Consignment_ID          VARCHAR(20)     PRIMARY KEY,
    Status                  VARCHAR(30)     NOT NULL,
    Delivered_TS            TIMESTAMP,
    VehicleNo               VARCHAR(20)     NOT NULL,
    Warehouse_ID            VARCHAR(20)     NOT NULL,
    Order_ID                VARCHAR(20)     NOT NULL,
    Transport_CP_Name       VARCHAR(100),
    Transport_CP_Phone      VARCHAR(15),
    Transport_CP_Email      VARCHAR(100),
    Expected_Arrival_Date   DATE,
    FOREIGN KEY (VehicleNo)     REFERENCES Vehicle(VehicleNo),
    FOREIGN KEY (Warehouse_ID)  REFERENCES Warehouse(Warehouse_ID),
    FOREIGN KEY (Order_ID)      REFERENCES PurchaseOrder(Order_ID)
);

ALTER TABLE Department
    ADD COLUMN Manager_Emp_ID VARCHAR(20),
    ADD CONSTRAINT fk_dept_manager
        FOREIGN KEY (Manager_Emp_ID) REFERENCES Employee(Emp_ID);

CREATE TABLE ExtraEmployeeDetails (
    Emp_ID              VARCHAR(20)     PRIMARY KEY,
    Account_Number      VARCHAR(30)     NOT NULL,
    IFSC_Code           VARCHAR(15)     NOT NULL,
    Policy_Number       VARCHAR(30)     NOT NULL,
    Address_Details     TEXT            NOT NULL,
    PIN                 VARCHAR(10)     NOT NULL,
    Date_Of_Joining     DATE            NOT NULL,
    Blood_Group         VARCHAR(5)      NOT NULL,
    Doc_Type            VARCHAR(50)     NOT NULL,
    Doc_Number          VARCHAR(50)     NOT NULL,
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID) ON DELETE CASCADE
);

CREATE TABLE Dependent (
    Emp_ID          VARCHAR(20)     NOT NULL,
    Dep_Name        VARCHAR(100)    NOT NULL,
    Relationship    VARCHAR(30)     NOT NULL,
    Date_Of_Birth   DATE            NOT NULL,
    PRIMARY KEY (Emp_ID, Dep_Name),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID) ON DELETE CASCADE
);

CREATE TABLE Attendance (
    Emp_ID          VARCHAR(20)     NOT NULL,
    Att_Date        DATE            NOT NULL,
    Status          VARCHAR(20)     NOT NULL
                    CHECK (Status IN ('Present', 'Absent', 'Half-Day', 'Leave')),
    Check_In_TS     TIMESTAMP,
    Check_Out_TS    TIMESTAMP,
    PRIMARY KEY (Emp_ID, Att_Date),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID) ON DELETE CASCADE
);

CREATE TABLE Employee_Shift (
    Emp_ID      VARCHAR(20)     NOT NULL,
    Shift_ID    VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Emp_ID, Shift_ID),
    FOREIGN KEY (Emp_ID)    REFERENCES Employee(Emp_ID)  ON DELETE CASCADE,
    FOREIGN KEY (Shift_ID)  REFERENCES Shift(Shift_ID)   ON DELETE CASCADE
);

CREATE TABLE FinalMaterial (
    Product_ID      VARCHAR(20)     PRIMARY KEY,
    Product_Name    VARCHAR(100)    NOT NULL,
    Grade           VARCHAR(20)     NOT NULL,
    Fabric_Type     VARCHAR(50)     NOT NULL,
    Colour          VARCHAR(50)     NOT NULL,
    Reorder_Level   NUMERIC(10,2)   NOT NULL DEFAULT 0
);

CREATE TABLE ProductionOrder (
    Order_ID            VARCHAR(20)     PRIMARY KEY,
    Start_Date          DATE            NOT NULL,
    Expected_End_Date   DATE            NOT NULL,
    Status              VARCHAR(30)     NOT NULL,
    Dept_ID             VARCHAR(20)     NOT NULL,
    Product_ID          VARCHAR(20)     NOT NULL,
    Expected_Qty_Output NUMERIC(10,2)   NOT NULL,
    FOREIGN KEY (Dept_ID)     REFERENCES Department(Dept_ID),
    FOREIGN KEY (Product_ID)  REFERENCES FinalMaterial(Product_ID)
);

CREATE TABLE PhaseExecution (
    Order_ID        VARCHAR(20)     NOT NULL,
    Seq_No          INT             NOT NULL,
    Qty_Input       NUMERIC(10,2)   NOT NULL,
    Qty_Output      NUMERIC(10,2),
    Status          VARCHAR(30)     NOT NULL,
    Start_TS        TIMESTAMP,
    End_TS          TIMESTAMP,
    Dept_ID         VARCHAR(20)     NOT NULL,
    Product_ID      VARCHAR(20),
    Qty_Produced    NUMERIC(10,2),
    PRIMARY KEY (Order_ID, Seq_No),
    FOREIGN KEY (Order_ID)    REFERENCES ProductionOrder(Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (Dept_ID)     REFERENCES Department(Dept_ID),
    FOREIGN KEY (Product_ID)  REFERENCES FinalMaterial(Product_ID)
);

CREATE TABLE PhaseTimeLog (
    Log_ID          VARCHAR(20)     NOT NULL,
    Order_ID        VARCHAR(20)     NOT NULL,
    Seq_No          INT             NOT NULL,
    Event           VARCHAR(100)    NOT NULL,
    Event_TS        TIMESTAMP       NOT NULL,
    Reason          TEXT,
    PRIMARY KEY (Log_ID, Order_ID, Seq_No),
    FOREIGN KEY (Order_ID, Seq_No) REFERENCES PhaseExecution(Order_ID, Seq_No) ON DELETE CASCADE
);

CREATE TABLE PhaseResourceConsumption (
    Consumption_ID  VARCHAR(20)     NOT NULL,
    Order_ID        VARCHAR(20)     NOT NULL,
    Seq_No          INT             NOT NULL,
    Recorded_TS     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Consumption_ID, Order_ID, Seq_No),
    FOREIGN KEY (Order_ID, Seq_No) REFERENCES PhaseExecution(Order_ID, Seq_No) ON DELETE CASCADE
);

CREATE TABLE ResourceConsumed (
    Consumption_ID  VARCHAR(20)     NOT NULL,
    Order_ID        VARCHAR(20)     NOT NULL,
    Seq_No          INT             NOT NULL,
    Resource_Type   VARCHAR(50)     NOT NULL,
    Unit            VARCHAR(20)     NOT NULL,
    Qty_Consumed    NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Consumption_ID, Order_ID, Seq_No, Resource_Type),
    FOREIGN KEY (Consumption_ID, Order_ID, Seq_No)
        REFERENCES PhaseResourceConsumption(Consumption_ID, Order_ID, Seq_No) ON DELETE CASCADE
);

CREATE TABLE Worker (
    Worker_ID       VARCHAR(20)     PRIMARY KEY,
    Worker_Name     VARCHAR(100)    NOT NULL,
    Phone           VARCHAR(15)     NOT NULL,
    Worker_Role     VARCHAR(50)     NOT NULL,
    isActive        BOOLEAN         NOT NULL DEFAULT TRUE,
    Emp_ID          VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID)
);

CREATE TABLE PackingBatch (
    Packing_ID          VARCHAR(20)     PRIMARY KEY,
    Packing_TS          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Qty_Packed    NUMERIC(10,2)   NOT NULL,
    Status              VARCHAR(30)     NOT NULL,
    Dept_ID             VARCHAR(20)     NOT NULL,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE FabricRoll (
    Roll_ID         VARCHAR(20)     PRIMARY KEY,
    Length          NUMERIC(10,2)   NOT NULL,
    Weight          NUMERIC(10,2)   NOT NULL,
    Status          VARCHAR(30)     NOT NULL,
    Packing_ID      VARCHAR(20)     NOT NULL,
    Warehouse_ID    VARCHAR(20)     NOT NULL,
    Storage_Rack    VARCHAR(30),
    Product_ID      VARCHAR(20)     NOT NULL,
    Qty_Stored      NUMERIC(10,2)   NOT NULL,
    FOREIGN KEY (Packing_ID)    REFERENCES PackingBatch(Packing_ID),
    FOREIGN KEY (Warehouse_ID)  REFERENCES Warehouse(Warehouse_ID),
    FOREIGN KEY (Product_ID)    REFERENCES FinalMaterial(Product_ID)
);

CREATE TABLE Company_RawMaterial (
    Company_ID      VARCHAR(20)     NOT NULL,
    Material_ID     VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Company_ID, Material_ID),
    FOREIGN KEY (Company_ID)    REFERENCES Company(Company_ID)      ON DELETE CASCADE,
    FOREIGN KEY (Material_ID)   REFERENCES RawMaterial(Material_ID) ON DELETE CASCADE
);

CREATE TABLE RawMaterial_Warehouse (
    Material_ID     VARCHAR(20)     NOT NULL,
    Warehouse_ID    VARCHAR(20)     NOT NULL,
    Qty_Stock       NUMERIC(10,2)   NOT NULL DEFAULT 0,
    PRIMARY KEY (Material_ID, Warehouse_ID),
    FOREIGN KEY (Material_ID)   REFERENCES RawMaterial(Material_ID) ON DELETE CASCADE,
    FOREIGN KEY (Warehouse_ID)  REFERENCES Warehouse(Warehouse_ID)  ON DELETE CASCADE
);

CREATE TABLE RawMaterial_Department (
    Material_ID     VARCHAR(20)     NOT NULL,
    Dept_ID         VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Material_ID, Dept_ID),
    FOREIGN KEY (Material_ID)   REFERENCES RawMaterial(Material_ID) ON DELETE CASCADE,
    FOREIGN KEY (Dept_ID)       REFERENCES Department(Dept_ID)       ON DELETE CASCADE
);

CREATE TABLE Consignment_RawMaterial (
    Consignment_ID  VARCHAR(20)     NOT NULL,
    Material_ID     VARCHAR(20)     NOT NULL,
    Qty_Delivered   NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Consignment_ID, Material_ID),
    FOREIGN KEY (Consignment_ID)    REFERENCES Consignment(Consignment_ID)  ON DELETE CASCADE,
    FOREIGN KEY (Material_ID)       REFERENCES RawMaterial(Material_ID)      ON DELETE CASCADE
);

CREATE TABLE PurchaseOrder_RawMaterial (
    Order_ID        VARCHAR(20)     NOT NULL,
    Material_ID     VARCHAR(20)     NOT NULL,
    Unit_Price      NUMERIC(12,2)   NOT NULL,
    PRIMARY KEY (Order_ID, Material_ID),
    FOREIGN KEY (Order_ID)      REFERENCES PurchaseOrder(Order_ID)   ON DELETE CASCADE,
    FOREIGN KEY (Material_ID)   REFERENCES RawMaterial(Material_ID)  ON DELETE CASCADE
);

CREATE TABLE PO_Company (
    Order_ID                    VARCHAR(20)     NOT NULL,
    Company_ID                  VARCHAR(20)     NOT NULL,
    Expected_Order_Completion   DATE            NOT NULL,
    Invoice_ID                  VARCHAR(20)     NOT NULL UNIQUE,
    PRIMARY KEY (Order_ID, Company_ID),
    FOREIGN KEY (Order_ID)      REFERENCES PurchaseOrder(Order_ID)  ON DELETE CASCADE,
    FOREIGN KEY (Company_ID)    REFERENCES Company(Company_ID)       ON DELETE CASCADE,
    FOREIGN KEY (Invoice_ID)    REFERENCES OrderInvoice(Invoice_ID)
);

CREATE TABLE ProductionOrder_RawMaterial_Warehouse (
    Order_ID        VARCHAR(20)     NOT NULL,
    Material_ID     VARCHAR(20)     NOT NULL,
    Warehouse_ID    VARCHAR(20)     NOT NULL,
    Qty_Required    NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Order_ID, Material_ID, Warehouse_ID),
    FOREIGN KEY (Order_ID)                  REFERENCES ProductionOrder(Order_ID)                             ON DELETE CASCADE,
    FOREIGN KEY (Material_ID, Warehouse_ID) REFERENCES RawMaterial_Warehouse(Material_ID, Warehouse_ID)
);

ALTER TABLE PackingBatch
    ADD COLUMN Prod_Order_ID    VARCHAR(20),
    ADD COLUMN Phase_Seq_No     INT,
    ADD COLUMN Phase_Status     VARCHAR(30),
    ADD CONSTRAINT fk_packingbatch_phase
        FOREIGN KEY (Prod_Order_ID, Phase_Seq_No)
            REFERENCES PhaseExecution(Order_ID, Seq_No);

CREATE TABLE Worker_Department (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Dept_ID         VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Worker_ID, Dept_ID),
    FOREIGN KEY (Worker_ID) REFERENCES Worker(Worker_ID)    ON DELETE CASCADE,
    FOREIGN KEY (Dept_ID)   REFERENCES Department(Dept_ID)  ON DELETE CASCADE
);

CREATE TABLE WorkerDept_Shift (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Dept_ID         VARCHAR(20)     NOT NULL,
    Shift_ID        VARCHAR(20)     NOT NULL,
    Wages           NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Worker_ID, Dept_ID, Shift_ID),
    FOREIGN KEY (Worker_ID, Dept_ID)    REFERENCES Worker_Department(Worker_ID, Dept_ID) ON DELETE CASCADE,
    FOREIGN KEY (Shift_ID)              REFERENCES Shift(Shift_ID)
);

CREATE TABLE Worker_PackingBatch (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Packing_ID      VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Worker_ID, Packing_ID),
    FOREIGN KEY (Worker_ID)     REFERENCES Worker(Worker_ID)         ON DELETE CASCADE,
    FOREIGN KEY (Packing_ID)    REFERENCES PackingBatch(Packing_ID)  ON DELETE CASCADE
);

CREATE TABLE WorkerPacking_Shift (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Packing_ID      VARCHAR(20)     NOT NULL,
    Shift_ID        VARCHAR(20)     NOT NULL,
    Wages           NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Worker_ID, Packing_ID, Shift_ID),
    FOREIGN KEY (Worker_ID, Packing_ID)     REFERENCES Worker_PackingBatch(Worker_ID, Packing_ID) ON DELETE CASCADE,
    FOREIGN KEY (Shift_ID)                  REFERENCES Shift(Shift_ID)
);

CREATE TABLE Worker_Warehouse (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Warehouse_ID    VARCHAR(20)     NOT NULL,
    PRIMARY KEY (Worker_ID, Warehouse_ID),
    FOREIGN KEY (Worker_ID)     REFERENCES Worker(Worker_ID)         ON DELETE CASCADE,
    FOREIGN KEY (Warehouse_ID)  REFERENCES Warehouse(Warehouse_ID)   ON DELETE CASCADE
);

CREATE TABLE WorkerWarehouse_Shift (
    Worker_ID       VARCHAR(20)     NOT NULL,
    Warehouse_ID    VARCHAR(20)     NOT NULL,
    Shift_ID        VARCHAR(20)     NOT NULL,
    Wages           NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (Worker_ID, Warehouse_ID, Shift_ID),
    FOREIGN KEY (Worker_ID, Warehouse_ID)   REFERENCES Worker_Warehouse(Worker_ID, Warehouse_ID) ON DELETE CASCADE,
    FOREIGN KEY (Shift_ID)                  REFERENCES Shift(Shift_ID)
);