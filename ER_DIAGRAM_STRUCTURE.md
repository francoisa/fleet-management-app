# Fleet Management App - ER Diagram Data Structure

## 🔗 Association Matrix (for ER Diagram Generation)

### Format: SOURCE_MODEL → TARGET_MODEL [RELATIONSHIP_TYPE] {FOREIGN_KEY_INFO}

---

## CORE RELATIONSHIPS BY DOMAIN

### 🏢 Organization Domain
```
Account → Agency (belongs_to, optional)
Account → AccountTransaction (has_many, debit_account_id)
Account → AccountTransaction (has_many, credit_account_id)
Account → Payable (has_many)

Agency → User (has_many)
Agency → Vehicle (has_many)
Agency → Driver (has_many)
Agency → Alert (has_many)
Agency → Route (has_many)
Agency → CashierSession (has_many)
Agency → Account (has_many)
Agency → AgencySetting (has_many)
Agency → MaintenanceRequest (has_many, requesting_agency_id)
Agency → MaintenanceRequest (has_many, processing_agency_id)
Agency → Rfq (has_many, requesting_agency_id)
Agency → Rfq (has_many, processing_agency_id)
Agency → Quotation (has_many)
Agency → JobTemplate (has_many)
Agency → FareRule (has_many)
Agency → AccountTransaction (has_many)
Agency → LedgerEntry (has_many)

User → Agency (belongs_to, required)
User → CashierSession (has_many)
User → Quotation (has_many, created_by_id)
User → PurchaseOrder (has_many, created_by_id)
User → PurchaseOrder (has_many, approved_by_id)
User → AuditLog (has_many)

Role → UserRole (has_many)
UserRole → Role (belongs_to)
UserRole → User (belongs_to)
UserRole → Agency (belongs_to, optional)

AgencySetting → Agency (belongs_to)
```

### 🚗 Fleet Management Domain
```
Vehicle → Owner [Polymorphic: Agency/Client] (belongs_to)
Vehicle → Agency (belongs_to, optional - backward compat)
Vehicle → Driver (belongs_to, optional)
Vehicle → Alert (has_many)
Vehicle → Inspection (has_many)
Vehicle → Maintenance (has_many)
Vehicle → Trip (has_many)
Vehicle → VehicleDocument (has_many)
Vehicle → VehicleStatus (has_many)
Vehicle → VehicleConditionReport (has_many)
Vehicle → ReceptionLog (has_many)
Vehicle → Invoice (has_many)
Vehicle → LedgerEntry (has_many)
Vehicle → PurchaseOrder (has_many)
Vehicle → PosTransaction (has_many)

Driver → Agency (belongs_to, optional)
Driver → Vehicle (has_many)
Driver → Trip (has_many)
Driver → DamageReport (has_many)
Driver → Alert (has_many)

VehicleStatus → Vehicle (belongs_to)
VehicleStatus → User (belongs_to, created_by, optional)

VehicleDocument → Vehicle (belongs_to)

VehicleConditionReport → Vehicle (belongs_to)
VehicleConditionReport → ReceptionLog (belongs_to, optional)
VehicleConditionReport → User (belongs_to, security_gate_officer)
VehicleConditionReport → Client [Polymorphic] (belongs_to, optional)

Trip → Vehicle (belongs_to)
Trip → User (belongs_to, driver, optional)

Alert → Vehicle (belongs_to, optional)
Alert → Driver (belongs_to, optional)
Alert → Agency (belongs_to, optional)

DamageReport → Vehicle (belongs_to)
DamageReport → Driver (belongs_to, optional)

Route → Agency (belongs_to)
Route → FareRule (has_many)

FareRule → Agency (belongs_to)
FareRule → Route (belongs_to, optional)
```

### 🔧 Maintenance Domain
```
Maintenance → Vehicle (belongs_to)
Maintenance → User (belongs_to, assigned_to, optional)
Maintenance → ServiceProvider (belongs_to, optional)
Maintenance → Maintenance (belongs_to, parent_maintenance, optional)
Maintenance → Quotation (belongs_to, optional)
Maintenance → MaintenanceTask (has_many)
Maintenance → Maintenance (has_many, child_maintenances)

MaintenanceTask → Maintenance (belongs_to)
MaintenanceTask → User (belongs_to, assigned_to, optional)

MaintenancePart → Maintenance (belongs_to)
MaintenancePart → Part (belongs_to)

MaintenanceRequest → Vehicle (belongs_to)
MaintenanceRequest → Agency (belongs_to, requesting_agency)
MaintenanceRequest → Agency (belongs_to, processing_agency, optional)

ServiceProvider → N/A (Standalone)
```

