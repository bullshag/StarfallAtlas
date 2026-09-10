-- Fetch items for sale at a node
SELECT s.item_id AS id, i.name, s.price, COALESCE(i.description, '') AS description,
       COALESCE(i.taught_ability_id,0) AS taught_ability_id,
       COALESCE(i.item_category,'') AS item_category, COALESCE(i.equipment_slot,'') AS equipment_slot,
       COALESCE(i.hand_type,'') AS hand_type, COALESCE(i.weapon_type,'') AS weapon_type,
       COALESCE(i.base_damage_min,0) AS base_damage_min, COALESCE(i.base_damage_max,0) AS base_damage_max,
       COALESCE(i.strength_bonus,0) AS strength_bonus, COALESCE(i.agility_bonus,0) AS agility_bonus,
       COALESCE(i.intelligence_bonus,0) AS intelligence_bonus, COALESCE(i.max_hp_bonus,0) AS max_hp_bonus,
       COALESCE(i.max_mana_bonus,0) AS max_mana_bonus, COALESCE(i.physical_defense_bonus,0) AS physical_defense_bonus,
       COALESCE(i.magic_defense_bonus,0) AS magic_defense_bonus, COALESCE(i.attack_speed_mod,0) AS attack_speed_mod,
       COALESCE(i.strength_scaling,0) AS strength_scaling, COALESCE(i.agility_scaling,0) AS agility_scaling,
       COALESCE(i.threat_multiplier,1) AS threat_multiplier, COALESCE(i.stackable,0) AS stackable
FROM shop_stock s
JOIN items i ON s.item_id = i.id
WHERE s.node_id = @nodeId;
