import "./setup";

export const randomString = (length = 8) =>
  Math.random()
    .toString(36)
    .substring(2, length + 2);

export const randomEmailAddress = () => `test-${randomString()}@example.com`;

export const goToEmailClient = async (page, cachebust = "") => {
  await page.waitForTimeout(1000); // Wait a moment to let the server save the email.
  await page.goto(`/_email?cachebust=${cachebust}`);
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
