import {describe, expect, test} from "bun:test";
import {
	ROOT_APP_DEFAULT_ORIGIN,
	readRootAppProps,
	resolveRootAppUrl,
} from "../../../../../app/javascript/views/root/app/application.ts";

describe("Root app hydration helpers", () => {
	test("resolves the default root app origin", () => {
		const url = resolveRootAppUrl();

		expect(url.origin).toBe(ROOT_APP_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values from the root app container", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Root",
				rootServiceUrl: "root.localhost",
				docsServiceUrl: "docs.localhost",
				helpServiceUrl: "help.localhost",
				newsServiceUrl: "news.localhost",
			},
		} as unknown as HTMLElement;

		expect(readRootAppProps(element)).toEqual({
			codeName: "Umaxica Root",
			rootServiceUrl: "root.localhost",
			docsServiceUrl: "docs.localhost",
			helpServiceUrl: "help.localhost",
			newsServiceUrl: "news.localhost",
		});
	});

	test("returns empty props when the container is missing", () => {
		expect(readRootAppProps(null)).toEqual({});
	});
});
