import { describe, describe, expect, expect, test, test } from "bun:test";
import {
	readWwwAppProps,
	resolveWwwAppUrl,
	WWW_APP_DEFAULT_ORIGIN,} from "../../../../../app/javascript/views/www/app/application.ts";

describe("WWW app landing shell", () => {
	test("resolves the default sign origin", () => {
		const url = resolveWwwAppUrl();

		expect(url.origin).toBe(WWW_APP_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica App",
				wwwServiceUrl: "sign.app.localhost",
				docsServiceUrl: "docs.app.localhost",
				helpServiceUrl: "help.app.localhost",
				newsServiceUrl: "news.app.localhost",
			},
		} as unknown as HTMLElement;

		expect(readWwwAppProps(element)).toEqual({
			codeName: "Umaxica App",
			wwwServiceUrl: "sign.app.localhost",
			docsServiceUrl: "docs.app.localhost",
			helpServiceUrl: "help.app.localhost",
			newsServiceUrl: "news.app.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readWwwAppProps(null)).toEqual({});
	});
});
