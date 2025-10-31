import {describe, expect, test} from "bun:test";
import {} from "../../../../../app/javascript/controllers/www/app/application.ts";
import {describe, expect, test} from "bun:test";
import {
    WWW_APP_DEFAULT_ORIGIN,
    readWwwAppProps,
    resolveWwwAppUrl,
} from "../../../../../app/javascript/controllers/www/app/application.ts";

describe("WWW app landing shell", () => {
    test("resolves the default www origin", () => {
        const url = resolveWwwAppUrl();

        expect(url.origin).toBe(WWW_APP_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica App",
                wwwServiceUrl: "www.app.localhost",
                docsServiceUrl: "docs.app.localhost",
                helpServiceUrl: "help.app.localhost",
                newsServiceUrl: "news.app.localhost",
            },
        } as unknown as HTMLElement;

        expect(readWwwAppProps(element)).toEqual({
            codeName: "Umaxica App",
            wwwServiceUrl: "www.app.localhost",
            docsServiceUrl: "docs.app.localhost",
            helpServiceUrl: "help.app.localhost",
            newsServiceUrl: "news.app.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readWwwAppProps(null)).toEqual({});
    });

    test.todo("hydrates the www app shell with server-provided props");
    test.todo("supports keyboard traversal between promo sections");
    test.todo("launches docs/help/news links via dataset URLs");
});
