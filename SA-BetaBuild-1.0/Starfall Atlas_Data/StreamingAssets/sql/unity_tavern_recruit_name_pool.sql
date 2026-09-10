-- Add the reusable fantasy-name pool used when taverns generate hire candidates.
-- Existing neutral templates are preserved. A hired character no longer counts as
-- a neutral template, allowing the name to return to the pool for other accounts.
INSERT INTO characters (
    account_id,
    name,
    current_hp,
    max_hp,
    mana,
    max_mana,
    experience_points,
    action_speed,
    strength,
    dex,
    intelligence,
    melee_defense,
    magic_defense,
    level,
    skill_points,
    in_tavern
)
SELECT
    NULL,
    seed.name,
    45,
    45,
    45,
    45,
    0,
    1,
    10,
    10,
    10,
    0,
    0,
    1,
    0,
    1
FROM (
    SELECT 'Alden Veyr' AS name
    UNION ALL SELECT 'Mira Thorn'
    UNION ALL SELECT 'Cael Rowan'
    UNION ALL SELECT 'Sera Vale'
    UNION ALL SELECT 'Bram Hollow'
    UNION ALL SELECT 'Nessa Quill'
    UNION ALL SELECT 'Torren Ash'
    UNION ALL SELECT 'Elira Fen'
    UNION ALL SELECT 'Garrick Stone'
    UNION ALL SELECT 'Lyra Dawn'
    UNION ALL SELECT 'Oren Pike'
    UNION ALL SELECT 'Talia Reed'
    UNION ALL SELECT 'Joren Blackwood'
    UNION ALL SELECT 'Kessa Mire'
    UNION ALL SELECT 'Darian Frost'
    UNION ALL SELECT 'Vela Hart'
    UNION ALL SELECT 'Rurik Ember'
    UNION ALL SELECT 'Anwen Gale'
    UNION ALL SELECT 'Corin Wren'
    UNION ALL SELECT 'Maelis Rune'
    UNION ALL SELECT 'Harlan Crest'
    UNION ALL SELECT 'Ilyra Moss'
    UNION ALL SELECT 'Bastian Crow'
    UNION ALL SELECT 'Nyra Flint'
    UNION ALL SELECT 'Eamon Rook'
    UNION ALL SELECT 'Selene Marsh'
    UNION ALL SELECT 'Tobin Graye'
    UNION ALL SELECT 'Arden Skye'
    UNION ALL SELECT 'Freya Calder'
    UNION ALL SELECT 'Lucan Briar'
    UNION ALL SELECT 'Ysra Moon'
    UNION ALL SELECT 'Kellan Voss'
    UNION ALL SELECT 'Maren Holt'
    UNION ALL SELECT 'Doran Fallow'
    UNION ALL SELECT 'Elowen Cairn'
    UNION ALL SELECT 'Perrin Locke'
    UNION ALL SELECT 'Thalia Venn'
    UNION ALL SELECT 'Rowan Strake'
    UNION ALL SELECT 'Isolde Mere'
    UNION ALL SELECT 'Cedric Noll'
    UNION ALL SELECT 'Asha Lark'
    UNION ALL SELECT 'Varren Dusk'
    UNION ALL SELECT 'Kaia Winter'
    UNION ALL SELECT 'Osric Bell'
    UNION ALL SELECT 'Liora Sable'
    UNION ALL SELECT 'Theron Mott'
    UNION ALL SELECT 'Eira Sol'
    UNION ALL SELECT 'Merek Tarn'
    UNION ALL SELECT 'Sabine Orr'
    UNION ALL SELECT 'Galen Ward'
) AS seed
WHERE NOT EXISTS (
    SELECT 1
    FROM characters existing
    WHERE existing.account_id IS NULL
      AND existing.name = seed.name
);
