-- ==========================================================
-- AttachFlow Database
-- Module 06 - Reports & Analytics
-- ==========================================================

USE attachflow_db;

-- ==========================================================
-- REPORT DEFINITIONS
-- Saved report templates/layouts.
-- ==========================================================

CREATE TABLE report_definitions (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    name VARCHAR(255) NOT NULL,

    report_type ENUM(
        'Weekly',
        'Monthly',
        'Final',
        'Custom'
    ) DEFAULT 'Weekly',

    theme VARCHAR(100) DEFAULT 'Default',

    logo_path VARCHAR(500),

    configuration JSON,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_reportdefinition_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    INDEX idx_reportdefinition_attachment (attachment_id)
) ENGINE=InnoDB;

-- ==========================================================
-- GENERATED REPORTS
-- ==========================================================

CREATE TABLE generated_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    definition_id INT NULL,

    title VARCHAR(255) NOT NULL,

    report_type ENUM(
        'Weekly',
        'Monthly',
        'Final',
        'Custom'
    ) NOT NULL,

    format ENUM(
        'PDF',
        'DOCX',
        'Web'
    ) NOT NULL,

    file_path VARCHAR(500),

    generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    generated_by INT NOT NULL,

    CONSTRAINT fk_generatedreport_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_generatedreport_definition
        FOREIGN KEY (definition_id)
        REFERENCES report_definitions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_generatedreport_user
        FOREIGN KEY (generated_by)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    INDEX idx_generatedreport_attachment (attachment_id),
    INDEX idx_generatedreport_date (generated_at)
) ENGINE=InnoDB;

-- ==========================================================
-- REPORT SCHEDULES
-- ==========================================================

CREATE TABLE report_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    report_definition_id INT NOT NULL,

    frequency ENUM(
        'Daily',
        'Weekly',
        'Monthly'
    ) NOT NULL,

    next_run DATETIME NOT NULL,

    enabled BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reportschedule_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reportschedule_definition
        FOREIGN KEY (report_definition_id)
        REFERENCES report_definitions(id)
        ON DELETE CASCADE,

    INDEX idx_reportschedule_next_run (next_run)
) ENGINE=InnoDB;

-- ==========================================================
-- USER GOALS
-- ==========================================================

CREATE TABLE user_goals (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    title VARCHAR(255) NOT NULL,

    description TEXT,

    target_value DECIMAL(10,2),

    current_value DECIMAL(10,2) DEFAULT 0,

    goal_type ENUM(
        'Hours',
        'Projects',
        'Milestones',
        'Skills',
        'Custom'
    ) NOT NULL,

    due_date DATE,

    completed BOOLEAN DEFAULT FALSE,

    completed_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_goal_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    INDEX idx_goal_attachment (attachment_id)
) ENGINE=InnoDB;

-- ==========================================================
-- ACHIEVEMENTS
-- ==========================================================

CREATE TABLE achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(150) NOT NULL,

    description TEXT,

    icon VARCHAR(100),

    category VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================================
-- USER ACHIEVEMENTS
-- ==========================================================

CREATE TABLE user_achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    achievement_id INT NOT NULL,

    earned_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_userachievement_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_userachievement_achievement
        FOREIGN KEY (achievement_id)
        REFERENCES achievements(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_attachment_achievement
        (attachment_id, achievement_id)
) ENGINE=InnoDB;

-- ==========================================================
-- ANALYTICS SNAPSHOTS
-- Cached analytics for fast dashboards.
-- ==========================================================

CREATE TABLE analytics_snapshots (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    snapshot_date DATE NOT NULL,

    total_hours DECIMAL(6,2),

    total_logs INT,

    total_projects INT,

    completed_projects INT,

    total_milestones INT,

    completed_milestones INT,

    total_skills INT,

    completed_skills INT,

    productivity_score DECIMAL(5,2),

    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_snapshot_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_snapshot
        (attachment_id, snapshot_date),

    INDEX idx_snapshot_attachment (attachment_id)
) ENGINE=InnoDB;