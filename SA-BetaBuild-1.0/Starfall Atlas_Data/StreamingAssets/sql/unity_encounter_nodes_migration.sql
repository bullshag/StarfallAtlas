-- Encounter-only world nodes. Safe to rerun against accounts.
USE accounts;

INSERT INTO nodes(id,name) VALUES
('nodeWolfDen','Wolf Den'),
('nodeDesertCave','Desert Cave'),
('nodeCultCave','Cult Cave'),
('nodeVolcano','Volcano'),
('nodeDragonLair','Dragon Lair')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- These locations intentionally expose no tavern, shop, temple, or board.
DELETE FROM activities WHERE node_id IN
('nodeWolfDen','nodeDesertCave','nodeCultCave','nodeVolcano','nodeDragonLair');
INSERT INTO activities(node_id,activity_type,description,duration_seconds) VALUES
('nodeWolfDen','search_for_enemies','Search the Wolf Den for hostile creatures.',0),
('nodeDesertCave','search_for_enemies','Search the Desert Cave for hostile creatures.',0),
('nodeCultCave','search_for_enemies','Search the Cult Cave for hostile creatures.',0),
('nodeVolcano','search_for_enemies','Search the Volcano for hostile creatures.',0),
('nodeDragonLair','search_for_enemies','Search the Dragon Lair for hostile creatures.',0);

INSERT INTO combat_encounter_tables(node_id,name,min_enemies,max_enemies) VALUES
('nodeWolfDen','Wolf Den Hunt',2,4),
('nodeDesertCave','Desert Cave Expedition',2,4),
('nodeCultCave','Cult Cave Expedition',2,4),
('nodeVolcano','Volcano Expedition',2,4),
('nodeDragonLair','Dragon Lair Assault',1,3)
ON DUPLICATE KEY UPDATE min_enemies=VALUES(min_enemies),max_enemies=VALUES(max_enemies);

DELETE entry FROM combat_encounter_entries entry
JOIN combat_encounter_tables encounter ON encounter.id=entry.encounter_table_id
WHERE encounter.node_id IN
('nodeWolfDen','nodeDesertCave','nodeCultCave','nodeVolcano','nodeDragonLair');

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT encounter.id,npc.id,seed.weight,seed.min_count,seed.max_count
FROM combat_encounter_tables encounter
JOIN (
 SELECT 'Snow Wolf' npc_name,60 weight,1 min_count,3 max_count, 'nodeWolfDen' node_id
 UNION ALL SELECT 'Frenzied Duelist',25,1,2,'nodeWolfDen'
 UNION ALL SELECT 'War Cleaver',15,1,1,'nodeWolfDen'
 UNION ALL SELECT 'Ironjaw Brute',35,1,2,'nodeDesertCave'
 UNION ALL SELECT 'Storm Capacitor',40,1,2,'nodeDesertCave'
 UNION ALL SELECT 'Plague Conductor',25,1,1,'nodeDesertCave'
 UNION ALL SELECT 'Blight Hexer',45,1,2,'nodeCultCave'
 UNION ALL SELECT 'Cultist Acolyte',35,1,2,'nodeCultCave'
 UNION ALL SELECT 'Plague Conductor',20,1,1,'nodeCultCave'
 UNION ALL SELECT 'Ember Adept',40,1,2,'nodeVolcano'
 UNION ALL SELECT 'War Cleaver',35,1,2,'nodeVolcano'
 UNION ALL SELECT 'Storm Capacitor',25,1,1,'nodeVolcano'
 UNION ALL SELECT 'Plague Conductor',35,1,2,'nodeDragonLair'
 UNION ALL SELECT 'War Cleaver',35,1,2,'nodeDragonLair'
 UNION ALL SELECT 'Mana Warden',30,1,1,'nodeDragonLair'
) seed ON seed.node_id=encounter.node_id
JOIN npcs npc ON npc.name=seed.npc_name
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);
