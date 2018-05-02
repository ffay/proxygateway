CREATE TABLE `agw_api` (
  `id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `request_uri` varchar(64) DEFAULT NULL,
  `original_uri` varchar(64) DEFAULT NULL,
  `uri_limit_seconds` int(10) NOT NULL DEFAULT '0',
  `uri_limit_times` int(10) NOT NULL DEFAULT '0',
  `ip_uri_limit_seconds` int(10) NOT NULL DEFAULT '0',
  `ip_uri_limit_times` int(10) NOT NULL DEFAULT '0',
  `description` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `agw_api` (`id`, `service_id`, `request_uri`, `original_uri`, `description`) VALUES
(1, 1, '/', '/', 'all request map');
CREATE TABLE `agw_domain` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `agw_domain` (`id`, `name`) VALUES
(1, 'localhost');
CREATE TABLE `agw_server` (
  `id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `ip` varchar(64) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `protocol` varchar(32) NOT NULL DEFAULT 'http://',
  `weight` int(11) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `description` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `agw_server` (`id`, `service_id`, `ip`, `port`, `protocol`, `weight`, `status`, `description`) VALUES
(1, 1, '127.0.0.1', 8081, 'http://', 1, 1, 'proxygateway management');
CREATE TABLE `agw_service` (
  `id` int(11) NOT NULL,
  `domain_id` int(11) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `host` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `agw_service` (`id`, `domain_id`, `name`, `host`, `description`) VALUES
(1, 1, 'default', 'localhost', 'default proxy configuration');
ALTER TABLE `agw_api`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `service_id` (`service_id`,`request_uri`),
  ADD KEY `service_id_2` (`service_id`);
ALTER TABLE `agw_domain`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);
ALTER TABLE `agw_server`
  ADD PRIMARY KEY (`id`);
ALTER TABLE `agw_service`
  ADD PRIMARY KEY (`id`),
  ADD KEY `domain_id` (`domain_id`);
ALTER TABLE `agw_api`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
ALTER TABLE `agw_domain`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
ALTER TABLE `agw_server`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
ALTER TABLE `agw_service`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;