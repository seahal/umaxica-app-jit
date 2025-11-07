import { afterEach, describe, expect, test } from "bun:test";

const modulePath =
	"../../../app/javascript/views/sign/app/inquiry/before_submit.js";

const originalDocument = (globalThis as { document?: Document }).document;
const originalAlert = (globalThis as { alert?: (message: string) => void })
	.alert;

afterEach(() => {
	if (originalDocument === undefined) {
		delete (globalThis as { document?: Document }).document;
	} else {
		(globalThis as { document?: Document }).document = originalDocument;
	}

	if (originalAlert === undefined) {
		delete (globalThis as { alert?: (message: string) => void }).alert;
	} else {
		(globalThis as { alert?: (message: string) => void }).alert = originalAlert;
	}
});

describe("sign inquiry submit guard", () => {
	test("returns early when document is undefined", async () => {
		delete (globalThis as { document?: Document }).document;

		await import(`${modulePath}?case=no-document`);

		expect((globalThis as { document?: Document }).document).toBeUndefined();
	});

	test("returns early when inquiry form is missing", async () => {
		let selectorUsed: string | null = null;

		(globalThis as { document?: Document }).document = {
			querySelector: (selector: string) => {
				selectorUsed = selector;
				return null;
			},
		} as any;

		await import(`${modulePath}?case=form-missing`);

		expect(selectorUsed).toBe("form[action$='/help/app/inquiries']");
	});

	test("prevents submission when policy checkbox is unchecked", async () => {
		const listeners: Record<
			string,
			(event: { preventDefault: () => void }) => void
		> = {};
		let prevented = false;
		let alertMessage: string | null = null;
		let focused = false;

		const policy = {
			checked: false,
			focus: () => {
				focused = true;
			},
		};

		const form = {
			addEventListener: (
				event: string,
				handler: (event: { preventDefault: () => void }) => void,
			) => {
				listeners[event] = handler;
			},
			querySelector: (selector: string) =>
				selector === "input[name='service_site_contact[confirm_policy]']"
					? policy
					: null,
		};

		(globalThis as { document?: Document }).document = {
			querySelector: (selector: string) =>
				selector === "form[action$='/help/app/inquiries']" ? form : null,
		} as any;

		(globalThis as { alert?: (message: string) => void }).alert = (message) => {
			alertMessage = message;
		};

		await import(`${modulePath}?case=form-present`);

		const handler = listeners.submit;
		expect(typeof handler).toBe("function");

		const event = {
			preventDefault: () => {
				prevented = true;
			},
		};

		handler?.(event);

		expect(prevented).toBe(true);
		expect(alertMessage).toBe("You must agree to the terms of service.");
		expect(focused).toBe(true);

		prevented = false;
		alertMessage = null;
		focused = false;
		policy.checked = true;

		handler?.(event);

		expect(prevented).toBe(false);
		expect(alertMessage).toBeNull();
		expect(focused).toBe(false);
	});
});
