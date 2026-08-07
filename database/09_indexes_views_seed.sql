-- ============================================
-- AttachFlow Database
-- Module: Indexes, Views & Seed Preparation
-- File: 09_indexes_views_seed.sql
-- ============================================

USE attachflow_db;

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_users_email
ON users(email);

CREATE INDEX idx_daily_logs_date
ON daily_logs(log_date);

CREATE INDEX idx_daily_logs_user
ON daily_logs(user_id);

CREATE INDEX idx_projects_status
ON projects(status);

CREATE INDEX idx_projects_user
ON projects(user_id);

CREATE INDEX idx_milestones_due_date
ON milestones(due_date);

CREATE INDEX idx_skills_user
ON skills(user_id);

CREATE INDEX idx_notifications_user
ON notifications(user_id);

-- ============================================
-- VIEWS
-- ============================================

CREATE VIEW active_projects AS
SELECT
    id,
    user_id,
    title,
    progress_percentage,
    status
FROM projects
WHERE deleted_at IS NULL
  AND status <> 'Completed';

CREATE VIEW pending_milestones AS
SELECT
    id,
    project_id,
    title,
    due_date,
    status
FROM milestones
WHERE deleted_at IS NULL
  AND status <> 'Completed';

CREATE VIEW recent_daily_logs AS
SELECT
    id,
    user_id,
    log_date,
    total_hours,
    submitted
FROM daily_logs
ORDER BY log_date DESC;

-- ============================================
-- FUTURE SEED DATA
-- ============================================

/*
Seed data will be added after development of Version 1.

Examples:

- Default notification preferences
- Demo organization
- Demo department
- Demo administrator
- Sample skills
- Sample reports
- Application settings

Actual INSERT statements will live in:

database/seed.sql
*/