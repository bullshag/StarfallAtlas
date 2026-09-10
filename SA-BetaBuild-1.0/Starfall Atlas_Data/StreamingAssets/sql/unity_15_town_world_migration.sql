-- Idempotent eight-town frontier consolidation.
-- Retains Fort Aurus, Small Village, Mounttown, River Village, Ashbrook,
-- Ironpass, Dreadscar, and Crown of Stars. Towns 7-13 from the former plan
-- are retired and their progression is folded into the remaining shops.

INSERT INTO nodes (id,name) VALUES
('nodeAshbrook','Ashbrook'),
('nodeIronpass','Ironpass'),
('nodeDreadscar','Dreadscar'),
('nodeCrownOfStars','Crown of Stars')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Move persistent references away from retired nodes before deleting them.
UPDATE travel_state
SET current_node = CASE
        WHEN current_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere') THEN 'nodeIronpass'
        WHEN current_node IN ('nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge') THEN 'nodeDreadscar'
        ELSE current_node END,
    destination_node = CASE
        WHEN destination_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere') THEN 'nodeIronpass'
        WHEN destination_node IN ('nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge') THEN 'nodeDreadscar'
        ELSE destination_node END
WHERE current_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge')
   OR destination_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');

UPDATE travel_logs SET from_node='nodeIronpass'
WHERE from_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere');
UPDATE travel_logs SET to_node='nodeIronpass'
WHERE to_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere');
UPDATE travel_logs SET from_node='nodeDreadscar'
WHERE from_node IN ('nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
UPDATE travel_logs SET to_node='nodeDreadscar'
WHERE to_node IN ('nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');

UPDATE player_position
SET last_town_node_id = CASE
    WHEN last_town_node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere') THEN 'nodeIronpass'
    ELSE 'nodeDreadscar' END
WHERE last_town_node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');

UPDATE combat_encounters SET node_id='nodeIronpass'
WHERE node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere');
UPDATE combat_encounters SET node_id='nodeDreadscar'
WHERE node_id IN ('nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');

DELETE FROM node_connections
WHERE from_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge')
   OR to_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
DELETE FROM activities
WHERE node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
DELETE FROM unity_tavern_recruits
WHERE node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
DELETE FROM shop_stock
WHERE node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
DELETE FROM combat_encounter_tables
WHERE node_id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
UPDATE quest_definitions
SET destination_node='nodeDreadscar',
    description='Deliver the frontier muster roll to Dreadscar.'
WHERE quest_key='ironpass_muster';
DELETE FROM quest_definitions
WHERE source_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge')
   OR destination_node IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');
DELETE FROM nodes
WHERE id IN ('nodeMirewatch','nodeSunreach','nodeFrostmere','nodeThornwall','nodeStarfallCrossing','nodeEmberhold','nodeSkyforge');

-- Rebuild the four expansion-town facility sets without duplicate rows.
DELETE FROM activities
WHERE node_id IN ('nodeAshbrook','nodeIronpass','nodeDreadscar','nodeCrownOfStars');
INSERT INTO activities(node_id,activity_type,description,duration_seconds) VALUES
('nodeAshbrook','tavern','Hire party members at the Ashbrook tavern.',0),
('nodeAshbrook','shop','Browse Ashbrook equipment.',0),
('nodeAshbrook','temple','Restore and bless the party at Ashbrook temple.',0),
('nodeAshbrook','town_board','View Ashbrook work orders.',0),
('nodeAshbrook','search_for_enemies','Search the Ashbrook region for enemies.',0),
('nodeIronpass','tavern','Hire party members at the Ironpass tavern.',0),
('nodeIronpass','shop','Browse Ironpass equipment.',0),
('nodeIronpass','temple','Restore and bless the party at Ironpass temple.',0),
('nodeIronpass','town_board','View Ironpass work orders.',0),
('nodeIronpass','search_for_enemies','Search the Ironpass region for enemies.',0),
('nodeDreadscar','tavern','Hire party members at Dreadscar.',0),
('nodeDreadscar','shop','Browse Dreadscar equipment.',0),
('nodeDreadscar','temple','Restore and bless the party at Dreadscar.',0),
('nodeDreadscar','town_board','View Dreadscar work orders.',0),
('nodeDreadscar','search_for_enemies','Search the Dreadscar region for enemies.',0),
('nodeDreadscar','elite_search','Search for elite encounters.',0),
('nodeCrownOfStars','tavern','Hire party members at Crown of Stars.',0),
('nodeCrownOfStars','shop','Browse Crown of Stars equipment.',0),
('nodeCrownOfStars','temple','Restore and bless the party at Crown of Stars.',0),
('nodeCrownOfStars','town_board','View Crown of Stars work orders.',0),
('nodeCrownOfStars','search_for_enemies','Search the Crown of Stars region for enemies.',0),
('nodeCrownOfStars','blessings','Purchase Crown of Stars blessings.',0),
('nodeCrownOfStars','boss_search','Search for endgame encounters.',0);

-- Keep three quests per remaining expansion town. Ironpass now connects
-- directly to Dreadscar so the courier chain never points at a retired town.
INSERT INTO quest_definitions
(quest_key,source_node,destination_node,title,description,reward_gold,reward_xp,reward_item_key,reward_item_quantity,objective_type,objective_target,objective_required)
VALUES
('ashbrook_cinderwood','nodeAshbrook','nodeAshbrook','CINDERWOOD THREAT','Defeat the ash beasts threatening Ashbrook.',220,70,'healing_potion',2,'Kill','ash_beast',5),
('ashbrook_dispatch','nodeAshbrook','nodeIronpass','ASHBROOK DISPATCH','Carry Ashbrook orders to Ironpass.',180,55,NULL,0,'Courier','ashbrook_dispatch',1),
('ashbrook_caravan','nodeAshbrook','nodeAshbrook','THE BURNED CARAVAN','Recover supplies from the burned caravan.',260,85,'mana_potion',2,'Kill','ash_raider',4),
('ironpass_passbreakers','nodeIronpass','nodeIronpass','PASSBREAKERS','Defeat the raiders blocking Ironpass.',420,145,'iron_sword',1,'Kill','mountain_raider',6),
('ironpass_muster','nodeIronpass','nodeDreadscar','IRONPASS MUSTER','Deliver the frontier muster roll to Dreadscar.',460,155,NULL,0,'Courier','ironpass_muster',1),
('ironpass_smith','nodeIronpass','nodeIronpass','THE MISSING SMITH','Rescue the missing town smith.',520,180,'heavy_shield',1,'Kill','cave_brute',4),
('dreadscar_legion','nodeDreadscar','nodeDreadscar','SCARRED LEGION','Defeat the Scarred Legion.',1200,430,'plate_armor',1,'Kill','scarred_legion',8),
('dreadscar_dispatch','nodeDreadscar','nodeCrownOfStars','FINAL DISPATCH','Deliver the final dispatch to Crown of Stars.',760,250,NULL,0,'Courier','final_dispatch',1),
('dreadscar_omen','nodeDreadscar','nodeDreadscar','THE NEMIFAX OMEN','Investigate Nemifax''s influence.',1400,500,'trinket',1,'Kill','nemifax_omen',1),
('crown_guard','nodeCrownOfStars','nodeCrownOfStars','CROWN GUARD','Defeat the Crown Guard.',1600,560,'greatsword',1,'Kill','crown_guardian',8),
('crown_seal','nodeCrownOfStars','nodeCrownOfStars','THE LAST SEAL','Recover the final seal.',1800,620,'amulet',1,'Kill','last_seal_guardian',3),
('crownfall','nodeCrownOfStars','nodeCrownOfStars','CROWNFALL','Defeat the designated final encounter.',2500,1000,'trinket',1,'Kill','crown_boss',1)
ON DUPLICATE KEY UPDATE
source_node=VALUES(source_node),destination_node=VALUES(destination_node),title=VALUES(title),
description=VALUES(description),reward_gold=VALUES(reward_gold),reward_xp=VALUES(reward_xp),
reward_item_key=VALUES(reward_item_key),reward_item_quantity=VALUES(reward_item_quantity),
objective_type=VALUES(objective_type),objective_target=VALUES(objective_target),objective_required=VALUES(objective_required);

-- Persist an explicit power tier on every item. Existing low-tier authored
-- equipment keeps its current stats; later shops receive scaled variants.
ALTER TABLE items ADD COLUMN IF NOT EXISTS item_tier TINYINT UNSIGNED NOT NULL DEFAULT 0;
UPDATE items SET item_tier=1 WHERE name LIKE 'Aurus %';
UPDATE items SET item_tier=2 WHERE name IN ('Wayfarer Grand Amulet','Prismatic Covenant','Chronicle Stone','Sovereign Compass');
UPDATE items SET item_tier=3 WHERE name LIKE 'Mounttown %';
UPDATE items SET item_tier=4 WHERE name IN
('Riverlord Torque','Tidesage Pendant','Floodsteel Saber','Deepwood Warbow','Riverguard Shield','Currentfang Dagger','Riverguard Greathelm','Tidesage Circlet','Riverlord Cuirass','Mistwalker Raiment','Riverguard Legplates','Rapidwater Leggings','River Crown Emblem','Whispering Reed');

-- Remove obsolete prototype equipment from specialist and mid-game shops.
-- Consumables and spell tomes remain available.
DELETE s FROM shop_stock s
JOIN items i ON i.id=s.item_id
WHERE s.node_id IN ('nodeSmallVillage','nodeMounttown','nodeRiverVillage')
  AND i.item_category='equipment' AND i.item_tier=0;

-- Generate two choices for each supported equipment slot in every remaining
-- expansion shop. Each pair spans that town's advertised tier range.
INSERT INTO items
(name,base_price,stackable,description,item_category,equipment_slot,hand_type,weapon_type,
 base_damage_min,base_damage_max,strength_bonus,agility_bonus,intelligence_bonus,max_hp_bonus,
 max_mana_bonus,physical_defense_bonus,magic_defense_bonus,attack_speed_mod,strength_scaling,
 agility_scaling,threat_multiplier,item_tier)
SELECT
 CONCAT(g.prefix,' ',g.name),
 ROUND(g.base_price * (1 + g.generated_tier * 1.75)),
 0,
 CONCAT('Tier ',g.generated_tier,' equipment crafted for ',g.town_name,'. ',g.description),
 g.item_category,g.equipment_slot,g.hand_type,g.weapon_type,
 ROUND(g.base_damage_min * (1 + g.generated_tier * 0.42)),
 ROUND(g.base_damage_max * (1 + g.generated_tier * 0.42)),
 ROUND(g.strength_bonus * (1 + g.generated_tier * 0.35)),
 ROUND(g.agility_bonus * (1 + g.generated_tier * 0.35)),
 ROUND(g.intelligence_bonus * (1 + g.generated_tier * 0.35)),
 ROUND(g.max_hp_bonus * (1 + g.generated_tier * 0.40)),
 ROUND(g.max_mana_bonus * (1 + g.generated_tier * 0.40)),
 ROUND(g.physical_defense_bonus * (1 + g.generated_tier * 0.38)),
 ROUND(g.magic_defense_bonus * (1 + g.generated_tier * 0.38)),
 g.attack_speed_mod,g.strength_scaling,g.agility_scaling,g.threat_multiplier,g.generated_tier
FROM (
 SELECT t.node_id,t.prefix,t.town_name,i.*,
        CASE WHEN i.name IN ('Sage Pendant','Hunter Bow','Runed Wand','Mystic Hood','Runespun Vestment','Mystic Leggings','Clockwork Feather')
             THEN t.high_tier ELSE t.low_tier END AS generated_tier
 FROM (
   SELECT 'nodeAshbrook' node_id,'Ashbrook' prefix,'Ashbrook' town_name,4 low_tier,5 high_tier
   UNION ALL SELECT 'nodeIronpass','Ironpass','Ironpass',5,7
   UNION ALL SELECT 'nodeDreadscar','Dreadscar','Dreadscar',7,9
   UNION ALL SELECT 'nodeCrownOfStars','Crown','Crown of Stars',10,10
 ) t
 CROSS JOIN items i
 WHERE i.name IN
 ('Copper Amulet','Sage Pendant','Shortsword','Hunter Bow','Heavy Shield','Runed Wand','Iron Helm','Mystic Hood','Plate Armor','Runespun Vestment','Iron Greaves','Mystic Leggings','Guardian Sigil','Clockwork Feather')
) g
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

DELETE FROM shop_stock
WHERE node_id IN ('nodeAshbrook','nodeIronpass','nodeDreadscar','nodeCrownOfStars');
INSERT INTO shop_stock(node_id,item_id,price)
SELECT t.node_id,i.id,i.base_price
FROM (
 SELECT 'nodeAshbrook' node_id,'Ashbrook' prefix
 UNION ALL SELECT 'nodeIronpass','Ironpass'
 UNION ALL SELECT 'nodeDreadscar','Dreadscar'
 UNION ALL SELECT 'nodeCrownOfStars','Crown'
) t
JOIN items i ON i.name LIKE CONCAT(t.prefix,' %')
WHERE i.item_category='equipment'
ON DUPLICATE KEY UPDATE price=VALUES(price);

-- Keep core consumables available as difficulty rises without pretending that
-- potions are equipment tiers.
INSERT INTO shop_stock(node_id,item_id,price)
SELECT t.node_id,i.id,ROUND(i.base_price*t.price_multiplier)
FROM (
 SELECT 'nodeAshbrook' node_id,2 price_multiplier
 UNION ALL SELECT 'nodeIronpass',3
 UNION ALL SELECT 'nodeDreadscar',5
 UNION ALL SELECT 'nodeCrownOfStars',7
) t
JOIN items i ON i.name IN ('Healing Potion','Mana Potion','Travel Potion')
ON DUPLICATE KEY UPDATE price=VALUES(price);
