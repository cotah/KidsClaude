import { test, expect } from '@playwright/test';

/**
 * Test auth split: child JWT cannot reach parent routes, parent cannot reach child routes.
 * Critical security requirement from spec section 12.3
 */
test.describe('Auth Split', () => {
  test.beforeEach(async ({ page }) => {
    // Mock backend responses
    await page.route('/v1/**', async route => {
      const url = route.request().url();

      if (url.includes('/auth/parent/login')) {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            access_token: 'parent-jwt-token',
            expires_in: 604800
          })
        });
      } else if (url.includes('/auth/child/login')) {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            access_token: 'child-jwt-token',
            expires_in: 14400,
            child: {
              id: 'child-1',
              name: 'Test Child',
              age: 8,
              avatar_id: 'cat'
            }
          })
        });
      } else {
        await route.fulfill({ status: 401 });
      }
    });
  });

  test('child JWT cannot reach parent dashboard', async ({ page }) => {
    // Simulate child login by setting cookie directly
    await page.addInitScript(() => {
      document.cookie = 'child-session=child-jwt-token; path=/';
    });

    // Try to access parent dashboard
    await page.goto('/dashboard');

    // Should redirect to /select or /login
    expect(page.url()).toMatch(/(\/select|\/login)$/);
  });

  test('parent JWT cannot reach child play routes without active child session', async ({ page }) => {
    // Simulate parent login
    await page.addInitScript(() => {
      document.cookie = 'parent-session=parent-jwt-token; path=/';
    });

    // Try to access child play area
    await page.goto('/play');

    // Should redirect to /select (to choose child)
    expect(page.url()).toMatch(/\/select$/);
  });

  test('middleware enforces route access correctly', async ({ page, context }) => {
    // Test unauthorized access to protected routes
    const protectedRoutes = [
      '/dashboard',
      '/children/new',
      '/children/123',
      '/account',
      '/play',
      '/play/lesson/123'
    ];

    for (const route of protectedRoutes) {
      const response = await page.goto(route);

      // Should redirect (3xx) or show login page
      if (response) {
        expect(response.status()).toBeLessThan(400);
      }

      // Verify not on protected route (should redirect)
      expect(page.url()).not.toContain(route);
    }
  });

  test('successful auth flow allows correct access', async ({ page }) => {
    // Mock successful parent login
    await page.route('/api/auth/session', async route => {
      if (route.request().method() === 'POST') {
        await route.fulfill({ status: 200, body: JSON.stringify({ success: true }) });
      }
    });

    // Go to login page
    await page.goto('/login');

    // Fill and submit login form
    await page.fill('[name="email"]', 'parent@test.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Should redirect to dashboard after successful login
    await page.waitForURL('/dashboard');
    expect(page.url()).toMatch(/\/dashboard$/);
  });
});