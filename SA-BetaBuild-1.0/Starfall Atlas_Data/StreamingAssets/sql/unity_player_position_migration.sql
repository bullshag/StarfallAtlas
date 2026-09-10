CREATE TABLE IF NOT EXISTS player_position (
    player_id INT NOT NULL,
    position_x DOUBLE NOT NULL DEFAULT 0,
    position_y DOUBLE NOT NULL DEFAULT 0,
    position_z DOUBLE NOT NULL DEFAULT 0,
    current_pos VARCHAR(160) NOT NULL DEFAULT '0,0,0',
    is_traveling TINYINT(1) NOT NULL DEFAULT 0,
    next_waypoint_x DOUBLE NULL,
    next_waypoint_y DOUBLE NULL,
    next_waypoint_z DOUBLE NULL,
    next_waypoint VARCHAR(160) NULL,
    scene_name VARCHAR(64) NOT NULL DEFAULT 'RPG',
    last_town_position_x DOUBLE NOT NULL DEFAULT 5608.0,
    last_town_position_y DOUBLE NOT NULL DEFAULT 553.85,
    last_town_position_z DOUBLE NOT NULL DEFAULT 2730.0,
    last_town_node_id VARCHAR(50) NOT NULL DEFAULT 'nodeFortAurus',
    timestamp DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (player_id),
    CONSTRAINT fk_player_position_user FOREIGN KEY (player_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE player_position ADD COLUMN IF NOT EXISTS last_town_position_x DOUBLE NOT NULL DEFAULT 5608.0;
ALTER TABLE player_position ADD COLUMN IF NOT EXISTS last_town_position_y DOUBLE NOT NULL DEFAULT 553.85;
ALTER TABLE player_position ADD COLUMN IF NOT EXISTS last_town_position_z DOUBLE NOT NULL DEFAULT 2730.0;
ALTER TABLE player_position ADD COLUMN IF NOT EXISTS last_town_node_id VARCHAR(50) NOT NULL DEFAULT 'nodeFortAurus';

-- Give existing accounts an initial world position. The runtime immediately
-- replaces this with the player's exact position once the RPG scene loads.
INSERT IGNORE INTO player_position
    (player_id, position_x, position_y, position_z, current_pos, is_traveling, scene_name)
SELECT
    id, 5608.0, 553.85, 2730.0, '5608,553.85,2730', 0, 'RPG'
FROM users;
