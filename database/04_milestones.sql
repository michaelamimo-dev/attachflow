-- ==========================================================
-- AttachFlow Database
-- Module 04 - Milestones
-- ==========================================================

USE attachflow;

-- ==========================================================
-- MILESTONES
-- ==========================================================

CREATE TABLE milestones (
    id INT AUTO_INCREMENT PRIMARY KEY,

    project_id INT NOT NULL,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    status ENUM(
        'Not Started',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Not Started',

    priority ENUM(
        'Low',
        'Medium',
        'High'
    ) DEFAULT 'Medium',

    progress_percentage TINYINT UNSIGNED DEFAULT 0,

    due_date DATE,
    completed_at DATETIME NULL,

    reminder_enabled BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_milestone_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,

    INDEX idx_milestone_project (project_id),
    INDEX idx_milestone_status (status),
    INDEX idx_milestone_due (due_date)
) ENGINE=InnoDB;

-- ==========================================================
-- MILESTONE ATTACHMENTS
-- ==========================================================

CREATE TABLE milestone_attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,

    milestone_id INT NOT NULL,

    file_name VARCHAR(255) NOT NULL,
    original_file_name VARCHAR(255),

    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,

    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_milestoneattachment_milestone
        FOREIGN KEY (milestone_id)
        REFERENCES milestones(id)
        ON DELETE CASCADE,

    INDEX idx_milestoneattachment_milestone (milestone_id)
) ENGINE=InnoDB;

-- ==========================================================
-- MILESTONE DAILY LOGS
-- Allows milestones to be linked to the
-- daily logs where work was performed.
-- ==========================================================

CREATE TABLE milestone_daily_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    milestone_id INT NOT NULL,
    daily_log_id INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_milestonelog_milestone
        FOREIGN KEY (milestone_id)
        REFERENCES milestones(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_milestonelog_dailylog
        FOREIGN KEY (daily_log_id)
        REFERENCES daily_logs(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_milestone_dailylog (
        milestone_id,
        daily_log_id
    ),

    INDEX idx_milestonelog_milestone (milestone_id),
    INDEX idx_milestonelog_dailylog (daily_log_id)
) ENGINE=InnoDB;

-- ==========================================================
-- MILESTONE REMINDERS
-- Future-proof table for reminder scheduling.
-- ==========================================================

CREATE TABLE milestone_reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,

    milestone_id INT NOT NULL,

    reminder_datetime DATETIME NOT NULL,

    reminder_type ENUM(
        'Email',
        'In-App'
    ) DEFAULT 'In-App',

    is_sent BOOLEAN DEFAULT FALSE,

    sent_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reminder_milestone
        FOREIGN KEY (milestone_id)
        REFERENCES milestones(id)
        ON DELETE CASCADE,

    INDEX idx_reminder_datetime (reminder_datetime),
    INDEX idx_reminder_sent (is_sent)
) ENGINE=InnoDB;
