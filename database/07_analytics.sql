-- ============================================
-- AttachFlow Database
-- Module: Analytics
-- File: 07_analytics.sql
-- ============================================

USE attachflow_db;

-- ============================================
-- USER ANALYTICS SNAPSHOTS
-- ============================================

CREATE TABLE user_analytics (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,

    total_hours DECIMAL(6,2) DEFAULT 0,
    total_daily_logs INT DEFAULT 0,
    total_projects INT DEFAULT 0,
    completed_projects INT DEFAULT 0,
    active_projects INT DEFAULT 0,
    completed_milestones INT DEFAULT 0,
    pending_milestones INT DEFAULT 0,
    total_skills INT DEFAULT 0,

    productivity_score DECIMAL(5,2),
    consistency_score DECIMAL(5,2),

    generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_analytics_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================
-- WEEKLY ANALYTICS
-- ============================================

CREATE TABLE weekly_statistics (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,

    week_start DATE NOT NULL,
    week_end DATE NOT NULL,

    hours_logged DECIMAL(6,2) DEFAULT 0,
    logs_created INT DEFAULT 0,
    milestones_completed INT DEFAULT 0,
    projects_updated INT DEFAULT 0,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_weekly_statistics_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================
-- USER ACHIEVEMENTS
-- ============================================

CREATE TABLE user_achievements (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,

    achievement_name VARCHAR(120) NOT NULL,
    description TEXT,

    icon VARCHAR(100),
    badge_color VARCHAR(30),

    earned_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_achievements_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);