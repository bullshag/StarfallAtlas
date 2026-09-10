-- Database-driven equipment catalog for the Unity vertical slice.
-- Safe to rerun against the accounts database.
USE accounts;

ALTER TABLE items ADD COLUMN IF NOT EXISTS weapon_type VARCHAR(24) NULL;
ALTER TABLE items ADD COLUMN IF NOT EXISTS base_damage_min INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS base_damage_max INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS strength_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS agility_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS intelligence_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS max_hp_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS max_mana_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS physical_defense_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS magic_defense_bonus INT NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS attack_speed_mod DECIMAL(6,2) NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS strength_scaling DECIMAL(6,4) NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS agility_scaling DECIMAL(6,4) NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS threat_multiplier DECIMAL(6,3) NOT NULL DEFAULT 1;

INSERT INTO items
(name, base_price, stackable, description, item_category, equipment_slot, hand_type,
 weapon_type, base_damage_min, base_damage_max, strength_bonus, agility_bonus,
 intelligence_bonus, max_hp_bonus, max_mana_bonus, physical_defense_bonus,
 magic_defense_bonus, attack_speed_mod, strength_scaling, agility_scaling, threat_multiplier)
VALUES
-- Amulets (4)
('Copper Amulet',45,0,'A simple amulet that steadies a new adventurer.','equipment','Amulet',NULL,NULL,0,0,1,0,0,4,0,0,0,0,0,0,1),
('Amulet of Vigor',90,0,'A warm pendant that strengthens its wearer.','equipment','Amulet',NULL,NULL,0,0,2,0,0,10,0,0,0,0,0,0,1),
('Sage Pendant',105,0,'A silver pendant etched with focusing runes.','equipment','Amulet',NULL,NULL,0,0,0,0,3,0,10,0,2,0,0,0,1),
('Windglass Locket',120,0,'A light crystal locket that quickens movement.','equipment','Amulet',NULL,NULL,0,0,0,2,1,0,4,0,0,8,0,0,1),

-- Left-hand catalog (4)
('Shortsword',50,0,'A balanced one-handed sword.','equipment','LeftHand','one_handed','sword',5,8,0,0,0,0,0,0,0,4,0.40,0.60,1),
('Ashen Dagger',65,0,'A fast one-handed blade with a narrow edge.','equipment','LeftHand','one_handed','dagger',4,7,0,2,0,0,0,0,0,18,0.40,0.60,1),
('Greatsword',150,0,'A heavy two-handed blade that rewards strength.','equipment','LeftHand','two_handed','greatsword',11,17,3,0,0,0,0,0,0,-20,0.75,0.25,1),
('Hunter Bow',125,0,'A two-handed bow built for agile hunters. Its attacks generate half threat.','equipment','LeftHand','two_handed','bow',8,14,0,3,0,0,0,0,0,10,0.25,0.75,0.5),

-- Right-hand catalog (4)
('Heavy Shield',80,0,'A broad shield that absorbs punishing blows.','equipment','RightHand','shield','shield',0,0,0,0,0,8,0,5,1,-12,0,0,1),
('Iron Buckler',55,0,'A compact shield with little impact on speed.','equipment','RightHand','shield','shield',0,0,0,1,0,3,0,3,0,-3,0,0,1),
('Mace',70,0,'A sturdy one-handed mace.','equipment','RightHand','one_handed','mace',6,10,2,0,0,0,0,0,0,-6,0.40,0.60,1),
('Runed Wand',95,0,'A quick one-handed focus for battle magic.','equipment','RightHand','one_handed','wand',4,7,0,0,3,0,8,0,2,12,0.40,0.60,1),

