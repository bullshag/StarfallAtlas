-- Applies the August 2026 party-member baseline increase exactly once.
-- Current HP/MP gain the same amount as their maxima so existing damage and
-- spent-mana deficits are preserved instead of silently healing to full.

CREATE TABLE IF NOT EXISTS unity_applied_migrations (
    migration_key VARCHAR(100) NOT NULL,
    applied_utc DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
    PRIMARY KEY (migration_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

START TRANSACTION;

INSERT IGNORE INTO unity_applied_migrations (migration_key)
VALUES ('party_base_stats_plus_2026_08');

SET @apply_party_base_stats = ROW_COUNT();

UPDATE characters
SET max_hp = max_hp + (10 * @apply_party_base_stats),
    current_hp = current_hp + (10 * @apply_party_base_stats),
    max_mana = max_mana + (10 * @apply_party_base_stats),
    mana = mana + (10 * @apply_party_base_stats),
    strength = strength + (5 * @apply_party_base_stats),
    dex = dex + (5 * @apply_party_base_stats),
    intelligence = intelligence + (5 * @apply_party_base_stats);

UPDATE unity_tavern_recruits
SET max_hp = max_hp + (10 * @apply_party_base_stats),
    max_mp = max_mp + (10 * @apply_party_base_stats),
    strength = strength + (5 * @apply_party_base_stats),
    dexterity = dexterity + (5 * @apply_party_base_stats),
    intelligence = intelligence + (5 * @apply_party_base_stats);

COMMIT;
