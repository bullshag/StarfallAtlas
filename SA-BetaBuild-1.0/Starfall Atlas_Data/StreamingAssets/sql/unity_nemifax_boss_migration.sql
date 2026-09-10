-- Nemifax the Terrible boss encounter and summoned Dragon Whelps.
USE accounts;

INSERT INTO nodes(id,name) VALUES ('nodeNemifaxLair','Nemifax''s Lair')
ON DUPLICATE KEY UPDATE name=VALUES(name);

DELETE FROM activities WHERE node_id='nodeNemifaxLair' AND activity_type='search_for_enemies';
INSERT INTO activities(node_id,activity_type,description,duration_seconds)
VALUES ('nodeNemifaxLair','search_for_enemies','Enter Nemifax''s Lair and confront Nemifax the Terrible.',0);

ALTER TABLE npcs ADD COLUMN IF NOT EXISTS half_health_ability_key VARCHAR(64) NULL AFTER targeting_style;
ALTER TABLE npcs ADD COLUMN IF NOT EXISTS heal_on_kill_percent DECIMAL(6,4) NOT NULL DEFAULT 0 AFTER half_health_ability_key;

INSERT INTO abilities(ability_key,behavior_key,name,description,cost,cooldown,can_roll_as_starting_ability,starting_ability_weight)
VALUES
('flame_breath','flame_breath','Flame Breath','Breathes fire over all enemies for 55 magic damage and burns them for 15 damage each second for 3 seconds.',35,10,0,0),
('call_younglings','call_younglings','Call Younglings','Calls three Dragon Whelps into the fight.',0,30,0,0)
ON DUPLICATE KEY UPDATE behavior_key=VALUES(behavior_key),description=VALUES(description),cost=VALUES(cost),cooldown=VALUES(cooldown);

UPDATE abilities SET ability_key='enrage_ability',behavior_key='enrage_ability',description='Increases damage dealt by 25% for 8 seconds.',cost=0,cooldown=12 WHERE name='Enrage';
UPDATE abilities SET ability_key='bleed_ability',behavior_key='bleed_ability',description='Causes an enemy to bleed for 1 plus 25% Strength every 0.5 seconds for 6 seconds.',cost=0,cooldown=10 WHERE name='Bleed';

DELETE effect FROM combat_ability_effects effect JOIN abilities ability ON ability.id=effect.ability_id
WHERE ability.ability_key IN ('flame_breath','call_younglings','enrage_ability','bleed_ability');

INSERT INTO combat_ability_effects
(ability_id,effect_index,effect_type,target_type,damage_school,base_power,strength_ratio,dexterity_ratio,intelligence_ratio,duration_seconds,tick_interval_seconds,threat_multiplier,status_key,icon_key,stack_mode,max_stacks,tint_r,tint_g,tint_b)
SELECT id,1,'damage','all_enemies','magic',55,0,0,0,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='flame_breath'
UNION ALL SELECT id,2,'damage_over_time','all_enemies','magic',15,0,0,0,3,1,1,'flame_breath_burn','Red10','replace',1,1,.25,.10 FROM abilities WHERE ability_key='flame_breath'
UNION ALL SELECT id,1,'buff','self','physical',0,0,0,0,.1,0,1,'call_younglings','Red10','replace',1,1,1,1 FROM abilities WHERE ability_key='call_younglings'
UNION ALL SELECT id,1,'buff','self','physical',0,0,0,0,8,0,1,'nemifax_enrage','Red10','replace',1,1,.2,.1 FROM abilities WHERE ability_key='enrage_ability'
UNION ALL SELECT id,1,'damage_over_time','enemy','physical',1,.25,0,0,6,.5,1,'nemifax_bleed','Red10','replace',1,1,.2,.1 FROM abilities WHERE ability_key='bleed_ability';