-- Head (4)
('Leather Cap',25,0,'A light cap offering modest protection.','equipment','Head',NULL,NULL,0,0,0,1,0,2,0,2,0,0,0,0,1),
('Iron Helm',85,0,'A solid helm made for front-line fighters.','equipment','Head',NULL,NULL,0,0,1,0,0,7,0,5,1,-3,0,0,1),
('Mystic Hood',90,0,'A hood woven with mana-conducting thread.','equipment','Head',NULL,NULL,0,0,0,0,2,0,9,0,3,0,0,0,1),
('Scout Hood',80,0,'A fitted hood that keeps the wearer alert.','equipment','Head',NULL,NULL,0,0,0,2,0,0,0,2,1,5,0,0,1),

-- Body (4)
('Cloth Robe',30,0,'A simple robe with minor magical protection.','equipment','Body',NULL,NULL,0,0,0,0,1,0,5,1,3,0,0,0,1),
('Leather Armor',60,0,'Flexible armor suited to mobile fighters.','equipment','Body',NULL,NULL,0,0,0,2,0,7,0,4,2,2,0,0,1),
('Plate Armor',120,0,'Heavy armor offering excellent physical protection.','equipment','Body',NULL,NULL,0,0,2,0,0,15,0,9,3,-8,0,0,1),
('Runespun Vestment',135,0,'An enchanted vestment that reinforces body and mind.','equipment','Body',NULL,NULL,0,0,0,0,3,5,12,2,6,0,0,0,1),

-- Legs (4)
('Leather Boots',25,0,'Light boots for rough roads.','equipment','Legs',NULL,NULL,0,0,0,1,0,0,0,1,0,3,0,0,1),
('Iron Greaves',75,0,'Heavy greaves that guard the legs.','equipment','Legs',NULL,NULL,0,0,1,0,0,6,0,5,0,-4,0,0,1),
('Mystic Leggings',85,0,'Inscribed leggings that preserve magical energy.','equipment','Legs',NULL,NULL,0,0,0,0,2,0,10,0,3,0,0,0,1),
('Scout Trousers',70,0,'Supple travel gear made for quick footwork.','equipment','Legs',NULL,NULL,0,0,0,2,0,0,0,1,1,7,0,0,1),

-- Trinkets (4)
('Lucky Charm',55,0,'A small charm that sharpens every instinct.','equipment','Trinket',NULL,NULL,0,0,1,1,1,0,0,0,0,0,0,0,1),
('Guardian Sigil',100,0,'A warding token that bolsters both defenses.','equipment','Trinket',NULL,NULL,0,0,0,0,0,6,0,3,3,0,0,0,1),
('Emberstone',110,0,'A hot stone that empowers force and spellcraft.','equipment','Trinket',NULL,NULL,0,0,2,0,2,0,5,0,0,-5,0,0,1),
('Clockwork Feather',125,0,'A precise mechanism that greatly increases attack speed.','equipment','Trinket',NULL,NULL,0,0,0,2,0,0,0,0,0,15,0,0,1)
ON DUPLICATE KEY UPDATE
base_price=VALUES(base_price), stackable=VALUES(stackable), description=VALUES(description),
item_category=VALUES(item_category), equipment_slot=VALUES(equipment_slot), hand_type=VALUES(hand_type),
weapon_type=VALUES(weapon_type), base_damage_min=VALUES(base_damage_min), base_damage_max=VALUES(base_damage_max),
strength_bonus=VALUES(strength_bonus), agility_bonus=VALUES(agility_bonus), intelligence_bonus=VALUES(intelligence_bonus),
max_hp_bonus=VALUES(max_hp_bonus), max_mana_bonus=VALUES(max_mana_bonus),
physical_defense_bonus=VALUES(physical_defense_bonus), magic_defense_bonus=VALUES(magic_defense_bonus),
attack_speed_mod=VALUES(attack_speed_mod), strength_scaling=VALUES(strength_scaling),
agility_scaling=VALUES(agility_scaling), threat_multiplier=VALUES(threat_multiplier);

-- Keep pre-existing saves useful by giving legacy weapon rows complete combat metadata.
UPDATE items SET description='A quick one-handed knife.',weapon_type='dagger',base_damage_min=3,base_damage_max=6,
 attack_speed_mod=15,strength_scaling=0.40,agility_scaling=0.60,threat_multiplier=1 WHERE name='Dagger';
