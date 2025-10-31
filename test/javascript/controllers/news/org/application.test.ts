import {describe, expect, test} from "bun:test";
import {} from "../../../../../app/javascript/controllers/news/org/application.ts";
import {describe, expect, test} from "bun:test";
import {
    NEWS_ORG_DEFAULT_ORIGIN,
    readNewsOrgProps,
    resolveNewsOrgUrl,
} from "../../../../../app/javascript/controllers/news/org/application.ts";

describe("News staff landing shell", () => {
    test("resolves the default staff news origin", () => {
        const url = resolveNewsOrgUrl();

        expect(url.origin).toBe(NEWS_ORG_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Org",
                newsServiceUrl: "news.org.localhost",
                docsServiceUrl: "docs.org.localhost",
                helpServiceUrl: "help.org.localhost",
            },
        } as unknown as HTMLElement;

        expect(readNewsOrgProps(element)).toEqual({
            codeName: "Umaxica Org",
            newsServiceUrl: "news.org.localhost",
            docsServiceUrl: "docs.org.localhost",
            helpServiceUrl: "help.org.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readNewsOrgProps(null)).toEqual({});
    });

});
