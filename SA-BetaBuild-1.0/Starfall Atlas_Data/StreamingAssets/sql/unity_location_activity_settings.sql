SELECT activity_type AS activity_key,
       1 AS is_enabled
FROM activities
WHERE node_id = @location_id
ORDER BY activity_type;
