-- Slot-aware equipment metadata used by the Unity party inventory screen.
ALTER TABLE items ADD COLUMN IF NOT EXISTS description VARCHAR(500) NOT NULL DEFAULT '';
ALTER TABLE items ADD COLUMN IF NOT EXISTS item_category VARCHAR(24) NOT NULL DEFAULT 'misc';
ALTER TABLE items ADD COLUMN IF NOT EXISTS equipment_slot VARCHAR(24) NULL;
ALTER TABLE items ADD COLUMN IF NOT EXISTS hand_type VARCHAR(24) NULL;
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

CREATE TABLE IF NOT EXISTS character_equipment (
    account_id INT NOT NULL,
    character_name VARCHAR(100) NOT NULL,
    slot VARCHAR(24) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (account_id, character_name, slot),
    FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Consolidate legacy Unity inventory rows so every equippable item has one
-- authoritative quantity and can move to equipment transactionally.
INSERT INTO inventory(user_id, item_id, quantity)
SELECT ui.account_id, i.id, ui.quantity
FROM user_items ui JOIN items i ON i.name=ui.item_name
ON DUPLICATE KEY UPDATE quantity=inventory.quantity+VALUES(quantity);
DELETE ui FROM user_items ui JOIN items i ON i.name=ui.item_name;

-- Preserve equipment created by the older single "Weapon" slot.
UPDATE character_equipment SET slot='LeftHand' WHERE slot='Weapon';

UPDATE items SET item_category='consumable', equipment_slot=NULL, hand_type=NULL,
 description='Restores health to one party member.' WHERE name='Healing Potion';

UPDATE items SET item_category='equipment', equipment_slot='Body', hand_type=NULL
 WHERE name IN ('Cloth Robe','Leather Armor','Plate Armor');
UPDATE items SET item_category='equipment', equipment_slot='Head', hand_type=NULL
 WHERE name='Leather Cap';
UPDATE items SET item_category='equipment', equipment_slot='Legs', hand_type=NULL
 WHERE name='Leather Boots';
UPDATE items SET item_category='equipment', equipment_slot='RightHand', hand_type='shield'
 WHERE name='Heavy Shield';
UPDATE items SET item_category='equipment', equipment_slot='LeftHand', hand_type='one_handed'
 WHERE name IN ('Shortsword','Dagger','Longsword','Wand','Mace');
UPDATE items SET item_category='equipment', equipment_slot='LeftHand', hand_type='two_handed'
 WHERE name IN ('Bow','Staff','Rod','Greataxe','Scythe','Greatsword','Greatmaul');

INSERT INTO items(name, base_price, stackable, description, item_category, equipment_slot, hand_type)
VALUES ('Copper Amulet', 45, 0, 'A simple amulet worn by new adventurers.', 'equipment', 'Amulet', NULL),
       ('Lucky Charm', 55, 0, 'A small trinket said to favor its bearer.', 'equipment', 'Trinket', NULL)
ON DUPLICATE KEY UPDATE item_category=VALUES(item_category), equipment_slot=VALUES(equipment_slot), hand_type=VALUES(hand_type);
