-- ============================================
-- AttachFlow Database
-- File: 00_create_database.sql
-- Purpose: Create the AttachFlow database
-- ============================================

-- Create the database if it does not already exist
CREATE DATABASE IF NOT EXISTS attachflow_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE attachflow_db;

-- ============================================
-- Database Information
-- ============================================
SELECT
    DATABASE() AS database_name,
    VERSION() AS mysql_version;