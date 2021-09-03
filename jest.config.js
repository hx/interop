/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */
const {Blob} = require('buffer')

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/jest-setup.ts'],
  testMatch: ['**/*.spec.ts']
}
