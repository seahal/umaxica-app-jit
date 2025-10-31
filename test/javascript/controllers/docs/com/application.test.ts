import {describe, expect, test} from "bun:test";
import {
    DOCS_COM_DEFAULT_ORIGIN,
    readDocsComProps,
    resolveDocsComUrl,
} from "../../../../../app/javascript/controllers/docs/com/main.ts";

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

    test.todo("hydrates the docs com React shell with enterprise guides");
    test.todo("announces tab selection changes for assistive technologies");
    test.todo("links to newsroom and help using corporate dataset origins");
});
