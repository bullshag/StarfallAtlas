-- Load purchases from the Unity shop inventory together with legacy/loot items.
SELECT MAX(combined.item_id) AS item_id,
       combined.item_name,
       SUM(combined.quantity) AS quantity,
       MAX(combined.stackable) AS stackable,
       MAX(combined.base_price) AS base_price,
       MAX(combined.description) AS description,
       MAX(combined.taught_ability_id) AS taught_ability_id,
       MAX(combined.item_category) AS item_category,
       MAX(combined.equipment_slot) AS equipment_slot,
       MAX(combined.hand_type) AS hand_type,
       MAX(combined.weapon_type) AS weapon_type,
       MAX(combined.base_damage_min) AS base_damage_min,
       MAX(combined.base_damage_max) AS base_damage_max,
       MAX(combined.strength_bonus) AS strength_bonus,
       MAX(combined.agility_bonus) AS agility_bonus,
       MAX(combined.intelligence_bonus) AS intelligence_bonus,
       MAX(combined.max_hp_bonus) AS max_hp_bonus,
       MAX(combined.max_mana_bonus) AS max_mana_bonus,
       MAX(combined.physical_defense_bonus) AS physical_defense_bonus,
       MAX(combined.magic_defense_bonus) AS magic_defense_bonus,
       MAX(combined.attack_speed_mod) AS attack_speed_mod,
       MAX(combined.strength_scaling) AS strength_scaling,
       MAX(combined.agility_scaling) AS agility_scaling,
       MAX(combined.threat_multiplier) AS threat_multiplier
FROM (
    SELECT items.id AS item_id,
           items.name AS item_name,
           inventory.quantity,
           items.stackable,
           items.base_price,
           items.description,
           items.taught_ability_id,
           items.item_category,
           items.equipment_slot,
           items.hand_type, items.weapon_type, items.base_damage_min, items.base_damage_max,
           items.strength_bonus, items.agility_bonus, items.intelligence_bonus,
           items.max_hp_bonus, items.max_mana_bonus, items.physical_defense_bonus,
           items.magic_defense_bonus, items.attack_speed_mod, items.strength_scaling,
           items.agility_scaling, items.threat_multiplier
    FROM inventory
    JOIN items ON items.id = inventory.item_id
    WHERE inventory.user_id = @id

    UNION ALL

    SELECT items.id AS item_id,
           user_items.item_name,
           user_items.quantity,
           COALESCE(items.stackable, 0) AS stackable,
           COALESCE(items.base_price, 0) AS base_price,
           items.description,
           items.taught_ability_id,
           items.item_category,
           items.equipment_slot,
           items.hand_type, items.weapon_type, items.base_damage_min, items.base_damage_max,
           items.strength_bonus, items.agility_bonus, items.intelligence_bonus,
           items.max_hp_bonus, items.max_mana_bonus, items.physical_defense_bonus,
           items.magic_defense_bonus, items.attack_speed_mod, items.strength_scaling,
           items.agility_scaling, items.threat_multiplier
    FROM user_items
    LEFT JOIN items ON items.name = user_items.item_name
    WHERE user_items.account_id = @id
) AS combined
GROUP BY combined.item_name;

-- Loads user equipment
SELECT ce.character_name, ce.slot, ce.item_name, i.id AS item_id,
       i.base_price, i.stackable, i.description, i.taught_ability_id, i.item_category,
       i.equipment_slot, i.hand_type, i.weapon_type, i.base_damage_min, i.base_damage_max,
       i.strength_bonus, i.agility_bonus, i.intelligence_bonus,
       i.max_hp_bonus, i.max_mana_bonus, i.physical_defense_bonus,
       i.magic_defense_bonus, i.attack_speed_mod, i.strength_scaling,
       i.agility_scaling, i.threat_multiplier
FROM character_equipment ce
LEFT JOIN items i ON i.name=ce.item_name
WHERE ce.account_id=@id;
