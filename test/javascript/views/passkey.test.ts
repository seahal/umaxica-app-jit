import {describe, expect, test} from "bun:test";

describe("Passkey enrollment view", () => {
	test("registers a click handler when the passkey button exists", async () => {
		const globalAny = globalThis as Record<string, unknown>;
		const originalDocument = globalAny.document;

		const listeners: Record<string, unknown> = {};
		const button = {
			addEventListener: (event: string, handler: unknown) => {
				listeners[event] = handler;
			},
		};

		globalAny.document = {
			getElementById: (id: string) => (id === "add-passkey" ? button : null),
		};

		try {
			await import("../../../app/javascript/views/passkey.js");

			expect(listeners.click).toBeDefined();
			expect(typeof listeners.click).toBe("function");
		} finally {
			if (originalDocument === undefined) {
				delete globalAny.document;
			} else {
				globalAny.document = originalDocument;
			}
		}
	});
});
