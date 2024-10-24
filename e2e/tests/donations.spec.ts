import "./setup";

import { test, expect } from "@playwright/test";
import { randomEmailAddress } from "./utils";

const getPageInIframe = (page) =>
  page.frameLocator('iframe[name="newspack_modal_checkout"]');

const getStripeIframe = (page) =>
  getPageInIframe(page).frameLocator(`[title="Secure payment input frame"]`);

const emailAddress = randomEmailAddress();

test("Donations", async ({ page }) => {
  /**
   * Make a donation.
   */
  await page.goto("/support-our-publication/");
  await page.getByRole("button", { name: "Donate Now" }).click();
  await expect(getPageInIframe(page).getByRole("strong")).toContainText(
    "Donate: Monthly"
  );
  await getPageInIframe(page).getByLabel("First name *").fill("John");
  await getPageInIframe(page).getByLabel("Last name *").fill("Doe");
  await getPageInIframe(page).getByLabel("Email address *").fill(emailAddress);

  // HACK: till https://github.com/Automattic/newspack-blocks/pull/1921 is deployed.
  await page.waitForTimeout(2000);

  await getPageInIframe(page).getByRole("button", { name: "Continue" }).click();

  await getStripeIframe(page)
    .getByPlaceholder("1234 1234 1234 1234")
    .fill("4242 4242 4242 42424");
  await getStripeIframe(page).getByPlaceholder("MM / YY").fill("04 / 44");
  await getStripeIframe(page).getByPlaceholder("CVC").fill("333");

  // Depending on geo, Stripe may want a ZIP code, too.
  const zipLocator = await getStripeIframe(page).getByPlaceholder("12345");
  if (await zipLocator.isVisible()) {
    await getStripeIframe(page).getByPlaceholder("12345").fill("12345");
  }

  await getPageInIframe(page)
    .getByRole("button", { name: "Donate now" })
    .click();

  await expect(
    getPageInIframe(page).getByRole("heading", {
      name: "Transaction Successful",
    })
  ).toBeVisible();
  await getPageInIframe(page).getByText("Continue browsing").click();

  await expect(page.getByRole("link", { name: "Close" })).not.toBeVisible();

  /**
   * Go to "My Account" page – it's now available as the reader account has been created.
   */
  await page.getByRole("link", { name: "My Account" }).click();
  await expect(page.getByLabel("Email address")).toHaveValue(emailAddress);
  await page.getByRole("link", { name: "My Subscription" }).click();

  await expect(page.getByText("Via visa card ending in 4242")).toBeVisible();
  await expect(
    page.getByRole("cell", { name: "$15.00 / month" }).first()
  ).toBeVisible();
});
