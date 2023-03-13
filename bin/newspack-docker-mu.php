<?php 
/**
 * MU Plugin for the Newspack Docker development environment
 */

/**
 * By default, Site Kit will not report to GA from a local site. This can be overridden with the following filter:
 */
add_filter(
	'googlesitekit_allowed_tag_environment_types',
	function( $types ) {
		$types[] = 'local';
		return $types;
	}
);

/**
 * Disable SSL for local WP development
 *
 * Plugin Name: Disable SSL for local WP development
 * Description: Disable SSL for local WP development
 */

 add_filter(
	'http_request_args',
	function( $r ) {
		$r['sslverify']          = false;
		$r['reject_unsafe_urls'] = false;
		return $r;
	}
);