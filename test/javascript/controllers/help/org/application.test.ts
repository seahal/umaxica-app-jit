import {describe, expect, test} from "bun:test";
import {
    HELP_ORG_DEFAULT_ORIGIN,
    readHelpOrgProps,
    resolveHelpOrgUrl,
} from "../../../../../app/javascript/controllers/help/org/application.ts";

describe("Help org landing shell (React Aria)", () => {
    test("resolves the default help origin", () => {
        const url = resolveHelpOrgUrl();

        expect(url.origin).toBe(HELP_ORG_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Org",
                helpServiceUrl: "help.org.localhost",
                docsServiceUrl: "docs.org.localhost",
                newsServiceUrl: "news.org.localhost",
            },
        } as unknown as HTMLElement;

        expect(readHelpOrgProps(element)).toEqual({
            codeName: "Umaxica Org",
            helpServiceUrl: "help.org.localhost",
            docsServiceUrl: "docs.org.localhost",
            newsServiceUrl: "news.org.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readHelpOrgProps(null)).toEqual({});
    });
});
