import "./setup";

import { test, expect } from "@playwright/test";
import { logIn } from "./utils";

const URL = process.env.SITE_URL;

test("Create a registration page", async ({ page }) => {
  logIn(page);
});
