SELECT id, nickname, COALESCE(appearance_key, 'chara2_1') AS appearance_key FROM users WHERE username = @username AND passwordhash = @passwordHash;
