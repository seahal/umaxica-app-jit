import {describe, expect, test} from "bun:test";
import {
    DOCS_ORG_DEFAULT_ORIGIN,
    readDocsOrgProps,
    resolveDocsOrgUrl,
} from "../../../../../app/javascript/controllers/docs/org/application.ts";

describe("Docs org landing shell (React Aria)", () => {
    test("resolves the default staff docs origin", () => {
        const url = resolveDocsOrgUrl();

        expect(url.origin).toBe(DOCS_ORG_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Staff Docs",
                docsServiceUrl: "docs.org.localhost",
                helpServiceUrl: "help.org.localhost",
                newsServiceUrl: "news.org.localhost",
            },
        } as unknown as HTMLElement;

        expect(readDocsOrgProps(element)).toEqual({
            codeName: "Umaxica Staff Docs",
            docsServiceUrl: "docs.org.localhost",
            helpServiceUrl: "help.org.localhost",
            newsServiceUrl: "news.org.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readDocsOrgProps(null)).toEqual({});
    });

});
