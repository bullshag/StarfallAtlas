-- Natural progression balance pass.  Safe on clean and established accounts.
USE accounts;

ALTER TABLE nodes ADD COLUMN IF NOT EXISTS recommended_min_level INT NOT NULL DEFAULT 1;
ALTER TABLE nodes ADD COLUMN IF NOT EXISTS recommended_max_level INT NOT NULL DEFAULT 3;
ALTER TABLE nodes ADD COLUMN IF NOT EXISTS expected_party_size INT NOT NULL DEFAULT 1;
ALTER TABLE nodes ADD COLUMN IF NOT EXISTS danger_rating VARCHAR(24) NOT NULL DEFAULT 'Low';
ALTER TABLE characters ADD COLUMN IF NOT EXISTS party_order INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS intelligence_scaling DECIMAL(8,3) NOT NULL DEFAULT 0;
ALTER TABLE character_equipment ADD COLUMN IF NOT EXISTS character_id INT NULL;
ALTER TABLE character_equipment ADD COLUMN IF NOT EXISTS item_id INT NULL;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS level_ratio DECIMAL(10,3) NOT NULL DEFAULT 0 AFTER intelligence_ratio;

CREATE TABLE IF NOT EXISTS level_progression (
 level INT PRIMARY KEY, xp_to_next INT NOT NULL
);
INSERT INTO level_progression(level,xp_to_next) VALUES
(1,52),(2,68),(3,88),(4,112),(5,140),(6,172),(7,208),(8,248),(9,292),(10,340),(11,392),(12,448),(13,508),(14,572),(15,640),(16,712),(17,788),(18,868),(19,952),(20,1040),(21,1132),(22,1228),(23,1328),(24,1432),(25,0)
ON DUPLICATE KEY UPDATE xp_to_next=VALUES(xp_to_next);

UPDATE character_equipment ce JOIN characters c ON c.account_id=ce.account_id AND c.name=ce.character_name SET ce.character_id=c.id WHERE ce.character_id IS NULL;
UPDATE character_equipment ce JOIN items i ON i.name=ce.item_name SET ce.item_id=i.id WHERE ce.item_id IS NULL;

-- New accounts are seeded by the API at Fort Aurus; existing travel is intentionally untouched.
INSERT INTO nodes(id,name,recommended_min_level,recommended_max_level,expected_party_size,danger_rating) VALUES
('nodeFortAurus','Fort Aurus',1,3,1,'Low'),('nodeSmallVillage','Small Village',2,5,1,'Low'),('nodeMounttown','Mounttown',3,6,2,'Guarded'),('nodeRiverVillage','River Village',6,9,3,'Moderate'),('nodeAshbrook','Ashbrook',9,12,3,'Moderate'),('nodeIronpass','Ironpass',12,15,4,'High'),('nodeOasisTown','Oasis Town',15,18,4,'High'),('nodeDreadscar','Dreadscar',18,22,5,'Severe'),('nodeCrownOfStars','Crown of Stars',22,25,5,'Extreme')
ON DUPLICATE KEY UPDATE name=VALUES(name),recommended_min_level=VALUES(recommended_min_level),recommended_max_level=VALUES(recommended_max_level),expected_party_size=VALUES(expected_party_size),danger_rating=VALUES(danger_rating);

ALTER TABLE combat_encounter_tables ADD COLUMN IF NOT EXISTS recommended_min_level INT NOT NULL DEFAULT 1;
ALTER TABLE combat_encounter_tables ADD COLUMN IF NOT EXISTS recommended_max_level INT NOT NULL DEFAULT 3;
ALTER TABLE combat_encounter_tables ADD COLUMN IF NOT EXISTS expected_party_size INT NOT NULL DEFAULT 1;
ALTER TABLE combat_encounter_tables ADD COLUMN IF NOT EXISTS difficulty_tier INT NOT NULL DEFAULT 0;

