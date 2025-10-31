import {describe, expect, test} from "bun:test";
import {
    DOCS_APP_DEFAULT_ORIGIN,
    readDocsAppProps,
    resolveDocsAppUrl,
} from "../../../../../app/javascript/controllers/docs/app/application.ts";

describe("Docs app landing shell (React Aria)", () => {
    test("resolves the default docs origin", () => {
        const url = resolveDocsAppUrl();

        expect(url.origin).toBe(DOCS_APP_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Docs",
                docsServiceUrl: "docs.app.localhost",
                helpServiceUrl: "help.app.localhost",
                newsServiceUrl: "news.app.localhost",
            },
        } as unknown as HTMLElement;

        expect(readDocsAppProps(element)).toEqual({
            codeName: "Umaxica Docs",
            docsServiceUrl: "docs.app.localhost",
            helpServiceUrl: "help.app.localhost",
            newsServiceUrl: "news.app.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readDocsAppProps(null)).toEqual({});
    });

    test.todo("hydrates the docs app React shell with server-provided props");
    test.todo("navigates between document categories via keyboard only");
    test.todo("routes support links using dataset-provided service URLs");
});
