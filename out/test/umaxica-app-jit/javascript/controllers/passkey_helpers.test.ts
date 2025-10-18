import {describe, expect, test} from "bun:test";

import {
    toB64url,
    fromB64url,
    decodeCreationOptions,
} from "../../../app/javascript/controllers/passkey_helpers.js";

function bufEq(a: ArrayBuffer, b: ArrayBuffer): boolean {
    const ua = new Uint8Array(a);
    const ub = new Uint8Array(b);
    if (ua.length !== ub.length) return false;
    for (let i = 0; i < ua.length; i++) if (ua[i] !== ub[i]) return false;
    return true;
}

describe("passkey_helpers base64url", () => {
    test("roundtrip random bytes", () => {
        const src = crypto.getRandomValues(new Uint8Array(256)).buffer;
        const b64u = toB64url(src);
        const back = fromB64url(b64u);
        expect(bufEq(src, back)).toBe(true);
    });

    test("handles no padding variants", () => {
        const src = new Uint8Array([0xde, 0xad, 0xbe, 0xef]).buffer;
        const b64u = toB64url(src); // should end without '='
        expect(b64u.includes("=")).toBe(false);
        const back = fromB64url(b64u);
        expect(bufEq(src, back)).toBe(true);
    });
});

describe("decodeCreationOptions", () => {
    test("decodes challenge, user.id and excludeCredentials[*].id", () => {
        const challenge = new Uint8Array([1, 2, 3, 4]).buffer;
        const userId = new Uint8Array([9, 9, 9]).buffer;
        const ex1 = new Uint8Array([5]).buffer;
        const ex2 = new Uint8Array([6, 7]).buffer;

        const opts = {
            publicKey: {
                challenge: toB64url(challenge),
                user: {id: toB64url(userId)},
                excludeCredentials: [
                    {type: "public-key", id: toB64url(ex1)},
                    {type: "public-key", id: toB64url(ex2)},
                ],
            },
        };

        const decoded = decodeCreationOptions(opts as any);
        expect(bufEq(decoded.challenge, challenge)).toBe(true);
        expect(bufEq(decoded.user.id, userId)).toBe(true);
        expect(bufEq(decoded.excludeCredentials[0].id, ex1)).toBe(true);
        expect(bufEq(decoded.excludeCredentials[1].id, ex2)).toBe(true);
    });
});

