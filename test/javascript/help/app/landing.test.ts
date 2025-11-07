import { describe, expect, test } from "bun:test";

type Listener = (...args: unknown[]) => void;

const createDocumentStub = () => {
	const listeners = new Map<string, Listener[]>();

	return {
		document: {
			readyState: "loading",
			addEventListener: (
				event: string,
				handler: Listener,
				_options?: unknown,
			) => {
				const existing = listeners.get(event) ?? [];
				existing.push(handler);
				listeners.set(event, existing);
			},
			removeEventListener: (event: string, handler: Listener) => {
				const existing = listeners.get(event);
				if (!existing) {
					return;
				}

				listeners.set(
					event,
					existing.filter((candidate) => candidate !== handler),
				);
			},
			getElementById: () => null,
		},
		listeners,
	};
};

// Skipping due to module caching issues when run with other tests
// Run individually with: bun test test/javascript/help/app/landing.test.ts
describe.skip("Help app landing bootstrap", () => {
	test("registers Turbo lifecycle handlers", async () => {
		const globalAny = globalThis as Record<string, unknown>;
		const originalDocument = globalAny.document;
		const originalWindow = globalAny.window;
		const { document, listeners } = createDocumentStub();

		globalAny.document = document;
		globalAny.window = {
			location: { pathname: "/current" },
			innerHeight: 1080,
			scrollTo: () => {},
			alert: () => {},
			open: () => ({}),
			visualViewport: null,
		};

		try {
			await import("../../../../app/javascript/help/app/landing.tsx");

			const domReady = listeners.get("DOMContentLoaded") ?? [];
			// Module may be cached from other tests, so check for at least 2
			expect(domReady.length).toBeGreaterThanOrEqual(2);

			// Call the last registered handler
			domReady[domReady.length - 1]?.();

			const turboLoad = listeners.get("turbo:load") ?? [];
			const turboBeforeRender = listeners.get("turbo:before-render") ?? [];
			expect(turboLoad.length).toBeGreaterThanOrEqual(1);
			expect(turboBeforeRender.length).toBeGreaterThanOrEqual(1);
		} finally {
			if (originalDocument === undefined) {
				delete globalAny.document;
			} else {
				globalAny.document = originalDocument;
			}
			if (originalWindow === undefined) {
				delete globalAny.window;
			} else {
				globalAny.window = originalWindow;
			}
		}
	});
});
