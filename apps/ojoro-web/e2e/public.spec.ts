import { expect, test } from "@playwright/test";

test("landing page communicates the real-world activity proposition", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: /go do something/i })).toBeVisible();
  await expect(page.getByRole("link", { name: /join ojoro/i })).toBeVisible();
  await expect(page.getByText(/what can i do/i).first()).toBeVisible();
});

test("landing page stays usable at mobile viewport", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
  await expect(page.getByRole("link", { name: /find your people/i })).toBeVisible();
});
