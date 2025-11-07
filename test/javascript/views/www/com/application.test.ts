import { describe, describe, expect, expect, test, test } from "bun:test";
import {
	readSignOrgProps as readWwwComProps,
	resolveSignOrgUrl as resolveWwwComUrl,
	SIGN_ORG_DEFAULT_ORIGIN as WWW_COM_DEFAULT_ORIGIN,} from "../../../../../app/javascript/views/www/com/application.ts";

describe("WWW corporate landing shell", () => {
	test("resolves the default corporate sign origin", () => {
		const url = resolveWwwComUrl();

		expect(url.origin).toBe(WWW_COM_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Corporate",
				signServiceUrl: "sign.com.localhost",
				helpServiceUrl: "help.com.localhost",
			},
		} as unknown as HTMLElement;

		expect(readWwwComProps(element)).toEqual({
			codeName: "Umaxica Corporate",
			signServiceUrl: "sign.com.localhost",
			helpServiceUrl: "help.com.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readWwwComProps(null)).toEqual({});
	});
});
