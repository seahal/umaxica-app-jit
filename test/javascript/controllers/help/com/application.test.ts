import {describe, expect, test} from "bun:test";
import {
    HELP_COM_DEFAULT_ORIGIN,
    readHelpComProps,
    resolveHelpComUrl,
} from "../../../../../app/javascript/controllers/help/com/application.ts";

describe("Help com landing shell (React Aria)", () => {
    test("resolves the default corporate help origin", () => {
        const url = resolveHelpComUrl();

        expect(url.origin).toBe(HELP_COM_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Corporate",
                helpServiceUrl: "help.com.localhost",
                docsServiceUrl: "docs.com.localhost",
                newsServiceUrl: "news.com.localhost",
            },
        } as unknown as HTMLElement;

        expect(readHelpComProps(element)).toEqual({
            codeName: "Umaxica Corporate",
            helpServiceUrl: "help.com.localhost",
            docsServiceUrl: "docs.com.localhost",
            newsServiceUrl: "news.com.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readHelpComProps(null)).toEqual({});
    });

    test.todo("hydrates the help com React shell with corporate-specific content");
    test.todo("announces navigation changes for assistive technology users");
    test.todo("links to newsroom and docs using corporate dataset origins");
});