INSERT INTO npcs(name,level,current_hp,max_hp,mana,max_mana,action_speed,strength,dex,intelligence,melee_defense,magic_defense,role,targeting_style,power)
VALUES
('Ash Beast',10,150,150,35,35,10,27,18,10,16,13,'DPS','lowest_hp',700),
('Ash Raider',11,175,175,50,50,11,31,22,11,19,15,'DPS','lowest_hp',790),
('Mountain Raider',13,205,205,55,55,10,35,25,13,23,18,'DPS','highest_threat',930),
('Cave Brute',14,240,240,25,25,8,39,16,8,25,18,'Tank','highest_threat',1030),
('Scarred Legionnaire',19,335,335,70,70,10,50,34,17,36,29,'DPS','highest_threat',1580),
('Scarred Arcanist',20,305,305,260,260,11,20,30,54,30,42,'DPS','lowest_hp',1650),
('Crown Guardian',23,465,465,110,110,9,62,38,25,48,43,'Tank','highest_threat',2150),
('Crown Astromancer',24,425,425,350,350,11,25,40,64,42,54,'DPS','lowest_hp',2280),
('Crown Sovereign',25,720,720,500,500,10,68,48,66,55,55,'Boss','lowest_hp',3100)
ON DUPLICATE KEY UPDATE level=VALUES(level),current_hp=VALUES(current_hp),max_hp=VALUES(max_hp),mana=VALUES(mana),max_mana=VALUES(max_mana),action_speed=VALUES(action_speed),strength=VALUES(strength),dex=VALUES(dex),intelligence=VALUES(intelligence),melee_defense=VALUES(melee_defense),magic_defense=VALUES(magic_defense),role=VALUES(role),targeting_style=VALUES(targeting_style),power=VALUES(power);

DELETE s FROM combat_npc_abilities s JOIN npcs n ON n.id=s.npc_id WHERE n.name IN ('Ash Beast','Ash Raider','Mountain Raider','Cave Brute','Scarred Legionnaire','Scarred Arcanist','Crown Guardian','Crown Astromancer','Crown Sovereign');
INSERT INTO combat_npc_abilities(npc_id,ability_id,slot,priority)
SELECT n.id,a.id,x.slot,x.priority FROM (
 SELECT 'Ash Beast' n,'quick_strike' a,1 slot,1 priority UNION ALL SELECT 'Ash Raider','heavy_blow',1,1 UNION ALL SELECT 'Mountain Raider','wild_strike',1,1 UNION ALL SELECT 'Cave Brute','heavy_blow',1,1 UNION ALL SELECT 'Scarred Legionnaire','heavy_blow',1,1 UNION ALL SELECT 'Scarred Arcanist','fireball',1,1 UNION ALL SELECT 'Crown Guardian','heavy_blow',1,1 UNION ALL SELECT 'Crown Astromancer','fireball',1,1 UNION ALL SELECT 'Crown Sovereign','firestorm',1,1
) x JOIN npcs n ON n.name=x.n JOIN abilities a ON a.ability_key=x.a;

-- Standardized ability budgets: fixed base + level + primary-stat scaling.
UPDATE combat_ability_effects e JOIN abilities a ON a.id=e.ability_id
SET e.base_power=CASE a.ability_key WHEN 'quick_strike' THEN 3 WHEN 'fireball' THEN 5 WHEN 'heavy_blow' THEN 5 WHEN 'wild_strike' THEN 5 WHEN 'poison' THEN 1 WHEN 'firestorm' THEN 20 ELSE e.base_power END,
 e.level_ratio=CASE a.ability_key WHEN 'quick_strike' THEN .40 WHEN 'fireball' THEN .60 WHEN 'heavy_blow' THEN .50 WHEN 'wild_strike' THEN .40 WHEN 'poison' THEN .15 WHEN 'firestorm' THEN .50 ELSE e.level_ratio END,
 e.strength_ratio=CASE a.ability_key WHEN 'quick_strike' THEN .70 WHEN 'heavy_blow' THEN .40 ELSE e.strength_ratio END,
 e.dexterity_ratio=CASE a.ability_key WHEN 'quick_strike' THEN .35 WHEN 'heavy_blow' THEN .35 WHEN 'wild_strike' THEN .45 WHEN 'poison' THEN .25 ELSE e.dexterity_ratio END,
 e.intelligence_ratio=CASE a.ability_key WHEN 'fireball' THEN .80 WHEN 'firestorm' THEN .35 ELSE e.intelligence_ratio END
WHERE e.effect_index=1 AND a.ability_key IN ('quick_strike','fireball','heavy_blow','wild_strike','poison','firestorm');

