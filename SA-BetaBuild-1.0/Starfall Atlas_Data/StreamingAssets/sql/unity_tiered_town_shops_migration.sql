-- Tiered vertical-slice town facilities, equipment, consumables, and shop stock.
ALTER TABLE users ADD COLUMN IF NOT EXISTS travel_speed_buff_until DATETIME NULL;

INSERT INTO items
(name,base_price,stackable,description,item_category,equipment_slot,hand_type,weapon_type,base_damage_min,base_damage_max,strength_bonus,agility_bonus,intelligence_bonus,max_hp_bonus,max_mana_bonus,physical_defense_bonus,magic_defense_bonus,attack_speed_mod,strength_scaling,agility_scaling,threat_multiplier)
VALUES
('Aurus Recruit Amulet',55,0,'A dependable amulet issued near Fort Aurus.','equipment','Amulet','none','',0,0,1,0,0,4,0,0,0,0,0,0,1),
('Aurus Scout Pendant',65,0,'A light pendant suited to new scouts.','equipment','Amulet','none','',0,0,0,1,1,0,3,0,0,2,0,0,1),
('Aurus Ironblade',70,0,'A balanced one-handed sword.','equipment','LeftHand','one_handed','sword',4,7,2,0,0,0,0,0,0,0,0.6,0.4,1),
('Aurus Longbow',85,0,'A simple two-handed bow with reduced threat.','equipment','LeftHand','two_handed','bow',5,9,0,2,0,0,0,0,0,-5,0.25,0.75,0.5),
('Aurus Buckler',75,0,'A small shield for learning to block.','equipment','RightHand','shield','shield',0,0,0,0,0,6,0,3,1,-3,0,0,1),
('Aurus Sidearm',60,0,'A quick one-handed dagger.','equipment','RightHand','one_handed','dagger',3,6,0,2,0,0,0,0,0,6,0.4,0.6,1),
('Aurus Recruit Helm',55,0,'Basic Fort Aurus head protection.','equipment','Head','none','',0,0,1,0,0,3,0,2,0,0,0,0,1),
('Aurus Scout Cowl',60,0,'A flexible cowl for alert travelers.','equipment','Head','none','',0,0,0,2,0,0,2,1,1,2,0,0,1),
('Aurus Chain Vest',90,0,'Reliable chain armor from Fort Aurus.','equipment','Body','none','',0,0,1,0,0,6,0,4,1,-2,0,0,1),
('Aurus Ranger Jerkin',85,0,'Light armor made for mobility.','equipment','Body','none','',0,0,0,2,0,3,0,2,1,3,0,0,1),
('Aurus Iron Legguards',75,0,'Sturdy iron leg protection.','equipment','Legs','none','',0,0,1,0,0,4,0,3,0,-1,0,0,1),
('Aurus Trail Leggings',70,0,'Light leggings for long patrols.','equipment','Legs','none','',0,0,0,2,0,0,2,1,1,3,0,0,1),
('Aurus Defender Badge',65,0,'A Fort Aurus badge that bolsters resolve.','equipment','Trinket','none','',0,0,1,0,0,5,0,1,1,0,0,0,1),
('Aurus Quickstep Charm',70,0,'A charm that encourages quick action.','equipment','Trinket','none','',0,0,0,1,0,0,3,0,0,5,0,0,1),

