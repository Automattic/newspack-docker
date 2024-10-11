#!/bin/bash

# Load the /e2e/.env file.
if [ -f /var/scripts/.e2e-env ]; then
    export $(cat /var/scripts/.e2e-env | grep -v '#' | awk '/=/ {print $1}')
fi

echo ""
echo "Making sure all necessary plugins are active"
wp  --allow-root --skip-plugins --skip-themes plugin activate newspack-plugin newspack-blocks newspack-popups newspack-ads newspack-newsletters

echo ""
echo "Enabling RAS"
wp  --allow-root --skip-plugins --skip-themes option set newspack_reader_activation_enabled 1

echo ""
if [[ -z "$ATOMIC_SITE_ID" ]]; then
    echo "Installing the Newspack E2E plugin…"
    cp -r /var/scripts/e2e-plugin.php $(wp --allow-root --skip-plugins --skip-themes eval 'echo ABSPATH;')/wp-content/plugins/e2e-plugin.php
else
    echo "Running on Atomic site, e2e-plugin is already there."
fi
wp --allow-root  --skip-plugins --skip-themes plugin activate e2e-plugin

echo ""
echo "Selective resetting for E2E tests…"

echo ""
echo "Resetting user editor preferences…"
wp --allow-root --skip-plugins --skip-themes user meta delete 1 wp_persisted_preferences
# Disable the post editor welcome guide
wp --allow-root --skip-plugins --skip-themes user meta add 1 wp_persisted_preferences "{\"core/edit-post\":{\"welcomeGuide\": false}}" --format=json

echo ""
echo "Deleting all Campaigns entities…"
# Remove all posts of type newspack_popups_cpt
wp --allow-root --skip-plugins --skip-themes post delete $(wp --allow-root --skip-plugins --skip-themes post list --post_type=newspack_popups_cpt --format=ids) --force || true
# Remove all segments
wp --allow-root --skip-plugins --skip-themes option delete newspack_popups_segments || true
# Remove the "Campaigns"
wp --allow-root --skip-plugins --skip-themes term list newspack_popups_taxonomy --field=term_id | xargs wp --allow-root --skip-plugins --skip-themes term delete newspack_popups_taxonomy || true

# Site setup - could be a testing scenario of its own some day, via UI.
echo ""
echo "Setup the site - Reader Revenue"
WCGS_OPTION=$(jq -n --arg pk "$STRIPE_PUBLISHABLE_KEY" --arg sk "$STRIPE_SECRET_KEY" '{"enabled":"yes","testMode":true,"test_publishable_key":$pk,"test_secret_key":$sk}' | sed 's/\\"//g')
wp --allow-root --skip-plugins --skip-themes option set woocommerce_stripe_settings "$WCGS_OPTION" --format=json
wp --allow-root --skip-plugins --skip-themes post update $(wp --allow-root --skip-plugins --skip-themes option get newspack_donation_page_id) --post_status=publish
# Create the donation products – this happens when the RR settings are saved in RR wizard.
wp --allow-root --skip-themes eval "\Newspack\Donations::update_donation_product();"
# Limit the fields required for checkout.
wp --allow-root --skip-plugins --skip-themes option set newspack_donations_billing_fields '["billing_email","billing_first_name","billing_last_name"]' --format=json
