/// <reference types="vitest" />
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: [
      '**/__tests__/**/*.{js,ts,jsx,tsx}',
      '**/?(*.){test,spec}.{js,ts,jsx,tsx}'
    ],
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
      '**/e2e/**',
      '**/.next/**'
    ],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: [
        'components/**/*.{ts,tsx}',
        'lib/**/*.{ts,tsx}',
        'app/**/*.{ts,tsx}'
      ],
      exclude: [
        '**/*.d.ts',
        '**/node_modules/**',
        '**/tests/**',
        '**/*.test.{ts,tsx}',
        '**/*.spec.{ts,tsx}',
        '**/layout.tsx',
        '**/loading.tsx',
        '**/error.tsx',
        '**/not-found.tsx'
      ],
      thresholds: {
        functions: 70,
        lines: 70,
        statements: 70,
        branches: 60
      }
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './')
    }
  }
});