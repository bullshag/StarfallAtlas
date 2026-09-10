ALTER TABLE users ADD COLUMN IF NOT EXISTS appearance_key VARCHAR(32) NOT NULL DEFAULT 'chara2_1';
UPDATE users SET appearance_key='chara2_1' WHERE appearance_key IS NULL OR appearance_key='';
