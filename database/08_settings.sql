-- ==========================================================
-- AttachFlow Database
-- Module 07 - Settings
-- ==========================================================

USE attachflow;

-- ==========================================================
-- USER SETTINGS
-- Stores all user-configurable application preferences.
-- ==========================================================

CREATE TABLE user_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    theme ENUM(
        'Dark',
        'Light',
        'System'
    ) DEFAULT 'Dark',

    accent_color VARCHAR(30) DEFAULT 'Purple',

    landing_page ENUM(
        'Dashboard',
        'Daily Logs',
        'Projects',
        'Milestones',
        'Skills',
        'Reports',
        'Analytics'
    ) DEFAULT 'Dashboard',

    date_format ENUM(
        'DD/MM/YYYY',
        'MM/DD/YYYY',
        'YYYY-MM-DD'
    ) DEFAULT 'DD/MM/YYYY',

    timezone VARCHAR(100) DEFAULT 'UTC',

    language VARCHAR(50) DEFAULT 'English',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_settings_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_settings_user (user_id)

) ENGINE=InnoDB;

-- ==========================================================
-- NOTIFICATION SETTINGS
-- ==========================================================

CREATE TABLE notification_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    email_notifications BOOLEAN DEFAULT TRUE,

    browser_notifications BOOLEAN DEFAULT TRUE,

    reminder_notifications BOOLEAN DEFAULT TRUE,

    milestone_notifications BOOLEAN DEFAULT TRUE,

    report_notifications BOOLEAN DEFAULT TRUE,

    achievement_notifications BOOLEAN DEFAULT TRUE,

    security_notifications BOOLEAN DEFAULT TRUE,

    weekly_summary BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_notification_user (user_id)

) ENGINE=InnoDB;

-- ==========================================================
-- USER NOTIFICATIONS
-- ==========================================================

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    title VARCHAR(255) NOT NULL,

    message TEXT NOT NULL,

    notification_type ENUM(
        'Reminder',
        'Milestone',
        'Project',
        'Report',
        'Achievement',
        'System',
        'Security'
    ) NOT NULL,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    read_at DATETIME NULL,

    CONSTRAINT fk_notificationrecipient_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    INDEX idx_notification_user (user_id),
    INDEX idx_notification_read (is_read)

) ENGINE=InnoDB;

-- ==========================================================
-- USER DASHBOARD PREFERENCES
-- ==========================================================

CREATE TABLE dashboard_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    show_summary_cards BOOLEAN DEFAULT TRUE,

    show_recent_logs BOOLEAN DEFAULT TRUE,

    show_upcoming_milestones BOOLEAN DEFAULT TRUE,

    show_weekly_hours_chart BOOLEAN DEFAULT TRUE,

    show_activity_heatmap BOOLEAN DEFAULT TRUE,

    show_attachment_journey BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_dashboardpref_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_dashboardpref_user (user_id)

) ENGINE=InnoDB;

-- ==========================================================
-- USER HEALTH CHECK
-- Stores results from AttachFlow Health Check.
-- ==========================================================

CREATE TABLE health_check_history (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    overall_score DECIMAL(5,2),

    missing_profile BOOLEAN DEFAULT FALSE,

    missing_attachment BOOLEAN DEFAULT FALSE,

    incomplete_daily_logs BOOLEAN DEFAULT FALSE,

    overdue_milestones BOOLEAN DEFAULT FALSE,

    inactive_projects BOOLEAN DEFAULT FALSE,

    missing_reports BOOLEAN DEFAULT FALSE,

    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_health_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    INDEX idx_health_user (user_id)

) ENGINE=InnoDB;

-- ==========================================================
-- APPLICATION AUDIT LOG
-- Tracks important account actions.
-- ==========================================================

CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    action VARCHAR(255) NOT NULL,

    description TEXT,

    ip_address VARCHAR(45),

    user_agent TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    INDEX idx_audit_user (user_id),
    INDEX idx_audit_action (action)

) ENGINE=InnoDB;
