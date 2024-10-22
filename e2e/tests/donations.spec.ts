import "./setup";

import { test, expect } from "@playwright/test";
import { randomEmailAddress } from "./utils";

const getPageInIframe = (page) =>
  page.frameLocator('iframe[name="newspack_modal_checkout"]');

const getStripeIframe = (page, selector) =>
  getPageInIframe(page).frameLocator(`${selector} iframe`);

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
  await page.waitForTimeout(600); // For some reason, the "Continue" button seems to only be functional after a delay.
  await getPageInIframe(page).getByRole("button", { name: "Continue" }).click();

  await getStripeIframe(page, "#stripe-card-element")
    .getByPlaceholder("1234 1234 1234 1234")
    .fill("4242 4242 4242 42424");
  await getStripeIframe(page, "#stripe-exp-element")
    .getByPlaceholder("MM / YY")
    .fill("04 / 44");
  await getStripeIframe(page, "#stripe-cvc-element")
    .getByPlaceholder("CVC")
    .fill("333");
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
