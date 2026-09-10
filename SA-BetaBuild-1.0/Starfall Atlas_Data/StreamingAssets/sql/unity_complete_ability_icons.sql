-- Complete ability/status icon coverage. Safe to rerun.
USE accounts;

ALTER TABLE abilities ADD COLUMN IF NOT EXISTS icon_key VARCHAR(64) NULL AFTER behavior_key;

UPDATE abilities SET icon_key=CASE
 WHEN LOWER(name) REGEXP 'heal|rejuven|prayer|cleanse|mending' THEN 'restorative_aura'
 WHEN LOWER(name) REGEXP 'fire|flame|meteor|searing|smite|holy light' THEN 'holy_flames'
 WHEN LOWER(name) REGEXP 'poison|venom' THEN 'poison'
 WHEN LOWER(name) REGEXP 'bleed|rend' THEN 'bleed'
 WHEN LOWER(name) REGEXP 'shield|ward|aegis|fortify|stone skin|bastion|intercept' THEN 'guardian'
 WHEN LOWER(name) REGEXP 'enrage|berserk|battle cry|taunt|challenge' THEN 'enrage'
 WHEN LOWER(name) REGEXP 'ice|frost|blizzard' THEN 'mana_shield'
 WHEN LOWER(name) REGEXP 'lightning|thunder|shock' THEN 'spellstorm'
 WHEN LOWER(name) REGEXP 'shadow|drain|blood|sickness|hex' THEN 'sickness'
 WHEN LOWER(name) REGEXP 'quick|strike|blow|bash|fist|slash|shot|arc|earthquake' THEN 'heavy_blow'
 WHEN LOWER(name) REGEXP 'summon|call|youngling|familiar' THEN 'familiar_call'
 ELSE 'arcane_whisper' END
WHERE icon_key IS NULL OR TRIM(icon_key)='';

UPDATE abilities SET icon_key='sickness' WHERE icon_key='Purple15';
UPDATE abilities SET icon_key='heavy_blow' WHERE icon_key='Red10';

UPDATE combat_ability_effects effect
JOIN abilities ability ON ability.id=effect.ability_id
SET effect.icon_key=CASE WHEN COALESCE(TRIM(effect.status_key),'')<>'' THEN effect.status_key ELSE ability.icon_key END
WHERE effect.icon_key IS NULL OR TRIM(effect.icon_key)='';
UPDATE combat_ability_effects SET icon_key='sickness' WHERE icon_key='Purple15';
UPDATE combat_ability_effects SET icon_key='heavy_blow' WHERE icon_key='Red10';
