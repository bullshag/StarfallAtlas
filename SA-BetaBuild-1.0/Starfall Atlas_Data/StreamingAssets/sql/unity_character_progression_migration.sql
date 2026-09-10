-- Ability-priority and level-up support for the vertical slice.
USE accounts;

ALTER TABLE characters ADD COLUMN IF NOT EXISTS skill_points INT NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS character_abilities (
    character_id INT NOT NULL,
    ability_id INT NOT NULL,
    PRIMARY KEY(character_id,ability_id),
    FOREIGN KEY(character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY(ability_id) REFERENCES abilities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS character_ability_slots (
    character_id INT NOT NULL,
    slot TINYINT NOT NULL,
    ability_id INT NULL,
    priority INT NOT NULL DEFAULT 1,
    PRIMARY KEY(character_id,slot),
    FOREIGN KEY(character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY(ability_id) REFERENCES abilities(id) ON DELETE CASCADE
);

-- Give existing and newly seeded tavern recruits a visible starter loadout.
INSERT IGNORE INTO character_abilities(character_id,ability_id)
SELECT character_row.id,ability.id FROM characters character_row
JOIN abilities ability ON ability.name='Quick Strike';

INSERT IGNORE INTO character_abilities(character_id,ability_id)
SELECT character_row.id,ability.id FROM characters character_row
JOIN abilities ability ON ability.name=CASE
    WHEN LOWER(character_row.role)='tank' THEN 'Taunting Blows'
    WHEN character_row.intelligence>=character_row.strength THEN 'Heal'
    ELSE 'Poison'
END;

INSERT IGNORE INTO character_ability_slots(character_id,slot,ability_id,priority)
SELECT character_row.id,1,ability.id,1 FROM characters character_row
JOIN abilities ability ON ability.name=CASE
    WHEN LOWER(character_row.role)='tank' THEN 'Taunting Blows'
    WHEN character_row.intelligence>=character_row.strength THEN 'Heal'
    ELSE 'Poison'
END;

INSERT IGNORE INTO character_ability_slots(character_id,slot,ability_id,priority)
SELECT character_row.id,2,ability.id,2 FROM characters character_row
JOIN abilities ability ON ability.name='Quick Strike';

UPDATE character_ability_slots SET priority=slot WHERE slot BETWEEN 1 AND 5;