('Mounttown Granite Amulet',125,0,'A granite-set amulet from Mounttown.','equipment','Amulet','none','',0,0,2,0,1,7,0,1,1,0,0,0,1),
('Mounttown Peak Pendant',140,0,'A pendant favored by peak mystics.','equipment','Amulet','none','',0,0,0,2,3,0,7,0,2,3,0,0,1),
('Mounttown Waraxe',150,0,'A heavy one-handed mountain axe.','equipment','LeftHand','one_handed','axe',8,13,4,0,0,0,0,0,0,-6,0.6,0.4,1),
('Mounttown Crag Bow',165,0,'A powerful bow made from alpine timber.','equipment','LeftHand','two_handed','bow',9,15,1,4,0,0,0,0,0,-4,0.25,0.75,0.5),
('Mounttown Granite Shield',155,0,'A broad shield faced with mountain stone.','equipment','RightHand','shield','shield',0,0,1,0,0,10,0,6,2,-5,0,0,1),
('Mounttown Climber Mace',145,0,'A compact one-handed mace.','equipment','RightHand','one_handed','mace',7,12,3,1,0,2,0,0,0,1,0.6,0.4,1),
('Mounttown Horned Helm',125,0,'A reinforced mountain helm.','equipment','Head','none','',0,0,2,0,0,6,0,4,1,-1,0,0,1),
('Mounttown Seer Hood',135,0,'A warm hood woven for mountain seers.','equipment','Head','none','',0,0,0,1,3,0,6,1,3,2,0,0,1),
('Mounttown Plate Coat',180,0,'Heavy armor built for harsh passes.','equipment','Body','none','',0,0,3,0,0,12,0,7,2,-4,0,0,1),
('Mounttown Windweave',175,0,'Layered armor that moves with the wind.','equipment','Body','none','',0,0,0,3,2,4,5,3,3,4,0,0,1),
('Mounttown Stone Greaves',145,0,'Dense greaves with excellent protection.','equipment','Legs','none','',0,0,2,0,0,8,0,5,1,-2,0,0,1),
('Mounttown Climber Trousers',140,0,'Flexible gear for steep trails.','equipment','Legs','none','',0,0,0,3,0,3,4,2,2,5,0,0,1),
('Mounttown Avalanche Token',135,0,'A token carrying the force of an avalanche.','equipment','Trinket','none','',0,0,3,0,0,6,0,2,0,-2,0,0,1),
('Mounttown Wind Chime',145,0,'A tiny chime that sharpens thought and motion.','equipment','Trinket','none','',0,0,0,2,2,0,6,0,2,7,0,0,1),

('Riverlord Torque',245,0,'A finely worked torque of the River Village.','equipment','Amulet','none','',0,0,4,1,1,12,0,2,2,1,0,0,1),
('Tidesage Pendant',265,0,'A potent focus for river magic.','equipment','Amulet','none','',0,0,0,2,5,0,14,1,4,4,0,0,1),
('Floodsteel Saber',280,0,'A swift one-handed blade of floodsteel.','equipment','LeftHand','one_handed','sword',13,20,5,3,0,0,0,0,0,5,0.6,0.4,1),
('Deepwood Warbow',310,0,'A masterwork two-handed bow with reduced threat.','equipment','LeftHand','two_handed','bow',15,23,2,6,0,0,0,0,0,2,0.25,0.75,0.5),
('Riverguard Shield',295,0,'A high-grade shield of the river guard.','equipment','RightHand','shield','shield',0,0,2,1,0,18,0,9,4,-4,0,0,1),
('Currentfang Dagger',270,0,'A very fast one-handed river dagger.','equipment','RightHand','one_handed','dagger',11,18,1,6,0,0,0,0,0,12,0.4,0.6,1),
('Riverguard Greathelm',240,0,'A polished helm worn by veteran guards.','equipment','Head','none','',0,0,3,1,0,11,0,6,3,0,0,0,1),
('Tidesage Circlet',255,0,'A silver circlet that focuses the mind.','equipment','Head','none','',0,0,0,2,5,0,10,2,5,4,0,0,1),
('Riverlord Cuirass',340,0,'Masterwork armor for the river elite.','equipment','Body','none','',0,0,5,0,0,22,0,11,4,-3,0,0,1),
('Mistwalker Raiment',330,0,'Enchanted armor that favors speed and magic.','equipment','Body','none','',0,0,0,4,4,7,10,5,5,7,0,0,1),
('Riverguard Legplates',285,0,'Veteran-grade river guard legplates.','equipment','Legs','none','',0,0,3,1,0,14,0,8,3,-1,0,0,1),
('Rapidwater Leggings',275,0,'Fine leggings that move like flowing water.','equipment','Legs','none','',0,0,0,5,1,4,8,3,4,9,0,0,1),
('River Crown Emblem',260,0,'An emblem that reinforces body and will.','equipment','Trinket','none','',0,0,3,1,2,12,8,3,3,0,0,0,1),
('Whispering Reed',275,0,'A rare reed charm humming with quick magic.','equipment','Trinket','none','',0,0,0,3,4,0,12,1,4,10,0,0,1),

