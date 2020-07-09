CREATE DATABASE inventory;
GRANT ALL PRIVILEGES ON inventory.* TO 'mysqluser'@'%';

CREATE USER 'debezium'@'localhost' IDENTIFIED BY 'debeziumpw';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium' IDENTIFIED BY 'debeziumpw';
FLUSH PRIVILEGES;
-- Switch to this database
USE inventory;

CREATE TABLE `cars` (
  `car_id` int(10) unsigned NOT NULL,
  `brand` varchar(200) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `model` varchar(200) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `ts_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`car_id`)
);
INSERT INTO `cars` (`car_id`, `brand`, `model`, `ts_created`) VALUES ( 1, 'ford', 'mustang', '2020-07-06 15:50:47');
INSERT INTO `cars` (`car_id`, `brand`, `model`, `ts_created`) VALUES ( 2, 'ford', 'mondeo', '2019-07-06 15:52:47');