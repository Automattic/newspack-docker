#!/bin/bash

# ummm maybe not needed after all
if [ -f /var/scripts/.e2e-env ]; then
    echo 'got it'
    export $(cat /var/scripts/.e2e-env | grep -v '#' | awk '/=/ {print $1}')
fi

echo ""
echo "Selective resetting for E2E tests…"

echo ""
echo "Resetting user editor preferences…"
wp --allow-root user meta delete 1 wp_persisted_preferences
# Disable the post editor welcome guide
wp --allow-root user meta add 1 wp_persisted_preferences "{\"core/edit-post\":{\"welcomeGuide\": false}}" --format=json

echo ""
echo "Deleting all Campaigns entities…"
# Remove all posts of type newspack_popups_cpt
wp --allow-root post delete $(wp --allow-root post list --post_type=newspack_popups_cpt --format=ids) --force || true
# Remove all segments
wp --allow-root option delete newspack_popups_segments || true
# Remove the "Campaigns"
wp --allow-root term list newspack_popups_taxonomy --field=term_id | xargs wp --allow-root term delete newspack_popups_taxonomy || true
