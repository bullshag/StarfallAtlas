-- New vertical-slice abilities, spell tomes, enemies, encounters, and loot.
-- Safe to rerun against the accounts database.
USE accounts;

ALTER TABLE abilities ADD COLUMN IF NOT EXISTS ability_key VARCHAR(64) NULL AFTER id;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS behavior_key VARCHAR(64) NULL AFTER ability_key;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS icon_key VARCHAR(64) NULL AFTER behavior_key;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS can_roll_as_starting_ability TINYINT(1) NOT NULL DEFAULT 0 AFTER cooldown;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS starting_ability_weight INT NOT NULL DEFAULT 0 AFTER can_roll_as_starting_ability;
CREATE UNIQUE INDEX IF NOT EXISTS uq_abilities_key ON abilities(ability_key);

ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS icon_key VARCHAR(64) NULL AFTER status_key;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS stack_mode VARCHAR(24) NOT NULL DEFAULT 'replace' AFTER icon_key;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS max_stacks INT NOT NULL DEFAULT 1 AFTER stack_mode;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS tint_r DECIMAL(5,3) NOT NULL DEFAULT 1 AFTER max_stacks;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS tint_g DECIMAL(5,3) NOT NULL DEFAULT 1 AFTER tint_r;
ALTER TABLE combat_ability_effects ADD COLUMN IF NOT EXISTS tint_b DECIMAL(5,3) NOT NULL DEFAULT 1 AFTER tint_g;

ALTER TABLE items ADD COLUMN IF NOT EXISTS taught_ability_id INT NULL AFTER description;

INSERT INTO abilities
(ability_key,behavior_key,name,description,cost,cooldown,can_roll_as_starting_ability,starting_ability_weight)
VALUES
('fireball','fireball','Fireball','Deals magic damage to one enemy equal to 5 + level + ((55% INT) / level).',15,3,1,100),
('haste','haste','Haste','Grants a random friendly target 30% increased action speed for 3 seconds.',30,5,0,0),
('mass_weakness','mass_weakness','Mass Weakness','Damages all enemies and applies a stacking 5% damage, healing, and action-speed reduction for 10 seconds.',10,5,0,0),
('restorative_aura','restorative_aura','Restorative Aura','Heals all allies, then restores 1% of each target''s missing health plus 1 every 0.5 seconds for 5 seconds.',30,8,1,85),
('heavy_blow','heavy_blow','Heavy Blow','Deals physical damage based on Strength and Agility and stuns the target for 2 seconds.',0,6,1,100),
('wild_strike','wild_strike','Wild Strike','Strikes a random enemy and builds Wild Momentum, reducing future Wild Strike cooldowns.',15,4,1,100),
('cleave','cleave','Cleave','Your next damaging or healing action affects the entire opposing or friendly group; existing area effects gain 50% power.',10,4,0,0),
('charge_discharge','charge_discharge','Charge/Discharge','Toggle Charged mana storage and an all-enemy discharge. Discharge grants 15% critical strike chance.',50,10,0,0),
('mana_shield','mana_shield','Mana Shield','For 10 seconds, redirects 80% of post-absorption damage to mana and converts 20% of overhealing into mana.',0,10,1,75),
('sickness','sickness','Sickness','For 3 seconds, damage-over-time effects tick an additional time for 30% damage.',23,5,0,0)
ON DUPLICATE KEY UPDATE
ability_key=VALUES(ability_key),behavior_key=VALUES(behavior_key),description=VALUES(description),
cost=VALUES(cost),cooldown=VALUES(cooldown),can_roll_as_starting_ability=VALUES(can_roll_as_starting_ability),
starting_ability_weight=VALUES(starting_ability_weight);

