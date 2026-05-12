import { test, expect } from '@playwright/test';

/**
 * Test moderation refusal handling.
 * Critical safety requirement from spec section 12.3
 */
test.describe('Moderation Refusal', () => {
  test.beforeEach(async ({ page }) => {
    // Mock authenticated child session
    await page.addInitScript(() => {
      document.cookie = 'child-session=child-jwt-token; path=/';
    });

    // Mock chat session and responses
    await page.route('/v1/**', async route => {
      const url = route.request().url();

      if (url.includes('/chat/sessions')) {
        if (route.request().method() === 'POST' && !url.includes('/messages')) {
          // Create session
          await route.fulfill({
            status: 201,
            contentType: 'application/json',
            body: JSON.stringify({
              session_id: 'test-session',
              started_at: new Date().toISOString()
            })
          });
        } else if (url.includes('/messages')) {
          // Send message - mock moderation block
          await route.fulfill({
            status: 400,
            contentType: 'application/json',
            body: JSON.stringify({
              error: {
                code: 'INPUT_BLOCKED',
                message: 'Texto contém termo não permitido',
                details: { category: 'inappropriate' }
              }
            })
          });
        }
      } else if (url.includes('/lessons/')) {
        // Mock lesson data
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            id: 'lesson-1',
            title: 'Teste de Lição',
            content_blocks: [{ type: 'text', content: 'Conteúdo de teste' }],
            prompt_templates: [
              {
                id: 'template-1',
                label: 'Conte uma história sobre...',
                template: 'Conte uma história sobre {{topic}}',
                slots: [{ name: 'topic', max_length: 30, allowed_chars: '^[A-Za-z ]+$' }],
                age_band: '6-8'
              }
            ]
          })
        });
      }
    });
  });

  test('shows friendly refusal message when backend blocks input', async ({ page }) => {
    // Navigate to chat page
    await page.goto('/play/lesson/lesson-1/chat');
    await page.waitForLoadState('networkidle');

    // Mock prompt button click that triggers moderation
    await page.click('[data-testid="prompt-button"]', { timeout: 5000 }).catch(() => {
      // If specific button doesn't exist, try first available button
      return page.click('button:has-text("Conte")').catch(() => null);
    });

    // Should show friendly refusal message (not scary error)
    await expect(page.locator('text=/vamos tentar outra coisa/i')).toBeVisible({
      timeout: 10000
    });

    // Should NOT show technical error messages
    await expect(page.locator('text=/error 400/i')).not.toBeVisible();
    await expect(page.locator('text=/failed/i')).not.toBeVisible();
    await expect(page.locator('text=/blocked/i')).not.toBeVisible();
  });

  test('increments visible strike counter on moderation blocks', async ({ page }) => {
    await page.goto('/play/lesson/lesson-1/chat');
    await page.waitForLoadState('networkidle');

    // First strike
    await page.click('button:first-of-type').catch(() => null);
    await expect(page.locator('[data-testid="strike-counter"]')).toContainText('1');

    // Second strike
    await page.click('button:first-of-type').catch(() => null);
    await expect(page.locator('[data-testid="strike-counter"]')).toContainText('2');

    // Third strike
    await page.click('button:first-of-type').catch(() => null);
    await expect(page.locator('[data-testid="strike-counter"]')).toContainText('3');
  });

  test('ends session with mascot message on 3rd strike', async ({ page }) => {
    // Mock session termination
    await page.route('/v1/chat/sessions/*/messages', async route => {
      const requestCount = await page.evaluate(() => {
        return (window as any).__requestCount = ((window as any).__requestCount || 0) + 1;
      });

      if (requestCount >= 3) {
        await route.fulfill({
          status: 400,
          contentType: 'application/json',
          body: JSON.stringify({
            error: {
              code: 'SESSION_TERMINATED',
              message: 'Sessão encerrada por segurança',
              details: { strikes: 3, action: 'session_ended' }
            }
          })
        });
      } else {
        await route.fulfill({
          status: 400,
          contentType: 'application/json',
          body: JSON.stringify({
            error: {
              code: 'INPUT_BLOCKED',
              message: 'Texto não permitido'
            }
          })
        });
      }
    });

    await page.goto('/play/lesson/lesson-1/chat');
    await page.waitForLoadState('networkidle');

    // Trigger 3 moderation blocks
    for (let i = 0; i < 3; i++) {
      await page.click('button:first-of-type').catch(() => null);
      await page.waitForTimeout(500);
    }

    // Should show mascot farewell message
    await expect(page.locator('text=/conversa encerrada/i')).toBeVisible({
      timeout: 10000
    });

    // Should redirect away from chat or disable further interaction
    await expect(page.locator('[data-testid="chat-input"]')).not.toBeVisible({
      timeout: 5000
    }).catch(() => {
      // Alternative: buttons should be disabled
      expect(page.locator('button:enabled')).toHaveCount(0);
    });
  });

  test('shows mascot character in refusal messages', async ({ page }) => {
    await page.goto('/play/lesson/lesson-1/chat');
    await page.waitForLoadState('networkidle');

    await page.click('button:first-of-type').catch(() => null);

    // Should show mascot (robot emoji or character)
    await expect(page.locator('text=/🤖/')).toBeVisible({
      timeout: 10000
    }).catch(async () => {
      // Alternative mascot indicators
      await expect(page.locator('[data-testid="mascot"]')).toBeVisible();
    });
  });
});