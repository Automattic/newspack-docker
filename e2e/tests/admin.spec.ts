import { test, expect } from "@playwright/test";
import "dotenv/config";

const URL = process.env.SITE_URL;
console.log(`Running tests against ${URL}`);

test("Campaigns", async ({ page }) => {
  // Log in to the admin dashboard.
  await page.goto(`${URL}/wp-login.php`);
  await page.getByLabel("Username or Email Address").click();
  await page
    .getByLabel("Username or Email Address")
    .fill(process.env.ADMIN_USER);
  await page.getByLabel("Password", { exact: true }).click();
  await page
    .getByLabel("Password", { exact: true })
    .fill(process.env.ADMIN_PASSWORD);
  await page.getByRole("button", { name: "Log In" }).click();

  // Go to Campaigns wizard.
  await page
    .getByLabel("Main menu", { exact: true })
    .getByRole("link", { name: "Newspack" })
    .click();
  await page
    .getByRole("link", { name: "Campaigns Reach your readers" })
    .click();
  await expect(page.getByRole("heading", { name: "Everyone" })).toBeVisible();
  await expect(page.getByText("Reach your readers with")).toBeVisible();
  await page.getByRole("button", { name: "Add New Campaign" }).click();
  await page.getByPlaceholder("Campaign Name").fill("Basic");
  await page.getByRole("button", { name: "Add" }).click();
  await page.waitForURL("**/campaigns/**");

  await page.getByRole("button", { name: "Add New Prompt" }).click();
  await page.getByRole("link", { name: "Center Overlay Fixed at the" }).click();
  await page.waitForURL(/post_type=newspack_popups_cpt/);

  // Create the prompt.
  await page.getByLabel("Add title").fill("Hello!");
  await page.getByLabel("Add default block").click();
  await page
    .getByLabel("Empty block; start writing or")
    .fill("This is an overlay campaign");
  await page.getByRole("tab", { name: "Prompt" }).click();
  await page
    .getByLabel("Editor settings")
    .getByRole("button", { name: "Settings", exact: true })
    .click();
  await page.getByRole("spinbutton", { name: "Delay (seconds)" }).fill("1");

  // Preview the prompt.
  await page.getByRole("button", { name: "Preview" }).click();
  await expect(
    page
      .frameLocator('iframe[title="web-preview"]')
      .getByRole("button", { name: "draft This is an overlay" })
  ).toBeVisible();
  await page.getByLabel("Close Preview").click();

  // Publish the prompt.
  await page.getByRole("button", { name: "Publish", exact: true }).click();
  await page
    .getByLabel("Editor publish")
    .getByRole("button", { name: "Publish", exact: true })
    .click();

  // Go to the front-end and verify the prompt is visible.
  await page.goto(URL);
  await expect(page.getByText("This is an overlay campaign")).toBeVisible();
  await page.getByLabel("Close Pop-up").click();
  await expect(page.getByText("This is an overlay campaign")).not.toBeVisible();
});
