-- ============================================
-- AttachFlow Database
-- Module: Integrity Constraint Migration
-- File: 10_integrity_constraints.sql
-- ============================================

USE attachflow_db;


-- ============================================
-- 1. DAILY LOG STATUS WORKFLOW
-- ============================================
-- Final Version 1 workflow:
--
-- Draft -> Submitted -> Approved
--                    -> Rejected
--
-- Valid status values are enforced by the database.
-- Actual status transitions remain application-level
-- responsibilities.

ALTER TABLE daily_logs
MODIFY COLUMN status ENUM(
    'Draft',
    'Submitted',
    'Approved',
    'Rejected'
) NOT NULL DEFAULT 'Draft';


-- ============================================
-- 2. ATTACHMENT DATE INTEGRITY
-- ============================================

ALTER TABLE attachments
ADD CONSTRAINT chk_attachment_dates
CHECK (end_date >= start_date);


-- ============================================
-- 3. PROJECT PROGRESS RANGE
-- ============================================

ALTER TABLE projects
ADD CONSTRAINT chk_project_progress
CHECK (progress_percentage BETWEEN 0 AND 100);


-- ============================================
-- 4. PROJECT DATE INTEGRITY
-- ============================================

ALTER TABLE projects
ADD CONSTRAINT chk_project_dates
CHECK (
    target_end_date IS NULL
    OR start_date IS NULL
    OR target_end_date >= start_date
);


-- ============================================
-- 5. MILESTONE PROGRESS RANGE
-- ============================================

ALTER TABLE milestones
ADD CONSTRAINT chk_milestone_progress
CHECK (progress_percentage BETWEEN 0 AND 100);


-- ============================================
-- 6. SKILL DATE INTEGRITY
-- ============================================

ALTER TABLE skills
ADD CONSTRAINT chk_skill_dates
CHECK (
    last_used_date IS NULL
    OR first_used_date IS NULL
    OR last_used_date >= first_used_date
);


-- ============================================
-- 7. ANALYTICS SANITY CHECKS
-- ============================================
-- Analytics snapshots contain derived values.
-- These constraints only protect basic numerical
-- validity. Calculation logic remains application-level.

ALTER TABLE analytics_snapshots
ADD CONSTRAINT chk_snapshot_hours
CHECK (total_hours >= 0),

ADD CONSTRAINT chk_snapshot_logs
CHECK (total_logs >= 0),

ADD CONSTRAINT chk_snapshot_projects
CHECK (total_projects >= 0),

ADD CONSTRAINT chk_snapshot_completed_projects
CHECK (completed_projects >= 0),

ADD CONSTRAINT chk_snapshot_milestones
CHECK (total_milestones >= 0),

ADD CONSTRAINT chk_snapshot_completed_milestones
CHECK (completed_milestones >= 0),

ADD CONSTRAINT chk_snapshot_skills
CHECK (total_skills >= 0),

ADD CONSTRAINT chk_snapshot_completed_skills
CHECK (completed_skills >= 0),

ADD CONSTRAINT chk_snapshot_productivity_score
CHECK (
    productivity_score IS NULL
    OR productivity_score BETWEEN 0 AND 100
);