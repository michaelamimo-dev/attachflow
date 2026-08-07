-- ==========================================================
-- AttachFlow Database
-- Module 01 - Authentication
-- ==========================================================

CREATE DATABASE IF NOT EXISTS attachflow
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE attachflow;

-- ==========================================================
-- UNIVERSITIES
-- ==========================================================

CREATE TABLE universities (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(50),
    country VARCHAR(100),
    website VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    UNIQUE KEY uk_university_name (name)
) ENGINE=InnoDB;

-- ==========================================================
-- ORGANIZATIONS
-- ==========================================================

CREATE TABLE organizations (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(150),
    country VARCHAR(150),
    website VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(50),
    logo_path VARCHAR(500),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    UNIQUE KEY uk_organization_name (name)
) ENGINE=InnoDB;

-- ==========================================================
-- DEPARTMENTS
-- ==========================================================

CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,

    organization_id INT NOT NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_department_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_department (organization_id, name),

    INDEX idx_department_org (organization_id)
) ENGINE=InnoDB;

-- ==========================================================
-- SUPERVISORS
-- ==========================================================

CREATE TABLE supervisors (
    id INT AUTO_INCREMENT PRIMARY KEY,

    organization_id INT NOT NULL,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(255),
    phone_number VARCHAR(50),
    position VARCHAR(150),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_supervisor_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_supervisor_email (organization_id, email),

    INDEX idx_supervisor_org (organization_id),
    INDEX idx_supervisor_name (last_name, first_name)
) ENGINE=InnoDB;

-- ==========================================================
-- USERS
-- ==========================================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,

    university_id INT NOT NULL,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    student_registration_number VARCHAR(100) NOT NULL,

    phone_number VARCHAR(30),
    profile_picture VARCHAR(500),

    gender ENUM(
        'Male',
        'Female',
        'Other',
        'Prefer not to say'
    ),

    date_of_birth DATE,

    course VARCHAR(255),
    year_of_study VARCHAR(50),

    role ENUM(
        'Student',
        'Supervisor',
        'Administrator'
    ) NOT NULL DEFAULT 'Student',

    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified_at DATETIME NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_user_university
        FOREIGN KEY (university_id)
        REFERENCES universities(id),

    UNIQUE KEY uk_user_email (email),
    UNIQUE KEY uk_student_reg (student_registration_number),

    INDEX idx_user_university (university_id),
    INDEX idx_user_role (role)
) ENGINE=InnoDB;

-- ==========================================================
-- ATTACHMENTS
-- ==========================================================

CREATE TABLE attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    organization_id INT NOT NULL,
    department_id INT NOT NULL,
    supervisor_id INT NOT NULL,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    status ENUM(
        'Upcoming',
        'Active',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Upcoming',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_attachment_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attachment_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_attachment_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id),

    CONSTRAINT fk_attachment_supervisor
        FOREIGN KEY (supervisor_id)
        REFERENCES supervisors(id),

    INDEX idx_attachment_user (user_id),
    INDEX idx_attachment_org (organization_id),
    INDEX idx_attachment_department (department_id),
    INDEX idx_attachment_supervisor (supervisor_id),
    INDEX idx_attachment_dates (start_date, end_date)
) ENGINE=InnoDB;

-- ==========================================================
-- USER SESSIONS
-- ==========================================================

CREATE TABLE user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    session_token VARCHAR(255) NOT NULL,

    ip_address VARCHAR(45),
    user_agent TEXT,

    remember_me BOOLEAN DEFAULT FALSE,

    last_activity DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_session_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_session_token (session_token),

    INDEX idx_session_user (user_id),
    INDEX idx_session_expiry (expires_at)
) ENGINE=InnoDB;