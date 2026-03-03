import { test, expect } from '@playwright/test';

test.describe('App', () => {
  test('loads and shows select patient when none selected', async ({ page }) => {
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await expect(page.getByText('March Health')).toBeVisible();
    await expect(page.getByTestId('header-patient-button')).toContainText('Select patient', { timeout: 10000 });
  });

  test('opens patient picker and selects a patient', async ({ page }) => {
    await page.goto('/');
    await page.getByTestId('header-patient-button').click();
    await expect(page.getByTestId('patient-picker-modal')).toBeVisible();
    await page.getByTestId('patient-row-p1').click();
    await expect(page.getByTestId('patient-picker-modal')).not.toBeVisible();
    await expect(page.getByTestId('header-patient-button')).toContainText('Demo Patient');
  });
});