### 📋 Inspection & Diagnostics Domain
```
Inspection → Vehicle (belongs_to)
Inspection → User (belongs_to, inspector, optional)
Inspection → User (belongs_to, supervisor, optional)
Inspection → User (belongs_to, assigned_mechanic, optional)
Inspection → WorkOrder (belongs_to, optional)
Inspection → PurchaseOrder (belongs_to, optional)
Inspection → User (belongs_to, final_inspector, optional)
Inspection → User (belongs_to, workflow_selected_by, optional)
Inspection → ReceptionLog (belongs_to, optional)
Inspection → InspectionJob (has_many)
Inspection → PartsRequest (has_many)
Inspection → Quotation (has_many)
Inspection → Finding (has_many)
Inspection → InspectionRecommendation (has_many)

InspectionJob → Inspection (belongs_to)
InspectionJob → JobTemplate (belongs_to, optional)
InspectionJob → User (belongs_to, assigned_mechanic, optional)
InspectionJob → WorkOrder (belongs_to, optional)
InspectionJob → User (belongs_to, pre_check_by, optional)
InspectionJob → InspectionJobPart (has_many)
InspectionJob → Part (has_many, through: inspection_job_parts)
InspectionJob → MechanicAssignment (has_many)
InspectionJob → PartsRequest (has_many)
InspectionJob → Finding (has_many)
InspectionJob → JobTask (has_many)
InspectionJob → JobDependency (has_many, as dependency)
InspectionJob → InspectionJob (has_many, dependent_jobs)

InspectionJobPart → InspectionJob (belongs_to)
InspectionJobPart → Part (belongs_to, optional)
InspectionJobPart → InspectionJob (belongs_to, dependency_job, optional)

Finding → Inspection (belongs_to)
Finding → InspectionJob (belongs_to, optional)
Finding → User (belongs_to, created_by, optional)
Finding → InspectionJob (belongs_to, job, optional)
Finding → WorkOrder (belongs_to, optional)
Finding → User (belongs_to, approved_by, optional)

InspectionRecommendation → Inspection (belongs_to)
InspectionRecommendation → User (belongs_to, suggested_by, optional)
InspectionRecommendation → InspectionJob (belongs_to, converted_to_job, optional)
InspectionRecommendation → User (belongs_to, approved_by, optional)

ReceptionLog → Vehicle (belongs_to)
ReceptionLog → Inspection (belongs_to, optional)
ReceptionLog → User (belongs_to, security_gate_officer)
ReceptionLog → User (belongs_to, inspector, optional)
ReceptionLog → PurchaseOrder (belongs_to, optional)
ReceptionLog → VehicleConditionReport (belongs_to, optional)
```

### 💰 Financial & Accounting Domain
```
Invoice → Vehicle (belongs_to)
Invoice → Maintenance (belongs_to, optional)
Invoice → PurchaseOrder (belongs_to, optional)
Invoice → PosTransaction (belongs_to, optional)
Invoice → Supplier (belongs_to, optional)
Invoice → Account (belongs_to, optional)
Invoice → User (belongs_to, created_by, optional)
Invoice → User (belongs_to, received_by, optional)
Invoice → User (belongs_to, reviewed_by, optional)
Invoice → User (belongs_to, paid_by, optional)
Invoice → User (belongs_to, disputed_by, optional)
Invoice → WorkOrder (belongs_to, optional)
Invoice → Payable (has_one)
Invoice → LedgerEntry (has_many)
Invoice → Transaction (has_many)
Invoice → PaymentHistory (has_many)

Payable → Supplier (belongs_to, vendor, optional)
Payable → PurchaseOrder (belongs_to, optional)
Payable → Invoice (belongs_to, optional)
Payable → Agency (belongs_to, optional)
Payable → Account (belongs_to)
Payable → AccountTransaction (has_many)
Payable → PaymentHistory (has_many)

AccountTransaction → Account (belongs_to, debit_account)
AccountTransaction → Account (belongs_to, credit_account)
AccountTransaction → Payable (belongs_to, optional)
AccountTransaction → Agency (belongs_to, optional)
AccountTransaction → N/A [Polymorphic] (belongs_to, reference, optional)

LedgerEntry → Agency (belongs_to)
LedgerEntry → Vehicle (belongs_to)
LedgerEntry → Invoice (belongs_to)
LedgerEntry → User (belongs_to, posted_by, optional)

PaymentHistory → Invoice (belongs_to)
PaymentHistory → User (belongs_to, optional)
PaymentHistory → N/A [Polymorphic] (belongs_to, payment_transaction, optional)

Payment → Inspection (belongs_to)
Payment → WorkOrder (belongs_to, optional)

PosTransaction → Agency (belongs_to)
PosTransaction → Invoice (belongs_to, optional)
PosTransaction → Vehicle (belongs_to, optional)
PosTransaction → User (belongs_to, optional)
PosTransaction → CashierSession (belongs_to, optional)

CashierSession → User (belongs_to)
CashierSession → Agency (belongs_to)
CashierSession → User (belongs_to, closed_by, optional)
CashierSession → PosTransaction (has_many)
```

