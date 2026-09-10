-- Authoritative projectile delivery metadata. This migration is additive and
-- intentionally leaves existing range, power, and cooldown tuning intact.
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS delivery_type VARCHAR(16) NOT NULL DEFAULT 'instant';
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS projectile_speed_yards DECIMAL(8,2) NOT NULL DEFAULT 35;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS projectile_radius_yards DECIMAL(8,2) NOT NULL DEFAULT 0.75;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS projectile_lifetime_seconds DECIMAL(8,2) NOT NULL DEFAULT 2.5;
ALTER TABLE abilities ADD COLUMN IF NOT EXISTS projectile_homing TINYINT(1) NOT NULL DEFAULT 0;

-- Contact actions resolve at the target.  Area and caster/self effects stay
-- instant; only explicitly listed attacks launch a world-space projectile.
UPDATE abilities SET delivery_type='melee'
 WHERE ability_key IN ('quick_strike','heavy_blow','wild_strike','shield_bash','taunting_blows','vampiric_strike','execute','bleed');
UPDATE abilities SET delivery_type='area'
 WHERE COALESCE(area_radius_yards,0)>0;
UPDATE abilities SET delivery_type='projectile', projectile_speed_yards=35, projectile_radius_yards=.75, projectile_lifetime_seconds=2.5, projectile_homing=0
 WHERE ability_key IN ('fireball','ice_lance','lightning_bolt','shadow_bolt','mind_spike','wind_slash','poison_arrow','piercing_shot','silencing_shot');
UPDATE abilities SET delivery_type='projectile', projectile_speed_yards=30, projectile_radius_yards=.65, projectile_lifetime_seconds=3, projectile_homing=1
 WHERE ability_key='magic_missile';
