# Fleet Management App - Rails Models & Associations

**Last Updated:** 2024-01-15  
**Total Models:** 80+  
**Database Type:** PostgreSQL  

---

## 📊 Core Models Summary

This document contains a comprehensive list of all Rails models in the fleet-management-app project with their associations, organized by functional domain.

---

## 🏢 Organization & Access Control

### Account (`Account`)
**Table:** `accounts`

**Associations:**
- `belongs_to :agency` (optional)
- `has_many :debit_transactions` (class_name: 'AccountTransaction', foreign_key: 'debit_account_id', dependent: :restrict_with_error)
- `has_many :credit_transactions` (class_name: 'AccountTransaction', foreign_key: 'credit_account_id', dependent: :restrict_with_error)
- `has_many :payables` (dependent: :restrict_with_error)

**Key Fields:** account_number, name, account_type, sub_type, balance, is_active

---

### Agency (`Agency`)
**Table:** `agencies`

**Associations:**
- `has_many :users` (dependent: :destroy)
- `has_many :vehicles` (dependent: :destroy)
- `has_many :drivers` (dependent: :destroy)
- `has_many :alerts` (dependent: :destroy)
- `has_many :routes` (dependent: :destroy)
- `has_many :fare_rules` (through: :routes)
- `has_many :cashier_sessions` (dependent: :destroy)
- `has_many :pos_transactions` (through: :cashier_sessions)
- `has_many :accounts` (dependent: :destroy)
- `has_many :agency_settings` (dependent: :destroy)
- `has_many :invoices` (through: :vehicles)
- `has_many :maintenance_requests` (foreign_key: :requesting_agency_id, dependent: :destroy)
- `has_many :processed_maintenance_requests` (class_name: 'MaintenanceRequest', foreign_key: :processing_agency_id, dependent: :destroy)
- `has_many :rfqs` (foreign_key: :requesting_agency_id, dependent: :destroy)
- `has_many :processed_rfqs` (class_name: 'Rfq', foreign_key: :processing_agency_id, dependent: :destroy)
- `has_many :quotations` (dependent: :destroy)
- `has_many :quotations_through_rfqs` (through: :rfqs, source: :quotations)
- `has_many :purchase_orders` (through: :vehicles)
- `has_many :job_templates` (dependent: :destroy)
- `has_many :parts` (through: :job_templates)
- `has_many :account_transactions` (dependent: :destroy)

**Key Fields:** code, name, is_active

---

### User (`User`)
**Table:** `users`

**Associations:**
- `belongs_to :agency` (required)
- `has_many :cashier_sessions`
- `has_many :quotations` (foreign_key: :created_by_id)
- `has_many :created_purchase_orders` (class_name: "PurchaseOrder", foreign_key: :created_by_id)
- `has_many :approved_purchase_orders` (class_name: "PurchaseOrder", foreign_key: :approved_by_id)
- `has_many :audit_logs` (foreign_key: :user_id, dependent: :nullify)

**Key Fields:** email, role, is_system_admin, first_name, last_name

**Roles:** clerk, supervisor, finance, admin, fleet_manager, maintenance_supervisor, driver, vmcott_staff, inspector, mechanic, security_gate_officer, inventory_manager, procurement

---

### Role (`Role`)
**Table:** `roles`

**Associations:**
- `has_many :user_roles`
- `has_many :users` (through: :user_roles)

**Key Fields:** name

---

### UserRole (`UserRole`)
**Table:** `user_roles`

**Associations:**
- `belongs_to :user`
- `belongs_to :role`
- `belongs_to :agency` (optional)

**Key Fields:** N/A (Junction table)

---

### AgencySetting (`AgencySetting`)
**Table:** `agency_settings`

**Associations:**
- `belongs_to :agency`

**Key Fields:** setting_key, setting_value, data_type

---

---

## 🚗 Fleet Management

### Vehicle (`Vehicle`)
**Table:** `vehicles`

**Associations:**
- `belongs_to :owner` (polymorphic: true) - Can be Agency or Client
- `belongs_to :agency` (optional - for backward compatibility)
- `belongs_to :driver` (optional)
- `has_many :alerts` (dependent: :destroy)
- `has_many :inspections` (dependent: :destroy)
- `has_many :maintenances` (dependent: :destroy)
- `has_many :trips` (dependent: :destroy)
- `has_many :vehicle_documents` (dependent: :destroy)
- `has_many :vehicle_statuses` (dependent: :destroy)
- `has_many :vehicle_condition_reports` (dependent: :nullify)
- `has_many :reception_logs`
- `has_one_attached :primary_photo`
- `has_many_attached :gallery_photos`

**Key Fields:** make, model, license_plate, registration_number, year_of_manufacture, chassis_number, serial_number, vehicle_type, service_owner

**Key Methods:** latest_inspection, display_name

---

### Driver (`Driver`)
**Table:** `drivers`

**Associations:**
- `belongs_to :agency` (optional)
- `has_many :vehicles` (dependent: :nullify)
- `has_many :trips` (dependent: :nullify)
- `has_many :damage_reports` (dependent: :nullify)
- `has_many :alerts` (dependent: :destroy)

