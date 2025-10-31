import {describe, expect, test} from "bun:test";
import {} from "../../../../../app/javascript/controllers/sign/org/application.ts";
import {describe, expect, test} from "bun:test";
import {
    SIGN_ORG_DEFAULT_ORIGIN,
    readSignOrgProps,
    resolveSignOrgUrl,
} from "../../../../../app/javascript/controllers/sign/org/application.ts";

describe("Sign staff landing shell", () => {
    test("resolves the default staff sign origin", () => {
        const url = resolveSignOrgUrl();

        expect(url.origin).toBe(SIGN_ORG_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Org",
                signServiceUrl: "sign.org.localhost",
                helpServiceUrl: "help.org.localhost",
            },
        } as unknown as HTMLElement;

        expect(readSignOrgProps(element)).toEqual({
            codeName: "Umaxica Org",
            signServiceUrl: "sign.org.localhost",
            helpServiceUrl: "help.org.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readSignOrgProps(null)).toEqual({});
    });
});
