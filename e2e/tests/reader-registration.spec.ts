import "./setup";

import { test, expect } from "@playwright/test";

const URL = process.env.SITE_URL;

const randomString = () => Math.random().toString(36).substring(2, 8);
const emailAddress = `test-${randomString()}@example.com`;

test("Register on the site", async ({ page }) => {
  /**
   * Create a new reader account using the "Sign In" header link.
   */
  await page.goto(URL);
  await page.getByRole("link", { name: "Sign In" }).click();
  await page.getByRole("link", { name: "I don't have an account" }).click();
  await page
    .getByRole("textbox", { name: "Enter your email address" })
    .fill(emailAddress);
  await page.getByRole("button", { name: "Sign up" }).click();
  await page.waitForURL(/my-account/);
  await page.waitForTimeout(300);
  await page.getByText("Log out").click();

  /**
   * Log in as the previously created reader.
   */
  await page.goto(URL);
  await page.getByRole("link", { name: "Sign In" }).click();
  await page
    .getByRole("textbox", { name: "Enter your email address" })
    .fill(emailAddress);
  await page.getByRole("button", { name: "Send authorization code" }).click();
  await expect(page.getByText("Enter the code you received")).toBeVisible();

  /**
   * Go to the email client to get the log in link.
   */
  await page.waitForTimeout(1000); // Wait a moment to let the server save the email.
  await page.goto(`${URL}/_email?cachebust=${emailAddress}`);
  await page.getByText(`Authorization code (${emailAddress}`).click();
  const logInElement = await page.getByRole("link", { name: "Log in" });
  const logInURL = await logInElement.getAttribute("href");
  await page.goto(logInURL);

  /**
   * Now the user is authenticated via the magic link, they can update their name.
   */
  await page.getByRole("link", { name: "My Account" }).click();
  await page.getByPlaceholder("Your Name").click();
  await page.getByPlaceholder("Your Name").fill("John Doe");
  await page.getByRole("button", { name: "Save changes" }).click();
  await expect(page.getByText("Account details changed")).toBeVisible();
  await expect(page.getByPlaceholder("Your Name")).toHaveValue("John Doe");
});