**Key Fields:** name, license_number, status, contact_number, employee_id, emergency_contact_name, emergency_contact_phone

**Statuses:** active, suspended, inactive

---

### VehicleStatus (`VehicleStatus`)
**Table:** `vehicle_statuses`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :created_by` (class_name: 'User', optional)

**Key Fields:** status, current, notes

**Statuses:** pending_reception, vehicle_received, pending_inspection, inspection_in_progress, inspection_complete, awaiting_parts, parts_ordered, parts_received, ready_for_repair, repair_in_progress, repair_complete, qc_pending, qc_in_progress, qc_passed, qc_failed, ready_for_pickup, completed

---

### VehicleDocument (`VehicleDocument`)
**Table:** `vehicle_documents`

**Associations:**
- `belongs_to :vehicle`
- `has_one_attached :file`

**Key Fields:** document_type, uploaded_at

---

### VehicleConditionReport (`VehicleConditionReport`)
**Table:** `vehicle_condition_reports`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :reception_log` (optional)
- `belongs_to :security_gate_officer` (class_name: 'User', foreign_key: 'security_officer_id')
- `belongs_to :client` (polymorphic: true, optional)
- `has_many_attached :condition_photos`

**Key Fields:** fuel_level, odometer, driver_name, signed_at, status, condition_data (JSON), acknowledgment (JSON)

**Statuses:** draft, completed, disputed

---

### Trip (`Trip`)
**Table:** `trips`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :driver` (class_name: "User", optional)

**Key Fields:** start_time, end_time, distance_km, ongoing

**Key Methods:** duration_seconds, duration_hours, formatted_duration, status, ongoing?

---

### Alert (`Alert`)
**Table:** `alerts`

**Associations:**
- `belongs_to :vehicle` (optional)
- `belongs_to :driver` (optional)
- `belongs_to :agency` (optional)

**Key Fields:** title, alert_type, severity, status, priority, description

**Enums:** alert_type (maintenance, safety, operational, financial, system, critical_incident), severity (info, warning, high_severity, critical), status (active, acknowledged, awaiting_procurement, resolved, closed), priority (low, medium, high_priority, urgent)

---

### DamageReport (`DamageReport`)
**Table:** `damage_reports`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :driver` (optional)
- `has_many_attached :photos`

**Key Fields:** description, report_date

---

### Route (`Route`)
**Table:** `routes`

**Associations:**
- `belongs_to :agency`
- `has_many :fare_rules` (foreign_key: :route_code, primary_key: :route_code)

**Key Fields:** route_code, name, start_point, end_point, distance_km, estimated_duration_minutes, stops, is_active

**Key Methods:** display_name, full_route_name, current_fare_rules

---

### FareRule (`FareRule`)
**Table:** `fare_rules`

**Associations:**
- `belongs_to :agency`
- `belongs_to :route` (foreign_key: :route_code, primary_key: :route_code, optional)

**Key Fields:** route_code, fare_class, amount, child_amount, student_amount, senior_amount, effective_from, effective_to, is_active

---

---

## 🔧 Maintenance & Service

### Maintenance (`Maintenance`)
**Table:** `maintenances`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :assigned_to` (class_name: "User", optional)
- `belongs_to :service_provider` (optional)
- `belongs_to :parent_maintenance` (class_name: "Maintenance", optional)
- `belongs_to :quotation` (optional)
- `has_many :maintenance_tasks` (dependent: :destroy)
- `has_many :child_maintenances` (class_name: "Maintenance", foreign_key: "parent_maintenance_id")

**Key Fields:** service_type, status, urgency, category, date, start_date, end_date, cost, next_due_date, assignment_type, additional_work, cancelled_by_agency

**Enums:** urgency (routine, scheduled, emergency, high, medium, low), status (Pending, In Progress, Completed, Cancelled), assignment_type (stores, purchasing), category (OilChange, TireRotation, BrakeService, EngineCheck, Transmission, Electrical, BodyWork, AirConditioning, Suspension, General)

**Key Methods:** completed?, pending?, in_progress?, cancelled?

---

### MaintenanceTask (`MaintenanceTask`)
**Table:** `maintenance_tasks`

**Associations:**
- `belongs_to :maintenance`
- `belongs_to :assigned_to` (class_name: "User", optional)

**Key Fields:** task_name, status, start_date, end_date

---

### MaintenancePart (`MaintenancePart`)
**Table:** `maintenance_parts`

**Associations:**
- `belongs_to :maintenance`
- `belongs_to :part`

**Key Fields:** N/A (Junction table)

---

### MaintenanceRequest (`MaintenanceRequest`)
**Table:** `maintenance_requests`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :requesting_agency` (class_name: 'Agency')
- `belongs_to :processing_agency` (class_name: 'Agency', optional)

**Key Fields:** description, requested_date, status, priority

**Enums:** status (pending, approved, in_progress, completed, rejected), priority (low, medium, high, emergency)

---

### ServiceProvider (`ServiceProvider`)
**Table:** `service_providers`

**Associations:** N/A

**Key Fields:** name, provider_type, is_active

**Provider Types:** internal_workshop, external_contractor

---

---

## 📋 Inspection & Diagnostics

