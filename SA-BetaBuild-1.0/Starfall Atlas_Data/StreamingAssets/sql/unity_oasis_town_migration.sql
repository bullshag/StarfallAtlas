-- Oasis Town: a mid-range T5-T6 settlement between Ironpass and Dreadscar.
-- Safe to rerun against the accounts database.
USE accounts;

INSERT INTO nodes(id,name) VALUES ('nodeOasisTown','Oasis Town')
ON DUPLICATE KEY UPDATE name=VALUES(name);

DELETE FROM activities WHERE node_id='nodeOasisTown';
INSERT INTO activities(node_id,activity_type,description,duration_seconds) VALUES
('nodeOasisTown','tavern','Hire party members and rest at the Oasis Town caravanserai.',0),
('nodeOasisTown','shop','Browse tier 5-6 desert equipment and supplies.',0),
('nodeOasisTown','temple','Restore, resurrect, and bless the party at the spring shrine.',0),
('nodeOasisTown','town_board','View Oasis Town work orders.',0),
('nodeOasisTown','search_for_enemies','Search the dunes surrounding Oasis Town.',0);

INSERT INTO node_connections(from_node,to_node,travel_time_days) VALUES
('nodeIronpass','nodeOasisTown',3),
('nodeOasisTown','nodeIronpass',3),
('nodeOasisTown','nodeDreadscar',4),
('nodeDreadscar','nodeOasisTown',4)
ON DUPLICATE KEY UPDATE travel_time_days=VALUES(travel_time_days);

INSERT INTO quest_definitions
(quest_key,source_node,destination_node,title,description,reward_gold,reward_xp,reward_item_key,reward_item_quantity,objective_type,objective_target,objective_required)
VALUES
('oasis_dune_raiders','nodeOasisTown','nodeOasisTown','RAIDERS AT THE WELLS','Defeat the War Cleavers threatening the town wells.',560,190,'healing_potion',2,'Kill','war_cleaver',5),
('oasis_sun_dispatch','nodeOasisTown','nodeDreadscar','THE SUN DISPATCH','Carry the oasis watch report to Dreadscar.',500,170,NULL,0,'Courier','oasis_sun_dispatch',1),
('oasis_stormglass','nodeOasisTown','nodeOasisTown','STORMGLASS IN THE DUNES','Defeat Storm Capacitors and recover charged stormglass.',640,220,'mana_potion',2,'Kill','storm_capacitor',4)
ON DUPLICATE KEY UPDATE
source_node=VALUES(source_node),destination_node=VALUES(destination_node),title=VALUES(title),
description=VALUES(description),reward_gold=VALUES(reward_gold),reward_xp=VALUES(reward_xp),
reward_item_key=VALUES(reward_item_key),reward_item_quantity=VALUES(reward_item_quantity),
objective_type=VALUES(objective_type),objective_target=VALUES(objective_target),objective_required=VALUES(objective_required);

-- Generate two database-defined choices for every supported equipment slot.
ALTER TABLE items ADD COLUMN IF NOT EXISTS item_tier TINYINT UNSIGNED NOT NULL DEFAULT 0;
INSERT INTO items
(name,base_price,stackable,description,item_category,equipment_slot,hand_type,weapon_type,
 base_damage_min,base_damage_max,strength_bonus,agility_bonus,intelligence_bonus,max_hp_bonus,
 max_mana_bonus,physical_defense_bonus,magic_defense_bonus,attack_speed_mod,strength_scaling,
 agility_scaling,threat_multiplier,item_tier)
