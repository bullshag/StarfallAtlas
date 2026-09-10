-- Server-authoritative temple revival credit. Each account may use one free
-- whole-party resurrection; that credit refreshes every fifteen minutes.
USE accounts;

CREATE TABLE IF NOT EXISTS account_temple_revivals (
    account_id INT NOT NULL PRIMARY KEY,
    next_free_resurrection_utc DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
    CONSTRAINT fk_account_temple_revivals_user
        FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Existing players begin with one available credit. Reruns retain an earned
-- cooldown and never grant an extra use early.
INSERT IGNORE INTO account_temple_revivals(account_id)
SELECT id FROM users;
