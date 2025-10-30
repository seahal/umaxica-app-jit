import {afterEach, describe, expect, test} from "bun:test";
import {
    csrfToken,
    decodeCreationOptions,
    fromB64url,
    toB64url,
} from "../../../app/javascript/controllers/passkey_helpers.js";

describe("passkey helpers", () => {
    describe("toB64url/fromB64url", () => {
        test("round-trips binary data", () => {
            const source = new Uint8Array([1, 2, 3, 254, 255]);
            const encoded = toB64url(source.buffer);
            const decoded = new Uint8Array(fromB64url(encoded));

            expect([...decoded]).toEqual([...source]);
        });

        test("preserves values that produce URL-safe characters", () => {
            const source = new Uint8Array([255, 239, 190, 13]); // -> includes +, / before URL-safe conversion
            const encoded = toB64url(source.buffer);
            const decoded = new Uint8Array(fromB64url(encoded));

            expect([...decoded]).toEqual([...source]);
        });
    });

    describe("decodeCreationOptions", () => {
        const rawChallenge = new Uint8Array([11, 22, 33, 44]).buffer;
        const rawUserId = new Uint8Array([55, 66]).buffer;
        const rawExcludedId = new Uint8Array([77, 88, 99]).buffer;
        const encodedChallenge = toB64url(rawChallenge);
        const encodedUserId = toB64url(rawUserId);
        const encodedExcludedId = toB64url(rawExcludedId);

        const template = {
            publicKey: {
                challenge: encodedChallenge,
                user: {id: encodedUserId},
                excludeCredentials: [
                    {
                        id: encodedExcludedId,
                        type: "public-key",
                    },
                ],
            },
        };

        test("decodes buffers while leaving the original object untouched", () => {
            const input = structuredClone(template);
            const decoded = decodeCreationOptions(input);

            expect(input.publicKey.challenge).toBe(encodedChallenge);
            expect(input.publicKey.user?.id).toBe(encodedUserId);

            expect(new Uint8Array(decoded.challenge)).toEqual(
                new Uint8Array(rawChallenge),
            );
            expect(new Uint8Array(decoded.user?.id ?? new ArrayBuffer(0))).toEqual(
                new Uint8Array(rawUserId),
            );
            expect(
                new Uint8Array(decoded.excludeCredentials[0]?.id ?? new ArrayBuffer(0)),
            ).toEqual(new Uint8Array(rawExcludedId));
        });

        test("returns clones so mutations do not bleed into callers", () => {
            const decoded = decodeCreationOptions(structuredClone(template));

            const challenge = new Uint8Array(decoded.challenge);
            challenge[0] = 0;

            expect(template.publicKey.challenge).toBe(encodedChallenge);
        });
    });

    describe("csrfToken", () => {
        const originalDocument = globalThis.document;

        afterEach(() => {
            if (originalDocument === undefined) {
                delete globalThis.document;
            } else {
                globalThis.document = originalDocument;
            }
        });

        test("reads token from meta tag", () => {
            const meta = {content: "csrf-token-value"};
            globalThis.document = {
                querySelector: (selector: string) =>
                    selector === 'meta[name="csrf-token"]' ? meta : null,
            } as any;

            expect(csrfToken()).toBe("csrf-token-value");
        });

        test("falls back to empty string when meta tag missing", () => {
            globalThis.document = {
                querySelector: () => null,
            } as any;

            expect(csrfToken()).toBe("");
        });

        test("returns empty string when document is undefined", () => {
            (globalThis as {document?: unknown}).document = undefined;
            expect(csrfToken()).toBe("");
        });
    });
});
