-- Server-authoritative spatial combat, range metadata, and persistent combat art.
-- Safe to rerun against clean and existing databases.
USE accounts;

ALTER TABLE abilities ADD COLUMN IF NOT EXISTS minimum_range_yards DECIMAL(8,3) NOT NULL DEFAULT 0;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS maximum_range_yards DECIMAL(8,3) NOT NULL DEFAULT 15;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS area_radius_yards DECIMAL(8,3) NOT NULL DEFAULT 0;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS area_origin VARCHAR(16) NOT NULL DEFAULT 'target';
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS animation_kind VARCHAR(24) NOT NULL DEFAULT 'attack';
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS windup_seconds DECIMAL(6,3) NOT NULL DEFAULT 0.350;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS recovery_seconds DECIMAL(6,3) NOT NULL DEFAULT 0.200;

ALTER TABLE characters ADD COLUMN IF NOT EXISTS combat_appearance_key VARCHAR(64) NULL;
ALTER TABLE npcs ADD COLUMN IF NOT EXISTS combat_appearance_key VARCHAR(64) NULL;
ALTER TABLE npcs ADD COLUMN IF NOT EXISTS combat_style VARCHAR(16) NOT NULL DEFAULT 'Melee';
ALTER TABLE combat_encounters ADD COLUMN IF NOT EXISTS arena_version VARCHAR(64) NULL;

CREATE TABLE IF NOT EXISTS combat_appearance_roles (
    appearance_key VARCHAR(64) NOT NULL,
    role_tag VARCHAR(16) NOT NULL,
    PRIMARY KEY (appearance_key, role_tag)
);

INSERT IGNORE INTO combat_appearance_roles(appearance_key,role_tag) VALUES
('chara2_8','Tank'),('chara3_2','Tank'),('chara4_7','Tank'),('chara4_8','Tank'),('chara5_4','Tank'),('chara5_6','Tank'),('chara5_7','Tank'),
('chara2_1','Healer'),('chara2_7','Healer'),('chara3_1','Healer'),('chara3_4','Healer'),('chara4_1','Healer'),('chara4_3','Healer'),('chara4_6','Healer'),('chara5_2','Healer'),('chara5_5','Healer'),
('chara2_2','MeleeDps'),('chara2_3','MeleeDps'),('chara2_4','MeleeDps'),('chara3_3','MeleeDps'),('chara3_5','MeleeDps'),('chara4_2','MeleeDps'),('chara4_4','MeleeDps'),('chara5_1','MeleeDps'),
('chara2_5','RangedDps'),('chara2_6','RangedDps'),('chara3_6','RangedDps'),('chara3_7','RangedDps'),('chara3_8','RangedDps'),('chara4_5','RangedDps'),('chara5_3','RangedDps'),('chara5_8','RangedDps');

-- Seed only abilities that have never received spatial metadata. This keeps
-- later hand-tuned ranges and timings intact when database_setup.sql is rerun.
UPDATE abilities SET minimum_range_yards=0,maximum_range_yards=15,area_radius_yards=0,area_origin='target',animation_kind='attack',windup_seconds=0.350,recovery_seconds=0.200
WHERE COALESCE(description,'') NOT LIKE '%\nRange:%';

-- Self-only abilities never require navigation.
UPDATE abilities a JOIN combat_ability_effects e ON e.ability_id=a.id
SET a.minimum_range_yards=0,a.maximum_range_yards=0,a.area_radius_yards=0,a.area_origin='caster',a.animation_kind='cast'
WHERE LOWER(e.target_type)='self' AND COALESCE(a.description,'') NOT LIKE '%\nRange:%';

-- Current all-target effects are caster-centered and spatially limited.
UPDATE abilities a JOIN combat_ability_effects e ON e.ability_id=a.id
SET a.minimum_range_yards=0,a.maximum_range_yards=0,a.area_radius_yards=15,a.area_origin='caster',a.animation_kind='cast',a.windup_seconds=0.450
WHERE LOWER(e.target_type) IN ('all_enemies','all_allies') AND COALESCE(a.description,'') NOT LIKE '%\nRange:%';

-- Weapon-contact abilities use the 4-yard melee radius.
UPDATE abilities SET minimum_range_yards=0,maximum_range_yards=4,area_radius_yards=0,area_origin='target',animation_kind='melee'
WHERE LOWER(COALESCE(ability_key,REPLACE(name,' ','_'))) IN
('quick_strike','heavy_blow','wild_strike','shield_bash','taunting_blows','vampiric_strike','execute','bleed');

-- Every targeted non-area ability must have a finite maximum range, even when
-- an older row already contains a range annotation in its description.
UPDATE abilities a
SET a.minimum_range_yards=0,a.maximum_range_yards=15
WHERE (a.maximum_range_yards IS NULL OR a.maximum_range_yards<=0)
  AND NOT EXISTS (
      SELECT 1 FROM combat_ability_effects e
      WHERE e.ability_id=a.id
        AND (LOWER(e.target_type)='self'
             OR LOWER(e.target_type) IN ('all_enemies','all_allies') AND LOWER(a.area_origin)='caster')
  );

