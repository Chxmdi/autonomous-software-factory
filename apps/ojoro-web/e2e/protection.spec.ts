import { expect, test } from "@playwright/test";
for (const path of ["/home","/discover","/create","/compete","/you","/messages","/notifications","/people","/calendar","/safety"]) {
  test(`${path} requires authentication`, async ({ page }) => {
    await page.goto(path);
    await expect(page).toHaveURL(/\/login$/);
    await expect(page.getByRole("heading", { name: /good to see you/i })).toBeVisible();
    await expect(page.getByRole("button", { name: /sign in/i })).toBeVisible();
  });
}
