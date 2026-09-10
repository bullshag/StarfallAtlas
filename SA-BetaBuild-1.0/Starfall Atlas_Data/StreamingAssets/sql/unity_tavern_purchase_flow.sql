-- Deduct gold, assign the recruit, and flag the roster entry as purchased
UPDATE users
SET gold = gold - @cost
WHERE id = @userId
  AND gold >= @cost;

UPDATE characters c
JOIN unity_tavern_recruits roster
  ON roster.recruit_id = c.id
 AND roster.node_id = @nodeId
 AND roster.purchased_utc IS NULL
SET c.account_id = @userId,
    c.strength = roster.strength,
    c.dex = roster.dexterity,
    c.intelligence = roster.intelligence,
    c.max_hp = roster.max_hp,
    c.current_hp = roster.max_hp,
    c.max_mana = roster.max_mp,
    c.mana = roster.max_mp,
    c.action_speed = roster.action_speed,
    c.melee_defense = roster.physical_defense,
    c.magic_defense = roster.magic_defense,
    c.in_tavern = 0,
    c.is_mercenary = 1,
    c.combat_appearance_key = COALESCE(NULLIF(c.combat_appearance_key,''), CASE
        WHEN LOWER(COALESCE(role,'dps'))='tank' THEN ELT(1+MOD(id,7),'chara2_8','chara3_2','chara4_7','chara4_8','chara5_4','chara5_6','chara5_7')
        WHEN LOWER(COALESCE(role,'dps')) IN ('healer','support') THEN ELT(1+MOD(id,9),'chara2_1','chara2_7','chara3_1','chara3_4','chara4_1','chara4_3','chara4_6','chara5_2','chara5_5')
        WHEN LOWER(COALESCE(role,'')) REGEXP 'ranged|archer|caster|mage|channeler'
          OR c.intelligence >= GREATEST(c.strength,c.dex)+2
          OR EXISTS (
              SELECT 1 FROM character_equipment ce
              JOIN items equipped_item ON equipped_item.name=ce.item_name
              WHERE ce.character_name=c.name
                AND LOWER(COALESCE(equipped_item.weapon_type,'')) IN ('bow','wand','staff','rod')
          )
          THEN ELT(1+MOD(id,8),'chara2_5','chara2_6','chara3_6','chara3_7','chara3_8','chara4_5','chara5_3','chara5_8')
        ELSE ELT(1+MOD(id,8),'chara2_2','chara2_3','chara2_4','chara3_3','chara3_5','chara4_2','chara4_4','chara5_1') END)
WHERE c.id = @recruitId
  AND c.in_tavern = 1
  AND (c.account_id IS NULL OR c.account_id=0);

UPDATE unity_tavern_recruits
SET purchased_utc = UTC_TIMESTAMP(),
    purchased_account_id = @userId
WHERE node_id = @nodeId
  AND recruit_id = @recruitId
  AND purchased_utc IS NULL;

-- Behavior defaults apply only to this newly hired recruit. Existing tactics survive.
INSERT IGNORE INTO character_tactics(character_id,settings_json,version)
SELECT id, CASE
 WHEN LOWER(COALESCE(role,'')) IN ('healer','support') THEN '{"Preset":4,"Positioning":2,"PreferredDistance":15,"ManaReserve":50,"HealThreshold":85,"EmergencyThreshold":40}'
 WHEN LOWER(COALESCE(role,''))='tank' THEN '{"Preset":1,"StickToTarget":true,"Positioning":1,"Evade":false,"HealThreshold":60,"EmergencyThreshold":25}'
 ELSE '{}' END, 1
FROM characters WHERE id=@recruitId AND account_id=@userId;