INSERT INTO npcs
(name,level,current_hp,max_hp,mana,max_mana,action_speed,strength,dex,intelligence,melee_defense,magic_defense,role,targeting_style,half_health_ability_key,heal_on_kill_percent,power)
VALUES
('Nemifax the Terrible',12,850,850,300,300,11.0,34,24,30,26,24,'Boss','lowest_hp','haste',.10,1600),
('Dragon Whelp',6,105,105,75,75,12.0,14,18,16,9,10,'DPS','random',NULL,0,330)
ON DUPLICATE KEY UPDATE level=VALUES(level),current_hp=VALUES(current_hp),max_hp=VALUES(max_hp),mana=VALUES(mana),max_mana=VALUES(max_mana),action_speed=VALUES(action_speed),strength=VALUES(strength),dex=VALUES(dex),intelligence=VALUES(intelligence),melee_defense=VALUES(melee_defense),magic_defense=VALUES(magic_defense),role=VALUES(role),targeting_style=VALUES(targeting_style),half_health_ability_key=VALUES(half_health_ability_key),heal_on_kill_percent=VALUES(heal_on_kill_percent),power=VALUES(power);

DELETE slots FROM combat_npc_abilities slots JOIN npcs npc ON npc.id=slots.npc_id
WHERE npc.name IN ('Nemifax the Terrible','Dragon Whelp');
INSERT INTO combat_npc_abilities(npc_id,ability_id,slot,priority)
SELECT npc.id,ability.id,seed.slot,seed.priority FROM (
 SELECT 'Nemifax the Terrible' npc_name,'call_younglings' ability_key,1 slot,1 priority UNION ALL
 SELECT 'Nemifax the Terrible','flame_breath',2,2 UNION ALL
 SELECT 'Nemifax the Terrible','enrage_ability',3,3 UNION ALL
 SELECT 'Nemifax the Terrible','bleed_ability',4,4 UNION ALL
 SELECT 'Nemifax the Terrible','quick_strike',5,5 UNION ALL
 SELECT 'Nemifax the Terrible','haste',6,99 UNION ALL
 SELECT 'Dragon Whelp','fireball',1,1 UNION ALL
 SELECT 'Dragon Whelp','quick_strike',2,2
) seed JOIN npcs npc ON npc.name=seed.npc_name JOIN abilities ability ON ability.ability_key=seed.ability_key;

INSERT INTO combat_loot_tables(name) VALUES ('Nemifax the Terrible Loot') ON DUPLICATE KEY UPDATE name=VALUES(name);
INSERT INTO combat_npc_loot(npc_id,loot_table_id,min_gold,max_gold,min_experience,max_experience)
SELECT npc.id,loot.id,180,260,240,340 FROM npcs npc JOIN combat_loot_tables loot ON loot.name='Nemifax the Terrible Loot'
WHERE npc.name='Nemifax the Terrible'
ON DUPLICATE KEY UPDATE loot_table_id=VALUES(loot_table_id),min_gold=VALUES(min_gold),max_gold=VALUES(max_gold),min_experience=VALUES(min_experience),max_experience=VALUES(max_experience);

INSERT INTO combat_encounter_tables(node_id,name,min_enemies,max_enemies)
VALUES ('nodeNemifaxLair','Nemifax''s Lair',1,1)
ON DUPLICATE KEY UPDATE min_enemies=1,max_enemies=1;

DELETE entry FROM combat_encounter_entries entry
JOIN combat_encounter_tables encounter ON encounter.id=entry.encounter_table_id
JOIN npcs npc ON npc.id=entry.npc_id
WHERE npc.name='Nemifax the Terrible' AND encounter.node_id<>'nodeNemifaxLair';

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT encounter.id,npc.id,1,1,1 FROM combat_encounter_tables encounter JOIN npcs npc ON npc.name='Nemifax the Terrible'
WHERE encounter.node_id='nodeNemifaxLair' AND encounter.name='Nemifax''s Lair'
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);
