-- Ensure every active town shop sells two database-defined spell tomes.
-- Idempotent: safe to run during normal, debug, and Kim database setup.
USE accounts;

ALTER TABLE items ADD COLUMN IF NOT EXISTS taught_ability_id INT NULL AFTER description;

-- Create the town-specific tome items from canonical ability rows so their
-- descriptions and taught ability ids always stay current.
INSERT INTO items (name, base_price, stackable, description, taught_ability_id, item_category)
SELECT CONCAT('Tome: ', a.name),
       100,
       0,
       CONCAT('Teaches ', a.name, '. ', a.description),
       a.id,
       'consumable'
FROM abilities a
WHERE a.ability_key IN (
  'fireball','heal','poison','bleed_ability','heavy_blow','shield_bash',
  'restorative_aura','wild_strike','haste','cleave','iron_bastion','sweeping_arc',
  'mana_shield','charge_discharge','sickness','vampiric_strike','last_rites','firestorm')
ON DUPLICATE KEY UPDATE
  description=VALUES(description),
  taught_ability_id=VALUES(taught_ability_id),
  item_category='consumable';

-- Remove old generic tome assignments, then give every current town a distinct
-- tier-appropriate pair. A future unmapped shop receives Fireball and Heal.
DELETE stock FROM shop_stock stock
JOIN items item ON item.id=stock.item_id AND item.name LIKE 'Tome: %'
JOIN activities activity ON activity.node_id=stock.node_id AND LOWER(activity.activity_type)='shop';

INSERT INTO shop_stock (node_id, item_id, price)
SELECT mapping.node_id,item.id,mapping.price
FROM (
 SELECT 'nodeFortAurus' node_id,'fireball' ability_key,100 price UNION ALL SELECT 'nodeFortAurus','heal',100 UNION ALL
 SELECT 'nodeSmallVillage','poison',140 UNION ALL SELECT 'nodeSmallVillage','bleed_ability',140 UNION ALL
 SELECT 'nodeMounttown','heavy_blow',180 UNION ALL SELECT 'nodeMounttown','shield_bash',180 UNION ALL
 SELECT 'nodeRiverVillage','restorative_aura',220 UNION ALL SELECT 'nodeRiverVillage','wild_strike',220 UNION ALL
 SELECT 'nodeAshbrook','haste',280 UNION ALL SELECT 'nodeAshbrook','cleave',280 UNION ALL
 SELECT 'nodeIronpass','iron_bastion',340 UNION ALL SELECT 'nodeIronpass','sweeping_arc',340 UNION ALL
 SELECT 'nodeOasisTown','mana_shield',420 UNION ALL SELECT 'nodeOasisTown','charge_discharge',420 UNION ALL
 SELECT 'nodeDreadscar','sickness',560 UNION ALL SELECT 'nodeDreadscar','vampiric_strike',560 UNION ALL
 SELECT 'nodeCrownOfStars','last_rites',750 UNION ALL SELECT 'nodeCrownOfStars','firestorm',750
) mapping
JOIN abilities ability ON ability.ability_key=mapping.ability_key
JOIN items item ON item.taught_ability_id=ability.id
JOIN activities activity ON activity.node_id=mapping.node_id AND LOWER(activity.activity_type)='shop'
ON DUPLICATE KEY UPDATE price=VALUES(price);

INSERT INTO shop_stock(node_id,item_id,price)
SELECT DISTINCT activity.node_id,item.id,item.base_price
FROM activities activity
JOIN abilities ability ON ability.ability_key IN ('fireball','heal')
JOIN items item ON item.taught_ability_id=ability.id
WHERE LOWER(activity.activity_type)='shop'
AND activity.node_id NOT IN ('nodeFortAurus','nodeSmallVillage','nodeMounttown','nodeRiverVillage','nodeAshbrook','nodeIronpass','nodeOasisTown','nodeDreadscar','nodeCrownOfStars')
ON DUPLICATE KEY UPDATE price=VALUES(price);