UPDATE abilities SET ability_key='quick_strike',behavior_key='quick_strike' WHERE name='Quick Strike';
UPDATE abilities SET ability_key='heal',behavior_key='heal' WHERE name='Heal';
UPDATE abilities SET ability_key='poison',behavior_key='poison' WHERE name='Poison';
UPDATE abilities SET ability_key='taunting_blows',behavior_key='taunting_blows' WHERE name='Taunting Blows';
UPDATE abilities SET ability_key='shield_bash',behavior_key='shield_bash' WHERE name='Shield Bash';

-- Fifteen learnable party abilities. These remain out of randomized starting pools;
-- character_abilities/tome flows are the only acquisition paths.
INSERT INTO abilities
(ability_key,behavior_key,icon_key,name,description,cost,cooldown,can_roll_as_starting_ability,starting_ability_weight)
VALUES
('iron_bastion',NULL,'iron_bastion','Iron Bastion','Gain a heavy absorption shield and 15% damage reduction for 8 seconds.',6,12,0,0),
('challenge_roar',NULL,'suppress','Challenge Roar','Taunt all enemies and reduce their damage dealt for 4 seconds.',5,14,0,0),
('guardian_intercept',NULL,'guardian','Guardian Intercept','Shield an ally and force that ally''s attacker to focus on you.',7,16,0,0),
('rend',NULL,'bleed','Rend','Strike an enemy and cause a physical bleed.',4,9,0,0),
('sweeping_arc',NULL,'sweeping_arc','Sweeping Arc','Strike every enemy with a broad physical arc.',7,15,0,0),
('executioners_edge','execute','heavy_blow','Executioner''s Edge','Deal increased damage to enemies below 30% health.',8,18,0,0),
('renewing_touch',NULL,'restorative_aura','Renewing Touch','Heal an ally and restore health over time.',4,8,0,0),
('circle_of_mending',NULL,'restorative_aura','Circle of Mending','Heal and restore health over time to all allies.',8,18,0,0),
('soothing_ward',NULL,'soothing_ward','Soothing Ward','Shield an ally and reduce incoming damage.',6,14,0,0),
('battle_hymn',NULL,'empowerment','Battle Hymn','Increase the party''s offensive stat scaling for 8 seconds.',6,16,0,0),
('crippling_hex',NULL,'mass_weakness','Crippling Hex','Reduce an enemy''s damage and action speed.',5,12,0,0),
('familiar_call','summon_familiar','familiar_call','Familiar Call','Summon a temporary allied familiar.',9,24,0,0),
('vampiric_strike',NULL,'lifegiver','Vampiric Strike','Damage an enemy and heal yourself for part of the damage.',6,11,0,0),
('thornskin','retaliation','thornskin','Thornskin','Reflect a portion of direct physical damage for 8 seconds.',7,18,0,0),
('last_rites','execute','holy_flames','Last Rites','Deal holy damage with a powerful low-health execution bonus.',8,20,0,0)
ON DUPLICATE KEY UPDATE
behavior_key=VALUES(behavior_key),icon_key=VALUES(icon_key),description=VALUES(description),cost=VALUES(cost),cooldown=VALUES(cooldown),can_roll_as_starting_ability=0,starting_ability_weight=0;

DELETE effect FROM combat_ability_effects effect
JOIN abilities ability ON ability.id=effect.ability_id
WHERE ability.ability_key IN ('iron_bastion','challenge_roar','guardian_intercept','rend','sweeping_arc','executioners_edge','renewing_touch','circle_of_mending','soothing_ward','battle_hymn','crippling_hex','familiar_call','vampiric_strike','thornskin','last_rites');