### 📦 Procurement & Inventory Domain
```
Part → Supplier (belongs_to, optional)
Part → Purchase (has_many)
Part → MaintenancePart (has_many)
Part → Maintenance (has_many, through: maintenance_parts)
Part → PurchaseOrderItem (has_many)
Part → JobTemplatePart (has_many)
Part → JobTemplate (has_many, through: job_template_parts)
Part → QuotationJobPart (has_many)
Part → InventoryTransaction (has_many, as: inventory_item)
Part → PurchaseRequest (has_many)
Part → VendorPart (has_many)
Part → Supplier (has_many, through: vendor_parts)
Part → VendorInvoiceItem (has_many)

Supplier → Part (has_many)
Supplier → PurchaseRequest (has_many)
Supplier → VendorInvoice (has_many)
Supplier → PurchaseOrder (has_many)
Supplier → Invoice (has_many)
Supplier → VendorPart (has_many)
Supplier → Part (has_many, through: vendor_parts)

VendorPart → Supplier (belongs_to)
VendorPart → Part (belongs_to)

PurchaseOrder → Vehicle (belongs_to, optional)
PurchaseOrder → User (belongs_to, created_by)
PurchaseOrder → User (belongs_to, approved_by, optional)
PurchaseOrder → User (belongs_to, rejected_by, optional)
PurchaseOrder → User (belongs_to, payment_authorized_by, optional)
PurchaseOrder → User (belongs_to, payment_processed_by, optional)
PurchaseOrder → VendorRfq (belongs_to, optional)
PurchaseOrder → Quotation (belongs_to, optional)
PurchaseOrder → Supplier (belongs_to, optional)
PurchaseOrder → VendorQuotation (has_one)
PurchaseOrder → Payable (has_one)
PurchaseOrder → PurchaseOrderItem (has_many)
PurchaseOrder → Invoice (has_many)
PurchaseOrder → PaymentHistory (has_many)
PurchaseOrder → PaymentAudit (has_many)
PurchaseOrder → VendorInvoice (has_many)
PurchaseOrder → InternalPos (has_many)

PurchaseOrderItem → PurchaseOrder (belongs_to)
PurchaseOrderItem → Part (belongs_to, optional)
PurchaseOrderItem → VendorInvoiceItem (has_many)

VendorInvoice → Supplier (belongs_to)
VendorInvoice → User (belongs_to, optional)
VendorInvoice → InventoryTransaction (has_many)
VendorInvoice → PurchaseRequest (has_many)
VendorInvoice → VendorInvoiceItem (has_many)

VendorInvoiceItem → VendorInvoice (belongs_to)
VendorInvoiceItem → Part (belongs_to, optional)
VendorInvoiceItem → PurchaseOrderItem (belongs_to, optional)

InventoryTransaction → N/A [Polymorphic] (belongs_to, inventory_item)
InventoryTransaction → N/A [Polymorphic] (belongs_to, reference, optional)
InventoryTransaction → User (belongs_to)
InventoryTransaction → Agency (belongs_to, optional)

PurchaseRequest → User (belongs_to, requested_by, optional)
PurchaseRequest → User (belongs_to, approved_by, optional)
PurchaseRequest → User (belongs_to, rejected_by, optional)
PurchaseRequest → Part (belongs_to, optional)
PurchaseRequest → Quotation (belongs_to, optional)
PurchaseRequest → PurchaseRequestItem (has_many)

PurchaseRequestItem → PurchaseRequest (belongs_to)
PurchaseRequestItem → Part (belongs_to)

PartsRequest → Inspection (belongs_to)
PartsRequest → InspectionJob (belongs_to, optional)
PartsRequest → Part (belongs_to, optional)
PartsRequest → User (belongs_to, requested_by, optional)
PartsRequest → User (belongs_to, approved_by, optional)
PartsRequest → User (belongs_to, rejected_by, optional)
PartsRequest → User (belongs_to, issued_by, optional)
PartsRequest → PurchaseOrder (belongs_to, optional)
PartsRequest → VendorInvoice (belongs_to, optional)

Purchase → Part (belongs_to)
```