UPDATE items SET description='A two-handed hunting bow. Its attacks generate half threat.',weapon_type='bow',base_damage_min=7,base_damage_max=12,
 attack_speed_mod=8,strength_scaling=0.25,agility_scaling=0.75,threat_multiplier=0.5 WHERE name='Bow';
UPDATE items SET description='A dependable one-handed military sword.',weapon_type='sword',base_damage_min=7,base_damage_max=11,
 attack_speed_mod=0,strength_scaling=0.40,agility_scaling=0.60,threat_multiplier=1 WHERE name='Longsword';
UPDATE items SET description='A heavy two-handed spellcaster staff.',weapon_type='staff',base_damage_min=7,base_damage_max=12,
 attack_speed_mod=-12,strength_scaling=0.75,agility_scaling=0.25,threat_multiplier=1,intelligence_bonus=2,max_mana_bonus=8 WHERE name='Staff';
UPDATE items SET description='A light one-handed magical focus.',weapon_type='wand',base_damage_min=3,base_damage_max=6,
 attack_speed_mod=14,strength_scaling=0.40,agility_scaling=0.60,threat_multiplier=1,intelligence_bonus=2 WHERE name='Wand';
UPDATE items SET description='A two-handed ironshod casting rod.',weapon_type='rod',base_damage_min=8,base_damage_max=13,
 attack_speed_mod=-10,strength_scaling=0.75,agility_scaling=0.25,threat_multiplier=1,intelligence_bonus=2 WHERE name='Rod';
UPDATE items SET description='A brutal two-handed axe.',weapon_type='greataxe',base_damage_min=12,base_damage_max=18,
 attack_speed_mod=-25,strength_scaling=0.75,agility_scaling=0.25,threat_multiplier=1,strength_bonus=2 WHERE name='Greataxe';
UPDATE items SET description='A sweeping two-handed polearm.',weapon_type='scythe',base_damage_min=10,base_damage_max=16,
 attack_speed_mod=-10,strength_scaling=0.75,agility_scaling=0.25,threat_multiplier=1 WHERE name='Scythe';
UPDATE items SET description='A crushing two-handed war hammer.',weapon_type='greatmaul',base_damage_min=13,base_damage_max=20,
 attack_speed_mod=-30,strength_scaling=0.75,agility_scaling=0.25,threat_multiplier=1,strength_bonus=3 WHERE name='Greatmaul';

-- Spread the full catalog across the four towns so every item can be bought during testing.
INSERT INTO shop_stock(node_id,item_id,price)
SELECT seed.node_id, item.id, item.base_price
FROM (
 SELECT 'nodeFortAurus' node_id,'Copper Amulet' item_name UNION ALL
 SELECT 'nodeFortAurus','Shortsword' UNION ALL SELECT 'nodeFortAurus','Heavy Shield' UNION ALL
 SELECT 'nodeFortAurus','Iron Helm' UNION ALL SELECT 'nodeFortAurus','Plate Armor' UNION ALL
 SELECT 'nodeFortAurus','Iron Greaves' UNION ALL SELECT 'nodeFortAurus','Guardian Sigil' UNION ALL
 SELECT 'nodeMounttown','Amulet of Vigor' UNION ALL SELECT 'nodeMounttown','Greatsword' UNION ALL
 SELECT 'nodeMounttown','Mace' UNION ALL SELECT 'nodeMounttown','Leather Cap' UNION ALL
 SELECT 'nodeMounttown','Leather Armor' UNION ALL SELECT 'nodeMounttown','Leather Boots' UNION ALL
 SELECT 'nodeMounttown','Emberstone' UNION ALL
 SELECT 'nodeRiverVillage','Sage Pendant' UNION ALL SELECT 'nodeRiverVillage','Hunter Bow' UNION ALL
 SELECT 'nodeRiverVillage','Runed Wand' UNION ALL SELECT 'nodeRiverVillage','Mystic Hood' UNION ALL
 SELECT 'nodeRiverVillage','Runespun Vestment' UNION ALL SELECT 'nodeRiverVillage','Mystic Leggings' UNION ALL
 SELECT 'nodeRiverVillage','Lucky Charm' UNION ALL
 SELECT 'nodeSmallVillage','Windglass Locket' UNION ALL SELECT 'nodeSmallVillage','Ashen Dagger' UNION ALL
 SELECT 'nodeSmallVillage','Iron Buckler' UNION ALL SELECT 'nodeSmallVillage','Scout Hood' UNION ALL
 SELECT 'nodeSmallVillage','Cloth Robe' UNION ALL SELECT 'nodeSmallVillage','Scout Trousers' UNION ALL
 SELECT 'nodeSmallVillage','Clockwork Feather'
) seed JOIN items item ON item.name=seed.item_name
ON DUPLICATE KEY UPDATE price=VALUES(price);

