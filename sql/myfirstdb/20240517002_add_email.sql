-- +migrate Up
ALTER TABLE user_test
ADD COLUMN email VARCHAR(255) NOT NULL DEFAULT '' COMMENT '使用者Email，不能為空';

-- +migrate Down
ALTER TABLE user_test
DROP COLUMN email;