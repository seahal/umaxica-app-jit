import {describe, expect, test} from "bun:test";

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

describe("Help app landing bootstrap", () => {
	test("registers Turbo lifecycle handlers", async () => {
		const globalAny = globalThis as Record<string, unknown>;
		const originalDocument = globalAny.document;
		const { document, listeners } = createDocumentStub();

		globalAny.document = document;

		try {
			await import("../../../../app/javascript/help/app/landing.tsx");

			const domReady = listeners.get("DOMContentLoaded") ?? [];
			expect(domReady.length).toBe(2);

			domReady[1]?.();

			expect(listeners.get("turbo:load")?.length).toBe(1);
			expect(listeners.get("turbo:before-render")?.length).toBe(1);
		} finally {
			if (originalDocument === undefined) {
				delete globalAny.document;
			} else {
				globalAny.document = originalDocument;
			}
		}
	});
});
