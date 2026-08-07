-- ==========================================================
-- AttachFlow Database
-- Module 03 - Projects
-- ==========================================================

USE attachflow;

-- ==========================================================
-- PROJECTS
-- ==========================================================

CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    objective TEXT,

    status ENUM(
        'Planning',
        'In Progress',
        'On Hold',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Planning',

    priority ENUM(
        'Low',
        'Medium',
        'High'
    ) DEFAULT 'Medium',

    progress_percentage TINYINT UNSIGNED DEFAULT 0,

    start_date DATE,
    target_end_date DATE,
    completed_at DATETIME NULL,

    cover_image_path VARCHAR(500),

    is_favourite BOOLEAN DEFAULT FALSE,

    health_status ENUM(
        'Excellent',
        'Good',
        'Needs Attention',
        'At Risk'
    ) DEFAULT 'Good',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_project_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    INDEX idx_project_attachment (attachment_id),
    INDEX idx_project_status (status),
    INDEX idx_project_priority (priority),
    INDEX idx_project_health (health_status)
) ENGINE=InnoDB;

-- ==========================================================
-- PROJECT TECHNOLOGIES
-- ==========================================================

CREATE TABLE project_technologies (
    id INT AUTO_INCREMENT PRIMARY KEY,

    project_id INT NOT NULL,

    technology_name VARCHAR(150) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_projecttechnology_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_project_technology
        (project_id, technology_name),

    INDEX idx_projecttechnology_project (project_id)
) ENGINE=InnoDB;

-- ==========================================================
-- PROJECT ATTACHMENTS
-- ==========================================================

CREATE TABLE project_attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,

    project_id INT NOT NULL,

    file_name VARCHAR(255) NOT NULL,
    original_file_name VARCHAR(255),

    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,

    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_projectattachment_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,

    INDEX idx_projectattachment_project (project_id)
) ENGINE=InnoDB;

-- ==========================================================
-- PROJECT DAILY LOGS
-- Allows one project to appear in many daily logs,
-- and one daily log to reference multiple projects.
-- ==========================================================

CREATE TABLE project_daily_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    project_id INT NOT NULL,
    daily_log_id INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_projectlog_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_projectlog_dailylog
        FOREIGN KEY (daily_log_id)
        REFERENCES daily_logs(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_project_dailylog
        (project_id, daily_log_id),

    INDEX idx_projectlog_project (project_id),
    INDEX idx_projectlog_dailylog (daily_log_id)
) ENGINE=InnoDB;