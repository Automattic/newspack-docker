import "./setup";

import { test, expect } from "@playwright/test";
import {
  addClickIndicator,
  randomString,
  goToEmailClient,
  clickLinkURL,
  randomEmailAddress,
} from "./utils";

const emailAddress = randomEmailAddress();

test.beforeEach(addClickIndicator);

test("Register on the site", async ({ page }) => {
  /**
   * Create a new reader account using the "Sign In" header link.
   */
  await page.goto("/");
  await page.getByRole("link", { name: "Sign In" }).click();
  await page.getByRole("link", { name: "I don't have an account" }).click();
  await page
    .getByRole("textbox", { name: "Enter your email address" })
    .fill(emailAddress);
  await page.getByRole("button", { name: "Sign up" }).click();
  await page.waitForURL(/my-account/);
  await page.getByText("Log out").click();

  /**
   * Log in as the previously created reader.
   */
  await page.goto("/");
  await page.getByRole("link", { name: "Sign In" }).click();
  await page
    .getByRole("textbox", { name: "Enter your email address" })
    .fill(emailAddress);
  await page.getByRole("button", { name: "Send authorization code" }).click();
  await expect(page.getByText("Enter the code you received")).toBeVisible();

  /**
   * Go to the email client to get the log in link.
   */
  await goToEmailClient(page, emailAddress);
  await page.getByText(`Authorization code (${emailAddress}`).click();
  await clickLinkURL(page, "Log in");

  /**
   * Now the user is authenticated via the magic link, they can update their name.
   */
  await page.getByRole("link", { name: "My Account" }).click();
  await page.getByPlaceholder("Your Name").click();
  await page.getByPlaceholder("Your Name").fill("John Doe");
  await page.getByRole("button", { name: "Save changes" }).click();
  await expect(page.getByText("Account details changed")).toBeVisible();
  await expect(page.getByPlaceholder("Your Name")).toHaveValue("John Doe");

  /**
   * Reader sets up a password.
   */
  await page
    .getByRole("link", { name: "Create a Password Email me a" })
    .click();
  await expect(
    page.getByText(
      "Please check your email inbox for instructions on how to set a new password."
    )
  ).toBeVisible();
  await goToEmailClient(page, emailAddress);
  await page.getByText(`Set a new password (${emailAddress}`).click();
  await clickLinkURL(page, "Set new password");

  const password = randomString(14);
  await page
    .getByLabel("New password *Required", { exact: true })
    .fill(password);
  await page.getByLabel("Re-enter new password *").fill(password);
  await page.getByRole("button", { name: "Save" }).click();
  await expect(page.getByText("Your password has been reset")).toBeVisible();

  /**
   * Reader logs in using the password.
   */
  await page.getByRole("link", { name: "Sign In", exact: true }).click();
  await page
    .getByRole("link", { name: "sign in using a password" })
    .nth(1)
    .click();
  await page
    .getByRole("textbox", { name: "Enter your password" })
    .fill(password);
  await page.getByRole("button", { name: "Sign in" }).click();
  await page.waitForURL(/my-account/);
});
