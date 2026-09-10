-- Ensure Small Village exposes the tavern facility.
INSERT INTO activities (node_id, activity_type, description)
SELECT 'nodeSmallVillage', 'tavern', 'Hire party members at the Small Village tavern.'
WHERE NOT EXISTS (SELECT 1 FROM activities WHERE node_id='nodeSmallVillage' AND activity_type='tavern');
