-- ============================================
-- AttachFlow Database
-- Module: Authentication Token Infrastructure
-- File: 11_authentication_tokens.sql
-- ============================================

USE attachflow_db;

-- ============================================
-- EMAIL VERIFICATION TOKENS
-- ============================================

CREATE TABLE email_verification_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    token_hash VARCHAR(255) NOT NULL,

    expires_at DATETIME NOT NULL,

    used_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_email_verification_tokens_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_email_verification_tokens_token_hash (token_hash),

    INDEX idx_email_verification_tokens_user_id (user_id),

    INDEX idx_email_verification_tokens_expires_at (expires_at)
);


-- ============================================
-- PASSWORD RESET TOKENS
-- ============================================

CREATE TABLE password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    token_hash VARCHAR(255) NOT NULL,

    expires_at DATETIME NOT NULL,

    used_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_reset_tokens_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_password_reset_tokens_token_hash (token_hash),

    INDEX idx_password_reset_tokens_user_id (user_id),

    INDEX idx_password_reset_tokens_expires_at (expires_at)
);