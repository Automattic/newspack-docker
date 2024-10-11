import "./setup";

const URL = process.env.SITE_URL;

export const logIn = async (page) => {
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
};
