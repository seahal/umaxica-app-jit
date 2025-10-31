import {describe, expect, test} from "bun:test";
import {} from "../../../../../app/javascript/controllers/www/com/application.ts";
import {describe, expect, test} from "bun:test";
import {
    SIGN_ORG_DEFAULT_ORIGIN as WWW_COM_DEFAULT_ORIGIN,
    readSignOrgProps as readWwwComProps,
    resolveSignOrgUrl as resolveWwwComUrl,
} from "../../../../../app/javascript/controllers/www/com/application.ts";

describe("WWW corporate landing shell", () => {
    test("resolves the default corporate www origin", () => {
        const url = resolveWwwComUrl();

        expect(url.origin).toBe(WWW_COM_DEFAULT_ORIGIN);
        expect(url.pathname).toBe("/");
    });

    test("reads dataset values for hydration props", () => {
        const element = {
            dataset: {
                codeName: "Umaxica Corporate",
                signServiceUrl: "sign.com.localhost",
                helpServiceUrl: "help.com.localhost",
            },
        } as unknown as HTMLElement;

        expect(readWwwComProps(element)).toEqual({
            codeName: "Umaxica Corporate",
            signServiceUrl: "sign.com.localhost",
            helpServiceUrl: "help.com.localhost",
        });
    });

    test("returns empty props when container missing", () => {
        expect(readWwwComProps(null)).toEqual({});
    });

});
