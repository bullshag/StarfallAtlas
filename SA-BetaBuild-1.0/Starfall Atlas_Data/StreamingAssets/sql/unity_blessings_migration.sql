CREATE TABLE IF NOT EXISTS account_blessings (
    account_id INT NOT NULL,
    blessing_key VARCHAR(40) NOT NULL,
    purchased_utc DATETIME NOT NULL,
    expires_utc DATETIME NOT NULL,
    PRIMARY KEY (account_id, blessing_key),
    INDEX ix_account_blessings_expiry (expires_utc),
    CONSTRAINT fk_account_blessings_user FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO activities(node_id,activity_type,description)
SELECT node.id,'temple','Purchase party-wide blessings.'
FROM nodes node
WHERE node.id IN ('nodeFortAurus','nodeMounttown','nodeRiverVillage','nodeSmallVillage')
  AND NOT EXISTS (SELECT 1 FROM activities existing WHERE existing.node_id=node.id AND existing.activity_type='temple');
