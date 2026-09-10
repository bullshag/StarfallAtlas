-- Inserts a new account without hashing the password
INSERT INTO Users (Username, Nickname, PasswordHash, Gold, last_seen, appearance_key)
VALUES (@username, @nickname, @password, 500, NOW(), @appearanceKey);
