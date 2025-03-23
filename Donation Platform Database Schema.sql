-- Donation Platform Database Schema
-- This schema defines all necessary tables for the donation platform app
-- with comprehensive fields for all three interfaces: Donor, Organization, and Admin

-- Enable UUID extension (for PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------
-- USERS AND AUTHENTICATION
-- -----------------------------------------------

-- Users table (base table for all user types)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('donor', 'organization', 'admin')),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    profile_image_url VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP
);

-- User Verification table (for automatic CNIC verification)
CREATE TABLE user_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cnic VARCHAR(15) UNIQUE, -- National ID number
    cnic_verified BOOLEAN NOT NULL DEFAULT FALSE,
    cnic_verified_at TIMESTAMP,
    cnic_verification_response JSONB, -- Store API response from CNIC verification service
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    phone_verified_at TIMESTAMP,
    is_blacklisted BOOLEAN NOT NULL DEFAULT FALSE, -- For admins to disable fowl donors
    blacklisted_reason TEXT,
    blacklisted_at TIMESTAMP,
    blacklisted_by UUID REFERENCES users(id), -- Admin who blacklisted
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OTP Verification table
CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    purpose VARCHAR(20) NOT NULL CHECK (purpose IN ('phone_verification', 'login', 'password_reset')),
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User Sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(512) NOT NULL UNIQUE,
    device_info JSONB,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User Roles and Permissions (for fine-grained access control)
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- -----------------------------------------------
-- DONOR-SPECIFIC TABLES
-- -----------------------------------------------

-- Donor Profiles
CREATE TABLE donor_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender VARCHAR(10),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    preferred_categories JSONB, -- Array of preferred donation categories
    is_anonymous_by_default BOOLEAN NOT NULL DEFAULT FALSE,
    notification_preferences JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- ORGANIZATION-SPECIFIC TABLES
-- -----------------------------------------------

-- Organization Profiles
CREATE TABLE organization_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    organization_name VARCHAR(255) NOT NULL,
    description TEXT,
    mission_statement TEXT,
    vision TEXT,
    founding_year INTEGER,
    organization_type VARCHAR(100) NOT NULL, -- e.g., NGO, Foundation, etc.
    registration_number VARCHAR(100) UNIQUE,
    tax_id VARCHAR(100) UNIQUE,
    website_url VARCHAR(512),
    social_media JSONB, -- JSON object with social media links
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_address_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending' 
        CHECK (verification_status IN ('pending', 'in_review', 'approved', 'rejected')),
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    logo_url VARCHAR(512),
    banner_url VARCHAR(512),
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Organization Categories (many-to-many relationship)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(512),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organization_categories (
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (organization_id, category_id)
);

-- Organization Verification (comprehensive verification data)
CREATE TABLE organization_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    
    -- Registration Documents
    registration_certificate_url VARCHAR(512),
    tax_certificate_url VARCHAR(512),
    annual_report_url VARCHAR(512),
    governing_document_url VARCHAR(512), -- bylaws, constitution, etc.
    
    -- Financial Documents
    bank_statement_url VARCHAR(512),
    financial_report_url VARCHAR(512),
    
    -- Board and Leadership
    board_resolution_url VARCHAR(512),
    board_members JSONB, -- JSON array with board member details
    
    -- Contact Person Details
    contact_person_name VARCHAR(255) NOT NULL,
    contact_person_position VARCHAR(100) NOT NULL,
    contact_person_email VARCHAR(255) NOT NULL,
    contact_person_phone VARCHAR(20) NOT NULL,
    contact_person_cnic VARCHAR(15),
    
    -- Bank Details
    bank_name VARCHAR(255) NOT NULL,
    account_title VARCHAR(255) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    branch_code VARCHAR(20),
    swift_code VARCHAR(20),
    is_bank_verified BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- References
    reference_letters JSONB, -- JSON array with reference documents
    
    -- Verification Process
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending' 
        CHECK (verification_status IN ('pending', 'in_review', 'approved', 'rejected')),
    verification_stage VARCHAR(50),
    verification_notes TEXT,
    verified_by UUID REFERENCES users(id), -- Admin who performed verification
    verified_at TIMESTAMP,
    rejection_reason TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- REPORTING SYSTEM TABLES
-- -----------------------------------------------

