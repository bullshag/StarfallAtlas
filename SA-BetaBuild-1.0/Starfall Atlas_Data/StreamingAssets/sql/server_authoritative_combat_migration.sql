-- Server-authoritative combat persistence. Safe to rerun.
USE accounts;

CREATE TABLE IF NOT EXISTS active_combat_accounts (
    account_id INT PRIMARY KEY,
    encounter_id CHAR(36) NOT NULL UNIQUE,
    started_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_active_combat_account FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_active_combat_encounter FOREIGN KEY (encounter_id) REFERENCES combat_encounters(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_event_log (
    encounter_id CHAR(36) NOT NULL,
    sequence_no INT NOT NULL,
    event_index INT NOT NULL DEFAULT 0,
    event_type VARCHAR(32) NOT NULL,
    payload LONGTEXT NOT NULL,
    created_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (encounter_id, sequence_no, event_index),
    CONSTRAINT fk_combat_event_encounter FOREIGN KEY (encounter_id) REFERENCES combat_encounters(id) ON DELETE CASCADE
);

ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS server_version VARCHAR(32) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS entry_x DECIMAL(12,4) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS entry_y DECIMAL(12,4) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS entry_z DECIMAL(12,4) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS state_snapshot LONGTEXT NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS snapshot_utc DATETIME NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS sequence_no INT NOT NULL DEFAULT 0;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS outcome VARCHAR(20) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS rules_version VARCHAR(32) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS snapshot_version VARCHAR(32) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS rng_version VARCHAR(32) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS rng_state VARCHAR(64) NULL;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS completion_attempts INT NOT NULL DEFAULT 0;
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS completion_error VARCHAR(1000) NULL;
ALTER TABLE combat_event_log ADD COLUMN IF NOT EXISTS event_index INT NOT NULL DEFAULT 0 AFTER sequence_no;

SET @combat_event_pk_columns = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='combat_event_log' AND index_name='PRIMARY');
SET @combat_event_pk_sql = IF(@combat_event_pk_columns=2,
    'ALTER TABLE combat_event_log DROP PRIMARY KEY, ADD PRIMARY KEY(encounter_id,sequence_no,event_index)',
    'SELECT 1');
PREPARE combat_event_pk_stmt FROM @combat_event_pk_sql;
EXECUTE combat_event_pk_stmt;
DEALLOCATE PREPARE combat_event_pk_stmt;

CREATE TABLE IF NOT EXISTS server_wilderness_zones (
    zone_id VARCHAR(64) PRIMARY KEY,
    world_id VARCHAR(64) NOT NULL DEFAULT 'main_world',
    center_x DECIMAL(12,4) NOT NULL,
    center_y DECIMAL(12,4) NOT NULL DEFAULT 0,
    center_z DECIMAL(12,4) NOT NULL,
    radius DECIMAL(12,4) NOT NULL,
    encounter_chance DECIMAL(8,6) NOT NULL DEFAULT 0.08,
    min_group_size TINYINT NOT NULL DEFAULT 1,
    max_group_size TINYINT NOT NULL DEFAULT 3,
    enabled TINYINT(1) NOT NULL DEFAULT 1
);
