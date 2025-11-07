import { describe, expect, test } from "bun:test";

describe("WWW inquiry form guard", () => {
	test("prevents submission when policy checkbox is unchecked", async () => {
		const globalAny = globalThis as Record<string, unknown>;
		const originalDocument = globalAny.document;
		const originalAlert = globalAny.alert;

		let alertMessage: string | null = null;
		let focusCalled = false;
		let preventDefaultCalls = 0;

		const policy = {
			checked: false,
			focus: () => {
				focusCalled = true;
			},
		};

		const listeners: Record<string, (event: Event) => void> = {};

		const form = {
			addEventListener: (event: string, handler: (event: Event) => void) => {
				listeners[event] = handler;
			},
			querySelector: (selector: string) =>
				selector === "input[name='service_site_contact[confirm_policy]']"
					? policy
					: null,
		};

		globalAny.document = {
			querySelector: (selector: string) =>
				selector === "form[action$='/help/app/inquiries']" ? form : null,
		};

		globalAny.alert = (message: string) => {
			alertMessage = message as string;
		};

		try {
			await import(
				"../../../../../../app/javascript/views/www/app/inquiry/before_submit.js"
			);

			const submit = listeners.submit;
			expect(typeof submit).toBe("function");

			const event = {
				preventDefault: () => {
					preventDefaultCalls += 1;
				},
			} as Event;

			submit(event);
			expect(preventDefaultCalls).toBe(1);
			expect(alertMessage).toBe("You must agree to the terms of service.");
			expect(focusCalled).toBe(true);

			policy.checked = true;
			focusCalled = false;
			alertMessage = null;
			submit(event);

			expect(preventDefaultCalls).toBe(1);
			expect(alertMessage).toBeNull();
			expect(focusCalled).toBe(false);
		} finally {
			if (originalDocument === undefined) {
				delete globalAny.document;
			} else {
				globalAny.document = originalDocument;
			}

			if (originalAlert === undefined) {
				delete globalAny.alert;
			} else {
				globalAny.alert = originalAlert;
			}
		}
	});
});
