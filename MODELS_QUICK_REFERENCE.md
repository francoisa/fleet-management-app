# Fleet Management App - Models Quick Reference

## 📋 All Models Checklist (80 Models)

### Organization & Access Control (6 models)
- [x] Account
- [x] Agency
- [x] User
- [x] Role
- [x] UserRole
- [x] AgencySetting

### Fleet Management (10 models)
- [x] Vehicle
- [x] Driver
- [x] Trip
- [x] Alert
- [x] DamageReport
- [x] VehicleStatus
- [x] VehicleDocument
- [x] VehicleConditionReport
- [x] Route
- [x] FareRule

### Maintenance & Service (5 models)
- [x] Maintenance
- [x] MaintenanceTask
- [x] MaintenancePart
- [x] MaintenanceRequest
- [x] ServiceProvider

### Inspection & Diagnostics (7 models)
- [x] Inspection
- [x] InspectionJob
- [x] InspectionJobPart
- [x] Finding
- [x] InspectionRecommendation
- [x] ReceptionLog

### Financial & Accounting (9 models)
- [x] Invoice
- [x] Payable
- [x] AccountTransaction
- [x] LedgerEntry
- [x] PaymentHistory
- [x] Payment
- [x] PosTransaction
- [x] CashierSession

### Procurement & Inventory (15 models)
- [x] Part
- [x] Supplier
- [x] VendorPart
- [x] PurchaseOrder
- [x] PurchaseOrderItem
- [x] VendorInvoice
- [x] VendorInvoiceItem
- [x] InventoryTransaction
- [x] PurchaseRequest
- [x] PurchaseRequestItem
- [x] PartsRequest
- [x] Purchase

### Quotations & RFQs (10 models)
- [x] Quotation
- [x] QuotationLineItem
- [x] QuotationJob
- [x] QuotationJobPart
- [x] Rfq
- [x] RfqLineItem
- [x] VendorRfq
- [x] VendorRfqItem
- [x] VendorQuotation
- [x] VendorQuotationLine

### Work Orders & Jobs (10 models)
- [x] WorkOrder
- [x] JobTemplate
- [x] JobTemplatePart
- [x] JobTemplateVehicleApplication
- [x] JobTask
- [x] JobTaskDependency
- [x] JobDependency
- [x] WorkSession
- [x] MechanicAssignment

### Auditing & Logging (2 models)
- [x] AuditLog
- [x] Notification

### Special/Utility (2 models)
- [x] Client
- [x] Current

---

## 🔗 Core Relationships Summary

### Hub Models (Central to ER Diagram)
1. **Vehicle** - Central to fleet operations, has 15+ associations
2. **Inspection** - Central to service workflow
3. **PurchaseOrder** - Central to procurement workflow
4. **Quotation** - Central to estimation workflow
5. **WorkOrder** - Central to service execution
6. **Part** - Central to inventory system

### Key Foreign Key Patterns

#### User Role References (Multiple)
```
assigned_to → User
created_by → User
approved_by → User
reviewer → User
inspector → User
mechanic → User
security_gate_officer → User
supervisor → User
```

#### Agency Scoping
```
belongs_to :agency (Most models)
requesting_agency → Agency
processing_agency → Agency
owned_by_agency → Agency
```

#### Polymorphic Associations
```
Vehicle.owner: Agency OR Client
VehicleConditionReport.client: Agency OR Client
Notification.notifiable: Any model
AuditLog.record: Any model
InventoryTransaction.inventory_item: Part or similar
InventoryTransaction.reference: Any reference
WorkOrder.customer: Any customer type
AccountTransaction.reference: Any reference model
PaymentHistory.payment_transaction: Payable OR similar
```

---

## 📊 Association Counts by Model

| Model | Has Many | Belongs To | Has One | Polymorphic |
|-------|----------|-----------|---------|------------|
| Vehicle | 10+ | 2 | 0 | 1 (owner) |
| Inspection | 6 | 8 | 0 | 0 |
| InspectionJob | 10 | 5 | 0 | 0 |
| PurchaseOrder | 9 | 7 | 2 | 0 |
| Quotation | 3 | 6 | 1 | 1 (client) |
| WorkOrder | 8 | 3 | 0 | 1 (customer) |
| User | 4 | 1 | 0 | 0 |
| Agency | 15+ | 0 | 0 | 0 |
| Part | 9 | 1 | 0 | 0 |
| Account | 3 | 1 | 0 | 0 |

---

## 🎯 Critical Relationships for ER Diagram

### Tier 1: Highest Priority (Always Include)
- Vehicle → Inspection → InspectionJob → JobTask → WorkSession
- Vehicle → Maintenance
- Vehicle → Trip
- PurchaseOrder → PurchaseOrderItem → Part → Supplier
- Quotation → QuotationJob → QuotationJobPart → Part
- Inspection → Finding
- Inspection → PartsRequest → Part

### Tier 2: Important Secondary
- WorkOrder → Quotation → PurchaseOrder
- VendorRfq → VendorQuotation → Supplier
- Rfq → RfqLineItem
- JobTemplate → JobTemplatePart → Part
- MaintenanceRequest → Rfq
- ReceptionLog → Vehicle → VehicleConditionReport

