-- ==========================================================
-- AttachFlow Database
-- Module 02 - Daily Logs
-- ==========================================================

USE attachflow_db;

-- ==========================================================
-- DAILY LOGS
-- ==========================================================

CREATE TABLE daily_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    work_date DATE NOT NULL,

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    total_hours DECIMAL(4,2) NOT NULL,

    title VARCHAR(255) NOT NULL,

    description TEXT NOT NULL,

    challenges TEXT,

    solutions TEXT,

    lessons_learned TEXT,

    supervisor_comment TEXT,

    status ENUM(
        'Draft',
        'Submitted',
        'Reviewed',
        'Approved'
    ) DEFAULT 'Draft',

    approved_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_dailylog_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    INDEX idx_dailylog_attachment (attachment_id),

    INDEX idx_dailylog_date (work_date),

    UNIQUE KEY uk_attachment_workdate
        (attachment_id, work_date)

) ENGINE=InnoDB;

-- ==========================================================
-- DAILY LOG ATTACHMENTS
-- ==========================================================

CREATE TABLE daily_log_attachments (

    id INT AUTO_INCREMENT PRIMARY KEY,

    daily_log_id INT NOT NULL,

    file_name VARCHAR(255) NOT NULL,

    original_file_name VARCHAR(255),

    file_path VARCHAR(500) NOT NULL,

    file_type VARCHAR(100),

    file_size BIGINT,

    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_dailylogattachment_log
        FOREIGN KEY (daily_log_id)
        REFERENCES daily_logs(id)
        ON DELETE CASCADE,

    INDEX idx_dailylogattachment_log
        (daily_log_id)

) ENGINE=InnoDB;