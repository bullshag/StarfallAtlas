-- Insert template tavern recruits when no neutral characters are available for seeding
INSERT INTO characters (
    account_id,
    name,
    current_hp,
    max_hp,
    mana,
    max_mana,
    experience_points,
    action_speed,
    strength,
    dex,
    intelligence,
    melee_defense,
    magic_defense,
    level,
    skill_points,
    in_tavern
)
SELECT
    NULL,
    CONCAT(fallback.name, ' ', UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 4))),
    fallback.max_hp,
    fallback.max_hp,
    fallback.max_mp,
    fallback.max_mp,
    0,
    fallback.action_speed,
    fallback.strength,
    fallback.dex,
    fallback.intelligence,
    fallback.melee_defense,
    fallback.magic_defense,
    fallback.level,
    0,
    1
FROM (
    SELECT 'Aspirant Mara' AS name, 48 AS max_hp, 40 AS max_mp, 10 AS action_speed, 11 AS strength, 10 AS dex, 9 AS intelligence, 1 AS melee_defense, 0 AS magic_defense, 1 AS level
    UNION ALL
    SELECT 'Scout Bronn', 44, 38, 11, 10, 12, 9, 0, 1, 1
    UNION ALL
    SELECT 'Acolyte Nia', 40, 46, 10, 9, 9, 12, 0, 1, 1
    UNION ALL
    SELECT 'Sentry Kellan', 52, 34, 9, 12, 9, 8, 2, 0, 1
    UNION ALL
    SELECT 'Channeler Ise', 38, 50, 10, 8, 9, 13, 0, 2, 1
    UNION ALL
    SELECT 'Veteran Orik', 50, 36, 11, 11, 10, 9, 2, 1, 1
) AS fallback;
