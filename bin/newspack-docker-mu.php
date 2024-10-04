<?php
/**
 * MU Plugin for the Newspack Docker development environment
 */

/**
 * By default, Site Kit will not report to GA from a local site. This can be overridden with the following filter:
 */
add_filter(
    'googlesitekit_allowed_tag_environment_types',
    function ( $types ) {
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
    function ( $r ) {
        $r['sslverify']          = false;
        $r['reject_unsafe_urls'] = false;
        return $r;
    }
);

 /**
  * Make sure CLI commands use the correct site URL
  * This is important when communicating with mmanager.local as the key is tied to the domain
  *
  * By default, the docker environment provides a dynamic site url, so you can access the site either via localhost or a tunneled domain, required for some actions.
  * Because of that, when running commands via CLI, the returned site url is localhost.
  * Use the NEWSPACK_DOCKER_SITE_URL_CLI_OVERRIDE to override the site url for CLI commands.
  */
 add_filter('home_url', 'newspack_docker_mu_site_url_cli', 10, 2);
 add_filter('site_url', 'newspack_docker_mu_site_url_cli', 10, 2);
function newspack_docker_mu_site_url_cli( $url, $path )
{
    if (defined('WP_CLI') && WP_CLI && defined('NEWSPACK_DOCKER_SITE_URL_CLI_OVERRIDE') ) {
        $url = NEWSPACK_DOCKER_SITE_URL_CLI_OVERRIDE;
        if ($path && is_string($path) ) {
            $url .= '/' . ltrim($path, '/');
        }
        return $url;
    }
    return $url;
}
