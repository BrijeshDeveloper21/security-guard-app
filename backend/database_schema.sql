-- ============================================================================
-- MULTI-BUILDING VISITOR & SECURITY MANAGEMENT SAAS PLATFORM
-- Production PostgreSQL Relational Database Schema & Row-Level Security (RLS)
-- ============================================================================

-- Enable UUID extension for cryptographically secure, collision-free primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. TENANTS & SOCIETIES
-- ----------------------------------------------------------------------------
CREATE TABLE tenants (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    building_name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL DEFAULT 'Mumbai',
    state VARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    postal_code VARCHAR(20),
    contact_phone VARCHAR(30) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo_url TEXT,
    timezone VARCHAR(50) NOT NULL DEFAULT 'Asia/Kolkata',
    subscription_status VARCHAR(30) NOT NULL DEFAULT 'trial' 
        CHECK (subscription_status IN ('trial', 'active', 'past_due', 'expired', 'suspended', 'cancelled')),
    subscription_plan_id VARCHAR(64) NOT NULL,
    subscription_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    security_settings JSONB NOT NULL DEFAULT '{
        "require_visitor_photo": true,
        "require_delivery_approval": false,
        "require_guest_approval": true,
        "require_cab_approval": false,
        "auto_approve_pre_approved": true,
        "visitor_history_retention_days": 365,
        "photo_retention_days": 90
    }'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tenants_status ON tenants(subscription_status, is_active);

-- ----------------------------------------------------------------------------
-- 2. SUBSCRIPTION PLANS & BILLING
-- ----------------------------------------------------------------------------
CREATE TABLE subscription_plans (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    tier VARCHAR(50) NOT NULL CHECK (tier IN ('basic', 'standard', 'premium', 'enterprise')),
    price_monthly NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    price_yearly NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    description TEXT,
    features JSONB NOT NULL DEFAULT '[]'::jsonb,
    limits JSONB NOT NULL DEFAULT '{
        "max_gates": 5,
        "max_guards": 10,
        "max_flats": 100,
        "storage_limit_gb": 5,
        "has_qr_system": true,
        "has_resident_approval": true,
        "has_emergency_view": true,
        "has_audit_logs": true,
        "has_offline_sync": true
    }'::jsonb,
    is_popular BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE society_subscriptions (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    plan_id VARCHAR(64) NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(30) NOT NULL DEFAULT 'active'
        CHECK (status IN ('trial', 'active', 'past_due', 'expired', 'suspended', 'cancelled')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    billing_cycle VARCHAR(20) NOT NULL DEFAULT 'yearly' CHECK (billing_cycle IN ('monthly', 'yearly')),
    last_payment_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    last_payment_date TIMESTAMP WITH TIME ZONE,
    next_billing_date TIMESTAMP WITH TIME ZONE NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'UPI / Razorpay',
    auto_renew BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_tenant ON society_subscriptions(tenant_id, status);

-- ----------------------------------------------------------------------------
-- 3. USERS & RBAC (Role-Based Access Control)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) REFERENCES tenants(id) ON DELETE CASCADE, -- NULL for SuperAdmin
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('superAdmin', 'societyAdmin', 'guard', 'resident')),
    assigned_gate_id VARCHAR(64),
    flat_id VARCHAR(64),
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_tenant_role ON users(tenant_id, role, is_active);