### Tier 3: Supporting
- Agency → User, Driver, Route, FareRule
- Account → AccountTransaction → Payable
- PaymentHistory, AuditLog, Notification (audit trails)
- WorkSession → JobTask (time tracking)
- JobDependency (task dependencies)

---

## 📐 ER Diagram Recommendation

### Suggested 3-View Approach

**View 1: Service Request & Inspection Workflow**
- Vehicle, Inspection, InspectionJob, Finding, PartsRequest, ReceptionLog

**View 2: Procurement & Quotation Workflow**
- PurchaseOrder, Quotation, Part, Supplier, VendorRfq, VendorQuotation, RFQ

**View 3: Financial & Accounting**
- Account, Invoice, Payable, AccountTransaction, LedgerEntry, Payment

**View 4: Work Execution & Fleet**
- WorkOrder, JobTask, WorkSession, Maintenance, Trip, Alert, Vehicle

**View 5: Organization & Access**
- Agency, User, Role, UserRole, AgencySetting

---

## 🔑 Key Unique Features

### Polymorphic Ownership
- Vehicle can be owned by Agency OR Client
- Enables external client vehicle servicing

### Self-Referencing Jobs
- Maintenance can have parent_maintenance (nested maintenance)
- InspectionJob can depend on other InspectionJobs
- JobTask can depend on other JobTasks

### Multi-Agency Support
- Most models include agency_id for tenant isolation
- Many models support requesting_agency and processing_agency

### Comprehensive Audit Trail
- AuditLog for all changes
- Multiple timestamp fields (created_at, updated_at, _at fields)
- User tracking (created_by, updated_by, approved_by, etc.)

### Complex User Roles
- 15+ different user roles (clerk, admin, driver, mechanic, inspector, etc.)
- Users referenced in many contexts (assigned_to, created_by, approved_by, etc.)

### Dual Quotation Systems
- Internal: Quotation (to customer) + QuotationJob (job-level)
- External: VendorRfq (to vendors) + VendorQuotation (vendor responses)

---

## 📝 Model Naming Conventions

### Naming Patterns Observed
```
Model Name                Type              Foreign Key Pattern
==========================================
assigned_to               User reference    assigned_to_id → User
created_by                User reference    created_by_id → User
approved_by               User reference    approved_by_id → User
processed_by              User reference    processed_by_id → User
reviewed_by               User reference    reviewed_by_id → User
rejected_by               User reference    rejected_by_id → User
dismissed_by              User reference    dismissed_by_id → User
owner                     Polymorphic       owner_id + owner_type
requesting_agency         Agency reference  requesting_agency_id → Agency
processing_agency         Agency reference  processing_agency_id → Agency
parent_maintenance        Self reference    parent_maintenance_id → Maintenance
```

---

## 🏗️ Entity Groups for Clustering

**High Cohesion Groups:**
1. Inspection Workflow: Inspection, InspectionJob, InspectionJobPart, Finding, InspectionRecommendation
2. Procurement Workflow: PurchaseOrder, PurchaseOrderItem, Supplier, Part, VendorInvoice
3. Quotation System: Quotation, QuotationJob, QuotationLineItem, RFQ, RfqLineItem
4. Financial System: Account, AccountTransaction, Invoice, Payable, LedgerEntry
5. Work Execution: WorkOrder, JobTask, WorkSession, Maintenance, MaintenanceTask
6. Fleet Management: Vehicle, Driver, Trip, Alert, DamageReport, Route

---

## ✅ Data Integrity Constraints

### Key Validations Found
- **Invoice.amount** must be > 0
- **Part.current_stock** must be >= 0
- **Trip.distance_km** must be >= 0 (or nil)
- **PurchaseOrder.amount** must be calculated from items
- **Maintenance.end_date** must be after start_date
- **User.role** must be in ROLES list
- **Vehicle.license_plate** must be unique
- **Part.part_number** must be unique

### Dependent Destroys
- Agency destroys: User, Vehicle, Driver, Alert, Route, etc.
- Vehicle destroys: Maintenance, Trip, Alert, VehicleDocument, VehicleStatus
- Inspection destroys: InspectionJob, PartsRequest, Finding
- PurchaseOrder destroys: PurchaseOrderItem

### Restrict Destroys
- Account restricts delete if has AccountTransaction
- Part restricts delete if used in templates

---

## 🎨 Suggested ER Diagram Color Coding

```
Organization Models        → Blue
Fleet Management          → Green
Maintenance/Service       → Orange
Inspection/Diagnostics    → Purple
Procurement/Inventory     → Brown
Quotations/RFQs          → Teal
Financial/Accounting     → Red
Work Orders/Jobs         → Yellow
Audit/Logging            → Gray
```

---

## 📊 Statistics

| Metric | Count |
|--------|-------|
| Total Models | 80+ |
| has_many associations | 200+ |
| belongs_to associations | 150+ |
| has_one associations | 30+ |
| Polymorphic associations | 8 |
| Through associations | 25+ |
| Self-referencing models | 3 |
| Models with agency_id | 40+ |
| Models with user references | 45+ |
| Enum-using models | 35+ |

---

*Quick Reference - Fleet Management App Models*
*Generated: 2024*
