import { describe, describe, expect, expect, test, test } from "bun:test";
import {
	NEWS_COM_DEFAULT_ORIGIN,
	readNewsComProps,
	resolveNewsComUrl,} from "../../../../../app/javascript/views/news/com/application.ts";

describe("News corporate landing shell", () => {
	test("resolves the default corporate news origin", () => {
		const url = resolveNewsComUrl();

		expect(url.origin).toBe(NEWS_COM_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Corporate",
				newsServiceUrl: "news.com.localhost",
				docsServiceUrl: "docs.com.localhost",
				helpServiceUrl: "help.com.localhost",
			},
		} as unknown as HTMLElement;

		expect(readNewsComProps(element)).toEqual({
			codeName: "Umaxica Corporate",
			newsServiceUrl: "news.com.localhost",
			docsServiceUrl: "docs.com.localhost",
			helpServiceUrl: "help.com.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readNewsComProps(null)).toEqual({});
	});
});
