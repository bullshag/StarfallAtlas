CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    base_price INT NOT NULL,
    stackable TINYINT(1) NOT NULL DEFAULT 0
);

ALTER TABLE items ADD COLUMN IF NOT EXISTS stackable TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE items ADD COLUMN IF NOT EXISTS description TEXT NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS inventory (
    user_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, item_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop_stock (
    node_id VARCHAR(50) NOT NULL,
    item_id INT NOT NULL,
    price INT NOT NULL,
    PRIMARY KEY (node_id, item_id),
    FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

INSERT INTO nodes (id, name) VALUES
('nodeFortAurus', 'Fort Aurus'),
('nodeMounttown', 'Mounttown'),
('nodeRiverVillage', 'River Village'),
('nodeSmallVillage', 'Small Village')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO items (name, base_price, stackable) VALUES
('Healing Potion', 30, 1),
('Cloth Robe', 30, 0),
('Leather Armor', 60, 0),
('Leather Cap', 25, 0),
('Leather Boots', 25, 0),
('Plate Armor', 120, 0),
('Heavy Shield', 80, 0),
('Shortsword', 50, 0),
('Dagger', 20, 0),
('Bow', 60, 0),
('Longsword', 80, 0),
('Staff', 70, 0),
('Wand', 40, 0),
('Rod', 60, 0),
('Greataxe', 100, 0),
('Scythe', 120, 0),
('Greatsword', 150, 0),
('Mace', 70, 0),
('Greatmaul', 130, 0)
ON DUPLICATE KEY UPDATE base_price = VALUES(base_price), stackable = VALUES(stackable);

INSERT INTO shop_stock (node_id, item_id, price)
SELECT stock.node_id, items.id, stock.price
FROM (
    SELECT 'nodeFortAurus' AS node_id, 'Healing Potion' AS item_name, 30 AS price
    UNION ALL SELECT 'nodeFortAurus', 'Leather Cap', 25
    UNION ALL SELECT 'nodeFortAurus', 'Dagger', 20
    UNION ALL SELECT 'nodeFortAurus', 'Shortsword', 50
    UNION ALL SELECT 'nodeFortAurus', 'Leather Armor', 60
    UNION ALL SELECT 'nodeFortAurus', 'Heavy Shield', 80
    UNION ALL SELECT 'nodeMounttown', 'Healing Potion', 36
    UNION ALL SELECT 'nodeMounttown', 'Plate Armor', 132
    UNION ALL SELECT 'nodeMounttown', 'Heavy Shield', 88
    UNION ALL SELECT 'nodeMounttown', 'Mace', 77
    UNION ALL SELECT 'nodeMounttown', 'Greatmaul', 143
    UNION ALL SELECT 'nodeMounttown', 'Greataxe', 110
    UNION ALL SELECT 'nodeRiverVillage', 'Healing Potion', 28
    UNION ALL SELECT 'nodeRiverVillage', 'Cloth Robe', 32
    UNION ALL SELECT 'nodeRiverVillage', 'Leather Armor', 62
    UNION ALL SELECT 'nodeRiverVillage', 'Bow', 58
    UNION ALL SELECT 'nodeRiverVillage', 'Staff', 72
    UNION ALL SELECT 'nodeRiverVillage', 'Wand', 42
    UNION ALL SELECT 'nodeSmallVillage', 'Healing Potion', 25
    UNION ALL SELECT 'nodeSmallVillage', 'Leather Cap', 24
    UNION ALL SELECT 'nodeSmallVillage', 'Leather Boots', 24
    UNION ALL SELECT 'nodeSmallVillage', 'Dagger', 18
    UNION ALL SELECT 'nodeSmallVillage', 'Shortsword', 48
    UNION ALL SELECT 'nodeSmallVillage', 'Bow', 55
) AS stock
JOIN items ON items.name = stock.item_name
ON DUPLICATE KEY UPDATE price = VALUES(price);