INSERT INTO combat_ability_effects
(ability_id,effect_index,effect_type,target_type,damage_school,base_power,strength_ratio,dexterity_ratio,intelligence_ratio,duration_seconds,tick_interval_seconds,threat_multiplier,status_key,icon_key,stack_mode,max_stacks,tint_r,tint_g,tint_b)
SELECT id,1,'shield','self','physical',0,.18,0,0,8,0,1,'iron_bastion','iron_bastion','replace',1,.75,.75,.85 FROM abilities WHERE ability_key='iron_bastion'
UNION ALL SELECT id,2,'buff','self','physical',0,0,0,0,8,0,1,'iron_bastion','iron_bastion','replace',1,.75,.75,.85 FROM abilities WHERE ability_key='iron_bastion'
UNION ALL SELECT id,1,'taunt','all_enemies','physical',0,0,0,0,4,0,1,'taunted','suppress','replace',1,1,.65,.2 FROM abilities WHERE ability_key='challenge_roar'
UNION ALL SELECT id,2,'debuff','all_enemies','physical',0,0,0,0,4,0,1,'challenge_roar','mass_weakness','replace',1,1,.65,.2 FROM abilities WHERE ability_key='challenge_roar'
UNION ALL SELECT id,1,'shield','ally','physical',0,.22,0,0,6,0,1,'guardian_intercept','guardian','replace',1,.2,.8,1 FROM abilities WHERE ability_key='guardian_intercept'
UNION ALL SELECT id,1,'damage','enemy','physical',4,.35,0,0,0,0,1,NULL,NULL,'replace',1,1,.3,.2 FROM abilities WHERE ability_key='rend'
UNION ALL SELECT id,2,'damage_over_time','enemy','physical',1,.20,0,0,5,.5,1,'rend','bleed','replace',1,1,.3,.2 FROM abilities WHERE ability_key='rend'
UNION ALL SELECT id,1,'damage','all_enemies','physical',3,.45,0,0,0,0,1,NULL,NULL,'replace',1,.8,.45,.15 FROM abilities WHERE ability_key='sweeping_arc'
UNION ALL SELECT id,1,'damage','enemy','physical',0,.40,0,0,0,0,1,NULL,NULL,'replace',1,1,.5,.2 FROM abilities WHERE ability_key='executioners_edge'
UNION ALL SELECT id,1,'heal','ally','holy',8,0,0,.12,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='renewing_touch'
UNION ALL SELECT id,2,'heal_over_time','ally','holy',1,0,0,.03,6,1,1,'renewing_touch','restorative_aura','replace',1,1,1,1 FROM abilities WHERE ability_key='renewing_touch'
UNION ALL SELECT id,1,'heal','all_allies','holy',5,0,0,.10,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='circle_of_mending'
UNION ALL SELECT id,2,'heal_over_time','all_allies','holy',1,0,0,.02,5,1,1,'circle_of_mending','restorative_aura','replace',1,1,1,1 FROM abilities WHERE ability_key='circle_of_mending'
UNION ALL SELECT id,1,'shield','ally','holy',12,0,0,.10,7,0,1,'soothing_ward','soothing_ward','replace',1,.35,.75,1 FROM abilities WHERE ability_key='soothing_ward'
UNION ALL SELECT id,1,'buff','all_allies','holy',0,0,0,0,8,0,1,'battle_hymn','empowerment','replace',1,1,.8,.2 FROM abilities WHERE ability_key='battle_hymn'
UNION ALL SELECT id,1,'debuff','enemy','nature',0,0,0,0,7,0,1,'crippling_hex','mass_weakness','replace',1,.45,.1,.8 FROM abilities WHERE ability_key='crippling_hex'
UNION ALL SELECT id,1,'buff','self','nature',0,0,0,0,12,0,1,'familiar_call','familiar_call','replace',1,.55,.85,.25 FROM abilities WHERE ability_key='familiar_call'
UNION ALL SELECT id,1,'damage','enemy','physical',4,.55,0,0,0,0,1,NULL,NULL,'replace',1,.65,.1,.75 FROM abilities WHERE ability_key='vampiric_strike'
UNION ALL SELECT id,1,'buff','self','nature',0,0,0,0,8,0,1,'thornskin','thornskin','replace',1,.15,.8,.2 FROM abilities WHERE ability_key='thornskin'
UNION ALL SELECT id,1,'damage','enemy','holy',6,0,0,.50,0,0,1,NULL,NULL,'replace',1,1,.85,.25 FROM abilities WHERE ability_key='last_rites';

