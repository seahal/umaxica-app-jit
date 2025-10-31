import {describe, expect, test} from "bun:test";
import {
    HELP_APP_DEFAULT_ORIGIN,
    readHelpAppProps,
    resolveHelpAppUrl,
} from "../../../../../app/javascript/controllers/help/app/main.ts";

describe("Help app landing shell (React Aria)", () => {
    test("resolves the default help origin", () => {
        const url = resolveHelpAppUrl();

        expect(url.origin).toBe(HELP_APP_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica",
                helpServiceUrl: "help.app.localhost",
                docsServiceUrl: "docs.app.localhost",
                newsServiceUrl: "news.app.localhost",
            },
        } as unknown as HTMLElement;

        expect(readHelpAppProps(element)).toEqual({
            codeName: "Umaxica",
            helpServiceUrl: "help.app.localhost",
            docsServiceUrl: "docs.app.localhost",
            newsServiceUrl: "news.app.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readHelpAppProps(null)).toEqual({});
    });

    test.todo("hydrates the help app React shell with server-provided props");
    test.todo("persists filter state when navigating between knowledge tabs");
    test.todo("routes external footer links via service URLs from dataset");
});