### 🏷️ Quotations & RFQs Domain
```
Quotation → Vehicle (belongs_to, optional)
Quotation → Rfq (belongs_to, optional)
Quotation → WorkOrder (belongs_to, optional)
Quotation → Agency (belongs_to, optional)
Quotation → N/A [Polymorphic] (belongs_to, client, optional)
Quotation → User (belongs_to, created_by, optional)
Quotation → User (belongs_to, submitted_by, optional)
Quotation → Inspection (belongs_to, optional)
Quotation → PurchaseOrder (has_one)
Quotation → QuotationLineItem (has_many)
Quotation → QuotationJob (has_many)

QuotationLineItem → Quotation (belongs_to)

QuotationJob → Quotation (belongs_to)
QuotationJob → InspectionJob (belongs_to, optional)
QuotationJob → JobTemplate (belongs_to, optional)
QuotationJob → QuotationJobPart (has_many)
QuotationJob → Part (has_many, through: quotation_job_parts)

QuotationJobPart → Part (referenced implicitly)

Rfq → Agency (belongs_to, requesting_agency)
Rfq → Agency (belongs_to, processing_agency, optional)
Rfq → Vehicle (belongs_to, optional)
Rfq → MaintenanceRequest (belongs_to, optional)
Rfq → Quotation (belongs_to, converted_to_quotation, optional)
Rfq → RfqLineItem (has_many)

RfqLineItem → Rfq (belongs_to)

VendorRfq → User (belongs_to, created_by, optional)
VendorRfq → Agency (belongs_to, processing_agency, optional)
VendorRfq → Vehicle (belongs_to, optional)
VendorRfq → VendorRfqItem (has_many)
VendorRfq → VendorQuotation (has_many)
VendorRfq → VendorQuotation (belongs_to, awarded_vendor_quotation, optional)

VendorRfqItem → N/A (Standalone)

VendorQuotation → VendorRfq (belongs_to)
VendorQuotation → Supplier (belongs_to)
VendorQuotation → PurchaseOrder (belongs_to, optional)
VendorQuotation → VendorQuotationLine (has_many)

VendorQuotationLine → VendorQuotation (belongs_to)
```

### 🛠️ Work Orders & Jobs Domain
```
WorkOrder → Vehicle (belongs_to)
WorkOrder → N/A [Polymorphic] (belongs_to, customer, optional)
WorkOrder → User (belongs_to, created_by, optional)
WorkOrder → User (belongs_to, updated_by, optional)
WorkOrder → Inspection (has_many)
WorkOrder → InspectionJob (has_many, through: inspections)
WorkOrder → JobTask (has_many, through: inspection_jobs)
WorkOrder → WorkSession (has_many, through: job_tasks)
WorkOrder → Quotation (has_many)
WorkOrder → Payment (has_many)
WorkOrder → Invoice (has_many)
WorkOrder → Finding (has_many)
WorkOrder → AuditLog (has_many, as: auditable)

JobTemplate → Agency (belongs_to)
JobTemplate → JobTemplatePart (has_many)
JobTemplate → Part (has_many, through: job_template_parts)
JobTemplate → QuotationJob (has_many)
JobTemplate → JobTemplateVehicleApplication (has_many)

JobTemplatePart → JobTemplate (belongs_to)
JobTemplatePart → Part (belongs_to)

JobTemplateVehicleApplication → N/A (Join table)

JobTask → InspectionJob (belongs_to)
JobTask → User (belongs_to, assigned_mechanic, optional)
JobTask → Finding (belongs_to, optional)
JobTask → WorkSession (has_many)
JobTask → JobTaskDependency (has_many)
JobTask → JobTask (has_many, depends_on)

JobTaskDependency → JobTask (referenced implicitly)

JobDependency → InspectionJob (referenced implicitly)

WorkSession → JobTask (belongs_to)
WorkSession → User (belongs_to, mechanic)
WorkSession → User (belongs_to, updated_by, optional)

MechanicAssignment → N/A (Standalone)
```

