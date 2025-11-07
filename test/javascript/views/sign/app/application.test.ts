import { describe, describe, expect, expect, test, test } from "bun:test";
import {
	readSignAppProps,
	resolveSignAppUrl,
	SIGN_APP_DEFAULT_ORIGIN,} from "../../../../../app/javascript/views/sign/app/application.ts";

describe("Sign app landing shell", () => {
	test("resolves the default sign origin", () => {
		const url = resolveSignAppUrl();

		expect(url.origin).toBe(SIGN_APP_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Sign App",
				signServiceUrl: "sign.app.localhost",
				helpServiceUrl: "help.app.localhost",
			},
		} as unknown as HTMLElement;

		expect(readSignAppProps(element)).toEqual({
			codeName: "Umaxica Sign App",
			signServiceUrl: "sign.app.localhost",
			helpServiceUrl: "help.app.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readSignAppProps(null)).toEqual({});
	});
});