-- Healing and magical actions use the generic cast animation.
UPDATE abilities a JOIN combat_ability_effects e ON e.ability_id=a.id
SET a.animation_kind='cast',a.windup_seconds=0.450
WHERE LOWER(e.effect_type) IN ('heal','heal_over_time','shield','absorb','buff','debuff','damage_over_time')
  AND a.maximum_range_yards>0 AND COALESCE(a.description,'') NOT LIKE '%\nRange:%';

-- Keep the displayed description derived from the authoritative range fields.
UPDATE abilities
SET description=CONCAT(TRIM(SUBSTRING_INDEX(COALESCE(description,''),'\nRange:',1)),'\nRange: ',
    CASE
      WHEN area_radius_yards>0 THEN CONCAT(area_radius_yards+0,' yards around the ',area_origin)
      WHEN maximum_range_yards=0 THEN 'Self'
      WHEN minimum_range_yards>0 THEN CONCAT(minimum_range_yards+0,'-',maximum_range_yards+0,' yards')
      ELSE CONCAT(maximum_range_yards+0,' yards')
    END)
WHERE COALESCE(description,'') NOT LIKE '%\nRange:%';

-- Stable role-themed backfill for existing characters. New hires use the same pools.
UPDATE characters SET combat_appearance_key = CASE
  WHEN LOWER(COALESCE(role,'dps'))='tank' THEN ELT(1+MOD(id,7),'chara2_8','chara3_2','chara4_7','chara4_8','chara5_4','chara5_6','chara5_7')
  WHEN LOWER(COALESCE(role,'dps')) IN ('healer','support') THEN ELT(1+MOD(id,9),'chara2_1','chara2_7','chara3_1','chara3_4','chara4_1','chara4_3','chara4_6','chara5_2','chara5_5')
  WHEN LOWER(COALESCE(role,'')) REGEXP 'ranged|archer|caster|mage|channeler'
    OR intelligence >= GREATEST(strength,dex)+2
    OR EXISTS (
      SELECT 1 FROM character_equipment ce
      JOIN items equipped_item ON equipped_item.name=ce.item_name
      WHERE ce.character_name=characters.name
        AND LOWER(COALESCE(equipped_item.weapon_type,'')) IN ('bow','wand','staff','rod')
    )
    THEN ELT(1+MOD(id,8),'chara2_5','chara2_6','chara3_6','chara3_7','chara3_8','chara4_5','chara5_3','chara5_8')
  ELSE ELT(1+MOD(id,8),'chara2_2','chara2_3','chara2_4','chara3_3','chara3_5','chara4_2','chara4_4','chara5_1')
END WHERE combat_appearance_key IS NULL OR combat_appearance_key='';

UPDATE npcs SET combat_style=CASE
  WHEN LOWER(COALESCE(role,'')) IN ('healer','support') THEN 'Support'
  WHEN LOWER(name) REGEXP 'sharpshooter|archer|hexer|mage|mender|acolyte|adept|channel|capacitor|astromancer|arcanist' THEN 'Ranged'
  ELSE 'Melee' END
WHERE combat_appearance_key IS NULL OR combat_appearance_key='';

UPDATE npcs SET combat_appearance_key=CASE name
  WHEN 'Snow Wolf' THEN 'SnowWolf'
  WHEN 'Bandit Guard' THEN 'BanditGuard'
  WHEN 'Bandit Captain' THEN 'BanditCaptain'
  WHEN 'Cultist Acolyte' THEN 'CultistAcolyte'
  WHEN 'Ashen Cultist' THEN 'AshenCultist'
  WHEN 'Bandit Sharpshooter' THEN 'BanditSharpshooter'
  WHEN 'Blight Hexer' THEN 'BlightHexer'
  WHEN 'Chronomancer Initiate' THEN 'ChronomancerInitiate'
  WHEN 'Cinderlord Ignivar' THEN 'CinderlordIgnivar'
  WHEN 'Dune Spellbinder' THEN 'DuneSpellbinder'
  WHEN 'Ember Adept' THEN 'EmberAdept'
  WHEN 'Fire Ember' THEN 'FireEmber'
  WHEN 'Frenzied Duelist' THEN 'FrenziedDuelist'
  WHEN 'Grave Knight' THEN 'GraveKnight'
  WHEN 'Grove Mender' THEN 'GroveMender'
  WHEN 'Grove Stalker' THEN 'GroveStalker'
  WHEN 'Ironclad Mercenary' THEN 'IroncladMercenary'
  WHEN 'Ironjaw Brute' THEN 'IronjawBrute'
  WHEN 'Mossback Treant' THEN 'MossbackTreant'
  WHEN 'Sand Raider' THEN 'SandRaider'
  WHEN 'Storm Capacitor' THEN 'StormCapacitor'
  WHEN 'Thorn Sprite' THEN 'ThornSprite'
  WHEN 'War Cleaver' THEN 'WarCleaver'
  WHEN 'Ash Wolf' THEN 'SnowWolf'
  WHEN 'Plague Conductor' THEN 'PlagueConductor'
  ELSE 'BanditGuard' END
WHERE combat_appearance_key IS NULL OR combat_appearance_key='';
UPDATE npcs SET combat_appearance_key='SnowWolf' WHERE name='Ash Wolf' AND combat_appearance_key='AshWolf';

CREATE INDEX IF NOT EXISTS ix_characters_combat_appearance ON characters(combat_appearance_key);
CREATE INDEX IF NOT EXISTS ix_npcs_combat_appearance ON npcs(combat_appearance_key);
