import {describe, expect, test} from "bun:test";
import {} from "../../../../../app/javascript/controllers/news/app/application.ts";
import {describe, expect, test} from "bun:test";
import {
    NEWS_APP_DEFAULT_ORIGIN,
    readNewsAppProps,
    resolveNewsAppUrl,
} from "../../../../../app/javascript/controllers/news/app/application.ts";

describe("News app landing shell", () => {
    test("resolves the default news origin", () => {
        const url = resolveNewsAppUrl();

        expect(url.origin).toBe(NEWS_APP_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica App",
                newsServiceUrl: "news.app.localhost",
                docsServiceUrl: "docs.app.localhost",
                helpServiceUrl: "help.app.localhost",
            },
        } as unknown as HTMLElement;

        expect(readNewsAppProps(element)).toEqual({
            codeName: "Umaxica App",
            newsServiceUrl: "news.app.localhost",
            docsServiceUrl: "docs.app.localhost",
            helpServiceUrl: "help.app.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readNewsAppProps(null)).toEqual({});
    });

});