INSERT INTO items (name,base_price,stackable,description,taught_ability_id,item_category)
SELECT CONCAT('Tome: ',name),125,0,CONCAT('Teaches ',name,'. ',description),id,'consumable'
FROM abilities WHERE ability_key IN ('iron_bastion','challenge_roar','guardian_intercept','rend','sweeping_arc','executioners_edge','renewing_touch','circle_of_mending','soothing_ward','battle_hymn','crippling_hex','familiar_call','vampiric_strike','thornskin','last_rites')
ON DUPLICATE KEY UPDATE description=VALUES(description),taught_ability_id=VALUES(taught_ability_id),item_category='consumable';

DELETE effect FROM combat_ability_effects effect JOIN abilities ability ON ability.id=effect.ability_id
WHERE ability.ability_key IN ('fireball','haste','mass_weakness','restorative_aura','heavy_blow','wild_strike','cleave','charge_discharge','mana_shield','sickness');

INSERT INTO combat_ability_effects
(ability_id,effect_index,effect_type,target_type,damage_school,base_power,strength_ratio,dexterity_ratio,
 intelligence_ratio,duration_seconds,tick_interval_seconds,threat_multiplier,status_key,icon_key,stack_mode,max_stacks,tint_r,tint_g,tint_b)
SELECT id,1,'damage','enemy','magic',0,0,0,0,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='fireball'
UNION ALL SELECT id,1,'buff','ally','magic',0,0,0,0,3,0,1,'haste','haste','replace',1,1,1,1 FROM abilities WHERE ability_key='haste'
UNION ALL SELECT id,1,'damage','all_enemies','magic',0,0,0,.10,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='mass_weakness'
UNION ALL SELECT id,2,'debuff','all_enemies','magic',0,0,0,0,10,0,1,'mass_weakness','mass_weakness','stack_refresh',20,1,1,1 FROM abilities WHERE ability_key='mass_weakness'
UNION ALL SELECT id,1,'heal','all_allies','holy',3,0,0,.15,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='restorative_aura'
UNION ALL SELECT id,2,'heal_over_time','all_allies','holy',1,0,0,0,5,.5,1,'restorative_aura','restorative_aura','replace',1,1,1,1 FROM abilities WHERE ability_key='restorative_aura'
UNION ALL SELECT id,1,'damage','enemy','physical',5,.30,.30,0,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='heavy_blow'
UNION ALL SELECT id,2,'stun','enemy','physical',0,0,0,0,2,0,1,'stunned','heavy_blow','replace',1,1,1,1 FROM abilities WHERE ability_key='heavy_blow'
UNION ALL SELECT id,1,'damage','enemy','physical',5,0,.30,0,0,0,1,NULL,NULL,'replace',1,1,1,1 FROM abilities WHERE ability_key='wild_strike'
UNION ALL SELECT id,2,'buff','self','physical',0,0,0,0,10,0,1,'wild_momentum','wild_momentum','stack_no_refresh',3,1,.15,.15 FROM abilities WHERE ability_key='wild_strike'
UNION ALL SELECT id,1,'buff','self','physical',0,0,0,0,3,0,1,'cleave','cleave','replace',1,1,1,1 FROM abilities WHERE ability_key='cleave'
UNION ALL SELECT id,1,'buff','self','magic',0,0,0,0,10,0,1,'charged','charged','replace',1,1,.85,.15 FROM abilities WHERE ability_key='charge_discharge'
UNION ALL SELECT id,2,'buff','self','magic',0,0,0,0,9999,0,1,'discharge','discharge','replace',1,1,1,1 FROM abilities WHERE ability_key='charge_discharge'
UNION ALL SELECT id,1,'buff','self','magic',0,0,0,0,10,1,1,'mana_shield','mana_shield','replace',1,.15,.55,1 FROM abilities WHERE ability_key='mana_shield'
UNION ALL SELECT id,1,'debuff','enemy','nature',0,0,0,0,3,0,1,'sickness','sickness','replace',1,1,1,1 FROM abilities WHERE ability_key='sickness';