SELECT
 CONCAT('Oasis ',i.name),
 ROUND(i.base_price*(1+g.generated_tier*1.75)),0,
 CONCAT('Tier ',g.generated_tier,' equipment traded through Oasis Town. ',i.description),
 i.item_category,i.equipment_slot,i.hand_type,i.weapon_type,
 ROUND(i.base_damage_min*(1+g.generated_tier*0.42)),
 ROUND(i.base_damage_max*(1+g.generated_tier*0.42)),
 ROUND(i.strength_bonus*(1+g.generated_tier*0.35)),
 ROUND(i.agility_bonus*(1+g.generated_tier*0.35)),
 ROUND(i.intelligence_bonus*(1+g.generated_tier*0.35)),
 ROUND(i.max_hp_bonus*(1+g.generated_tier*0.40)),
 ROUND(i.max_mana_bonus*(1+g.generated_tier*0.40)),
 ROUND(i.physical_defense_bonus*(1+g.generated_tier*0.38)),
 ROUND(i.magic_defense_bonus*(1+g.generated_tier*0.38)),
 i.attack_speed_mod,i.strength_scaling,i.agility_scaling,i.threat_multiplier,g.generated_tier
FROM items i
JOIN (
 SELECT 'Copper Amulet' item_name,5 generated_tier UNION ALL SELECT 'Sage Pendant',6
 UNION ALL SELECT 'Shortsword',5 UNION ALL SELECT 'Hunter Bow',6
 UNION ALL SELECT 'Heavy Shield',5 UNION ALL SELECT 'Runed Wand',6
 UNION ALL SELECT 'Iron Helm',5 UNION ALL SELECT 'Mystic Hood',6
 UNION ALL SELECT 'Plate Armor',5 UNION ALL SELECT 'Runespun Vestment',6
 UNION ALL SELECT 'Iron Greaves',5 UNION ALL SELECT 'Mystic Leggings',6
 UNION ALL SELECT 'Guardian Sigil',5 UNION ALL SELECT 'Clockwork Feather',6
) g ON i.name=g.item_name
ON DUPLICATE KEY UPDATE
base_price=VALUES(base_price),description=VALUES(description),item_category=VALUES(item_category),
equipment_slot=VALUES(equipment_slot),hand_type=VALUES(hand_type),weapon_type=VALUES(weapon_type),
base_damage_min=VALUES(base_damage_min),base_damage_max=VALUES(base_damage_max),
strength_bonus=VALUES(strength_bonus),agility_bonus=VALUES(agility_bonus),
intelligence_bonus=VALUES(intelligence_bonus),max_hp_bonus=VALUES(max_hp_bonus),
max_mana_bonus=VALUES(max_mana_bonus),physical_defense_bonus=VALUES(physical_defense_bonus),
magic_defense_bonus=VALUES(magic_defense_bonus),attack_speed_mod=VALUES(attack_speed_mod),
strength_scaling=VALUES(strength_scaling),agility_scaling=VALUES(agility_scaling),
threat_multiplier=VALUES(threat_multiplier),item_tier=VALUES(item_tier);

DELETE FROM shop_stock WHERE node_id='nodeOasisTown';
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeOasisTown',id,base_price FROM items
WHERE name LIKE 'Oasis %' AND item_category='equipment'
ON DUPLICATE KEY UPDATE price=VALUES(price);
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeOasisTown',id,ROUND(base_price*3) FROM items
WHERE name IN ('Healing Potion','Mana Potion','Travel Potion')
ON DUPLICATE KEY UPDATE price=VALUES(price);

INSERT INTO combat_encounter_tables(node_id,name,min_enemies,max_enemies)
VALUES ('nodeOasisTown','Oasis Town Dunes',2,4)
ON DUPLICATE KEY UPDATE min_enemies=VALUES(min_enemies),max_enemies=VALUES(max_enemies);

DELETE entry FROM combat_encounter_entries entry
JOIN combat_encounter_tables encounter ON encounter.id=entry.encounter_table_id
WHERE encounter.node_id='nodeOasisTown';
INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT encounter.id,npc.id,seed.weight,seed.min_count,seed.max_count
FROM combat_encounter_tables encounter
JOIN (
 SELECT 'Frenzied Duelist' npc_name,30 weight,1 min_count,2 max_count
 UNION ALL SELECT 'War Cleaver',28,1,2
 UNION ALL SELECT 'Storm Capacitor',22,1,1
 UNION ALL SELECT 'Mana Warden',14,1,1
 UNION ALL SELECT 'Plague Conductor',6,1,1
) seed
JOIN npcs npc ON npc.name=seed.npc_name
WHERE encounter.node_id='nodeOasisTown'
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);
