-- Party tactics v1. Existing skill slot assignments and character state are untouched.
CREATE TABLE IF NOT EXISTS character_tactics (
 character_id INT NOT NULL PRIMARY KEY,
 settings_json LONGTEXT NOT NULL,
 version INT NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS character_ability_tactics (
 character_id INT NOT NULL,
 ability_key VARCHAR(100) NOT NULL,
 enabled TINYINT NOT NULL DEFAULT 1,
 target_hp_percent INT NOT NULL DEFAULT 100,
 minimum_recipients INT NOT NULL DEFAULT 1,
 PRIMARY KEY(character_id,ability_key)
);

