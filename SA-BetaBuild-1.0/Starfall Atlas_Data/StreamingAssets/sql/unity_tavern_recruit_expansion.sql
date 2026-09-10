-- Expand the tavern candidate pool and starting-ability rolls.
-- Idempotent: existing characters, rosters, abilities, and learned skills are preserved.
USE accounts;

-- Ten supported abilities are eligible for a generated recruit's starting skill.
-- The weights intentionally favor simple early-game actions while still allowing
-- support, defense, and utility rolls.
UPDATE abilities
SET can_roll_as_starting_ability = 1,
    starting_ability_weight = CASE ability_key
        WHEN 'quick_strike' THEN 120
        WHEN 'fireball' THEN 100
        WHEN 'heal' THEN 95
        WHEN 'heavy_blow' THEN 90
        WHEN 'wild_strike' THEN 90
        WHEN 'poison' THEN 80
        WHEN 'mana_shield' THEN 70
        WHEN 'restorative_aura' THEN 70
        WHEN 'shield_bash' THEN 65
        WHEN 'taunting_blows' THEN 55
        ELSE starting_ability_weight END
WHERE ability_key IN ('quick_strike','fireball','heal','heavy_blow','wild_strike',
                      'poison','mana_shield','restorative_aura','shield_bash','taunting_blows');

-- Fifty stable, neutral candidates. Their generated roster stats and costs are
-- written to unity_tavern_recruits when a town refreshes its roster.
INSERT INTO characters
    (account_id,name,current_hp,max_hp,mana,max_mana,experience_points,action_speed,
     strength,dex,intelligence,melee_defense,magic_defense,level,skill_points,in_tavern)
SELECT NULL,s.name,s.max_hp,s.max_hp,s.max_mp,s.max_mp,0,s.action_speed,
       s.strength,s.dexterity,s.intelligence,s.physical_defense,s.magic_defense,1,0,1
FROM (
    SELECT 'Alden Veyr' name,45 max_hp,45 max_mp,1.00 action_speed,10 strength,10 dexterity,10 intelligence,0 physical_defense,0 magic_defense
    UNION ALL SELECT 'Anwen Gale',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Arden Skye',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Asha Lark',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Bastian Crow',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Bram Hollow',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Cael Rowan',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Cedric Noll',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Corin Wren',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Darian Frost',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Doran Fallow',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Eamon Rook',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Eira Sol',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Elira Fen',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Elowen Cairn',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Freya Calder',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Galen Ward',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Garrick Stone',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Harlan Crest',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Ilyra Moss',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Isolde Mere',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Joren Blackwood',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Kaia Winter',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Kellan Voss',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Kessa Mire',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Liora Sable',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Lucan Briar',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Lyra Dawn',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Maelis Rune',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Maren Holt',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Merek Tarn',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Mira Thorn',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Nessa Quill',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Nyra Flint',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Oren Pike',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Osric Bell',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Perrin Locke',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Rowan Strake',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Rurik Ember',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Sabine Orr',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Selene Marsh',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Sera Vale',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Talia Reed',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Thalia Venn',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Theron Mott',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Tobin Graye',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Torren Ash',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Varren Dusk',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Vela Hart',45,45,1.00,10,10,10,0,0
    UNION ALL SELECT 'Ysra Moon',45,45,1.00,10,10,10,0,0
) s
WHERE NOT EXISTS (SELECT 1 FROM characters existing WHERE existing.name=s.name);

CREATE INDEX IF NOT EXISTS ix_characters_tavern_available
    ON characters(in_tavern,account_id,level);