-- Make all 28 equipment pieces findable from the four vertical-slice enemy groups.
INSERT INTO combat_loot_table_entries
(loot_table_id,item_id,drop_chance,weight,min_quantity,max_quantity)
SELECT loot.id,item.id,seed.drop_chance,1,1,1
FROM (
 SELECT 'Snow Wolf Loot' loot_name,'Windglass Locket' item_name,0.06 drop_chance UNION ALL
 SELECT 'Snow Wolf Loot','Hunter Bow',0.04 UNION ALL SELECT 'Snow Wolf Loot','Iron Buckler',0.07 UNION ALL
 SELECT 'Snow Wolf Loot','Scout Hood',0.08 UNION ALL SELECT 'Snow Wolf Loot','Leather Armor',0.09 UNION ALL
 SELECT 'Snow Wolf Loot','Scout Trousers',0.08 UNION ALL SELECT 'Snow Wolf Loot','Clockwork Feather',0.03 UNION ALL
 SELECT 'Bandit Loot','Copper Amulet',0.08 UNION ALL SELECT 'Bandit Loot','Ashen Dagger',0.07 UNION ALL
 SELECT 'Bandit Loot','Heavy Shield',0.05 UNION ALL SELECT 'Bandit Loot','Iron Helm',0.06 UNION ALL
 SELECT 'Bandit Loot','Plate Armor',0.04 UNION ALL SELECT 'Bandit Loot','Iron Greaves',0.06 UNION ALL
 SELECT 'Bandit Loot','Guardian Sigil',0.04 UNION ALL
 SELECT 'Cultist Loot','Sage Pendant',0.06 UNION ALL SELECT 'Cultist Loot','Shortsword',0.06 UNION ALL
 SELECT 'Cultist Loot','Runed Wand',0.07 UNION ALL SELECT 'Cultist Loot','Mystic Hood',0.08 UNION ALL
 SELECT 'Cultist Loot','Runespun Vestment',0.05 UNION ALL SELECT 'Cultist Loot','Mystic Leggings',0.08 UNION ALL
 SELECT 'Cultist Loot','Lucky Charm',0.07 UNION ALL
 SELECT 'Bandit Captain Loot','Amulet of Vigor',0.10 UNION ALL SELECT 'Bandit Captain Loot','Greatsword',0.08 UNION ALL
 SELECT 'Bandit Captain Loot','Mace',0.10 UNION ALL SELECT 'Bandit Captain Loot','Leather Cap',0.12 UNION ALL
 SELECT 'Bandit Captain Loot','Cloth Robe',0.12 UNION ALL SELECT 'Bandit Captain Loot','Leather Boots',0.12 UNION ALL
 SELECT 'Bandit Captain Loot','Emberstone',0.07
) seed
JOIN combat_loot_tables loot ON loot.name=seed.loot_name
JOIN items item ON item.name=seed.item_name
ON DUPLICATE KEY UPDATE drop_chance=VALUES(drop_chance),weight=VALUES(weight),
min_quantity=VALUES(min_quantity),max_quantity=VALUES(max_quantity);
