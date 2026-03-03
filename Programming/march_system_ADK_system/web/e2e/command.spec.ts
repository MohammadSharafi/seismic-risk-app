import { test, expect } from '@playwright/test';

test.describe('Command flow', () => {
  test('select patient, send command, see assistant reply', async ({ page }) => {
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.getByTestId('header-patient-button').click();
    await page.getByTestId('patient-row-p1').click();
    await expect(page.getByTestId('header-patient-button')).toContainText('Demo Patient');

    await page.getByTestId('prompts-button').click();
    await page.getByTestId('prompt-card-suggest-risk').click();

    await expect(page.getByTestId('transcript').getByTestId('message-user')).toContainText(/risk_profile/i);
    await expect(page.getByTestId('message-assistant').first()).toBeVisible({ timeout: 10000 });
  });

  test('without patient, sending command shows select-patient hint', async ({ page }) => {
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await expect(page.getByTestId('composer-input')).toBeVisible();
    await page.getByTestId('composer-input').fill('/summary ');
    await page.getByTestId('composer-input').press('Enter');
    await expect(page.getByTestId('transcript').getByText('Select a patient first')).toBeVisible({ timeout: 5000 });
  });
});
