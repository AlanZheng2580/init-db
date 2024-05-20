-- +migrate Up
ALTER TABLE user_test
ADD COLUMN email VARCHAR(255) NOT NULL DEFAULT '';

-- +migrate Down
ALTER TABLE user_test
DROP COLUMN email;