-- ==========================================================
-- AttachFlow Database
-- Module 09 - Indexes, Views & Seed Preparation
-- ==========================================================

USE attachflow_db;

-- ==========================================================
-- ADDITIONAL INDEXES
-- ==========================================================

-- Daily log status filtering
CREATE INDEX idx_dailylog_status
    ON daily_logs (status);

-- Project favourite filtering
CREATE INDEX idx_project_favourite
    ON projects (is_favourite);

-- Milestone priority filtering
CREATE INDEX idx_milestone_priority
    ON milestones (priority);

-- Skill learning status filtering
CREATE INDEX idx_skill_learning_status
    ON skills (learning_status);

-- ==========================================================
-- ACTIVE PROJECTS VIEW
-- Returns non-deleted projects that are not completed.
-- ==========================================================

CREATE VIEW active_projects AS
SELECT
    id,
    attachment_id,
    title,
    progress_percentage,
    status,
    priority,
    health_status,
    start_date,
    target_end_date
FROM projects
WHERE deleted_at IS NULL
  AND status <> 'Completed';

-- ==========================================================
-- PENDING MILESTONES VIEW
-- Returns non-deleted milestones that are not completed.
-- ==========================================================

CREATE VIEW pending_milestones AS
SELECT
    id,
    project_id,
    title,
    due_date,
    status,
    priority,
    progress_percentage
FROM milestones
WHERE deleted_at IS NULL
  AND status <> 'Completed';

-- ==========================================================
-- RECENT DAILY LOGS VIEW
-- Returns non-deleted daily logs ordered by work date.
-- ==========================================================

CREATE VIEW recent_daily_logs AS
SELECT
    id,
    attachment_id,
    work_date,
    start_time,
    end_time,
    total_hours,
    title,
    status
FROM daily_logs
WHERE deleted_at IS NULL
ORDER BY work_date DESC, start_time DESC;

-- ==========================================================
-- FUTURE SEED DATA
-- ==========================================================

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