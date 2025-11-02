import {describe, expect, test} from "bun:test";
import {
	ROOT_COM_DEFAULT_ORIGIN,
	readRootComProps,
	resolveRootComUrl,
} from "../../../../../app/javascript/views/root/com/application.ts";

describe("Root corporate hydration helpers", () => {
	test("resolves the default root corporate origin", () => {
		const url = resolveRootComUrl();

		expect(url.origin).toBe(ROOT_COM_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values from the corporate container", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Corporate",
				rootServiceUrl: "root-corp.localhost",
				docsServiceUrl: "docs-corp.localhost",
				helpServiceUrl: "help-corp.localhost",
				newsServiceUrl: "news-corp.localhost",
			},
		} as unknown as HTMLElement;

		expect(readRootComProps(element)).toEqual({
			codeName: "Umaxica Corporate",
			rootServiceUrl: "root-corp.localhost",
			docsServiceUrl: "docs-corp.localhost",
			helpServiceUrl: "help-corp.localhost",
			newsServiceUrl: "news-corp.localhost",
		});
	});

	test("returns empty props when the corporate container is missing", () => {
		expect(readRootComProps(null)).toEqual({});
	});
});
