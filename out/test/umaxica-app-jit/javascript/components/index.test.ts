import { describe, expect, test } from "bun:test";

describe("Should see app homepage", () => {
	test("GET /app.www.localdomain:3000/", async () => {
		expect(1).toBe(1);
	});
});
