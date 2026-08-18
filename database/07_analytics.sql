-- ==========================================================
-- AttachFlow Database
-- Module 07 - Analytics
-- ==========================================================

USE attachflow_db;

-- ==========================================================
-- WEEKLY STATISTICS
-- Stores aggregated weekly attachment activity.
-- ==========================================================

CREATE TABLE weekly_statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    week_start DATE NOT NULL,
    week_end DATE NOT NULL,

    hours_logged DECIMAL(6,2) DEFAULT 0,

    logs_created INT DEFAULT 0,

    milestones_completed INT DEFAULT 0,

    projects_updated INT DEFAULT 0,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_weekly_statistics_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_weekly_statistics
        (attachment_id, week_start),

    INDEX idx_weekly_statistics_attachment
        (attachment_id),

    INDEX idx_weekly_statistics_week
        (week_start)
) ENGINE=InnoDB;