### 🎫 Auditing & Logging Domain
```
AuditLog → User (belongs_to, optional)
AuditLog → N/A [Polymorphic] (belongs_to, record)

Notification → User (belongs_to)
Notification → N/A [Polymorphic] (belongs_to, notifiable, optional)
```

### 🗂️ Special/Utility Models Domain
```
Client → Agency (belongs_to, optional)
Client → Vehicle (has_many, as: owner)
Client → Invoice (has_many, as: client)
Client → Quotation (has_many, as: client)
Client → VehicleConditionReport (has_many, as: client)

Current → N/A (Singleton context)
```

---

## 📊 Cardinality Summary

### One-to-Many Relationships
- Account ↔ AccountTransaction (1:N both debit & credit)
- Agency ↔ User, Vehicle, Driver, Alert, Route, etc. (1:N)
- Vehicle ↔ Trip, Alert, VehicleDocument, etc. (1:N)
- Part ↔ Maintenance, PurchaseOrderItem, etc. (1:N)
- User ↔ Quotation (as created_by) (1:N)
- And many more...

### Many-to-Many Relationships (via Junction Tables)
- Part ↔ JobTemplate (through JobTemplatePart)
- Part ↔ Maintenance (through MaintenancePart)
- Part ↔ QuotationJob (through QuotationJobPart)
- QuotationJob ↔ Part (through QuotationJobPart)
- And more...

### Polymorphic Relationships
- Vehicle.owner → Agency OR Client
- VehicleConditionReport.client → Agency OR Client
- InventoryTransaction.inventory_item → Any model
- InventoryTransaction.reference → Any model
- AuditLog.record → Any model
- Notification.notifiable → Any model
- WorkOrder.customer → Any customer type
- AccountTransaction.reference → Any reference model

### One-to-One Relationships
- Quotation ↔ PurchaseOrder (has_one)
- PurchaseOrder ↔ VendorQuotation (has_one)
- PurchaseOrder ↔ Payable (has_one)
- Invoice ↔ Payable (has_one)
- And several others...

---

## 🎯 Key Entity Clustering for ER Diagram

### Cluster 1: Fleet & Assets
- Vehicle, Driver, Trip, Alert, DamageReport, VehicleStatus, VehicleDocument, VehicleConditionReport, Route, FareRule

### Cluster 2: Inspection & Diagnostics
- Inspection, InspectionJob, InspectionJobPart, Finding, InspectionRecommendation, ReceptionLog

### Cluster 3: Maintenance
- Maintenance, MaintenanceTask, MaintenancePart, MaintenanceRequest, ServiceProvider

### Cluster 4: Work Management
- WorkOrder, JobTemplate, JobTemplatePart, JobTask, WorkSession, MechanicAssignment

### Cluster 5: Quotations
- Quotation, QuotationLineItem, QuotationJob, QuotationJobPart, Rfq, RfqLineItem

### Cluster 6: Procurement
- PurchaseOrder, PurchaseOrderItem, Part, Supplier, VendorPart, InventoryTransaction, PartsRequest, PurchaseRequest

### Cluster 7: Vendor & Quotations (External)
- VendorRfq, VendorRfqItem, VendorQuotation, VendorQuotationLine, VendorInvoice, VendorInvoiceItem

### Cluster 8: Financial
- Account, AccountTransaction, Invoice, Payable, LedgerEntry, PaymentHistory, PosTransaction, CashierSession

### Cluster 9: Organization
- Agency, User, Role, UserRole, AgencySetting, Client

### Cluster 10: Cross-cutting
- AuditLog, Notification, Current

---

## 📐 Foreign Key Summary

### Self-Referencing Foreign Keys
- Maintenance.parent_maintenance_id → Maintenance.id
- InspectionJob.dependency relationships (via JobDependency)
- JobTask.dependencies (via JobTaskDependency)

### Polymorphic Foreign Keys
- vehicle_condition_reports: client_id + client_type (Agency OR Client)
- invoices: (created_by_id, class User), (received_by_id, class User), etc.
- Multiple date-based user references (created_by, approved_by, assigned_to, etc.)

### Agency-Based Multi-Tenancy
- Most models include agency_id or belong_to agency for isolation

---

*End of ER Diagram Data Structure*
