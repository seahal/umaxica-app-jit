import { describe, describe, expect, expect, test, test } from "bun:test";
import {
	readSignOrgProps as readWwwOrgProps,
	resolveSignOrgUrl as resolveWwwOrgUrl,
	SIGN_ORG_DEFAULT_ORIGIN as WWW_ORG_DEFAULT_ORIGIN,} from "../../../../../app/javascript/views/www/org/application.ts";

describe("WWW staff landing shell", () => {
	test("resolves the default staff sign origin", () => {
		const url = resolveWwwOrgUrl();

		expect(url.origin).toBe(WWW_ORG_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Org",
				signServiceUrl: "sign.org.localhost",
				helpServiceUrl: "help.org.localhost",
			},
		} as unknown as HTMLElement;

		expect(readWwwOrgProps(element)).toEqual({
			codeName: "Umaxica Org",
			signServiceUrl: "sign.org.localhost",
			helpServiceUrl: "help.org.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readWwwOrgProps(null)).toEqual({});
	});
});
