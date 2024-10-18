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

export const randomString = (length = 8) =>
  Math.random().toString(36).substring(2, length);

export const goToEmailClient = async (page, cachebust = "") => {
  await page.waitForTimeout(1000); // Wait a moment to let the server save the email.
  await page.goto(`${URL}/_email?cachebust=${cachebust}`);
};

export const clickLinkURL = async (page, linkText) => {
  const logInElement = await page.getByRole("link", { name: linkText });
  const logInURL = await logInElement.getAttribute("href");
  await page.goto(logInURL);
};

export const addClickIndicator = async ({ page }) => {
  await page.addInitScript(() => {
    document.addEventListener(
      "click",
      (event) => {
        const clickWidth = 30;
        const clickIndicator = document.createElement("div");
        clickIndicator.style.position = "absolute";
        clickIndicator.style.width = `${clickWidth}px`;
        clickIndicator.style.height = `${clickWidth}px`;
        clickIndicator.style.backgroundColor = "red";
        clickIndicator.style.borderRadius = "50%";
        clickIndicator.style.top = `${event.clientY - clickWidth / 2}px`;
        clickIndicator.style.left = `${event.clientX - clickWidth / 2}px`;
        clickIndicator.style.zIndex = "9999";
        clickIndicator.style.pointerEvents = "none";
        clickIndicator.style.transition = "opacity 1s ease-out";
        document.body.appendChild(clickIndicator);

        // Remove the indicator
        setTimeout(() => {
          clickIndicator.style.opacity = "0";
          setTimeout(() => clickIndicator.remove(), 1000);
        }, 1000);
      },
      { capture: true }
    );
  });
};