### Inspection (`Inspection`)
**Table:** `inspections`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :inspector` (class_name: 'User', optional)
- `belongs_to :supervisor` (class_name: 'User', optional)
- `belongs_to :assigned_mechanic` (class_name: 'User', optional)
- `belongs_to :work_order` (optional)
- `belongs_to :purchase_order` (optional)
- `belongs_to :final_inspector` (class_name: 'User', optional)
- `belongs_to :workflow_selected_by` (class_name: "User", foreign_key: "workflow_selected_by_id", optional)
- `belongs_to :reception_log` (optional)
- `has_many :inspection_jobs` (dependent: :destroy)
- `has_many :parts_requests` (dependent: :destroy)
- `has_many :quotations` (dependent: :nullify)
- `has_many :findings` (dependent: :destroy)
- `has_many :inspection_recommendations` (dependent: :destroy)
- `has_many :jobs` (dependent: :destroy)

**Key Fields:** status, workflow_type, client_approval_status, client_selected_jobs, payment_status, scope_locked, labor_rate, parts_markup_percentage, diagnosis_notes, diagnosis_completed_at, notes, mileage_at_inspection

**Enums:** status (received, inspected, diagnosed, jobs_created, parts_pending, parts_ready, parts_confirmed, awaiting_approval, approved, in_progress, qc_pending, additional_findings_pending, on_hold, ready_for_pickup, completed, cancelled)

---

### InspectionJob (`InspectionJob`)
**Table:** `inspection_jobs`

**Associations:**
- `belongs_to :inspection`
- `belongs_to :job_template` (optional)
- `belongs_to :assigned_mechanic` (class_name: 'User', optional)
- `belongs_to :work_order` (optional)
- `belongs_to :pre_check_by` (class_name: 'User', optional)
- `has_many :inspection_job_parts` (dependent: :destroy)
- `has_many :parts` (through: :inspection_job_parts)
- `has_many :mechanic_assignments` (dependent: :destroy)
- `has_many :parts_requests` (foreign_key: :inspection_job_id, dependent: :nullify)
- `has_many :findings` (dependent: :destroy)
- `has_many :job_tasks` (dependent: :destroy)
- `has_many :dependencies_as_job` (class_name: 'JobDependency', foreign_key: :job_id, dependent: :destroy)
- `has_many :dependencies_on` (through: :dependencies_as_job, source: :depends_on)
- `has_many :dependencies_as_dependency` (class_name: 'JobDependency', foreign_key: :depends_on_job_id, dependent: :destroy)
- `has_many :dependent_jobs` (through: :dependencies_as_dependency, source: :job)

**Key Fields:** name, description, status, priority, estimated_labor_cost, estimated_parts_cost, actual_labor_cost, actual_parts_cost, started_at, completed_at, locked_for_changes, pre_check_notes

**Enums:** status (draft, pending_supervisor_review, pending_mechanic_review, pending_parts_review, approved, assigned, pre_check_in_progress, pre_check_completed, pending_approval, approved_for_work, in_progress, paused, blocked, rework_needed, completed, qc_pending, qc_in_progress, qc_passed, qc_failed, cancelled), priorities (low, normal, high, critical)

---

### InspectionJobPart (`InspectionJobPart`)
**Table:** `inspection_job_parts`

**Associations:**
- `belongs_to :inspection_job`
- `belongs_to :part` (optional)
- `belongs_to :dependency_job` (class_name: 'InspectionJob', optional)

**Key Fields:** quantity, estimated_cost, custom_part_name, customer_approved, part_type, cannot_complete_without

**Enums:** part_type (required, recommended, optional)

---

### Finding (`Finding`)
**Table:** `findings`

**Associations:**
- `belongs_to :inspection`
- `belongs_to :inspection_job` (optional)
- `belongs_to :created_by` (class_name: 'User', optional)
- `belongs_to :job` (class_name: 'InspectionJob', optional)
- `belongs_to :work_order` (optional)
- `belongs_to :approved_by` (class_name: 'User', optional)

**Key Fields:** finding_type, description, severity, priority, status, blocking, block_until_resolved, client_approved, job_created

**Enums:** finding_type (initial, mechanic, final, additional), status (pending, approved, rejected, in_progress, completed), severity (critical, major, minor), priority (low, normal, high, critical)

---

### InspectionRecommendation (`InspectionRecommendation`)
**Table:** `inspection_recommendations`

**Associations:**
- `belongs_to :inspection`
- `belongs_to :suggested_by` (class_name: 'User', optional)
- `belongs_to :converted_to_job` (class_name: 'InspectionJob', optional)
- `belongs_to :approved_by` (class_name: 'User', optional)

**Key Fields:** description, finding_type, status, priority, rejection_reason

**Enums:** status (pending, approved, converted, rejected), priority (low, normal, high, critical), finding_type (safety, mechanical, electrical, bodywork, maintenance)

---

### ReceptionLog (`ReceptionLog`)
**Table:** `reception_logs`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :inspection` (optional)
- `belongs_to :security_gate_officer` (class_name: 'User', foreign_key: 'user_id')
- `belongs_to :inspector` (class_name: 'User', optional, foreign_key: 'inspector_id')
- `belongs_to :purchase_order` (optional)
- `belongs_to :condition_report` (class_name: 'VehicleConditionReport', optional)

