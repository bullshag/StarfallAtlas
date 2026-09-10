-- Fixed encounter pools for special locations. Idempotent.
USE accounts;

UPDATE combat_encounter_tables
SET min_enemies=2,max_enemies=5
WHERE node_id='nodeWolfDen';
UPDATE combat_encounter_tables
SET min_enemies=1,max_enemies=1
WHERE node_id IN ('nodeVolcano','nodeCultCave');

DELETE e FROM combat_encounter_entries e
JOIN combat_encounter_tables t ON t.id=e.encounter_table_id
WHERE t.node_id IN ('nodeWolfDen','nodeVolcano','nodeCultCave');

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT t.id,n.id,1,1,1
FROM combat_encounter_tables t
JOIN npcs n ON n.name='Snow Wolf'
WHERE t.node_id='nodeWolfDen'
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT t.id,n.id,1,1,1
FROM combat_encounter_tables t
JOIN npcs n ON n.name='Cinderlord Ignivar'
WHERE t.node_id='nodeVolcano'
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT t.id,n.id,1,1,1
FROM combat_encounter_tables t
JOIN npcs n ON n.name='Nemifax the Terrible'
WHERE t.node_id='nodeCultCave'
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);
