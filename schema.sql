BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `unit` (
    `name`      TEXT PRIMARY KEY,
    `symbol`    TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS `transfer` (
    `from_id`        INTEGER,
    `to_id`          INTEGER,
    `valuable_id`    INTEGER NOT NULL,
    `amount`         INTEGER NOT NULL,
    `transaction_id` INTEGER NOT NULL,
    FOREIGN KEY(`transaction_id`) REFERENCES `transaction`(`transaction_id`),
    FOREIGN KEY(`from_id`) REFERENCES `user`(`account_id`),
    FOREIGN KEY(`to_id`) REFERENCES `user`(`account_id`),
    FOREIGN KEY(`valuable_id`) REFERENCES `valuable`(`valuable_id`)
);
CREATE TABLE IF NOT EXISTS `transaction` (
    `transaction_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `visible`   BOOLEAN NOT NULL DEFAULT 1,
    `comment`   TEXT,
    `datetime`  TEXT
);
CREATE TABLE IF NOT EXISTS `valuable` (
    `valuable_id`   INTEGER PRIMARY KEY AUTOINCREMENT,
    `name`          TEXT NOT NULL UNIQUE,
    `active`        INTEGER NOT NULL DEFAULT 1,
    `unit_name`     INTEGER NOT NULL,
    `price`         INTEGER NOT NULL,
    `image_path`    TEXT,
    `product`       INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY(`unit_name`) REFERENCES `unit`(`name`)
);
CREATE TABLE IF NOT EXISTS `user` (
    `name`               TEXT NOT NULL UNIQUE,
    `account_id`         INTEGER PRIMARY KEY AUTOINCREMENT,
    `mail`               TEXT,
    `image_path`         TEXT,
    `browsable`          INTEGER NOT NULL DEFAULT 1,
    `direct_payment`     INTEGER NOT NULL DEFAULT 0,
    `allow_edit_profile` INTEGER NOT NULL DEFAULT 1,
    `active`             INTEGER NOT NULL DEFAULT 1,
    `tax`                INTEGER NOT NULL DEFAULT 0,
	`start_semester`     INTEGER
);

CREATE VIEW IF NOT EXISTS `account_valuable_balance` AS
    SELECT
        user.name AS account_name,
        account_id,
        valuable.name AS valuable_name,
        valuable_id,
        ifnull((SELECT sum(ifnull(amount,0)) FROM transfer WHERE to_id = account_id AND valuable_id = valuable.valuable_id),0)-ifnull((SELECT sum(ifnull(amount,0)) FROM transfer WHERE from_id = account_id AND valuable_id = valuable.valuable_id),0) AS balance,
        valuable.unit_name AS unit_name
    FROM user, valuable
    ORDER BY account_id;

-- detailed transfer history, canceled transactions are hidden
CREATE VIEW IF NOT EXISTS `stats` AS
    SELECT 
        `transaction`.transaction_id,
        comment,
        datetime,
        account_from.name AS from_name,
        from_id,
        account_to.name AS to_name,
        to_id,
        amount,
        valuable.unit_name,
        valuable.name AS valuable_name,
        valuable.valuable_id
    FROM `transaction`
    JOIN transfer ON `transaction`.transaction_id = transfer.transaction_id
    JOIN `valuable` ON transfer.valuable_id = valuable.valuable_id
    LEFT JOIN user AS account_from ON from_id = account_from.account_id
    LEFT JOIN user AS account_to ON to_id = account_to.account_id
    WHERE visible = 1
    ORDER BY strftime("%s", datetime) DESC;

-- view for semester page
CREATE VIEW IF NOT EXISTS `index` AS
    SELECT user.name AS name, image_path, balance, umsatz, start_semester
    FROM user
    INNER JOIN account_valuable_balance AS avb ON user.account_id = avb.account_id
    LEFT JOIN (
        -- calculate turnover
        SELECT to_id, SUM(price) AS umsatz 
        FROM (
            -- select last 1000 transactions which aren't canceled
            SELECT to_id, price 
            FROM `transfer` 
            INNER JOIN valuable ON transfer.valuable_id=valuable.valuable_id
            INNER JOIN `transaction` ON `transaction`.transaction_id = transfer.transaction_id
            WHERE transfer.valuable_id != 1 AND to_id != 4 AND visible = 1
            ORDER BY transfer.transaction_id DESC 
            LIMIT 1000
        ) GROUP BY to_id
        ) ON ( to_id = avb.account_id )
    WHERE active=1 AND browsable=1 AND valuable_id = 1
    ORDER BY umsatz DESC, name ASC;

	
INSERT OR IGNORE INTO `user` (`name`, `browsable`, `direct_payment`, `allow_edit_profile`)
    VALUES ('Graue Kasse', 0, 0, 0);
INSERT OR IGNORE INTO `user` (`name`, `browsable`, `direct_payment`, `allow_edit_profile`)
    VALUES ('Bankkonto', 0, 0, 0);
INSERT OR IGNORE INTO `user` (`name`, `browsable`, `direct_payment`, `allow_edit_profile`)
    VALUES ('Lager & Kühlschrank', 0, 0, 0);
INSERT OR IGNORE INTO `user` (`name`, `browsable`, `direct_payment`, `allow_edit_profile`, `tax`)
    VALUES ('Gäste', 0, 1, 0, 0);

INSERT OR IGNORE INTO `unit` (`name`, `symbol`) VALUES ('Cent', '¢');
INSERT OR IGNORE INTO `unit` (`name`, `symbol`) VALUES ('Flasche', 'Fl.');
INSERT OR IGNORE INTO `unit` (`name`, `symbol`) VALUES ('Stück', 'Stk.');
INSERT OR IGNORE INTO `unit` (`name`, `symbol`) VALUES ('Tasse', 'Tas.');

INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`, `product`)
    VALUES ('Euro', 1, 'Cent', 1, NULL, 0);
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Bier (0,5)', 1, 'Flasche', 100, 'products/bier_05.jpg');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Bier (0,3)', 1, 'Flasche', 70, 'products/bier_03.jpg');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Radler', 1, 'Flasche', 70, 'products/radler.jpg');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Spezi', 1, 'Flasche', 70, 'products/spezi.jpg');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Cola', 1, 'Flasche', 100, 'products/cola.png');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Mate', 1, 'Flasche', 70, 'products/Loscher-Club-Mate.png');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Kaffee', 1, 'Tasse', 50, 'products/kaffee.jpg');
INSERT OR IGNORE INTO `valuable` (`name`, `active`, `unit_name`, `price`, `image_path`)
    VALUES ('Pizzastück', 0, 'Stück', 50, 'products/pizza.jpg');
COMMIT;