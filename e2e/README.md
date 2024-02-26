# Newspack end-to-end testing

Is run with Playwright.

## Local testing

- Set up a site and set its URL as `SITE_URL` in the `.env` file (see `.env-sample`).
- run `npm t` for a single test run
- run `npm run test:ui` for a test run with UI
- run `npm run codegen -- <site-url>` for a test code generation UI

After running the tests, run `/var/scripts/e2e-reset.sh` in the docker container (`n sh` to enter it) to reset the data.