INSERT INTO items (name,base_price,stackable,description,taught_ability_id,item_category)
SELECT CONCAT('Tome: ',name),125,0,CONCAT('Teaches ',name,'. ',description),id,'consumable'
FROM abilities WHERE ability_key IN ('fireball','haste','mass_weakness','restorative_aura','heavy_blow','wild_strike','cleave','charge_discharge','mana_shield','sickness')
ON DUPLICATE KEY UPDATE description=VALUES(description),taught_ability_id=VALUES(taught_ability_id),item_category='consumable';

INSERT INTO npcs
(name,level,current_hp,max_hp,mana,max_mana,action_speed,strength,dex,intelligence,melee_defense,magic_defense,role,targeting_style,power)
VALUES
('Ember Adept',3,55,55,70,70,10.5,5,7,18,3,9,'DPS','lowest_hp',180),
('Chronomancer Initiate',4,68,68,100,100,11.0,6,10,20,5,11,'Support','random',235),
('Blight Hexer',4,72,72,90,90,9.5,7,8,21,6,12,'DPS','random',245),
('Grove Mender',4,78,78,110,110,9.0,7,8,23,7,14,'Healer','lowest_hp',250),
('Ironjaw Brute',4,120,120,20,20,8.0,24,15,4,15,6,'Tank','highest_threat',270),
('Frenzied Duelist',5,100,100,75,75,13.0,15,25,6,10,8,'DPS','lowest_hp',310),
('War Cleaver',5,145,145,65,65,9.0,27,16,5,17,9,'Tank','highest_threat',345),
('Storm Capacitor',5,105,105,180,180,10.0,8,11,28,9,17,'DPS','random',365),
('Mana Warden',5,155,155,150,150,8.5,13,13,24,19,20,'Tank','highest_threat',390),
('Plague Conductor',6,135,135,160,160,10.5,10,17,30,12,22,'DPS','random',440)
ON DUPLICATE KEY UPDATE level=VALUES(level),current_hp=VALUES(current_hp),max_hp=VALUES(max_hp),mana=VALUES(mana),
max_mana=VALUES(max_mana),action_speed=VALUES(action_speed),strength=VALUES(strength),dex=VALUES(dex),
intelligence=VALUES(intelligence),melee_defense=VALUES(melee_defense),magic_defense=VALUES(magic_defense),
role=VALUES(role),targeting_style=VALUES(targeting_style),power=VALUES(power);

INSERT INTO combat_npc_abilities(npc_id,ability_id,slot,priority)
SELECT npc.id,ability.id,seed.slot,seed.priority FROM (
 SELECT 'Ember Adept' npc_name,'fireball' ability_key,1 slot,1 priority UNION ALL
 SELECT 'Chronomancer Initiate','haste',1,1 UNION ALL SELECT 'Chronomancer Initiate','fireball',2,2 UNION ALL
 SELECT 'Blight Hexer','mass_weakness',1,1 UNION ALL SELECT 'Blight Hexer','sickness',2,2 UNION ALL
 SELECT 'Grove Mender','restorative_aura',1,1 UNION ALL
 SELECT 'Ironjaw Brute','heavy_blow',1,1 UNION ALL
 SELECT 'Frenzied Duelist','wild_strike',1,1 UNION ALL
 SELECT 'War Cleaver','cleave',1,1 UNION ALL SELECT 'War Cleaver','heavy_blow',2,2 UNION ALL
 SELECT 'Storm Capacitor','charge_discharge',1,1 UNION ALL SELECT 'Storm Capacitor','fireball',2,2 UNION ALL
 SELECT 'Mana Warden','mana_shield',1,1 UNION ALL SELECT 'Mana Warden','haste',2,2 UNION ALL
 SELECT 'Plague Conductor','sickness',1,1 UNION ALL SELECT 'Plague Conductor','mass_weakness',2,2 UNION ALL SELECT 'Plague Conductor','poison',3,3
) seed JOIN npcs npc ON npc.name=seed.npc_name JOIN abilities ability ON ability.ability_key=seed.ability_key
ON DUPLICATE KEY UPDATE ability_id=VALUES(ability_id),priority=VALUES(priority);

