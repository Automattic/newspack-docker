import "./setup";

import { test, expect } from "@playwright/test";
import { logIn } from "./utils";

test("Create and view a prompt", async ({ page }) => {
  logIn(page);

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
  const CAMPAIGN_BODY = "This is an overlay campaign";
  await page.getByLabel("Add title").fill("Hello!");
  await page.getByLabel("Add default block").click();
  await page.getByLabel("Empty block; start writing or").fill(CAMPAIGN_BODY);
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
  await expect(page.getByText(CAMPAIGN_BODY)).toBeVisible();
  await page.getByLabel("Close Preview").click();

  // Publish the prompt.
  await page.getByRole("button", { name: "Publish", exact: true }).click();
  await page
    .getByLabel("Editor publish")
    .getByRole("button", { name: "Publish", exact: true })
    .click();
  await expect(
    page.getByTestId("snackbar").getByText("Post published.")
  ).toBeVisible();

  // Go to the front-end and verify the prompt is visible.
  await page.goto("/");
  await expect(page.getByText(CAMPAIGN_BODY)).toBeVisible();
  await page.getByLabel("Close Pop-up").click();
  await expect(page.getByText(CAMPAIGN_BODY)).not.toBeVisible();

  // Delete the prompt.
  await page.goto("/wp-admin/admin.php?page=newspack-popups-wizard#/campaigns");
  await page.getByLabel("More options").click();
  await page.getByRole("menuitem", { name: "Delete" }).click();
  await expect(
    page.getByText("No active prompts in this segment.")
  ).not.toBeVisible();
});
