-- Resurrection scrolls and the final equipment-slot audit. Safe to rerun.
USE accounts;

INSERT INTO items(name,base_price,stackable,description,taught_ability_id,item_category,item_tier)
VALUES('Resurrection Scroll',50,1,'Resurrects a dead party member with 10% health and mana.',NULL,'consumable',0)
ON DUPLICATE KEY UPDATE base_price=50,stackable=1,description=VALUES(description),item_category='consumable';

INSERT INTO shop_stock(node_id,item_id,price)
SELECT DISTINCT activity.node_id,item.id,50
FROM activities activity JOIN items item ON item.name='Resurrection Scroll'
WHERE LOWER(activity.activity_type)='shop'
ON DUPLICATE KEY UPDATE price=50;

-- Small Village was the only audited shop below two choices in supported slots.
INSERT INTO items(name,base_price,stackable,description,item_category,equipment_slot,hand_type,
 strength_bonus,agility_bonus,intelligence_bonus,max_hp_bonus,max_mana_bonus,physical_defense_bonus,magic_defense_bonus,item_tier)
VALUES
('Village Scout Cap',45,0,'A practical tier 1 cap.','equipment','Head','none',0,1,0,2,0,1,0,1),
('Village Leather Tunic',65,0,'A sturdy tier 1 traveling tunic.','equipment','Body','none',1,0,0,5,0,2,0,1),
('Herbalist Robe',95,0,'A tier 2 robe sewn for village healers.','equipment','Body','none',0,0,2,2,5,0,2,2),
('Village Trail Leggings',60,0,'Tier 1 leggings made for long roads.','equipment','Legs','none',0,1,0,3,0,1,0,1),
('Oakwood Buckler',70,0,'A tier 1 wooden shield.','equipment','RightHand','shield',0,0,0,4,0,2,0,1),
('Runed Wicker Shield',105,0,'A tier 2 shield reinforced with protective runes.','equipment','RightHand','shield',0,0,1,4,3,1,2,2)
ON DUPLICATE KEY UPDATE base_price=VALUES(base_price),description=VALUES(description),item_category='equipment',
equipment_slot=VALUES(equipment_slot),hand_type=VALUES(hand_type),strength_bonus=VALUES(strength_bonus),
agility_bonus=VALUES(agility_bonus),intelligence_bonus=VALUES(intelligence_bonus),max_hp_bonus=VALUES(max_hp_bonus),
max_mana_bonus=VALUES(max_mana_bonus),physical_defense_bonus=VALUES(physical_defense_bonus),
magic_defense_bonus=VALUES(magic_defense_bonus),item_tier=VALUES(item_tier);

INSERT INTO shop_stock(node_id,item_id,price)
SELECT 'nodeSmallVillage',id,base_price FROM items
WHERE name IN ('Village Scout Cap','Village Leather Tunic','Herbalist Robe','Village Trail Leggings','Oakwood Buckler','Runed Wicker Shield')
ON DUPLICATE KEY UPDATE price=VALUES(price);
