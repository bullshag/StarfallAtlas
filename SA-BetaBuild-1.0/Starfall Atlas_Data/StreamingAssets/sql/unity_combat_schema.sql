-- Returning vertical-slice combat schema and seed data.
-- Safe to rerun against the accounts database.

CREATE DATABASE IF NOT EXISTS accounts;
USE accounts;

ALTER TABLE npcs ADD COLUMN IF NOT EXISTS max_mana INT NOT NULL DEFAULT 0 AFTER mana;
ALTER TABLE npcs MODIFY COLUMN action_speed DECIMAL(6,2) NOT NULL DEFAULT 1.00;
ALTER TABLE characters MODIFY COLUMN action_speed DECIMAL(6,2) NOT NULL DEFAULT 1.00;

CREATE TABLE IF NOT EXISTS combat_ability_effects (
    ability_id INT NOT NULL,
    effect_index TINYINT NOT NULL DEFAULT 1,
    effect_type VARCHAR(32) NOT NULL,
    target_type VARCHAR(32) NOT NULL,
    damage_school VARCHAR(16) NOT NULL DEFAULT 'physical',
    base_power DECIMAL(10,3) NOT NULL DEFAULT 0,
    strength_ratio DECIMAL(10,3) NOT NULL DEFAULT 0,
    dexterity_ratio DECIMAL(10,3) NOT NULL DEFAULT 0,
    intelligence_ratio DECIMAL(10,3) NOT NULL DEFAULT 0,
    duration_seconds DECIMAL(10,3) NOT NULL DEFAULT 0,
    tick_interval_seconds DECIMAL(10,3) NOT NULL DEFAULT 0,
    threat_multiplier DECIMAL(10,3) NOT NULL DEFAULT 1,
    status_key VARCHAR(64) NULL,
    PRIMARY KEY (ability_id, effect_index),
    CONSTRAINT fk_combat_effect_ability FOREIGN KEY (ability_id) REFERENCES abilities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_npc_abilities (
    npc_id INT NOT NULL,
    ability_id INT NOT NULL,
    slot TINYINT NOT NULL DEFAULT 1,
    priority INT NOT NULL DEFAULT 1,
    PRIMARY KEY (npc_id, slot),
    CONSTRAINT fk_combat_npc_ability_npc FOREIGN KEY (npc_id) REFERENCES npcs(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_npc_ability_ability FOREIGN KEY (ability_id) REFERENCES abilities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_encounter_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    node_id VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    min_enemies TINYINT NOT NULL DEFAULT 1,
    max_enemies TINYINT NOT NULL DEFAULT 2,
    UNIQUE KEY uq_combat_encounter_node_name (node_id, name),
    CONSTRAINT fk_combat_encounter_node FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_encounter_entries (
    encounter_table_id INT NOT NULL,
    npc_id INT NOT NULL,
    weight INT NOT NULL DEFAULT 1,
    min_count TINYINT NOT NULL DEFAULT 1,
    max_count TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (encounter_table_id, npc_id),
    CONSTRAINT fk_combat_entry_table FOREIGN KEY (encounter_table_id) REFERENCES combat_encounter_tables(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_entry_npc FOREIGN KEY (npc_id) REFERENCES npcs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_loot_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS combat_loot_table_entries (
    loot_table_id INT NOT NULL,
    item_id INT NOT NULL,
    drop_chance DECIMAL(6,5) NOT NULL DEFAULT 1,
    weight INT NOT NULL DEFAULT 1,
    min_quantity INT NOT NULL DEFAULT 1,
    max_quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (loot_table_id, item_id),
    CONSTRAINT fk_combat_loot_entry_table FOREIGN KEY (loot_table_id) REFERENCES combat_loot_tables(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_loot_entry_item FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_npc_loot (
    npc_id INT PRIMARY KEY,
    loot_table_id INT NOT NULL,
    min_gold INT NOT NULL DEFAULT 0,
    max_gold INT NOT NULL DEFAULT 0,
    min_experience INT NOT NULL DEFAULT 0,
    max_experience INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_combat_npc_loot_npc FOREIGN KEY (npc_id) REFERENCES npcs(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_npc_loot_table FOREIGN KEY (loot_table_id) REFERENCES combat_loot_tables(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS combat_encounters (
    id CHAR(36) PRIMARY KEY,
    account_id INT NOT NULL,
    node_id VARCHAR(50) NOT NULL,
    random_seed INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'prepared',
    started_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_utc DATETIME NULL,
    reward_claimed TINYINT(1) NOT NULL DEFAULT 0,
    combat_log LONGTEXT NULL,
    CONSTRAINT fk_combat_history_account FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_history_node FOREIGN KEY (node_id) REFERENCES nodes(id)
);

CREATE TABLE IF NOT EXISTS combat_rewards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    encounter_id CHAR(36) NOT NULL,
    item_id INT NULL,
    quantity INT NOT NULL DEFAULT 0,
    gold INT NOT NULL DEFAULT 0,
    experience INT NOT NULL DEFAULT 0,
    created_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_combat_reward_encounter FOREIGN KEY (encounter_id) REFERENCES combat_encounters(id) ON DELETE CASCADE,
    CONSTRAINT fk_combat_reward_item FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL
);

INSERT INTO abilities (name, description, cost, cooldown) VALUES
('Quick Strike', 'A reliable weapon strike dealing physical damage.', 0, 2),
('Fireball', 'Hurl a blazing orb at one enemy.', 12, 4),
('Heal', 'Restore health to one ally.', 10, 5),
('Taunting Blows', 'Damage and force all enemies to focus on the caster.', 0, 7),
('Poison', 'Poison an enemy, dealing damage over time.', 8, 8),
('Shield Bash', 'Strike an enemy and briefly stun it.', 5, 6)
ON DUPLICATE KEY UPDATE
description = VALUES(description), cost = VALUES(cost), cooldown = VALUES(cooldown);

DELETE effect
FROM combat_ability_effects effect
JOIN abilities ability ON ability.id = effect.ability_id
WHERE ability.name IN ('Quick Strike','Fireball','Heal','Taunting Blows','Poison','Shield Bash');

INSERT INTO combat_ability_effects
(ability_id, effect_index, effect_type, target_type, damage_school, base_power,
 strength_ratio, dexterity_ratio, intelligence_ratio, duration_seconds,
 tick_interval_seconds, threat_multiplier, status_key)
SELECT id, 1, 'damage', 'enemy', 'physical', 3, 0.70, 0.35, 0, 0, 0, 1, NULL
FROM abilities WHERE name = 'Quick Strike'
UNION ALL
SELECT id, 1, 'damage', 'enemy', 'magic', 5, 0, 0, 1.00, 0, 0, 1, NULL
FROM abilities WHERE name = 'Fireball'
UNION ALL
SELECT id, 1, 'heal', 'ally', 'holy', 5, 0, 0, 1.20, 0, 0, 1, NULL
FROM abilities WHERE name = 'Heal'
UNION ALL
SELECT id, 1, 'damage', 'enemy', 'physical', 2, 0.45, 0, 0, 0, 0, 2.25, NULL
FROM abilities WHERE name = 'Taunting Blows'
UNION ALL
SELECT id, 2, 'taunt', 'all_enemies', 'physical', 0, 0, 0, 0, 2.5, 0, 1, 'taunted'
FROM abilities WHERE name = 'Taunting Blows'
UNION ALL
SELECT id, 1, 'damage_over_time', 'enemy', 'nature', 1, 0, 0.35, 0, 6, 1, 1, 'poison'
FROM abilities WHERE name = 'Poison'
UNION ALL
SELECT id, 1, 'damage', 'enemy', 'physical', 4, 0.65, 0, 0, 0, 0, 1.20, NULL
FROM abilities WHERE name = 'Shield Bash'
UNION ALL
SELECT id, 2, 'stun', 'enemy', 'physical', 0, 0, 0, 0, 1.25, 0, 1, 'stunned'
FROM abilities WHERE name = 'Shield Bash';

INSERT INTO npcs
(name, level, current_hp, max_hp, mana, max_mana, action_speed, strength, dex, intelligence,
 melee_defense, magic_defense, role, targeting_style, power)
VALUES
('Snow Wolf', 1, 42, 42, 0, 0, 12.00, 7, 9, 2, 3, 2, 'DPS', 'highest_threat', 80),
('Bandit Guard', 2, 58, 58, 12, 12, 8.50, 10, 6, 3, 6, 3, 'Tank', 'highest_threat', 125),
('Cultist Acolyte', 2, 40, 40, 36, 36, 9.50, 4, 5, 11, 2, 7, 'Healer', 'lowest_hp', 135),
('Bandit Captain', 3, 82, 82, 20, 20, 10.00, 13, 8, 5, 8, 6, 'Tank', 'highest_threat', 210)
ON DUPLICATE KEY UPDATE
level = VALUES(level), current_hp = VALUES(current_hp), max_hp = VALUES(max_hp),
mana = VALUES(mana), max_mana = VALUES(max_mana), action_speed = VALUES(action_speed),
strength = VALUES(strength), dex = VALUES(dex), intelligence = VALUES(intelligence),
melee_defense = VALUES(melee_defense), magic_defense = VALUES(magic_defense),
role = VALUES(role), targeting_style = VALUES(targeting_style), power = VALUES(power);

INSERT INTO combat_npc_abilities (npc_id, ability_id, slot, priority)
SELECT npc.id, ability.id, seed.slot, seed.priority
FROM (
    SELECT 'Snow Wolf' npc_name, 'Poison' ability_name, 1 slot, 1 priority
    UNION ALL SELECT 'Bandit Guard', 'Shield Bash', 1, 1
    UNION ALL SELECT 'Cultist Acolyte', 'Heal', 1, 1
    UNION ALL SELECT 'Cultist Acolyte', 'Fireball', 2, 2
    UNION ALL SELECT 'Bandit Captain', 'Taunting Blows', 1, 1
    UNION ALL SELECT 'Bandit Captain', 'Quick Strike', 2, 2
) seed
JOIN npcs npc ON npc.name = seed.npc_name
JOIN abilities ability ON ability.name = seed.ability_name
ON DUPLICATE KEY UPDATE ability_id = VALUES(ability_id), priority = VALUES(priority);

INSERT INTO combat_encounter_tables (node_id, name, min_enemies, max_enemies)
SELECT id, CONCAT(name, ' Outskirts'), 1, 3 FROM nodes
ON DUPLICATE KEY UPDATE min_enemies = VALUES(min_enemies), max_enemies = VALUES(max_enemies);

INSERT INTO combat_encounter_entries (encounter_table_id, npc_id, weight, min_count, max_count)
SELECT table_def.id, npc.id, seed.weight, seed.min_count, seed.max_count
FROM combat_encounter_tables table_def
CROSS JOIN (
    SELECT 'Snow Wolf' npc_name, 45 weight, 1 min_count, 2 max_count
    UNION ALL SELECT 'Bandit Guard', 30, 1, 2
    UNION ALL SELECT 'Cultist Acolyte', 18, 1, 1
    UNION ALL SELECT 'Bandit Captain', 7, 1, 1
) seed
JOIN npcs npc ON npc.name = seed.npc_name
WHERE 1 = 1
ON DUPLICATE KEY UPDATE weight = VALUES(weight), min_count = VALUES(min_count), max_count = VALUES(max_count);

INSERT INTO combat_loot_tables (name) VALUES
('Snow Wolf Loot'), ('Bandit Loot'), ('Cultist Loot'), ('Bandit Captain Loot')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO combat_loot_table_entries
(loot_table_id, item_id, drop_chance, weight, min_quantity, max_quantity)
SELECT loot.id, item.id, seed.drop_chance, seed.weight, seed.min_quantity, seed.max_quantity
FROM (
    SELECT 'Snow Wolf Loot' loot_name, 'Healing Potion' item_name, 0.35 drop_chance, 1 weight, 1 min_quantity, 1 max_quantity
    UNION ALL SELECT 'Bandit Loot', 'Dagger', 0.22, 1, 1, 1
    UNION ALL SELECT 'Bandit Loot', 'Healing Potion', 0.40, 1, 1, 2
    UNION ALL SELECT 'Cultist Loot', 'Cloth Robe', 0.18, 1, 1, 1
    UNION ALL SELECT 'Cultist Loot', 'Healing Potion', 0.55, 1, 1, 2
    UNION ALL SELECT 'Bandit Captain Loot', 'Longsword', 0.30, 1, 1, 1
    UNION ALL SELECT 'Bandit Captain Loot', 'Healing Potion', 0.80, 1, 1, 2
) seed
JOIN combat_loot_tables loot ON loot.name = seed.loot_name
JOIN items item ON item.name = seed.item_name
ON DUPLICATE KEY UPDATE drop_chance = VALUES(drop_chance), weight = VALUES(weight),
min_quantity = VALUES(min_quantity), max_quantity = VALUES(max_quantity);

INSERT INTO combat_npc_loot
(npc_id, loot_table_id, min_gold, max_gold, min_experience, max_experience)
SELECT npc.id, loot.id, seed.min_gold, seed.max_gold, seed.min_xp, seed.max_xp
FROM (
    SELECT 'Snow Wolf' npc_name, 'Snow Wolf Loot' loot_name, 4 min_gold, 8 max_gold, 8 min_xp, 12 max_xp
    UNION ALL SELECT 'Bandit Guard', 'Bandit Loot', 8, 15, 12, 18
    UNION ALL SELECT 'Cultist Acolyte', 'Cultist Loot', 10, 18, 14, 20
    UNION ALL SELECT 'Bandit Captain', 'Bandit Captain Loot', 20, 35, 28, 40
) seed
JOIN npcs npc ON npc.name = seed.npc_name
JOIN combat_loot_tables loot ON loot.name = seed.loot_name
ON DUPLICATE KEY UPDATE loot_table_id = VALUES(loot_table_id), min_gold = VALUES(min_gold),
max_gold = VALUES(max_gold), min_experience = VALUES(min_experience), max_experience = VALUES(max_experience);

-- Give existing characters a usable starter loadout without replacing choices already made.
INSERT IGNORE INTO character_abilities (character_id, ability_id)
SELECT character_row.id, ability.id
FROM characters character_row
JOIN abilities ability ON ability.name = 'Quick Strike';

INSERT IGNORE INTO character_abilities (character_id, ability_id)
SELECT character_row.id, ability.id
FROM characters character_row
JOIN abilities ability ON ability.name = CASE
    WHEN LOWER(character_row.role) = 'tank' THEN 'Taunting Blows'
    WHEN character_row.intelligence >= character_row.strength THEN 'Heal'
    ELSE 'Poison'
END;

INSERT IGNORE INTO character_ability_slots (character_id, slot, ability_id, priority)
SELECT character_row.id, 1, ability.id, 2
FROM characters character_row
JOIN abilities ability ON ability.name = 'Quick Strike';

INSERT IGNORE INTO character_ability_slots (character_id, slot, ability_id, priority)
SELECT character_row.id, 2, ability.id, 1
FROM characters character_row
JOIN abilities ability ON ability.name = CASE
    WHEN LOWER(character_row.role) = 'tank' THEN 'Taunting Blows'
    WHEN character_row.intelligence >= character_row.strength THEN 'Heal'
    ELSE 'Poison'
END;