-- Each regional table is explicit; no cross-town fallback pool is used.
DELETE e FROM combat_encounter_entries e JOIN combat_encounter_tables t ON t.id=e.encounter_table_id WHERE t.node_id IN ('nodeFortAurus','nodeSmallVillage','nodeMounttown','nodeRiverVillage','nodeAshbrook','nodeIronpass','nodeOasisTown','nodeDreadscar','nodeCrownOfStars');
DELETE FROM combat_encounter_tables WHERE node_id IN ('nodeFortAurus','nodeSmallVillage','nodeMounttown','nodeRiverVillage','nodeAshbrook','nodeIronpass','nodeOasisTown','nodeDreadscar','nodeCrownOfStars');
INSERT INTO combat_encounter_tables(node_id,name,min_enemies,max_enemies,recommended_min_level,recommended_max_level,expected_party_size,difficulty_tier) VALUES
('nodeFortAurus','Fort Aurus Patrols',1,2,1,3,1,0),('nodeSmallVillage','Small Village Roads',1,2,2,5,1,1),('nodeMounttown','Mounttown Pass',2,3,3,6,2,2),('nodeRiverVillage','River Village Banks',2,3,6,9,3,3),('nodeAshbrook','Ashbrook Wilds',2,4,9,12,3,4),('nodeIronpass','Ironpass Heights',3,4,12,15,4,5),('nodeOasisTown','Oasis Frontier',3,4,15,18,4,6),('nodeDreadscar','Dreadscar Legion',4,5,18,22,5,8),('nodeCrownOfStars','Crown Guardians',4,6,22,25,5,10);
INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT t.id,n.id,x.weight,x.min_count,x.max_count FROM (
 SELECT 'nodeFortAurus' node,'Snow Wolf' npc,70 weight,0 min_count,2 max_count UNION ALL SELECT 'nodeFortAurus','Bandit Guard',30,0,1 UNION ALL
 SELECT 'nodeSmallVillage','Snow Wolf',45,0,2 UNION ALL SELECT 'nodeSmallVillage','Bandit Guard',35,0,2 UNION ALL SELECT 'nodeSmallVillage','Cultist Acolyte',15,0,1 UNION ALL SELECT 'nodeSmallVillage','Bandit Captain',5,0,1 UNION ALL
 SELECT 'nodeMounttown','Bandit Guard',40,0,2 UNION ALL SELECT 'nodeMounttown','Bandit Captain',25,0,1 UNION ALL SELECT 'nodeMounttown','Ember Adept',20,0,1 UNION ALL SELECT 'nodeMounttown','Ironjaw Brute',15,0,1 UNION ALL
 SELECT 'nodeRiverVillage','Cultist Acolyte',35,0,2 UNION ALL SELECT 'nodeRiverVillage','Grove Mender',20,0,1 UNION ALL SELECT 'nodeRiverVillage','Dragon Whelp',25,0,2 UNION ALL SELECT 'nodeRiverVillage','Thorn Sprite',20,0,2 UNION ALL
 SELECT 'nodeAshbrook','Ashen Cultist',25,0,2 UNION ALL SELECT 'nodeAshbrook','Mossback Treant',20,0,1 UNION ALL SELECT 'nodeAshbrook','Grove Stalker',25,0,2 UNION ALL SELECT 'nodeAshbrook','Ash Beast',30,0,2 UNION ALL
 SELECT 'nodeIronpass','Ironclad Mercenary',25,0,2 UNION ALL SELECT 'nodeIronpass','Grave Knight',20,0,1 UNION ALL SELECT 'nodeIronpass','Mountain Raider',30,0,2 UNION ALL SELECT 'nodeIronpass','Cave Brute',25,0,1 UNION ALL
 SELECT 'nodeOasisTown','Sand Raider',35,0,2 UNION ALL SELECT 'nodeOasisTown','War Cleaver',20,0,1 UNION ALL SELECT 'nodeOasisTown','Storm Capacitor',20,0,1 UNION ALL SELECT 'nodeOasisTown','Dune Spellbinder',25,0,1 UNION ALL
 SELECT 'nodeDreadscar','Scarred Legionnaire',45,0,3 UNION ALL SELECT 'nodeDreadscar','Scarred Arcanist',30,0,2 UNION ALL SELECT 'nodeDreadscar','Grave Knight',25,0,2 UNION ALL
 SELECT 'nodeCrownOfStars','Crown Guardian',45,0,3 UNION ALL SELECT 'nodeCrownOfStars','Crown Astromancer',35,0,2 UNION ALL SELECT 'nodeCrownOfStars','Crown Sovereign',20,0,1
) x JOIN combat_encounter_tables t ON t.node_id=x.node JOIN npcs n ON n.name=x.npc;

-- Old level trigger duplicates server authority and used a different curve.
DROP TRIGGER IF EXISTS after_character_experience_update;
DROP TRIGGER IF EXISTS character_experience_level_up;
