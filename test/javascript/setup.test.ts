import { afterAll, beforeAll, describe, expect, it } from "bun:test";

// Example test environment setup
describe("Test Environment Setup", () => {
	beforeAll(() => {
		// Global setup before running all tests
		console.log("Setting up test environment...");
	});

	afterAll(() => {
		// Cleanup after running all tests
		console.log("Cleaning up test environment...");
	});

	it("should verify test environment", () => {
		// Verify that the test environment is configured correctly
		expect(typeof describe).toBe("function");
		expect(typeof it).toBe("function");
		expect(typeof expect).toBe("function");
	});

	it("should have access to global objects", () => {
		// Check availability of global objects
		expect(globalThis).toBeDefined();
		expect(process).toBeDefined();
		expect(console).toBeDefined();
	});

	// Environment variable test
	it("should handle environment variables", () => {
		// Example of setting a test-specific environment variable
		process.env.TEST_MODE = "true";

		expect(process.env.TEST_MODE).toBe("true");

		// Clean up
		delete process.env.TEST_MODE;
	});
});
