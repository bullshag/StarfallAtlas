-- Fetch persisted tavern recruits for a specific node
SELECT r.recruit_id,
       c.name,
       c.level,
       r.cost,
       r.created_utc,
       r.strength,
       r.dexterity,
       r.intelligence,
       r.max_hp,
       r.max_mp,
       r.action_speed,
       r.physical_defense,
       r.magic_defense,
       r.rolled_points,
       COALESCE((SELECT GROUP_CONCAT(a.name ORDER BY a.name SEPARATOR ', ')
                 FROM character_abilities ca JOIN abilities a ON a.id=ca.ability_id
                 WHERE ca.character_id=c.id),'') AS skills
FROM unity_tavern_recruits AS r
JOIN characters AS c ON c.id = r.recruit_id
WHERE r.node_id = @nodeId
  AND r.purchased_utc IS NULL
  AND c.in_tavern = 1
  AND (c.account_id IS NULL OR c.account_id = 0)
ORDER BY r.created_utc ASC;
