import { describe, expect, test } from "bun:test";
import {
	DOCS_COM_DEFAULT_ORIGIN,
	readDocsComProps,
	resolveDocsComUrl,
} from "../../../../../app/javascript/views/docs/com/application.ts";

describe("Docs com landing shell (React Aria)", () => {
	test("resolves the default corporate docs origin", () => {
		const url = resolveDocsComUrl();

		expect(url.origin).toBe(DOCS_COM_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values for hydration props", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Corporate Docs",
				docsServiceUrl: "docs.com.localhost",
				helpServiceUrl: "help.com.localhost",
				newsServiceUrl: "news.com.localhost",
			},
		} as unknown as HTMLElement;

		expect(readDocsComProps(element)).toEqual({
			codeName: "Umaxica Corporate Docs",
			docsServiceUrl: "docs.com.localhost",
			helpServiceUrl: "help.com.localhost",
			newsServiceUrl: "news.com.localhost",
		});
	});

	test("returns empty props when container missing", () => {
		expect(readDocsComProps(null)).toEqual({});
	});
});
