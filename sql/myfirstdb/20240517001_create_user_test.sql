-- +migrate Up
CREATE TABLE user_test (
  `user_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '使用者 ID，自動增量',
  `username` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '使用者名稱，不能為空',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '創建時間，默認為當前時間',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間，默認為當前時間並在更新時更新'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用戶測試表'; -- 表格引擎為 InnoDB，字符集為 utf8mb4，並添加表格評論

-- +migrate Down
DROP TABLE `user_test`;