**Key Fields:** driver_name, visitor_name, customer_email, received_at, check_in_time, inspected_at, condition_status, receipt_number, portal_access_token, portal_access_expires_at

---

---

## 💰 Financial & Accounting

### Invoice (`Invoice`)
**Table:** `invoices`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :maintenance` (optional)
- `belongs_to :purchase_order` (optional)
- `belongs_to :pos_transaction` (optional)
- `belongs_to :supplier` (optional)
- `belongs_to :account` (optional)
- `belongs_to :created_by` (class_name: "User", optional)
- `belongs_to :received_by` (class_name: "User", optional)
- `belongs_to :reviewed_by` (class_name: "User", optional)
- `belongs_to :paid_by` (class_name: "User", optional)
- `belongs_to :disputed_by` (class_name: "User", optional)
- `belongs_to :work_order` (optional)
- `has_one :payable` (dependent: :nullify)
- `has_many :ledger_entries` (dependent: :destroy)
- `has_many :transactions` (dependent: :destroy)
- `has_many :payment_histories` (dependent: :destroy)

**Key Fields:** invoice_number, invoice_date, due_date, vendor, amount, status, category, priority, aging_bucket, sync_status, payment_terms, dispute_reason

**Enums:** status (draft, pending, reviewed, approved, paid, overdue, disputed, cancelled, partially_paid), category (maintenance, repair, parts, fuel, insurance, licensing, other), priority (low, medium, high, critical), aging_bucket (current, 30_days, 60_days, over_90_days), payment_terms (net_15, net_30, net_45, net_60, immediate, on_receipt)

---

### Payable (`Payable`)
**Table:** `payables`

**Associations:**
- `belongs_to :vendor` (class_name: 'Supplier', foreign_key: 'vendor_id', optional)
- `belongs_to :purchase_order` (optional)
- `belongs_to :invoice` (optional)
- `belongs_to :agency` (optional)
- `belongs_to :account` (required)
- `has_many :account_transactions` (dependent: :restrict_with_error)
- `has_many :payment_histories` (as: :payment_transaction, dependent: :destroy)

**Key Fields:** reference_number, vendor_name, amount, amount_due, due_date, status, payable_id

**Enums:** status (draft, open, partially_paid, paid, overdue, cancelled)

---

### AccountTransaction (`AccountTransaction`)
**Table:** `account_transactions`

**Associations:**
- `belongs_to :debit_account` (class_name: 'Account')
- `belongs_to :credit_account` (class_name: 'Account')
- `belongs_to :payable` (optional)
- `belongs_to :agency` (optional)
- `belongs_to :reference` (polymorphic: true, optional)

**Key Fields:** transaction_number, transaction_date, amount, transaction_type, description, notes

**Transaction Types:** payment, receipt, journal, adjustment, transfer

---

### LedgerEntry (`LedgerEntry`)
**Table:** `ledger_entries`

**Associations:**
- `belongs_to :agency`
- `belongs_to :vehicle`
- `belongs_to :invoice`
- `belongs_to :posted_by` (class_name: "User", optional)

**Key Fields:** entry_date, account_code, account_name, debit, credit

---

### PaymentHistory (`PaymentHistory`)
**Table:** `payment_histories`

**Associations:**
- `belongs_to :invoice`
- `belongs_to :user` (optional)
- `belongs_to :payment_transaction` (polymorphic: true, optional)

**Key Fields:** amount, payment_date, status, payment_method, reference_number

**Statuses:** completed, pending, failed, refunded

---

### Payment (`Payment`)
**Table:** `payments`

**Associations:**
- `belongs_to :inspection`
- `belongs_to :work_order` (optional)

**Key Fields:** N/A (minimal structure)

---

### PosTransaction (`PosTransaction`)
**Table:** `pos_transactions`

**Associations:**
- `belongs_to :agency`
- `belongs_to :invoice` (optional)
- `belongs_to :vehicle` (optional)
- `belongs_to :user` (optional)
- `belongs_to :cashier_session` (optional)

**Key Fields:** amount, transaction_id, receipt_number, passenger_count, status, payment_type, route_code, fare_class, ticket_type, is_return_trip, unit_fare

**Enums:** status (pending, completed, voided, refunded), payment_type (cash, card, mobile_money, bank_transfer, credit)

---

### CashierSession (`CashierSession`)
**Table:** `cashier_sessions`

**Associations:**
- `belongs_to :user`
- `belongs_to :agency`
- `belongs_to :closed_by` (class_name: 'User', optional)
- `has_many :pos_transactions`

**Key Fields:** starting_cash, ending_cash, opened_at, closed_at, status, total_sales, transaction_count, voided_total, refunded_total, cash_total, card_total, mobile_money_total, bank_transfer_total, discrepancy

**Enums:** status (open, closed, suspended)

---

---

## 📦 Procurement & Inventory

### Part (`Part`)
**Table:** `parts`

**Associations:**
- `belongs_to :supplier` (optional)
- `has_many :purchases`
- `has_many :maintenance_parts`
- `has_many :maintenances` (through: :maintenance_parts)
- `has_many :purchase_order_items`
- `has_many :job_template_parts`
- `has_many :job_templates` (through: :job_template_parts)
- `has_many :quotation_job_parts`
- `has_many :inventory_transactions` (as: :inventory_item)
- `has_many :purchase_requests`
- `has_many :vendor_parts`
- `has_many :suppliers` (through: :vendor_parts)
- `has_many :vendor_invoice_items`

**Key Fields:** name, part_number, category, current_stock, minimum_stock, reorder_point, cost_price, standard_markup_percentage, is_active, is_consumable

**Key Methods:** selling_price, profit_margin, name_with_details, display_name

---

### Supplier (`Supplier`)
**Table:** `suppliers`

**Associations:**
- `has_many :parts`
- `has_many :purchase_requests`
- `has_many :vendor_invoices`
- `has_many :purchase_orders`
- `has_many :invoices`
- `has_many :vendor_parts`
- `has_many :parts_through_vendor` (through: :vendor_parts, source: :part)

**Key Fields:** name, email, phone, contact_person, is_active, address, city, state, postal_code, country

---

### VendorPart (`VendorPart`)
**Table:** `vendor_parts`

**Associations:**
- `belongs_to :supplier`
- `belongs_to :part`

**Key Fields:** vendor_part_number, cost, is_preferred, is_active

---

### PurchaseOrder (`PurchaseOrder`)
**Table:** `purchase_orders`

**Associations:**
- `belongs_to :vehicle` (optional)
- `belongs_to :created_by` (class_name: 'User')
- `belongs_to :approved_by` (class_name: 'User', optional)
- `belongs_to :rejected_by` (class_name: 'User', optional)
- `belongs_to :payment_authorized_by` (class_name: 'User', optional)
- `belongs_to :payment_processed_by` (class_name: 'User', optional)
- `belongs_to :rfq` (class_name: 'VendorRfq', optional)
- `belongs_to :quotation` (optional)
- `belongs_to :supplier` (optional)
- `has_one :vendor_quotation` (dependent: :nullify)
- `has_one :payable` (dependent: :destroy)
- `has_many :purchase_order_items` (dependent: :destroy)
- `has_many :invoices` (dependent: :nullify)
- `has_many :payment_histories` (as: :payment_transaction)
- `has_many :payment_audits` (dependent: :destroy)
- `has_many :vendor_invoices`
- `has_many :internal_pos` (class_name: 'InternalPos', dependent: :nullify)

**Key Fields:** amount, status, payment_status, payment_method, acceptance_status, vmcott_status, purchase_order_number

**Enums:** status (draft, pending_approval, approved, rejected, sent, ordered, received, stock_updated, ready_for_payment, cancelled, paid), payment_status (unpaid, pending, processing, authorized, completed, failed, refunded), payment_method (cash, cheque, bank_transfer, trinidad_debit_card, trinidad_credit_card, debit_card, credit_card, other), acceptance_status (pending_acceptance, fully_accepted, fully_rejected), vmcott_status (pending_internal_work, work_in_progress, internal_work_completed, ready_for_delivery, delivered)

---

### PurchaseOrderItem (`PurchaseOrderItem`)
**Table:** `purchase_order_items`

**Associations:**
- `belongs_to :purchase_order`
- `belongs_to :part` (optional)
- `has_many :vendor_invoice_items` (dependent: :nullify)

**Key Fields:** description, quantity, unit_price, total_price, is_accepted

**Key Methods:** compute_total_price, sync_purchase_order_rollups

---

### VendorInvoice (`VendorInvoice`)
**Table:** `vendor_invoices`

**Associations:**
- `belongs_to :supplier`
- `belongs_to :user` (optional)
- `has_many :inventory_transactions`
- `has_many :purchase_requests`
- `has_many :vendor_invoice_items` (dependent: :destroy)
- `has_one_attached :invoice_scan`

**Key Fields:** invoice_number, invoice_date, due_date, amount, status

**Enums:** status (pending, reviewed, paid, disputed, cancelled)

---

### VendorInvoiceItem (`VendorInvoiceItem`)
**Table:** `vendor_invoice_items`

**Associations:**
- `belongs_to :vendor_invoice`
- `belongs_to :part` (optional)
- `belongs_to :purchase_order_item` (optional)

**Key Fields:** quantity, unit_price, total_price, description

---

### InventoryTransaction (`InventoryTransaction`)
**Table:** `inventory_transactions`

**Associations:**
- `belongs_to :inventory_item` (polymorphic: true)
- `belongs_to :reference` (polymorphic: true, optional)
- `belongs_to :user`
- `belongs_to :agency` (optional)

**Key Fields:** quantity, transaction_type, unit_price, total_price, notes, description

**Enums:** transaction_type (receipt, consumption, reservation, release, adjustment, transfer, stock_in, stock_out, damage, return, write_off, purchase, sale)

---

### InventoryItem (`InventoryItem`)
**Table:** `parts` (same as Part model)

**Associations:** Same as Part

**Key Methods:** can_fulfill?, reserve_stock, release_stock, consume_stock, low_stock?, needs_reorder?

---

### PurchaseRequest (`PurchaseRequest`)
**Table:** `purchase_requests`

**Associations:**
- `belongs_to :requested_by` (class_name: 'User', optional)
- `belongs_to :approved_by` (class_name: 'User', optional)
- `belongs_to :rejected_by` (class_name: 'User', optional)
- `belongs_to :part` (optional)
- `belongs_to :quotation` (optional)
- `has_many :purchase_request_items` (dependent: :destroy)

**Key Fields:** quantity, urgency, status, needed_by_date, total_estimated_cost

**Enums:** status (pending, approved, rejected, ordered, received, cancelled), urgency (low, normal, high, critical)

---

### PurchaseRequestItem (`PurchaseRequestItem`)
**Table:** `purchase_request_items`

**Associations:**
- `belongs_to :purchase_request`
- `belongs_to :part`

**Key Fields:** quantity_requested

---

### PartsRequest (`PartsRequest`)
**Table:** `parts_requests`

**Associations:**
- `belongs_to :inspection`
- `belongs_to :inspection_job` (optional)
- `belongs_to :part` (optional)
- `belongs_to :requested_by` (class_name: 'User', optional)
- `belongs_to :approved_by` (class_name: 'User', optional)
- `belongs_to :rejected_by` (class_name: 'User', optional)
- `belongs_to :issued_by` (class_name: 'User', optional)
- `belongs_to :purchase_order` (optional)
- `belongs_to :vendor_invoice` (optional)

**Key Fields:** quantity, status, custom_part_name, approved_at, rejected_at, issued_at, approval_reason, rejection_reason

**Enums:** status (requested, approved, rejected, needs_order, ordered, received, confirmed, issued)

---

### Purchase (`Purchase`)
**Table:** `purchases`

**Associations:**
- `belongs_to :part`

**Key Fields:** quantity, supplier, status

---

---

## 🏷️ Quotations & RFQs

### Quotation (`Quotation`)
**Table:** `quotations`

**Associations:**
- `belongs_to :vehicle` (optional)
- `belongs_to :rfq` (optional)
- `belongs_to :work_order` (optional)
- `belongs_to :agency` (optional)
- `belongs_to :client` (polymorphic: true, optional)
- `belongs_to :created_by` (class_name: "User", optional)
- `belongs_to :submitted_by` (class_name: "User", optional)
- `belongs_to :inspection` (optional)
- `has_one :purchase_order` (dependent: :nullify)
- `has_many :quotation_line_items` (dependent: :destroy)
- `has_many :line_items` (class_name: "QuotationLineItem", foreign_key: :quotation_id, dependent: :destroy)
- `has_many :quotation_jobs` (dependent: :destroy)

**Key Fields:** quote_number, vendor, valid_from, valid_to, amount, status, notes

**Enums:** status (draft, sent, accepted, rejected, expired, converted, pending_acceptance, partially_rejected, superseded)

---

### QuotationLineItem (`QuotationLineItem`)
**Table:** `quotation_line_items`

**Associations:**
- `belongs_to :quotation`

**Key Fields:** description, quantity, unit_price, notes

**Key Methods:** total_price, formatted_unit_price, formatted_total_price

---

### QuotationJob (`QuotationJob`)
**Table:** `quotation_jobs`

**Associations:**
- `belongs_to :quotation`
- `belongs_to :inspection_job` (optional)
- `belongs_to :job_template` (optional)
- `has_many :quotation_job_parts` (dependent: :destroy)
- `has_many :parts` (through: :quotation_job_parts)

**Key Fields:** name, job_type, description, estimated_hours, labor_rate_per_hour, total_labor_cost

**Key Methods:** calculate_labor_cost, total_parts_cost, total_job_cost

---

### QuotationJobPart (`QuotationJobPart`)
**Table:** `quotation_job_parts`

**Associations:** N/A (Join table)

**Key Fields:** quotation_job_id, part_id

---

### Rfq (`Rfq`)
**Table:** `rfqs`

**Associations:**
- `belongs_to :requesting_agency` (class_name: "Agency")
- `belongs_to :processing_agency` (class_name: "Agency", optional)
- `belongs_to :vehicle` (optional)
- `belongs_to :maintenance_request` (optional)
- `belongs_to :converted_to_quotation` (class_name: "Quotation", foreign_key: "converted_to_quotation_id", optional)
- `has_many :rfq_line_items` (dependent: :destroy)

**Key Fields:** rfq_number, request_date, response_due_date, status, description

**Enums:** status (draft, submitted, under_review, quoted, converted, rejected, accepted)

---

### RfqLineItem (`RfqLineItem`)
**Table:** `rfq_line_items`

**Associations:**
- `belongs_to :rfq`

**Key Fields:** description, quantity, category, unit_price, estimated_cost

**Enums:** category (parts, labor, other)

---

### VendorRfq (`VendorRfq`)
**Table:** `vendor_rfqs`

**Associations:**
- `belongs_to :created_by` (class_name: "User", optional)
- `belongs_to :processing_agency` (class_name: "Agency", optional)
- `belongs_to :vehicle` (optional)
- `has_many :vendor_rfq_items` (dependent: :destroy)
- `has_many :vendor_quotations` (dependent: :destroy)
- `belongs_to :awarded_vendor_quotation` (class_name: "VendorQuotation", optional)

**Key Fields:** rfq_number, status, po_sent_at, po_received_at, description

**Statuses:** draft, sent, quotations_received, closed, awarded

**Key Methods:** can_create_po?, po_created?, po_received?, po_status_display

---

### VendorRfqItem (`VendorRfqItem`)
**Table:** `vendor_rfq_items`

**Associations:** N/A

**Key Fields:** part_id, part_name, part_number, quantity, description, custom

---

### VendorQuotation (`VendorQuotation`)
**Table:** `vendor_quotations`

**Associations:**
- `belongs_to :vendor_rfq`
- `belongs_to :supplier`
- `belongs_to :purchase_order` (optional)
- `has_many :vendor_quotation_lines` (dependent: :destroy)
- `has_one_attached :attachment`

**Key Fields:** status, submitted_date, valid_until

**Statuses:** draft, received, accepted, rejected

**Key Methods:** total_amount, supplier_name, has_attachment?

---

### VendorQuotationLine (`VendorQuotationLine`)
**Table:** `vendor_quotation_lines`

**Associations:** N/A

**Key Fields:** vendor_quotation_id, part_id, quantity, unit_price, total_price, description

---

---

## 🛠️ Work Orders & Jobs

### WorkOrder (`WorkOrder`)
**Table:** `work_orders`

**Associations:**
- `belongs_to :vehicle`
- `belongs_to :customer` (polymorphic: true, optional)
- `belongs_to :created_by` (class_name: 'User', optional)
- `belongs_to :updated_by` (class_name: 'User', optional)
- `has_many :inspections` (dependent: :destroy)
- `has_many :inspection_jobs` (through: :inspections)
- `has_many :job_tasks` (through: :inspection_jobs)
- `has_many :work_sessions` (through: :job_tasks)
- `has_many :quotations` (dependent: :destroy)
- `has_many :payments` (dependent: :destroy)
- `has_many :invoices` (dependent: :destroy)
- `has_many :findings` (dependent: :destroy)
- `has_many :audit_logs` (as: :auditable, dependent: :nullify)

**Key Fields:** work_order_number, status, payment_status, total_amount, notes

**Statuses:** received, inspected, awaiting_approval, approved, in_progress, on_hold, ready_for_pickup, completed, cancelled

**Key Methods:** can_transition_to?, transition_to!

---

### JobTemplate (`JobTemplate`)
**Table:** `job_templates`

**Associations:**
- `belongs_to :agency`
- `has_many :job_template_parts` (dependent: :destroy)
- `has_many :parts` (through: :job_template_parts)
- `has_many :quotation_jobs`
- `has_many :job_template_vehicle_applications` (dependent: :destroy)

**Key Fields:** name, description, category, estimated_hours, labor_rate, is_active, agency_id

**Key Methods:** applies_to_vehicle?, inventory_status

---

### JobTemplatePart (`JobTemplatePart`)
**Table:** `job_template_parts`

**Associations:**
- `belongs_to :job_template`
- `belongs_to :part`

**Key Fields:** quantity, required, notes

**Key Methods:** total_price, in_stock?, stock_status, copy_to_template

---

### JobTemplateVehicleApplication (`JobTemplateVehicleApplication`)
**Table:** `job_template_vehicle_applications`

**Associations:** N/A (appears to be implicit)

**Key Fields:** job_template_id, make, model, year

---

### JobTask (`JobTask`)
**Table:** `job_tasks`

**Associations:**
- `belongs_to :inspection_job`
- `belongs_to :assigned_mechanic` (class_name: 'User', optional)
- `belongs_to :finding` (optional)
- `has_many :work_sessions` (dependent: :destroy)
- `has_many :dependencies` (class_name: 'JobTaskDependency', foreign_key: :job_task_id)
- `has_many :depends_on` (through: :dependencies, source: :depends_on_task)

**Key Fields:** name, status, estimated_hours, actual_hours, started_at, completed_at, notes

**Statuses:** pending, approved, in_progress, blocked, completed, skipped

**Key Methods:** start!, can_start?, can_transition_to?

---

### JobTaskDependency (`JobTaskDependency`)
**Table:** `job_task_dependencies`

**Associations:** N/A

**Key Fields:** job_task_id, depends_on_task_id

---

### JobDependency (`JobDependency`)
**Table:** `job_dependencies`

**Associations:** N/A

**Key Fields:** job_id, depends_on_job_id

---

### WorkSession (`WorkSession`)
**Table:** `work_sessions`

**Associations:**
- `belongs_to :job_task`
- `belongs_to :mechanic` (class_name: 'User')
- `belongs_to :updated_by` (class_name: 'User', optional)

**Key Fields:** started_at, ended_at, session_type, duration_hours, notes, system_generated

**Session Types:** work, break, waiting, blocked

**Key Methods:** active?, end_session!, pause!, resume!, duration_minutes, formatted_duration

---

---

## 🎫 Auditing & Logging

### AuditLog (`AuditLog`)
**Table:** `audit_logs`

**Associations:**
- `belongs_to :user` (optional)
- `belongs_to :record` (polymorphic: true)

**Key Fields:** action, record_type, record_id, audit_changes (JSON), ip_address, note

---

### Notification (`Notification`)
**Table:** `notifications`

**Associations:**
- `belongs_to :user`
- `belongs_to :notifiable` (polymorphic: true, optional)

**Key Fields:** title, message, notification_type, read_at, read, link

**Key Methods:** read?, mark_as_read!, mark_as_unread!

---

---

## 🗂️ Special/Utility Models

### Client (`Client`)
**Table:** `clients`

**Associations:**
- `belongs_to :agency` (optional)
- `has_many :vehicles` (as: :owner, dependent: :nullify)
- `has_many :invoices` (as: :client, dependent: :nullify)
- `has_many :quotations` (as: :client, dependent: :nullify)
- `has_many :vehicle_condition_reports` (as: :client, dependent: :nullify)

**Key Fields:** name, email, phone, address, credit_limit, is_active, client_type, payment_terms

**Enums:** client_type (agency, corporate, individual), payment_terms (cash, net_15, net_30, net_60, deposit_balance)

**Key Methods:** display_name, client_type_display, payment_terms_display

---

### MechanicAssignment (`MechanicAssignment`)
**Table:** `mechanic_assignments`

**Associations:** N/A

**Key Fields:** inspection_job_id, mechanic_id, status, assigned_at, started_at, completed_at

---

### Current (`Current`)
**Table:** N/A (Singleton context object)

**Associations:** N/A

**Purpose:** Stores request context (ip_address, user_agent, etc.)

---

---

## 📊 Model Statistics

| Category | Count | Models |
|----------|-------|--------|
| Organization & Access | 6 | Account, Agency, User, Role, UserRole, AgencySetting |
| Fleet Management | 7 | Vehicle, Driver, VehicleStatus, VehicleDocument, VehicleConditionReport, Trip, Alert, DamageReport, Route, FareRule |
| Maintenance | 5 | Maintenance, MaintenanceTask, MaintenancePart, MaintenanceRequest, ServiceProvider |
| Inspection | 6 | Inspection, InspectionJob, InspectionJobPart, Finding, InspectionRecommendation, ReceptionLog |
| Financial | 9 | Invoice, Payable, AccountTransaction, LedgerEntry, PaymentHistory, Payment, PosTransaction, CashierSession, Purchase |
| Procurement | 15 | Part, Supplier, VendorPart, PurchaseOrder, PurchaseOrderItem, VendorInvoice, VendorInvoiceItem, InventoryTransaction, InventoryItem, PurchaseRequest, PurchaseRequestItem, PartsRequest, Quotation, QuotationLineItem, QuotationJob |
| RFQs | 6 | Rfq, RfqLineItem, VendorRfq, VendorRfqItem, VendorQuotation, VendorQuotationLine |
| Work Orders | 9 | WorkOrder, JobTemplate, JobTemplatePart, JobTemplateVehicleApplication, JobTask, JobTaskDependency, JobDependency, WorkSession, MechanicAssignment |
| Auditing & Logging | 2 | AuditLog, Notification |
| Special | 2 | Client, Current |
| **TOTAL** | **80+** | |

---

## 🔗 Key Relationship Patterns

### Polymorphic Relationships
- `Vehicle.owner` → Agency OR Client
- `Notification.notifiable` → Any model
- `InventoryTransaction.inventory_item` → Any inventory model
- `InventoryTransaction.reference` → Any reference model
- `VehicleConditionReport.client` → Agency OR Client
- `WorkOrder.customer` → Any customer type
- `AuditLog.record` → Any auditable model
- `AccountTransaction.reference` → Any referenced model

### Self-Referencing Relationships
- `Maintenance.parent_maintenance` ↔ `Maintenance`
- `InspectionJob.dependencies_as_job` ↔ `InspectionJob.dependencies_on`
- `JobTask.depends_on` ↔ `JobTask.dependencies`
- `User.created_purchase_orders` & `User.approved_purchase_orders` → Both reference User model

### Through Relationships (Complex Traversals)
- `Agency.quotations_through_rfqs` → Through RFQ to Quotation
- `Agency.pos_transactions` → Through CashierSession
- `Part.suppliers` → Through VendorPart
- `Agency.fare_rules` → Through Route
- `Vehicle.inspection_jobs` → Through Inspection

---

## 🎯 ER Diagram Key Insights

1. **Core Hub Models:** Vehicle, Inspection, PurchaseOrder, Quotation serve as central entities
2. **User Relationships:** Multiple user types (inspector, mechanic, security officer, etc.) reference via polymorphic or specific foreign keys
3. **Inventory Tracking:** Part model connects to multiple systems via has_many through relationships
4. **Financial Integration:** Account & Payable models form accounting backbone
5. **Workflow Models:** InspectionJob and JobTask track work progression through multiple states
6. **Multi-Agency Support:** Many models include agency_id for multi-tenant capability
7. **Polymorphic Ownership:** Vehicle and Client models enable flexible ownership models
8. **Audit Trail:** AuditLog and timestamp fields track all changes

---

*End of Model Associations Document*
