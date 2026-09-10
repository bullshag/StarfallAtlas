CREATE TABLE IF NOT EXISTS quest_definitions (
 id INT AUTO_INCREMENT PRIMARY KEY, quest_key VARCHAR(64) NOT NULL UNIQUE, source_node VARCHAR(64) NOT NULL,
 destination_node VARCHAR(64) NOT NULL, title VARCHAR(128) NOT NULL, description TEXT NOT NULL,
 reward_gold INT NOT NULL DEFAULT 0, reward_xp INT NOT NULL DEFAULT 0, reward_item_key VARCHAR(64) NULL,
 reward_item_quantity INT NOT NULL DEFAULT 0, objective_type ENUM('Courier','Kill') NOT NULL,
 objective_target VARCHAR(64) NOT NULL, objective_required INT NOT NULL DEFAULT 1
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS player_quests (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, account_id INT NOT NULL, quest_id INT NOT NULL, status ENUM('Active','ReadyToTurnIn','TurnedIn','Abandoned') NOT NULL,
 progress INT NOT NULL DEFAULT 0, parcel_key VARCHAR(64) NULL, accepted_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_player_quest(account_id,quest_id), KEY ix_player_status(account_id,status),
 CONSTRAINT fk_pq_quest FOREIGN KEY(quest_id) REFERENCES quest_definitions(id) ON DELETE CASCADE
) ENGINE=InnoDB;
ALTER TABLE quest_definitions MODIFY objective_type VARCHAR(32) NOT NULL;
CREATE TABLE IF NOT EXISTS quest_requirements (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, quest_id INT NOT NULL, requirement_type VARCHAR(32) NOT NULL,
 required_level INT NULL, required_quest_key VARCHAR(64) NULL,
 UNIQUE KEY uq_quest_requirement (quest_id, requirement_type, required_level, required_quest_key), KEY ix_quest_requirements_quest (quest_id),
 CONSTRAINT fk_quest_requirement_definition FOREIGN KEY (quest_id) REFERENCES quest_definitions(id) ON DELETE CASCADE
) ENGINE=InnoDB;
INSERT IGNORE INTO quest_definitions(quest_key,source_node,destination_node,title,description,reward_gold,reward_xp,reward_item_key,reward_item_quantity,objective_type,objective_target,objective_required) VALUES
('sealed_orders','nodeFortAurus','nodeMounttown','SEALED ORDERS','Deliver a sealed parcel to Mounttown.',90,20,NULL,0,'Courier','sealed_orders',1),
('wolves_at_gate','nodeFortAurus','nodeFortAurus','WOLVES AT THE GATE','Defeat four Snow Wolves.',75,15,'healing_potion',1,'Kill','snow_wolf',4),
('forge_ledger','nodeMounttown','nodeRiverVillage','THE FORGE LEDGER','Deliver a ledger to River Village.',100,25,NULL,0,'Courier','forge_ledger',1),
('bandit_line','nodeMounttown','nodeMounttown','BREAK THE BANDIT LINE','Defeat four Bandit Guards.',110,25,'healing_potion',1,'Kill','bandit_guard',4),
('river_medicine','nodeRiverVillage','nodeSmallVillage','RIVER MEDICINE','Deliver medicine to Small Village.',80,20,'healing_potion',1,'Courier','river_medicine',1),
('cult_banks','nodeRiverVillage','nodeRiverVillage','CULT ON THE BANKS','Defeat three Cultist Acolytes.',130,35,'cloth_robe',1,'Kill','cultist_acolyte',3),
('harvest_tallies','nodeSmallVillage','nodeFortAurus','HARVEST TALLIES','Deliver harvest records to Fort Aurus.',140,35,NULL,0,'Courier','harvest_tallies',1),
('captains_due','nodeSmallVillage','nodeSmallVillage','THE CAPTAIN''S DUE','Defeat a Bandit Captain.',160,50,'dagger',1,'Kill','bandit_captain',1),
('fort_supply_run','nodeFortAurus','nodeSmallVillage','FORT SUPPLY RUN','Deliver emergency supplies to Small Village.',120,30,NULL,0,'Courier','fort_supply_run',1),
('mounttown_patrol','nodeMounttown','nodeFortAurus','MOUNTTOWN PATROL','Defeat five Bandit Guards threatening the road.',150,40,'mana_potion',1,'Kill','bandit_guard',5),
('river_whelp_hunt','nodeRiverVillage','nodeRiverVillage','WHELP HUNT','Defeat three dragon whelps near the river.',190,55,'iron_sword',1,'Kill','dragon_whelp',3);

INSERT INTO quest_requirements (quest_id,requirement_type,required_level,required_quest_key) SELECT q.id,'Level',2,NULL FROM quest_definitions q WHERE q.quest_key='mounttown_patrol' AND NOT EXISTS (SELECT 1 FROM quest_requirements r WHERE r.quest_id=q.id AND r.requirement_type='Level' AND r.required_level=2);
INSERT INTO quest_requirements (quest_id,requirement_type,required_level,required_quest_key) SELECT q.id,'QuestCompleted',NULL,'wolves_at_gate' FROM quest_definitions q WHERE q.quest_key='captains_due' AND NOT EXISTS (SELECT 1 FROM quest_requirements r WHERE r.quest_id=q.id AND r.requirement_type='QuestCompleted' AND r.required_quest_key='wolves_at_gate');
INSERT INTO quest_requirements (quest_id,requirement_type,required_level,required_quest_key) SELECT q.id,'QuestCompleted',NULL,'bandit_line' FROM quest_definitions q WHERE q.quest_key='captains_due' AND NOT EXISTS (SELECT 1 FROM quest_requirements r WHERE r.quest_id=q.id AND r.requirement_type='QuestCompleted' AND r.required_quest_key='bandit_line');
