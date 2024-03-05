# Newspack end-to-end testing

Is run with Playwright.

## Local testing

- Set up a site (see next chapters for more) and set its URL as `SITE_URL` in the `.env` file (see `.env-sample`).
- run `npm t` for a single test run
- run `npm run test:ui` for a test run with UI
- run `npm run codegen -- <site-url>` for a test code generation UI

After running the tests, run `/var/scripts/e2e-reset.sh` in the docker container (`n sh` to enter it) to reset the data.

## CI testing

Will need some additional environment variables and setup steps:

1. Create a site (see next chapters for more) on a platform which accepts password-only SSH authentication, and define the following environment variables:
   1. `SSH_USER`
   2. `SSH_HOST`
   3. `SSH_USER_PASS`
   4. `SSH_KNOWN_HOST` - this one you can get by connecting to the platform and copying the line added to the `/root/.ssh/known_hosts` file

## Writing tests

Tests can be written by hand in the `tests` directory, or with the help of Playwright codegen. To use the latter option, run `npm run codegen -- <site-url>`. When you're done, copy and paste the code to `tests/<test-name>.spec.js`, adjust, and submit the changes in a PR.

If the tests manipulate any persistent items (anything in the DB), reset commands should be added to the `/bin/e2e-reset.sh` script. In the future, if that's too brittle, we might opt for a full reset, though.

## Setting up a test site

The tests will assume the test site has been set up in a following way:

- `newspack-plugin` installed and activated
- `wp newspack setup` command run
- after a test run, the `e2e-reset.sh` script to clean up
