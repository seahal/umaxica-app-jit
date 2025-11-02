import {describe, expect, test} from "bun:test";
import {
	ROOT_ORG_DEFAULT_ORIGIN,
	readRootOrgProps,
	resolveRootOrgUrl,
} from "../../../../../app/javascript/views/root/org/application.ts";

describe("Root staff hydration helpers", () => {
	test("resolves the default root staff origin", () => {
		const url = resolveRootOrgUrl();

		expect(url.origin).toBe(ROOT_ORG_DEFAULT_ORIGIN);
		expect(url.pathname).toBe("/");
	});

	test("reads dataset values from the staff container", () => {
		const element = {
			dataset: {
				codeName: "Umaxica Staff",
				rootServiceUrl: "root-org.localhost",
				docsServiceUrl: "docs-org.localhost",
				helpServiceUrl: "help-org.localhost",
				newsServiceUrl: "news-org.localhost",
			},
		} as unknown as HTMLElement;

		expect(readRootOrgProps(element)).toEqual({
			codeName: "Umaxica Staff",
			rootServiceUrl: "root-org.localhost",
			docsServiceUrl: "docs-org.localhost",
			helpServiceUrl: "help-org.localhost",
			newsServiceUrl: "news-org.localhost",
		});
	});

	test("returns empty props when the staff container is missing", () => {
		expect(readRootOrgProps(null)).toEqual({});
	});
});
