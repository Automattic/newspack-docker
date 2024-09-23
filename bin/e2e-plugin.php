<?php
/**
 * Plugin Name: Newspack E2E Plugin
 * Description: Special considerations for E2E testing.
 * Version: 0.0.0
 * Author: Automattic
 * Author URI: https://newspack.com/
 * License: GPL2
 * Text Domain: newspack-e2e-plugin
 * Domain Path: /languages/
 *
 * @package         Newspack_E2E_Plugin
 */

defined( 'ABSPATH' ) || exit;

// Prevent the admin email confirmation screen
add_filter('admin_email_check_interval', '__return_false');
