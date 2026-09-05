import { expect, test } from "@playwright/test";
for (const path of ["/home","/discover","/create","/compete","/you","/messages","/notifications","/people","/calendar","/safety"]) {
  test(`${path} requires authentication`, async ({ page }) => {
    await page.goto(path);
    await expect(page).toHaveURL(/\/login$/);
    await expect(page.getByRole("heading", { name: /welcome back/i })).toBeVisible();
  });
}