-- User Reports table (for both donors and organizations)
CREATE TABLE user_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reported_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL, -- 'spam', 'fraud', 'inappropriate', 'other'
    report_reason TEXT NOT NULL,
    report_evidence JSONB, -- URLs to evidence files or screenshots
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'rejected')),
    admin_notes TEXT,
    resolved_by UUID REFERENCES users(id), -- Admin who resolved the report
    resolved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create index for reports
CREATE INDEX idx_user_reports_reporter ON user_reports(reporter_id);
CREATE INDEX idx_user_reports_reported ON user_reports(reported_id);
CREATE INDEX idx_user_reports_status ON user_reports(status);

-- -----------------------------------------------
-- DONATION-RELATED TABLES
-- -----------------------------------------------

-- Donation Categories
CREATE TABLE donation_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(512),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insert default donation categories
INSERT INTO donation_categories (name, description) VALUES
('Food', 'Food items, groceries, and meal donations'),
('Clothes', 'Clothing items and apparel for all ages'),
('Money', 'Monetary donations in any currency'),
('Books', 'Books, educational materials, and literature'),
('Medical Supplies', 'Medicine, medical equipment, and healthcare items'),
('Household Items', 'Furniture, appliances, and home essentials'),
('Other', 'Special items and miscellaneous donations');

-- Donation Campaigns
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    goal_amount DECIMAL(12, 2) NOT NULL,
    raised_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    campaign_type VARCHAR(50) NOT NULL, -- emergency, ongoing, project-based, etc.
    cover_image_url VARCHAR(512),
    gallery_images JSONB, -- JSON array with image URLs
    video_url VARCHAR(512),
    category_id UUID REFERENCES categories(id),
    tags JSONB, -- JSON array of tags
    location_description TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Donations
CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donor_id UUID NOT NULL REFERENCES donor_profiles(user_id) ON DELETE SET NULL,
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE SET NULL,
    donation_category_id UUID NOT NULL REFERENCES donation_categories(id),
    amount DECIMAL(12, 2), -- NULL for non-monetary donations
    currency VARCHAR(3) DEFAULT 'USD', -- NULL for non-monetary donations
    donation_items JSONB, -- Details of donated items for non-monetary donations
    quantity INTEGER, -- For non-monetary donations
    estimated_value DECIMAL(12, 2), -- Estimated value for non-monetary donations
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' 
        CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'rejected')),
    payment_method VARCHAR(50), -- NULL for non-monetary donations
    payment_id VARCHAR(255), -- ID from payment processor
    transaction_reference VARCHAR(255), -- Reference number for tracking
    donation_notes TEXT,
    pickup_required BOOLEAN DEFAULT FALSE, -- For physical item donations
    pickup_address TEXT, -- For physical item donations
    pickup_date TIMESTAMP, -- For physical item donations
    pickup_status VARCHAR(20), -- 'scheduled', 'completed', 'cancelled'
    gift_aid_eligible BOOLEAN DEFAULT FALSE,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurring_frequency VARCHAR(20), -- monthly, quarterly, etc.
    receipt_url VARCHAR(512),
    ip_address VARCHAR(45),
    device_info JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Donation Tracking and Updates
