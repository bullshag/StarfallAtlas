-- Ten NPCs for mid/frontier encounters: six humanoids, three forest creatures,
-- and one Fire Elemental boss. Safe to rerun against accounts.
USE accounts;

ALTER TABLE npcs ADD COLUMN IF NOT EXISTS direct_hit_reaction_damage INT NOT NULL DEFAULT 0;
ALTER TABLE npcs ADD COLUMN IF NOT EXISTS low_health_split_count INT NOT NULL DEFAULT 0;
ALTER TABLE npcs ADD COLUMN IF NOT EXISTS low_health_split_npc_name VARCHAR(255) NULL;

INSERT INTO abilities(ability_key,behavior_key,icon_key,name,description,cost,cooldown,can_roll_as_starting_ability,starting_ability_weight)
VALUES ('firestorm','firestorm','Purple15','Firestorm','Hits all enemies for 20 magic damage and burns them for 1 magic damage every 0.5 seconds for 5 seconds.',25,10,0,0)
ON DUPLICATE KEY UPDATE behavior_key=VALUES(behavior_key),icon_key=VALUES(icon_key),description=VALUES(description),cost=VALUES(cost),cooldown=VALUES(cooldown);

DELETE e FROM combat_ability_effects e JOIN abilities a ON a.id=e.ability_id WHERE a.ability_key='firestorm';
INSERT INTO combat_ability_effects
(ability_id,effect_index,effect_type,target_type,damage_school,base_power,strength_ratio,dexterity_ratio,intelligence_ratio,duration_seconds,tick_interval_seconds,threat_multiplier,status_key,icon_key,stack_mode,max_stacks,tint_r,tint_g,tint_b)
SELECT id,1,'damage','all_enemies','magic',20,0,0,0,0,0,1,NULL,NULL,'replace',1,1,.2,.1 FROM abilities WHERE ability_key='firestorm'
UNION ALL
SELECT id,2,'damage_over_time','all_enemies','magic',1,0,0,0,5,.5,1,'firestorm_burn','Purple15','replace',1,1,.15,.1 FROM abilities WHERE ability_key='firestorm';

INSERT INTO npcs
(name,level,current_hp,max_hp,mana,max_mana,action_speed,strength,dex,intelligence,melee_defense,magic_defense,role,targeting_style,power,direct_hit_reaction_damage,low_health_split_count,low_health_split_npc_name)
VALUES
('Sand Raider',7,175,175,45,45,11.0,28,21,8,16,9,'DPS','lowest_hp',470,0,0,NULL),
('Ashen Cultist',8,150,150,180,180,10.0,12,16,32,12,24,'DPS','random',520,0,0,NULL),
('Ironclad Mercenary',8,230,230,35,35,8.5,35,14,7,28,12,'Tank','highest_threat',560,0,0,NULL),
('Bandit Sharpshooter',9,165,165,70,70,13.5,18,34,10,14,13,'DPS','lowest_hp',590,0,0,NULL),
('Dune Spellbinder',9,190,190,220,220,9.5,10,18,38,15,29,'Support','random',640,0,0,NULL),
('Grave Knight',10,280,280,60,60,8.0,42,20,12,34,18,'Tank','highest_threat',720,0,0,NULL),
('Mossback Treant',8,260,260,85,85,7.5,38,10,20,30,18,'Tank','highest_threat',600,0,0,NULL),
('Thorn Sprite',7,120,120,150,150,14.0,9,29,25,10,17,'DPS','random',480,0,0,NULL),
('Grove Stalker',9,205,205,80,80,13.0,25,35,14,18,15,'DPS','lowest_hp',630,0,0,NULL),
('Cinderlord Ignivar',14,1200,1200,400,400,10.0,48,26,42,34,38,'Boss','lowest_hp',2600,3,5,'Fire Ember')
ON DUPLICATE KEY UPDATE
level=VALUES(level),current_hp=VALUES(current_hp),max_hp=VALUES(max_hp),mana=VALUES(mana),max_mana=VALUES(max_mana),action_speed=VALUES(action_speed),strength=VALUES(strength),dex=VALUES(dex),intelligence=VALUES(intelligence),melee_defense=VALUES(melee_defense),magic_defense=VALUES(magic_defense),role=VALUES(role),targeting_style=VALUES(targeting_style),power=VALUES(power),direct_hit_reaction_damage=VALUES(direct_hit_reaction_damage),low_health_split_count=VALUES(low_health_split_count),low_health_split_npc_name=VALUES(low_health_split_npc_name);

