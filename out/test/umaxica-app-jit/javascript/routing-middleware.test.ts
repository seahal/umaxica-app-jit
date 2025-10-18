import {describe, it, expect} from "bun:test";
import {applyApexPrefix} from "./helpers/routing-middleware";

describe("routing middleware host-based prefixing", () => {
    const cases = [
        {
            host: "app.localhost",
            rawPaths: ["/", "/health", "/preference/region/edit", "/any/deep/path"],
            prefixed: ["/apex/app", "/apex/app/health", "/apex/app/preference/region/edit", "/apex/app/any/deep/path"],
            alreadyPrefixed: ["/apex/app", "/apex/app/health", "/apex/app/preference/region/edit", "/apex/app/any/deep/path"],
        },
        {
            host: "com.localhost",
            rawPaths: ["/", "/health", "/preference/theme/edit", "/x/y/z"],
            prefixed: ["/apex/com", "/apex/com/health", "/apex/com/preference/theme/edit", "/apex/com/x/y/z"],
            alreadyPrefixed: ["/apex/com", "/apex/com/health", "/apex/com/preference/theme/edit", "/apex/com/x/y/z"],
        },
        {
            host: "org.localhost",
            rawPaths: ["/", "/health", "/preference/email/edit", "/foo"],
            prefixed: ["/apex/org", "/apex/org/health", "/apex/org/preference/email/edit", "/apex/org/foo"],
            alreadyPrefixed: ["/apex/org", "/apex/org/health", "/apex/org/preference/email/edit", "/apex/org/foo"],
        },
    ] as const;

    for (const suite of cases) {
        describe(`${suite.host}`, () => {
            it("prefixes raw paths", () => {
                suite.rawPaths.forEach((path, i) => {
                    const out = applyApexPrefix(suite.host, path);
                    expect(out).toBe(suite.prefixed[i]);
                });
            });

            it("does not double-prefix already-prefixed paths", () => {
                suite.alreadyPrefixed.forEach((path) => {
                    const out = applyApexPrefix(suite.host, path);
                    expect(out).toBe(path);
                });
            });

            it("does not change paths prefixed for other sections", () => {
                // Ensure we don't create double or cross prefixes
                const others = ["/apex/app/abc", "/apex/com/abc", "/apex/org/abc"];
                others.forEach((path) => {
                    const out = applyApexPrefix(suite.host, path);
                    expect(out).toBe(path);
                });
            });
        });
    }
});