-- ----------------------------------------------------------------------------
-- 4. GATES (Dynamic Multi-Gate Architecture)
-- ----------------------------------------------------------------------------
CREATE TABLE gates (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL, -- e.g. Gate A - Main Entrance, Gate B - Parking
    code VARCHAR(50) NOT NULL, -- e.g. GATE-A, GATE-B
    type VARCHAR(50) NOT NULL DEFAULT 'mainEntrance'
        CHECK (type IN ('mainEntrance', 'parking', 'service', 'backGate', 'pedestrian', 'emergency')),
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_gates_tenant_code ON gates(tenant_id, code);

-- ----------------------------------------------------------------------------
-- 5. WINGS & FLATS
-- ----------------------------------------------------------------------------
CREATE TABLE wings (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- Wing A, Wing B
    total_floors INT NOT NULL DEFAULT 15,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE flats (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    wing_id VARCHAR(64) NOT NULL REFERENCES wings(id) ON DELETE CASCADE,
    wing_name VARCHAR(100) NOT NULL,
    flat_number VARCHAR(50) NOT NULL, -- e.g. B-1204
    floor INT NOT NULL DEFAULT 1,
    resident_name VARCHAR(255),
    resident_phone VARCHAR(30),
    resident_email VARCHAR(255),
    is_occupied BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_flats_tenant_number ON flats(tenant_id, flat_number);

-- ----------------------------------------------------------------------------
-- 6. GUARDS & RESIDENTS PROFILES
-- ----------------------------------------------------------------------------
CREATE TABLE guards (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    badge_number VARCHAR(50),
    assigned_gate_id VARCHAR(64) REFERENCES gates(id),
    shift VARCHAR(30) NOT NULL DEFAULT 'morning' CHECK (shift IN ('morning', 'afternoon', 'night')),
    is_on_duty BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE residents (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(255),
    flat_id VARCHAR(64) NOT NULL REFERENCES flats(id) ON DELETE CASCADE,
    flat_number VARCHAR(50) NOT NULL,
    wing_name VARCHAR(100) NOT NULL,
    is_owner BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 7. VISITORS (Entity Isolated from Visits)
-- ----------------------------------------------------------------------------
CREATE TABLE visitors (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    photo_url TEXT,
    vehicle_number VARCHAR(50),
    visitor_type VARCHAR(50) NOT NULL DEFAULT 'guest'
        CHECK (visitor_type IN ('guest', 'delivery', 'cab', 'technician', 'domesticHelp', 'vendor', 'other')),
    total_visits INT NOT NULL DEFAULT 1,
    last_visited_flat VARCHAR(50),
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_visit_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_visitors_tenant_phone ON visitors(tenant_id, phone);

-- ----------------------------------------------------------------------------
-- 8. VISITS (Entry & Exit Tracking with Multi-Gate Support)
-- ----------------------------------------------------------------------------
CREATE TABLE visits (
    id VARCHAR(64) PRIMARY KEY, -- e.g. VIS-2026-000123
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    visitor_id VARCHAR(64) NOT NULL REFERENCES visitors(id) ON DELETE CASCADE,
    visitor_name VARCHAR(255) NOT NULL,
    visitor_phone VARCHAR(30) NOT NULL,
    visitor_photo_url TEXT,
    flat_id VARCHAR(64) NOT NULL REFERENCES flats(id),
    flat_number VARCHAR(50) NOT NULL,
    wing_name VARCHAR(100) NOT NULL,
    visitor_type VARCHAR(50) NOT NULL DEFAULT 'guest',
    purpose VARCHAR(50) NOT NULL DEFAULT 'meetingResident'
        CHECK (purpose IN ('meetingResident', 'delivery', 'repair', 'maintenance', 'service', 'domesticWork', 'cabPickupDrop', 'other')),
    custom_purpose TEXT,
    vehicle_number VARCHAR(50),
    
    -- Automatic Entry Tracking
    entry_gate_id VARCHAR(64) NOT NULL REFERENCES gates(id),
    entry_gate_name VARCHAR(150) NOT NULL,
    entry_guard_id VARCHAR(64) NOT NULL REFERENCES users(id),
    entry_guard_name VARCHAR(255) NOT NULL,
    entry_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Automatic Exit Tracking (Cross-Gate)
    exit_gate_id VARCHAR(64) REFERENCES gates(id),
    exit_gate_name VARCHAR(150),
    exit_guard_id VARCHAR(64) REFERENCES users(id),
    exit_guard_name VARCHAR(255),
    exit_timestamp TIMESTAMP WITH TIME ZONE,
    
    -- Status & Cryptographic QR Token
    status VARCHAR(30) NOT NULL DEFAULT 'inside' CHECK (status IN ('inside', 'exited', 'rejected')),
    approval_status VARCHAR(30) NOT NULL DEFAULT 'notRequired' CHECK (approval_status IN ('notRequired', 'pending', 'approved', 'rejected')),
    secure_visit_token VARCHAR(255) UNIQUE NOT NULL,
    is_pre_approved BOOLEAN NOT NULL DEFAULT false,
    expected_arrival_time TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visits_tenant_status ON visits(tenant_id, status);
CREATE INDEX idx_visits_currently_inside ON visits(tenant_id) WHERE exit_timestamp IS NULL;
CREATE INDEX idx_visits_flat ON visits(tenant_id, flat_id);
CREATE INDEX idx_visits_entry_time ON visits(tenant_id, entry_timestamp DESC);

-- ----------------------------------------------------------------------------
-- 9. VISITOR APPROVAL WORKFLOW
-- ----------------------------------------------------------------------------
CREATE TABLE visitor_approvals (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    visit_id VARCHAR(64) NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    resident_id VARCHAR(64) NOT NULL REFERENCES users(id),
    flat_id VARCHAR(64) NOT NULL REFERENCES flats(id),
    flat_number VARCHAR(50) NOT NULL,
    visitor_name VARCHAR(255) NOT NULL,
    visitor_phone VARCHAR(30) NOT NULL,
    visitor_photo_url TEXT,
    visitor_type VARCHAR(50) NOT NULL,
    purpose VARCHAR(50) NOT NULL,
    entry_gate_name VARCHAR(150) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    requested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    rejection_reason TEXT
);

CREATE INDEX idx_approvals_tenant_flat ON visitor_approvals(tenant_id, flat_id, status);

-- ----------------------------------------------------------------------------
-- 10. COMPREHENSIVE AUDIT LOGS
-- ----------------------------------------------------------------------------
CREATE TABLE audit_logs (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id VARCHAR(64) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    user_role VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(64) NOT NULL,
    details TEXT NOT NULL,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_tenant_time ON audit_logs(tenant_id, timestamp DESC);

-- ----------------------------------------------------------------------------
-- 11. POSTGRESQL ROW-LEVEL SECURITY (RLS) FOR STRICT TENANT ISOLATION
-- ----------------------------------------------------------------------------
ALTER TABLE gates ENABLE ROW LEVEL SECURITY;
ALTER TABLE wings ENABLE ROW LEVEL SECURITY;
ALTER TABLE flats ENABLE ROW LEVEL SECURITY;
ALTER TABLE guards ENABLE ROW LEVEL SECURITY;
ALTER TABLE residents ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitor_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Tenant Isolation RLS Policies
-- Users can only query and mutate data matching the current session tenant:
CREATE POLICY tenant_isolation_gates ON gates
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));

CREATE POLICY tenant_isolation_flats ON flats
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));

CREATE POLICY tenant_isolation_visitors ON visitors
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));

CREATE POLICY tenant_isolation_visits ON visits
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));

CREATE POLICY tenant_isolation_approvals ON visitor_approvals
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));

CREATE POLICY tenant_isolation_audit ON audit_logs
    FOR ALL USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), ''));