INSERT INTO combat_loot_tables(name)
SELECT CONCAT(name,' Loot') FROM npcs WHERE name IN ('Ember Adept','Chronomancer Initiate','Blight Hexer','Grove Mender','Ironjaw Brute','Frenzied Duelist','War Cleaver','Storm Capacitor','Mana Warden','Plague Conductor')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO combat_loot_table_entries(loot_table_id,item_id,drop_chance,weight,min_quantity,max_quantity)
SELECT loot.id,item.id,.025,1,1,1 FROM (
 SELECT 'Ember Adept' npc_name,'Fireball' ability_name UNION ALL
 SELECT 'Chronomancer Initiate','Haste' UNION ALL SELECT 'Chronomancer Initiate','Fireball' UNION ALL
 SELECT 'Blight Hexer','Mass Weakness' UNION ALL SELECT 'Blight Hexer','Sickness' UNION ALL
 SELECT 'Grove Mender','Restorative Aura' UNION ALL SELECT 'Ironjaw Brute','Heavy Blow' UNION ALL
 SELECT 'Frenzied Duelist','Wild Strike' UNION ALL SELECT 'War Cleaver','Cleave' UNION ALL SELECT 'War Cleaver','Heavy Blow' UNION ALL
 SELECT 'Storm Capacitor','Charge/Discharge' UNION ALL SELECT 'Storm Capacitor','Fireball' UNION ALL
 SELECT 'Mana Warden','Mana Shield' UNION ALL SELECT 'Mana Warden','Haste' UNION ALL
 SELECT 'Plague Conductor','Sickness' UNION ALL SELECT 'Plague Conductor','Mass Weakness'
) seed JOIN combat_loot_tables loot ON loot.name=CONCAT(seed.npc_name,' Loot')
JOIN items item ON item.name=CONCAT('Tome: ',seed.ability_name)
ON DUPLICATE KEY UPDATE drop_chance=VALUES(drop_chance),min_quantity=1,max_quantity=1;

INSERT INTO combat_npc_loot(npc_id,loot_table_id,min_gold,max_gold,min_experience,max_experience)
SELECT npc.id,loot.id,npc.level*6,npc.level*10,npc.level*8,npc.level*13
FROM npcs npc JOIN combat_loot_tables loot ON loot.name=CONCAT(npc.name,' Loot')
WHERE npc.name IN ('Ember Adept','Chronomancer Initiate','Blight Hexer','Grove Mender','Ironjaw Brute','Frenzied Duelist','War Cleaver','Storm Capacitor','Mana Warden','Plague Conductor')
ON DUPLICATE KEY UPDATE loot_table_id=VALUES(loot_table_id),min_gold=VALUES(min_gold),max_gold=VALUES(max_gold),
min_experience=VALUES(min_experience),max_experience=VALUES(max_experience);

INSERT INTO combat_encounter_entries(encounter_table_id,npc_id,weight,min_count,max_count)
SELECT encounter.id,npc.id,GREATEST(4,18-npc.level*2),0,CASE WHEN npc.level<=4 THEN 2 ELSE 1 END
FROM combat_encounter_tables encounter CROSS JOIN npcs npc
WHERE npc.name IN ('Ember Adept','Chronomancer Initiate','Blight Hexer','Grove Mender','Ironjaw Brute','Frenzied Duelist','War Cleaver','Storm Capacitor','Mana Warden','Plague Conductor')
ON DUPLICATE KEY UPDATE weight=VALUES(weight),min_count=VALUES(min_count),max_count=VALUES(max_count);
