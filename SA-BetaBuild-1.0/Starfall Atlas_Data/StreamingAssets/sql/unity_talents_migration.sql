CREATE TABLE IF NOT EXISTS talent_definitions (
    talent_key VARCHAR(64) NOT NULL PRIMARY KEY,
    display_name VARCHAR(96) NOT NULL,
    description TEXT NOT NULL,
    parent_key VARCHAR(64) NULL,
    depth TINYINT UNSIGNED NOT NULL,
    point_cost TINYINT UNSIGNED NOT NULL,
    CONSTRAINT fk_talent_parent FOREIGN KEY (parent_key) REFERENCES talent_definitions(talent_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS character_talents (
    character_id INT NOT NULL,
    talent_key VARCHAR(64) NOT NULL,
    purchased_utc DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (character_id, talent_key),
    CONSTRAINT fk_character_talent_character FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_character_talent_definition FOREIGN KEY (talent_key) REFERENCES talent_definitions(talent_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO talent_definitions(talent_key,display_name,description,parent_key,depth,point_cost) VALUES
('arcane_whisper','Arcane Whisper','Original ability damage has a 1% + INT/level chance to deal additional magic damage based on Intelligence and level.',NULL,0,1),
('tempo','Tempo','Ability use has a 10% chance to halve all remaining cooldowns and halve the mana cost of the next mana-cost ability.','arcane_whisper',1,2),
('sigil_art','Sigil Art','Using Priority 1 schedules a free, cooldown-free duplicate one second later. The copy cannot trigger talent procs.','tempo',2,3),
('spell_fury','Spell Fury','Mana-spending casts gain 5% stacking ability damage before resolving. Stacks clear after a cast at 15% mana or lower.','sigil_art',3,4),
('spellstorm','Spellstorm','Applying an enemy debuff has a 50% chance to copy it to one other living enemy.','arcane_whisper',1,2),
('mana_resident','Mana Resident','Mana gains share 25% with other allies. At 50% mana, 10% of post-shield damage is paid from mana before health.','spellstorm',2,3),
('ripple','Ripple','When a timed stat buff expires, other living allies receive a non-rippling copy at half potency, stacks, and duration.','mana_resident',3,4),
('life_flows','Life Flows','Mana-cost healing may target allies and prioritizes the living ally with the lowest health percentage.',NULL,0,1),
('lifegiver','Lifegiver','Healing another ally has a 15% chance to add a five-second heal over time worth 15% of the actual heal each second.','life_flows',1,2),
('radiant_healing','Radiant Healing','All healing on a target carrying your buff is increased by 10% and restores 2% of actual healing as mana, except to yourself.','lifegiver',2,3),
('armorgiver','Armorgiver','Critical healing grants a source-owned shield worth 15% of actual healing, subject to a level and Intelligence cap.','life_flows',1,2),
('radiant_shields','Radiant Shields','At 15% mana or lower, your source-owned shields have double effective absorption and triple maximum capacity.','armorgiver',2,3),
('verge','Verge','Overhealing grants the target 10% damage reduction for three seconds.','life_flows',1,2),
('abstain','Abstain','Healing and absorption increase by 5% for each complete 25% of health the target is missing.','verge',2,3),
('guardian','Guardian','Healing -5%, threat +25%, damage -10%, defenses +10%, maximum HP +5%; prefer enemies attacking someone else.',NULL,0,1),
('suppress','Suppress','Original hits apply a non-refreshing five-second debuff reducing damage to everyone except you by 50%.','guardian',1,2),
('defensive_flurry','Defensive Flurry','Original direct hits and periodic ticks add 3% defenses for three seconds; adding stacks does not refresh the timer.','suppress',2,3),
('scatter','Scatter','Threat +25%. Weapon attacks also strike a different enemy for 25% pre-mitigation damage without triggering talent procs.','defensive_flurry',3,4),
('holy_flames','Holy Flames','Damage taken -15%. Direct hits create independent five-second self-burns totaling 15% of actual damage taken.','suppress',2,3),
('burning_spirit','Burning Spirit','Health damage from Holy Flames heals every other living ally for 50%, minimum 1.','holy_flames',3,4),
('battle_hungry','Battle Hungry','Threat -25%, attack speed +5%, defenses -5%.',NULL,0,1),
('enrage','Enrage','Successful original hostile actions grant 1% damage for five seconds, stacking to 25 and refreshing duration.','battle_hungry',1,2),
('focus','Focus','Successful original hostile actions grant 1% attack speed for five seconds, stacking to 25 and refreshing duration.','enrage',2,3),
('bleed','Bleed','Non-mana and weapon attacks bank 10% of inflicted damage as five one-second ticks; added damage does not refresh expiry.','focus',3,4),
('empowerment','Empowerment','Damage or healing received starts a random stacking bonus cycle; a successful hostile action clears it after resolving.','bleed',4,5),
('empowered_enrage','Empowered Enrage','Enrage can reach 100 stacks, but adding stacks no longer refreshes its duration.','empowerment',5,6),
('empowered_focus','Empowered Focus','Ability damage is increased by total attack speed above baseline.','empowerment',5,6),
('empowered_bleed','Empowered Bleed','Bleed banks 15% damage and each bleed health tick also removes mana equal to 10% of its damage.','empowerment',5,6),
('vet','Vet','Combat begins with a random 15% stat buff for ten seconds; successful original actions reduce it by three points.','empowerment',5,6)
ON DUPLICATE KEY UPDATE display_name=VALUES(display_name),description=VALUES(description),parent_key=VALUES(parent_key),depth=VALUES(depth),point_cost=VALUES(point_cost);