INSERT INTO npcs(name,level,current_hp,max_hp,mana,max_mana,action_speed,strength,dex,intelligence,melee_defense,magic_defense,role,targeting_style,power,direct_hit_reaction_damage)
VALUES ('Fire Ember',5,35,35,0,0,14.0,12,22,4,8,4,'DPS','random',180,1)
ON DUPLICATE KEY UPDATE level=VALUES(level),current_hp=VALUES(current_hp),max_hp=VALUES(max_hp),mana=VALUES(mana),max_mana=VALUES(max_mana),action_speed=VALUES(action_speed),strength=VALUES(strength),dex=VALUES(dex),intelligence=VALUES(intelligence),melee_defense=VALUES(melee_defense),magic_defense=VALUES(magic_defense),role=VALUES(role),targeting_style=VALUES(targeting_style),power=VALUES(power),direct_hit_reaction_damage=VALUES(direct_hit_reaction_damage);

DELETE s FROM combat_npc_abilities s JOIN npcs n ON n.id=s.npc_id WHERE n.name IN ('Sand Raider','Ashen Cultist','Ironclad Mercenary','Bandit Sharpshooter','Dune Spellbinder','Grave Knight','Mossback Treant','Thorn Sprite','Grove Stalker','Cinderlord Ignivar','Fire Ember');
INSERT INTO combat_npc_abilities(npc_id,ability_id,slot,priority)
SELECT n.id,a.id,x.slot,x.priority FROM (
 SELECT 'Sand Raider' npc_name,'quick_strike' ability_key,1 slot,1 priority UNION ALL SELECT 'Sand Raider','heavy_blow',2,2
 UNION ALL SELECT 'Ashen Cultist','fireball',1,1 UNION ALL SELECT 'Ashen Cultist','mass_weakness',2,2
 UNION ALL SELECT 'Ironclad Mercenary','heavy_blow',1,1 UNION ALL SELECT 'Ironclad Mercenary','quick_strike',2,2
 UNION ALL SELECT 'Bandit Sharpshooter','wild_strike',1,1 UNION ALL SELECT 'Bandit Sharpshooter','quick_strike',2,2
 UNION ALL SELECT 'Dune Spellbinder','fireball',1,1 UNION ALL SELECT 'Dune Spellbinder','haste',2,2
 UNION ALL SELECT 'Grave Knight','heavy_blow',1,1 UNION ALL SELECT 'Grave Knight','bleed_ability',2,2
 UNION ALL SELECT 'Mossback Treant','restorative_aura',1,1 UNION ALL SELECT 'Mossback Treant','heavy_blow',2,2
 UNION ALL SELECT 'Thorn Sprite','poison',1,1 UNION ALL SELECT 'Thorn Sprite','quick_strike',2,2
 UNION ALL SELECT 'Grove Stalker','wild_strike',1,1 UNION ALL SELECT 'Grove Stalker','bleed_ability',2,2
 UNION ALL SELECT 'Cinderlord Ignivar','firestorm',1,1 UNION ALL SELECT 'Cinderlord Ignivar','fireball',2,2
 UNION ALL SELECT 'Cinderlord Ignivar','quick_strike',3,3 UNION ALL SELECT 'Fire Ember','quick_strike',1,1
) x JOIN npcs n ON n.name=x.npc_name JOIN abilities a ON a.ability_key=x.ability_key
ON DUPLICATE KEY UPDATE ability_id=VALUES(ability_id),priority=VALUES(priority);

INSERT INTO combat_loot_tables(name) VALUES ('Cinderlord Ignivar Loot') ON DUPLICATE KEY UPDATE name=VALUES(name);
INSERT INTO combat_npc_loot(npc_id,loot_table_id,min_gold,max_gold,min_experience,max_experience)
SELECT n.id,l.id,500,800,700,1000 FROM npcs n JOIN combat_loot_tables l ON l.name='Cinderlord Ignivar Loot' WHERE n.name='Cinderlord Ignivar'
ON DUPLICATE KEY UPDATE loot_table_id=VALUES(loot_table_id),min_gold=VALUES(min_gold),max_gold=VALUES(max_gold),min_experience=VALUES(min_experience),max_experience=VALUES(max_experience);
