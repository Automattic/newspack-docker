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