-- Purchase item and update inventory
UPDATE users u
JOIN shop_stock s ON s.node_id=@nodeId AND s.item_id=@itemId
JOIN items i ON i.id=s.item_id
SET u.gold = u.gold - (s.price * @quantity)
WHERE u.id=@userId AND @quantity>0 AND s.price=@price AND s.price>0
  AND u.gold >= (s.price * @quantity)
  AND (s.price * @quantity) <= 2147483647
  AND COALESCE((SELECT quantity FROM inventory WHERE user_id=@userId AND item_id=@itemId),0) <= 2147483647-@quantity;
INSERT INTO inventory(user_id, item_id, quantity)
VALUES(@userId, @itemId, @quantity)
ON DUPLICATE KEY UPDATE quantity = quantity + @quantity;
