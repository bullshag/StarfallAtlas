USE accounts;

ALTER TABLE characters ADD COLUMN IF NOT EXISTS skill_points INT NOT NULL DEFAULT 0;

-- Any source that grants experience receives the same automatic, carry-over-aware
-- leveling behavior. Large rewards may award several levels in one update.
DROP TRIGGER IF EXISTS characters_auto_level_before_insert;
DROP TRIGGER IF EXISTS characters_auto_level_before_update;

DELIMITER $$
CREATE TRIGGER characters_auto_level_before_insert
BEFORE INSERT ON characters
FOR EACH ROW
BEGIN
    SET NEW.level = LEAST(25, GREATEST(1, NEW.level));
    WHILE NEW.level < 25 AND NEW.experience_points >= (25 * NEW.level) DO
        SET NEW.experience_points = NEW.experience_points - (25 * NEW.level);
        SET NEW.level = NEW.level + 1;
        SET NEW.skill_points = NEW.skill_points + 1;
        SET NEW.max_hp = NEW.max_hp + 5;
        SET NEW.current_hp = NEW.current_hp + 5;
        SET NEW.max_mana = NEW.max_mana + 5;
        SET NEW.mana = NEW.mana + 5;
    END WHILE;
    IF NEW.level >= 25 THEN
        SET NEW.experience_points = 0;
    END IF;
END$$

CREATE TRIGGER characters_auto_level_before_update
BEFORE UPDATE ON characters
FOR EACH ROW
BEGIN
    SET NEW.level = LEAST(25, GREATEST(1, NEW.level));
    WHILE NEW.level < 25 AND NEW.experience_points >= (25 * NEW.level) DO
        SET NEW.experience_points = NEW.experience_points - (25 * NEW.level);
        SET NEW.level = NEW.level + 1;
        SET NEW.skill_points = NEW.skill_points + 1;
        SET NEW.max_hp = NEW.max_hp + 5;
        SET NEW.current_hp = NEW.current_hp + 5;
        SET NEW.max_mana = NEW.max_mana + 5;
        SET NEW.mana = NEW.mana + 5;
    END WHILE;
    IF NEW.level >= 25 THEN
        SET NEW.experience_points = 0;
    END IF;
END$$
DELIMITER ;

-- Normalize legacy over-cap rows while preserving earned stats and skill points,
-- then catch up characters that crossed a threshold before this trigger existed.
UPDATE characters SET level=25, experience_points=0 WHERE level>25;
UPDATE characters SET experience_points=0 WHERE level=25 AND experience_points<>0;
UPDATE characters SET experience_points=experience_points;