CREATE TABLE donation_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('received', 'processing', 'utilized', 'completed')),
    feedback TEXT,
    updated_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE donation_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    media_urls JSONB, -- JSON array of image/video URLs
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Payment Transactions
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    transaction_id VARCHAR(255) NOT NULL, -- ID from payment gateway
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_gateway VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    gateway_response JSONB, -- JSON object with payment gateway response
    error_message TEXT,
    refund_status VARCHAR(20), -- if applicable
    refund_amount DECIMAL(12, 2), -- if applicable
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Recurring Donations
CREATE TABLE recurring_donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donor_id UUID NOT NULL REFERENCES donor_profiles(user_id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE SET NULL,
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    frequency VARCHAR(20) NOT NULL, -- monthly, quarterly, annually
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    next_donation_date TIMESTAMP NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_details JSONB, -- encrypted payment details
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- ADMIN-RELATED TABLES
-- -----------------------------------------------

-- Admin Actions Log
CREATE TABLE admin_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- user, organization, donation, etc.
    entity_id UUID NOT NULL,
    details JSONB, -- Details of the action
    ip_address VARCHAR(45),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- System Settings
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value JSONB NOT NULL,
    description TEXT,
    is_editable BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by UUID REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- NOTIFICATION AND COMMUNICATION TABLES
-- -----------------------------------------------

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    related_entity_type VARCHAR(50), -- donation, organization, etc.
    related_entity_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Notification Templates
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_key VARCHAR(100) NOT NULL UNIQUE,
    title_template TEXT NOT NULL,
    message_template TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Messages/Communication
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- REPORTING AND ANALYTICS TABLES
-- -----------------------------------------------

-- Donation Statistics (materialized view or table for faster queries)
CREATE TABLE donation_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
    day DATE NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    total_donations INTEGER NOT NULL DEFAULT 0,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    unique_donors INTEGER NOT NULL DEFAULT 0,
    new_donors INTEGER NOT NULL DEFAULT 0,
    recurring_donations INTEGER NOT NULL DEFAULT 0,
    avg_donation_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User Activity Logs
CREATE TABLE user_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    device_info JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- RATINGS AND REVIEWS TABLES
-- -----------------------------------------------

-- Organization Ratings and Reviews
CREATE TABLE organization_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organization_profiles(user_id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES donor_profiles(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    review TEXT,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- -----------------------------------------------

-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_user_type ON users(user_type);

-- Verification indexes
CREATE INDEX idx_user_verifications_user_id ON user_verifications(user_id);
CREATE INDEX idx_user_verifications_cnic ON user_verifications(cnic);

-- Organization indexes
CREATE INDEX idx_organization_profiles_name ON organization_profiles(organization_name);
CREATE INDEX idx_organization_profiles_status ON organization_profiles(verification_status);
CREATE INDEX idx_organization_verification_status ON organization_verifications(verification_status);
CREATE INDEX idx_organization_location ON organization_profiles(latitude, longitude);

-- Donation indexes
CREATE INDEX idx_donations_donor_id ON donations(donor_id);
CREATE INDEX idx_donations_organization_id ON donations(organization_id);
CREATE INDEX idx_donations_campaign_id ON donations(campaign_id);
CREATE INDEX idx_donations_status ON donations(status);
CREATE INDEX idx_donations_created_at ON donations(created_at);

-- Campaign indexes
CREATE INDEX idx_campaigns_organization_id ON campaigns(organization_id);
CREATE INDEX idx_campaigns_is_active ON campaigns(is_active);
CREATE INDEX idx_campaigns_dates ON campaigns(start_date, end_date);

-- Statistics indexes
CREATE INDEX idx_donation_statistics_org_id ON donation_statistics(organization_id);
CREATE INDEX idx_donation_statistics_dates ON donation_statistics(year, month, day);

-- -----------------------------------------------
-- INITIAL DATA SEEDING
-- -----------------------------------------------

-- Insert default admin user
INSERT INTO users (
    id, email, password_hash, phone, full_name, user_type, is_verified, is_active
) VALUES (
    uuid_generate_v4(), 
    'admin@donationplatform.com', 
    '$2a$12$1InE4dLsYiZ3YwfBpNuTPeusSYH563.Epw5xQaYVpyUUbFUwCvoVG', -- hashed 'admin123'
    '+123456789',
    'System Administrator',
    'admin',
    TRUE,
    TRUE
);

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('admin', 'Full system access'),
('org_admin', 'Organization administrator'),
('org_staff', 'Organization staff member'),
('donor', 'Donor role');

-- Insert default permissions
INSERT INTO permissions (name, description) VALUES
('manage_users', 'Create, update, and delete users'),
('approve_organizations', 'Approve organization verification'),
('manage_donations', 'Manage donation records'),
('view_reports', 'View system reports and analytics'),
('manage_campaigns', 'Create and manage donation campaigns'),
('send_updates', 'Send updates about donations');

-- Assign permissions to roles
-- Admin role
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
    (SELECT id FROM roles WHERE name = 'admin'),
    id
FROM permissions;

-- Org admin role
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
    (SELECT id FROM roles WHERE name = 'org_admin'),
    id
FROM permissions 
WHERE name IN ('manage_campaigns', 'send_updates', 'view_reports');

-- Donor role
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
    (SELECT id FROM roles WHERE name = 'donor'),
    id
FROM permissions 
WHERE name IN ('view_reports');

-- Insert default categories
INSERT INTO categories (name, description) VALUES
('Education', 'Educational programs and institutions'),
('Healthcare', 'Medical services and health initiatives'),
('Poverty Alleviation', 'Programs aimed at reducing poverty'),
('Disaster Relief', 'Emergency aid for disaster-affected regions'),
('Environment', 'Environmental conservation and sustainability'),
('Animal Welfare', 'Protection and care for animals'),
('Arts & Culture', 'Supporting arts, heritage and cultural initiatives'),
('Children & Youth', 'Programs focused on children and youth development'),
('Elderly Care', 'Services and support for the elderly'),
('Disability Support', 'Assistance for people with disabilities');

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('platform_fees', '{"percentage": 2.5, "fixed_amount": 0.30, "currency": "USD"}', 'Platform transaction fees'),
('donation_minimums', '{"one_time": 5, "recurring": 10, "currency": "USD"}', 'Minimum donation amounts'),
('verification_requirements', '{"documents": ["registration_certificate", "tax_certificate"], "mandatory": true}', 'Required verification documents'),
('notification_settings', '{"email": true, "sms": true, "push": true}', 'Default notification settings');

-- -----------------------------------------------
-- VIEWS FOR COMMON QUERIES
-- -----------------------------------------------

-- Organization View (with verification status and categories)
CREATE VIEW vw_organizations AS
SELECT 
    o.user_id,
    u.email,
    u.phone,
    o.organization_name,
    o.description,
    o.verification_status,
    o.address,
    o.city,
    o.state,
    o.country,
    o.latitude,
    o.longitude,
    o.logo_url,
    o.website_url,
    o.contact_email,
    o.contact_phone,
    ARRAY_AGG(c.name) AS categories,
    COUNT(DISTINCT d.id) AS total_donations,
    COALESCE(SUM(d.amount), 0) AS total_donation_amount,
    o.created_at,
    o.updated_at
FROM 
    organization_profiles o
JOIN 
    users u ON o.user_id = u.id
LEFT JOIN 
    organization_categories oc ON o.user_id = oc.organization_id
LEFT JOIN 
    categories c ON oc.category_id = c.id
LEFT JOIN 
    donations d ON o.user_id = d.organization_id AND d.status = 'completed'
WHERE 
    u.is_active = TRUE
GROUP BY 
    o.user_id, u.email, u.phone, o.organization_name, o.description, o.verification_status,
    o.address, o.city, o.state, o.country, o.latitude, o.longitude, o.logo_url,
    o.website_url, o.contact_email, o.contact_phone, o.created_at, o.updated_at;

-- Donor Activity View
CREATE VIEW vw_donor_activity AS
SELECT 
    d.user_id AS donor_id,
    u.full_name AS donor_name,
    COUNT(DISTINCT dn.id) AS total_donations,
    COALESCE(SUM(dn.amount), 0) AS total_amount_donated,
    COUNT(DISTINCT dn.organization_id) AS organizations_supported,
    MAX(dn.created_at) AS last_donation_date,
    CASE 
        WHEN MAX(dn.created_at) > NOW() - INTERVAL '90 days' THEN 'active'
        WHEN MAX(dn.created_at) > NOW() - INTERVAL '180 days' THEN 'semi-active'
        ELSE 'inactive'
    END AS activity_status,
    COUNT(DISTINCT CASE WHEN dn.is_recurring THEN dn.id END) AS recurring_donations_count
FROM 
    donor_profiles d
JOIN 
    users u ON d.user_id = u.id
LEFT JOIN 
    donations dn ON d.user_id = dn.donor_id AND dn.status = 'completed'
GROUP BY 
    d.user_id, u.full_name;
---------------------------------------
-- TRIGGERS AND FUNCTIONS
-- -----------------------------------------------

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create update timestamp triggers for tables with updated_at column
DO 
$$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
        AND table_name IN (
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_type = 'BASE TABLE' 
            AND table_schema = 'public'
        )
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_timestamp
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_timestamp();
        ', t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to update donation statistics after a donation is created/updated
CREATE OR REPLACE FUNCTION update_donation_statistics()
RETURNS TRIGGER AS $$
DECLARE
    donation_day DATE;
    donation_month INT;
    donation_year INT;
BEGIN
    -- Extract date parts
    donation_day := DATE(NEW.created_at);
    donation_month := EXTRACT(MONTH FROM NEW.created_at);
    donation_year := EXTRACT(YEAR FROM NEW.created_at);
    
    -- If this is a new donation or status changed to completed
    IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.status != 'completed' AND NEW.status = 'completed')) THEN
        -- Check if statistics record exists
        IF EXISTS (
            SELECT 1 FROM donation_statistics 
            WHERE organization_id = NEW.organization_id 
            AND day = donation_day
            AND campaign_id = NEW.campaign_id
        ) THEN
            -- Update existing statistics
            UPDATE donation_statistics
            SET 
                total_donations = total_donations + 1,
                total_amount = total_amount + NEW.amount,
                unique_donors = (
                    SELECT COUNT(DISTINCT donor_id) 
                    FROM donations 
                    WHERE organization_id = NEW.organization_id 
                    AND campaign_id = NEW.campaign_id
                    AND DATE(created_at) = donation_day
                    AND status = 'completed'
                ),
                recurring_donations = recurring_donations + CASE WHEN NEW.is_recurring THEN 1 ELSE 0 END,
                avg_donation_amount = (
                    SELECT AVG(amount) 
                    FROM donations 
                    WHERE organization_id = NEW.organization_id 
                    AND campaign_id = NEW.campaign_id
                    AND DATE(created_at) = donation_day
                    AND status = 'completed'
                ),
                updated_at = CURRENT_TIMESTAMP
            WHERE 
                organization_id = NEW.organization_id 
                AND day = donation_day
                AND campaign_id = NEW.campaign_id;
        ELSE
            -- Create new statistics record
            INSERT INTO donation_statistics (
                organization_id, campaign_id, day, month, year, 
                total_donations, total_amount, currency, unique_donors,
                new_donors, recurring_donations, avg_donation_amount
            )
            VALUES (
                NEW.organization_id, NEW.campaign_id, donation_day, donation_month, donation_year,
                1, NEW.amount, NEW.currency, 1,
                CASE WHEN NOT EXISTS (
                    SELECT 1 FROM donations 
                    WHERE donor_id = NEW.donor_id 
                    AND organization_id = NEW.organization_id
                    AND id != NEW.id
                    AND status = 'completed'
                ) THEN 1 ELSE 0 END,
                CASE WHEN NEW.is_recurring THEN 1 ELSE 0 END,
                NEW.amount
            );
        END IF;
        
        -- If campaign exists, update the campaign raised amount
        IF NEW.campaign_id IS NOT NULL THEN
            UPDATE campaigns
            SET 
                raised_amount = (
                    SELECT COALESCE(SUM(amount), 0)
                    FROM donations
                    WHERE campaign_id = NEW.campaign_id
                    AND status = 'completed'
                ),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.campaign_id;
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for donation statistics
CREATE TRIGGER update_donation_stats
AFTER INSERT OR UPDATE OF status ON donations
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION update_donation_statistics();

-- Function to create notification when donation status changes
CREATE OR REPLACE FUNCTION create_donation_notification()
RETURNS TRIGGER AS $$
DECLARE
    donor_user_id UUID;
    org_user_id UUID;
    template_title TEXT;
    template_message TEXT;
BEGIN
    -- Get donor user ID
    SELECT user_id INTO donor_user_id FROM donor_profiles WHERE user_id = NEW.donor_id;
    
    -- Get organization user ID
    SELECT user_id INTO org_user_id FROM organization_profiles WHERE user_id = NEW.organization_id;
    
    -- Create notification for donor
    IF OLD.status != NEW.status THEN
        -- Get appropriate message template
        SELECT 
            REPLACE(title_template, '{status}', NEW.status),
            REPLACE(message_template, '{status}', NEW.status)
        INTO 
            template_title, template_message
        FROM notification_templates
        WHERE template_key = 'donation_status_change'
        LIMIT 1;
        
        -- Insert notification for donor
        INSERT INTO notifications (
            user_id, title, message, notification_type, 
            related_entity_type, related_entity_id
        )
        VALUES (
            donor_user_id,
            COALESCE(template_title, 'Donation Status Updated'),
            COALESCE(template_message, 'Your donation status has been updated to ' || NEW.status),
            'donation_status',
            'donation',
            NEW.id
        );
        
        -- Insert notification for organization
        IF NEW.status IN ('pending', 'completed') THEN
            INSERT INTO notifications (
                user_id, title, message, notification_type, 
                related_entity_type, related_entity_id
            )
            VALUES (
                org_user_id,
                CASE 
                    WHEN NEW.status = 'pending' THEN 'New Donation Received'
                    WHEN NEW.status = 'completed' THEN 'Donation Completed'
                    ELSE 'Donation Status Updated'
                END,
                CASE 
                    WHEN NEW.status = 'pending' THEN 'You have received a new donation of ' || NEW.amount || ' ' || NEW.currency
                    WHEN NEW.status = 'completed' THEN 'A donation of ' || NEW.amount || ' ' || NEW.currency || ' has been completed'
                    ELSE 'Donation status has been updated to ' || NEW.status
                END,
                'donation_status',
                'donation',
                NEW.id
            );
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for donation notifications
CREATE TRIGGER donation_notification_trigger
AFTER UPDATE OF status ON donations
FOR EACH ROW
EXECUTE FUNCTION create_donation_notification();

-- Function to auto-approve organization if all documents are verified
CREATE OR REPLACE FUNCTION check_organization_verification_complete()
RETURNS TRIGGER AS $$
BEGIN
    -- If all required fields are verified, automatically approve the organization
    IF
        NEW.registration_certificate_url IS NOT NULL AND
        NEW.tax_certificate_url IS NOT NULL AND
        NEW.bank_statement_url IS NOT NULL AND
        NEW.board_resolution_url IS NOT NULL AND
        NEW.board_members IS NOT NULL AND
        NEW.is_bank_verified = TRUE AND
        NEW.verification_status = 'in_review'
    THEN
        -- Update verification status
        NEW.verification_status := 'approved';
        NEW.verification_stage := 'completed';
        NEW.verified_at := CURRENT_TIMESTAMP;
        
        -- Also update the organization profile status
        UPDATE organization_profiles
        SET 
            verification_status = 'approved',
            updated_at = CURRENT_TIMESTAMP
        WHERE 
            user_id = NEW.organization_id;
            
        -- Create notification for organization
        INSERT INTO notifications (
            user_id, title, message, notification_type, 
            related_entity_type, related_entity_id
        )
        VALUES (
            NEW.organization_id,
            'Organization Verified',
            'Congratulations! Your organization has been verified and approved.',
            'organization_verification',
            'organization',
            NEW.organization_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for organization verification auto-approval
CREATE TRIGGER organization_verification_trigger
BEFORE UPDATE ON organization_verifications
FOR EACH ROW
EXECUTE FUNCTION check_organization_verification_complete();

-- -----------------------------------------------
-- STORED PROCEDURES
-- -----------------------------------------------

-- Procedure to find nearby organizations
CREATE OR REPLACE FUNCTION find_nearby_organizations(
    lat DECIMAL,
    lng DECIMAL,
    radius_km DECIMAL DEFAULT 10,
    category_ids UUID[] DEFAULT NULL,
    verification_status VARCHAR DEFAULT 'approved'
)
RETURNS TABLE (
    organization_id UUID,
    organization_name VARCHAR,
    distance_km DECIMAL(10, 2),
    address TEXT,
    city VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    logo_url VARCHAR,
    categories TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.user_id,
        o.organization_name,
        (
            6371 * acos(
                cos(radians(lat)) * 
                cos(radians(o.latitude)) * 
                cos(radians(o.longitude) - radians(lng)) + 
                sin(radians(lat)) * 
                sin(radians(o.latitude))
            )
        ) AS distance_km,
        o.address,
        o.city,
        o.latitude,
        o.longitude,
        o.logo_url,
        ARRAY_AGG(c.name) AS categories
    FROM 
        organization_profiles o
    JOIN 
        users u ON o.user_id = u.id
    LEFT JOIN 
        organization_categories oc ON o.user_id = oc.organization_id
    LEFT JOIN 
        categories c ON oc.category_id = c.id
    WHERE 
        o.verification_status = verification_status
        AND u.is_active = TRUE
        AND o.latitude IS NOT NULL
        AND o.longitude IS NOT NULL
        AND (
            category_ids IS NULL 
            OR EXISTS (
                SELECT 1 FROM organization_categories 
                WHERE organization_id = o.user_id 
                AND category_id = ANY(category_ids)
            )
        )
    GROUP BY 
        o.user_id, o.organization_name, o.address, o.city, 
        o.latitude, o.longitude, o.logo_url
    HAVING 
        (
            6371 * acos(
                cos(radians(lat)) * 
                cos(radians(o.latitude)) * 
                cos(radians(o.longitude) - radians(lng)) + 
                sin(radians(lat)) * 
                sin(radians(o.latitude))
            )
        ) <= radius_km
    ORDER BY 
        distance_km;
END;
$$ LANGUAGE plpgsql;

-- Procedure to generate donation summary for a specific period
CREATE OR REPLACE FUNCTION generate_donation_summary(
    org_id UUID,
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    period VARCHAR,
    total_donations BIGINT,
    total_amount DECIMAL(12, 2),
    unique_donors BIGINT,
    new_donors BIGINT,
    recurring_donations BIGINT,
    avg_donation_amount DECIMAL(12, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR(ds.day, 'YYYY-MM-DD') AS period,
        SUM(ds.total_donations)::BIGINT AS total_donations,
        SUM(ds.total_amount) AS total_amount,
        SUM(ds.unique_donors)::BIGINT AS unique_donors,
        SUM(ds.new_donors)::BIGINT AS new_donors,
        SUM(ds.recurring_donations)::BIGINT AS recurring_donations,
        CASE 
            WHEN SUM(ds.total_donations) > 0 
            THEN SUM(ds.total_amount) / SUM(ds.total_donations)
            ELSE 0
        END AS avg_donation_amount
    FROM 
        donation_statistics ds
    WHERE 
        ds.organization_id = org_id
        AND ds.day BETWEEN start_date AND end_date
    GROUP BY 
        ds.day
    ORDER BY 
        ds.day;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------
-- DATABASE MANAGEMENT & SECURITY
-- -----------------------------------------------

-- Create a read-only user for reporting
CREATE ROLE donation_platform_reporting WITH LOGIN PASSWORD 'secure_password_here';

-- Grant select permissions to the reporting user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO donation_platform_reporting;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO donation_platform_reporting;

-- Create a separate schema for audit logs
CREATE SCHEMA audit;

-- Create audit trail table
CREATE TABLE audit.data_changes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id VARCHAR(100) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by UUID,
    ip_address VARCHAR(45),
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Function to record data changes
CREATE OR REPLACE FUNCTION audit.log_data_change()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB := NULL;
    new_data JSONB := NULL;
    record_id VARCHAR;
    current_user_id UUID;
BEGIN
    -- Get current user ID from application context (if available)
    current_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
    
    -- Determine record ID
    IF TG_OP = 'DELETE' THEN
        record_id := OLD.id::VARCHAR;
        old_data := row_to_json(OLD)::JSONB;
    ELSIF TG_OP = 'UPDATE' THEN
        record_id := NEW.id::VARCHAR;
        old_data := row_to_json(OLD)::JSONB;
        new_data := row_to_json(NEW)::JSONB;
    ELSE -- INSERT
        record_id := NEW.id::VARCHAR;
        new_data := row_to_json(NEW)::JSONB;
    END IF;
    
    -- Insert into audit table
    INSERT INTO audit.data_changes (
        table_name, operation, record_id, old_data, new_data, 
        changed_by, ip_address
    )
    VALUES (
        TG_TABLE_NAME, TG_OP, record_id, old_data, new_data,
        current_user_id, NULLIF(current_setting('app.client_ip', TRUE), '')
    );
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create audit triggers for sensitive tables
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit.log_data_change();

CREATE TRIGGER audit_donations
AFTER INSERT OR UPDATE OR DELETE ON donations
FOR EACH ROW EXECUTE FUNCTION audit.log_data_change();

CREATE TRIGGER audit_organization_verifications
AFTER INSERT OR UPDATE OR DELETE ON organization_verifications
FOR EACH ROW EXECUTE FUNCTION audit.log_data_change();

-- Ensure the reporting user can read audit logs
GRANT USAGE ON SCHEMA audit TO donation_platform_reporting;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO donation_platform_reporting;

-- -----------------------------------------------
-- JWT AUTHENTICATION SUPPORT
-- -----------------------------------------------

-- JWT Blacklist table for logging out/invalidating tokens
CREATE TABLE jwt_blacklist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    token_jti VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster JWT validation
CREATE INDEX idx_jwt_blacklist_token_jti ON jwt_blacklist(token_jti);
CREATE INDEX idx_jwt_blacklist_expiry ON jwt_blacklist(expiry_date);

-- Create function to clean up expired JWT tokens
CREATE OR REPLACE FUNCTION cleanup_expired_jwt()
RETURNS VOID AS $$
BEGIN
    DELETE FROM jwt_blacklist
    WHERE expiry_date < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Create a scheduled job to clean up expired tokens (depends on pg_cron extension)
-- Uncomment if pg_cron extension is available
-- SELECT cron.schedule('0 0 * * *', 'SELECT cleanup_expired_jwt()');

-- -----------------------------------------------
-- API KEY MANAGEMENT FOR INTEGRATIONS
-- -----------------------------------------------

CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key_name VARCHAR(100) NOT NULL,
    api_key VARCHAR(255) NOT NULL UNIQUE,
    scopes JSONB NOT NULL, -- Array of allowed scopes for this key
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at TIMESTAMP,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create index for API key validation
CREATE INDEX idx_api_keys_key ON api_keys(api_key);
CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);

-- -----------------------------------------------
-- MATERIALIZED VIEWS FOR DASHBOARD PERFORMANCE
-- -----------------------------------------------

-- Organization Dashboard Stats
CREATE MATERIALIZED VIEW mv_organization_stats AS
SELECT 
    o.user_id AS organization_id,
    o.organization_name,
    COALESCE(COUNT(DISTINCT d.id), 0) AS total_donations,
    COALESCE(SUM(d.amount), 0) AS total_donation_amount,
    COALESCE(COUNT(DISTINCT d.donor_id), 0) AS unique_donors,
    COALESCE(COUNT(DISTINCT CASE WHEN d.is_recurring THEN d.id END), 0) AS recurring_donations,
    COALESCE(COUNT(DISTINCT c.id), 0) AS active_campaigns,
    COALESCE(AVG(r.rating), 0) AS average_rating,
    COALESCE(COUNT(DISTINCT r.id), 0) AS review_count,
    COALESCE(SUM(CASE WHEN d.created_at > NOW() - INTERVAL '30 days' THEN d.amount ELSE 0 END), 0) AS last_30_days_amount,
    COALESCE(COUNT(DISTINCT CASE WHEN d.created_at > NOW() - INTERVAL '30 days' THEN d.id END), 0) AS last_30_days_donations
FROM 
    organization_profiles o
LEFT JOIN 
    donations d ON o.user_id = d.organization_id AND d.status = 'completed'
LEFT JOIN 
    campaigns c ON o.user_id = c.organization_id AND c.is_active = TRUE
LEFT JOIN 
    organization_reviews r ON o.user_id = r.organization_id AND r.is_approved = TRUE
GROUP BY 
    o.user_id, o.organization_name;

-- Create index on materialized view
CREATE UNIQUE INDEX idx_mv_organization_stats_id ON mv_organization_stats(organization_id);

-- Create function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_organization_stats()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_organization_stats;
END;
$$ LANGUAGE plpgsql;

-- Admin Dashboard Stats
CREATE MATERIALIZED VIEW mv_admin_dashboard_stats AS
SELECT
    -- Platform summary
    (SELECT COUNT(*) FROM users WHERE is_active = TRUE) AS total_active_users,
    (SELECT COUNT(*) FROM users WHERE user_type = 'donor' AND is_active = TRUE) AS total_donors,
    (SELECT COUNT(*) FROM organization_profiles WHERE verification_status = 'approved') AS approved_organizations,
    (SELECT COUNT(*) FROM organization_profiles WHERE verification_status = 'pending') AS pending_organizations,
    (SELECT COUNT(*) FROM campaigns WHERE is_active = TRUE) AS active_campaigns,
    
    -- Donation statistics
    (SELECT COUNT(*) FROM donations WHERE status = 'completed') AS total_donations,
    (SELECT COALESCE(SUM(amount), 0) FROM donations WHERE status = 'completed') AS total_donation_amount,
    (SELECT COALESCE(COUNT(*), 0) FROM donations WHERE status = 'completed' AND created_at > NOW() - INTERVAL '30 days') AS donations_last_30_days,
    (SELECT COALESCE(SUM(amount), 0) FROM donations WHERE status = 'completed' AND created_at > NOW() - INTERVAL '30 days') AS donation_amount_last_30_days,
    
    -- New registrations
    (SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '30 days') AS new_users_last_30_days,
    (SELECT COUNT(*) FROM organization_profiles WHERE created_at > NOW() - INTERVAL '30 days') AS new_organizations_last_30_days,
    
    -- Most active categories
    (
        SELECT COALESCE(json_agg(cat), '[]'::json)
        FROM (
            SELECT 
                c.name,
                COUNT(d.id) AS donation_count,
                SUM(d.amount) AS donation_amount
            FROM 
                categories c
            JOIN 
                campaigns camp ON c.id = camp.category_id
            JOIN 
                donations d ON camp.id = d.campaign_id AND d.status = 'completed'
            GROUP BY 
                c.name
            ORDER BY 
                donation_amount DESC
            LIMIT 5
        ) cat
    ) AS top_categories,
    
    -- Updated timestamp
    NOW() AS last_updated;

-- Create function to refresh admin stats
CREATE OR REPLACE FUNCTION refresh_admin_dashboard_stats()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_admin_dashboard_stats;
END;
$$ LANGUAGE plpgsql;