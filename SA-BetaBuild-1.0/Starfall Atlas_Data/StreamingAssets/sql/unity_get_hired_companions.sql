-- Fetch active mercenary (hired companion) party members for Unity CharacterService
SELECT id, name, current_hp AS hp, max_hp, mana, max_mana, is_dead,
       experience_points, skill_points, action_speed, strength, dex, intelligence,
       melee_defense, magic_defense, level, role, targeting_style
FROM characters
WHERE account_id = @id AND in_arena = 0 AND in_tavern = 0 AND is_mercenary = 1;
