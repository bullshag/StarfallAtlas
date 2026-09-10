-- Sell only inventory the player actually owns, then award gold atomically.
UPDATE inventory v JOIN items i ON i.id=v.item_id
SET v.quantity = v.quantity - @quantity
WHERE v.user_id=@userId AND v.item_id=@itemId AND @quantity>0 AND v.quantity >= @quantity
  AND i.base_price>0 AND GREATEST(1,FLOOR(i.base_price * 0.4))=@price;
UPDATE users SET gold = gold + (@price * @quantity)
WHERE id=@userId AND @price>0 AND gold <= 2147483647-(@price * @quantity);
DELETE FROM inventory
WHERE user_id=@userId AND item_id=@itemId AND quantity <= 0;
