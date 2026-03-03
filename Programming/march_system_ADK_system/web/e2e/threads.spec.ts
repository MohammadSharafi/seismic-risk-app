import { test, expect } from '@playwright/test';

test.describe('Threads', () => {
  test('opens threads drawer and creates new thread', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Threads' }).click();
    await expect(page.getByTestId('threads-drawer')).toBeVisible();
    await expect(page.getByTestId('thread-new')).toBeVisible();
    await page.getByTestId('thread-new').click();
    await expect(page.getByTestId('transcript')).toBeVisible();
    await expect(page.getByTestId('message-user')).toHaveCount(0);
  });
});
