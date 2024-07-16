-- +migrate Up
INSERT INTO user_test (username) VALUES ('Ray');

-- +migrate Down
DELETE FROM user_test WHERE username = 'Ray';