('Wayfarer Grand Amulet',390,0,'A high-quality amulet for seasoned travelers.','equipment','Amulet','none','',0,0,4,4,4,15,15,3,3,4,0,0,1),
('Prismatic Covenant',450,0,'A rare high-quality amulet attuned to every discipline.','equipment','Amulet','none','',0,0,5,5,5,10,20,2,5,6,0,0,1),
('Chronicle Stone',400,0,'A high-quality trinket that preserves hard-won strength.','equipment','Trinket','none','',0,0,5,2,2,18,8,4,3,3,0,0,1),
('Sovereign Compass',460,0,'A rare trinket that guides its bearer through danger.','equipment','Trinket','none','',0,0,2,5,4,10,18,3,4,12,0,0,1),
('Mana Potion',45,1,'Restores 30 mana to a party member.','consumable',NULL,'none','',0,0,0,0,0,0,0,0,0,0,0,0,1),
('Travel Potion',80,1,'Increases map travel speed by 50% for 1 minute.','consumable',NULL,'none','',0,0,0,0,0,0,0,0,0,0,0,0,1)
ON DUPLICATE KEY UPDATE base_price=VALUES(base_price),stackable=VALUES(stackable),description=VALUES(description),item_category=VALUES(item_category),equipment_slot=VALUES(equipment_slot),hand_type=VALUES(hand_type),weapon_type=VALUES(weapon_type),base_damage_min=VALUES(base_damage_min),base_damage_max=VALUES(base_damage_max),strength_bonus=VALUES(strength_bonus),agility_bonus=VALUES(agility_bonus),intelligence_bonus=VALUES(intelligence_bonus),max_hp_bonus=VALUES(max_hp_bonus),max_mana_bonus=VALUES(max_mana_bonus),physical_defense_bonus=VALUES(physical_defense_bonus),magic_defense_bonus=VALUES(magic_defense_bonus),attack_speed_mod=VALUES(attack_speed_mod),strength_scaling=VALUES(strength_scaling),agility_scaling=VALUES(agility_scaling),threat_multiplier=VALUES(threat_multiplier);

DELETE FROM activities WHERE node_id IN ('nodeFortAurus','nodeMounttown','nodeRiverVillage','nodeSmallVillage');
INSERT INTO activities(node_id,activity_type,description,duration_seconds) VALUES
('nodeFortAurus','tavern','Hire party members at the Fort Aurus tavern.',0),('nodeFortAurus','shop','Browse Fort Aurus equipment.',0),('nodeFortAurus','search_for_enemies','Search the Fort Aurus region for enemies.',0),
('nodeMounttown','tavern','Hire party members at the Mounttown tavern.',0),('nodeMounttown','shop','Browse Mounttown equipment.',0),('nodeMounttown','search_for_enemies','Search the Mounttown region for enemies.',0),
('nodeRiverVillage','tavern','Hire party members at the River Village tavern.',0),('nodeRiverVillage','shop','Browse River Village equipment.',0),('nodeRiverVillage','search_for_enemies','Search the River Village region for enemies.',0),
('nodeSmallVillage','shop','Browse specialist supplies and rare jewelry.',0),('nodeSmallVillage','search_for_enemies','Search the Small Village region for enemies.',0);

DELETE FROM shop_stock WHERE node_id IN ('nodeFortAurus','nodeMounttown','nodeRiverVillage','nodeSmallVillage');
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeFortAurus',id,base_price FROM items WHERE name LIKE 'Aurus %';
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeMounttown',id,base_price FROM items WHERE name LIKE 'Mounttown %';
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeRiverVillage',id,base_price FROM items WHERE name IN ('Riverlord Torque','Tidesage Pendant','Floodsteel Saber','Deepwood Warbow','Riverguard Shield','Currentfang Dagger','Riverguard Greathelm','Tidesage Circlet','Riverlord Cuirass','Mistwalker Raiment','Riverguard Legplates','Rapidwater Leggings','River Crown Emblem','Whispering Reed');
INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeSmallVillage',id,base_price FROM items
WHERE name IN ('Healing Potion','Mana Potion','Travel Potion','Wayfarer Grand Amulet','Prismatic Covenant','Chronicle Stone','Sovereign Compass') OR name LIKE 'Tome: %';
