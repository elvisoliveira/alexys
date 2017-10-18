--
-- Dumping data for table `wp_woocommerce_shipping_zone_locations`
--
LOCK TABLES `wp_woocommerce_shipping_zone_locations` WRITE;
TRUNCATE TABLE `wp_woocommerce_shipping_zone_locations`;
INSERT INTO `wp_woocommerce_shipping_zone_locations` VALUES (1, 1, 'BR', 'country');
UNLOCK TABLES;

--
-- Dumping data for table `wp_woocommerce_shipping_zone_methods`
--
LOCK TABLES `wp_woocommerce_shipping_zone_methods` WRITE;
TRUNCATE TABLE `wp_woocommerce_shipping_zone_methods`;
INSERT INTO `wp_woocommerce_shipping_zone_methods` VALUES (1, 1, 'correios-pac', 1, 1), (1, 2, 'correios-sedex', 2, 1);
UNLOCK TABLES;

--
-- Dumping data for table `wp_woocommerce_shipping_zones`
--
LOCK TABLES `wp_woocommerce_shipping_zones` WRITE;
TRUNCATE TABLE `wp_woocommerce_shipping_zones`;
INSERT INTO `wp_woocommerce_shipping_zones` VALUES (1, 'ES2BR', 0);
UNLOCK TABLES;