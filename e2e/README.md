# Newspack end-to-end testing

Is run with Playwright.

## Local testing

Will need a local test site – set it up with `newspack-docker` by running `n sites-add e2e`. This will create a local `https://e2e.local` site.

Follow the "Setting up a test site" instructions from this doc.

- Set site URL as `SITE_URL` in the `.env` file (see `.env-sample`).
- Set up the site for testing: install and activate the `newspack-plugin` and run `wp newspack setup` CLI command
- run `npm t` for a single test run
- run `npm run test:ui` for a test run with UI
- run `npm run codegen -- <site-url>` for a test code generation UI

After running the tests, run `/var/scripts/e2e-reset.sh` in the docker container (`n sh` to enter it, then navigate to the WordPress files (`/var/www/additional-sites-html/e2e/`)) to reset the data.

## CI testing

Will need a publicly accessible (or at least accessible for the CI server) test site, running on a platform which accepts password-only SSH authentication.

[The credentials for the Atomic site currently used for the e2e testing.](https://mc.a8c.com/secret-store/?secret_id=12168)

1. In addition to the variables from `.env-sample`, also define the following in the CircleCI project settings:
   1. `SSH_USER` - simply a username string, e.g. `newspack-user`
   2. `SSH_HOST` - hostname of the platform, e.g. `ssh.myplatform.net`
   3. `SSH_USER_PASS` - SSH password
   4. `SSH_KNOWN_HOST` - this one you can get by connecting to the platform and copying the line added to the `/root/.ssh/known_hosts` file
2. Follow the "Setting up a test site" instructions from this doc.

## Setting up a test site (CI or local)

1. On the test site, install and activate `newspack-plugin` and run `wp newspack setup`.
2. Install and activate also `woocommerce-gateway-stripe` and `woocommerce-subscriptions` plugins.

## Writing tests

Tests can be written by hand in the `tests` directory, or with the help of Playwright codegen. To use the latter option, run `npm run codegen -- <site-url>`. When you're done, copy and paste the code to `tests/<test-name>.spec.js`, adjust, and submit the changes in a PR.

If the tests manipulate any persistent items (anything in the DB), reset commands should be added to the `/bin/e2e-reset.sh` script. In the future, if that's too brittle, we might opt for a full reset, though.
