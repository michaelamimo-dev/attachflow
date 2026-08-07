-- ==========================================================
-- AttachFlow Database
-- Module 05 - Skills
-- ==========================================================

USE attachflow;

-- ==========================================================
-- SKILL CATEGORIES
-- ==========================================================

CREATE TABLE skill_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NULL,

    name VARCHAR(100) NOT NULL,

    icon VARCHAR(100),

    color VARCHAR(20),

    is_default BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_skillcategory_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    INDEX idx_skillcategory_user (user_id),

    UNIQUE KEY uk_user_category
        (user_id, name)
) ENGINE=InnoDB;

-- ==========================================================
-- SKILLS
-- ==========================================================

CREATE TABLE skills (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    category_id INT NOT NULL,

    name VARCHAR(150) NOT NULL,

    proficiency_level ENUM(
        'Beginner',
        'Intermediate',
        'Advanced',
        'Expert'
    ) DEFAULT 'Beginner',

    learning_status ENUM(
        'Currently Learning',
        'Done Learning',
        'Paused'
    ) DEFAULT 'Currently Learning',

    evidence_notes TEXT,

    first_used_date DATE,

    last_used_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_skill_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_skill_category
        FOREIGN KEY (category_id)
        REFERENCES skill_categories(id)
        ON DELETE RESTRICT,

    INDEX idx_skill_attachment (attachment_id),
    INDEX idx_skill_category (category_id),
    INDEX idx_skill_level (proficiency_level)
) ENGINE=InnoDB;

-- ==========================================================
-- SKILL TIMELINE
-- Tracks measurable growth over time.
-- ==========================================================

CREATE TABLE skill_timeline (
    id INT AUTO_INCREMENT PRIMARY KEY,

    skill_id INT NOT NULL,

    proficiency_level ENUM(
        'Beginner',
        'Intermediate',
        'Advanced',
        'Expert'
    ) NOT NULL,

    notes TEXT,

    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_skilltimeline_skill
        FOREIGN KEY (skill_id)
        REFERENCES skills(id)
        ON DELETE CASCADE,

    INDEX idx_skilltimeline_skill (skill_id),
    INDEX idx_skilltimeline_date (recorded_at)
) ENGINE=InnoDB;

-- ==========================================================
-- SKILL BADGES
-- ==========================================================

CREATE TABLE skill_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    description TEXT,

    icon VARCHAR(100),

    badge_color VARCHAR(30),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================================
-- USER SKILL BADGES
-- ==========================================================

CREATE TABLE user_skill_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,

    attachment_id INT NOT NULL,

    badge_id INT NOT NULL,

    earned_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_userskillbadge_attachment
        FOREIGN KEY (attachment_id)
        REFERENCES attachments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_userskillbadge_badge
        FOREIGN KEY (badge_id)
        REFERENCES skill_badges(id)
        ON DELETE CASCADE,

    UNIQUE KEY uk_attachment_badge
        (attachment_id, badge_id),

    INDEX idx_userskillbadge_attachment (attachment_id)
) ENGINE=InnoDB;

-- ==========================================================
-- SKILL EVIDENCE
-- Evidence supporting measurable growth.
-- ==========================================================

CREATE TABLE skill_evidence (
    id INT AUTO_INCREMENT PRIMARY KEY,

    skill_id INT NOT NULL,

    daily_log_id INT NULL,

    project_id INT NULL,

    milestone_id INT NULL,

    evidence_type ENUM(
        'Daily Log',
        'Project',
        'Milestone',
        'Manual'
    ) NOT NULL,

    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_skillevidence_skill
        FOREIGN KEY (skill_id)
        REFERENCES skills(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_skillevidence_log
        FOREIGN KEY (daily_log_id)
        REFERENCES daily_logs(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_skillevidence_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_skillevidence_milestone
        FOREIGN KEY (milestone_id)
        REFERENCES milestones(id)
        ON DELETE SET NULL,

    INDEX idx_skillevidence_skill (skill_id)
) ENGINE=InnoDB;