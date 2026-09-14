SET SEARCH_PATH TO Textile_Industry;

-- PurchaseOrder.Status — observed: Pending, In Transit, Delivered
ALTER TABLE PurchaseOrder
    ADD CONSTRAINT chk_purchaseorder_status
    CHECK (Status IN ('Pending', 'In Transit', 'Delivered'));

-- Consignment.Status — observed: Pending, In Transit, Delivered
ALTER TABLE Consignment
    ADD CONSTRAINT chk_consignment_status
    CHECK (Status IN ('Pending', 'In Transit', 'Delivered'));

-- ProductionOrder.Status — observed: Planned, In Progress, Completed
ALTER TABLE ProductionOrder
    ADD CONSTRAINT chk_productionorder_status
    CHECK (Status IN ('Planned', 'In Progress', 'Completed'));

-- PhaseExecution.Status — observed: In Progress, Completed, Not Started.
ALTER TABLE PhaseExecution
    ADD CONSTRAINT chk_phaseexecution_status
    CHECK (Status IN ('Not Started', 'In Progress', 'Completed'));

-- PackingBatch.Status — observed: Planned, In Progress, Completed
ALTER TABLE PackingBatch
    ADD CONSTRAINT chk_packingbatch_status
    CHECK (Status IN ('Pending', 'In Progress', 'Completed'));

-- PackingBatch.Phase_Status - observed: In Progress, Completed, Not Started.
ALTER TABLE PackingBatch
    ADD CONSTRAINT chk_packingbatch_phasestatus
    CHECK (Phase_Status IS NULL
           OR Phase_Status IN ('Not Started', 'In Progress', 'Completed'));

-- FabricRoll.Status — observed: In Stock, Dispatched
ALTER TABLE FabricRoll
    ADD CONSTRAINT chk_fabricroll_status
    CHECK (Status IN ('In Stock', 'Dispatched'));
