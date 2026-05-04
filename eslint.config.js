// @ts-check
import tseslint from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';

/** @type {import('eslint').Linter.FlatConfig[]} */
export default [
  {
    files: ['**/*.ts', '**/*.tsx'],
    plugins: { '@typescript-eslint': tseslint },
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: true,
      },
    },
    rules: {
      ...tseslint.configs['strict-type-checked'].rules,
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
  {
    ignores: ['**/dist/**', '**/node_modules/**'],
  },
];
