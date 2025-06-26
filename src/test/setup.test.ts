import { describe, expect, it, beforeAll, afterAll } from "bun:test";

// テスト環境のセットアップ例
describe("Test Environment Setup", () => {
	beforeAll(() => {
		// 全テスト実行前のグローバルセットアップ
		console.log("Setting up test environment...");
	});

	afterAll(() => {
		// 全テスト実行後のクリーンアップ
		console.log("Cleaning up test environment...");
	});

	it("should verify test environment", () => {
		// テスト環境が正しく設定されているかチェック
		expect(typeof describe).toBe("function");
		expect(typeof it).toBe("function");
		expect(typeof expect).toBe("function");
	});

	it("should have access to global objects", () => {
		// グローバルオブジェクトの確認
		expect(globalThis).toBeDefined();
		expect(process).toBeDefined();
		expect(console).toBeDefined();
	});

	// 環境変数のテスト
	it("should handle environment variables", () => {
		// テスト用環境変数の設定例
		process.env.TEST_MODE = "true";

		expect(process.env.TEST_MODE).toBe("true");

		// クリーンアップ
		delete process.env.TEST_MODE;
	});

	// タイムアウトのテスト
	it("should handle timeouts", async () => {
		const delay = (ms: number) =>
			new Promise((resolve) => setTimeout(resolve, ms));

		const start = Date.now();
		await delay(50);
		const elapsed = Date.now() - start;

		expect(elapsed).toBeGreaterThanOrEqual(50);
	}, 1000); // 1秒のタイムアウト
});
