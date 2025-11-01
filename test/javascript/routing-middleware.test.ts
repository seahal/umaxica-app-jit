import {describe, it, expect} from "bun:test";
import {applyRootPrefix} from "./helpers/routing-middleware";

describe("routing middleware host-based prefixing", () => {
    const cases = [
        {
            host: "app.localhost",
            rawPaths: ["/", "/health", "/preference/region/edit", "/any/deep/path"],
            prefixed: ["/root/app", "/root/app/health", "/root/app/preference/region/edit", "/root/app/any/deep/path"],
            alreadyPrefixed: ["/root/app", "/root/app/health", "/root/app/preference/region/edit", "/root/app/any/deep/path"],
        },
        {
            host: "com.localhost",
            rawPaths: ["/", "/health", "/preference/theme/edit", "/x/y/z"],
            prefixed: ["/root/com", "/root/com/health", "/root/com/preference/theme/edit", "/root/com/x/y/z"],
            alreadyPrefixed: ["/root/com", "/root/com/health", "/root/com/preference/theme/edit", "/root/com/x/y/z"],
        },
        {
            host: "org.localhost",
            rawPaths: ["/", "/health", "/preference/email/edit", "/foo"],
            prefixed: ["/root/org", "/root/org/health", "/root/org/preference/email/edit", "/root/org/foo"],
            alreadyPrefixed: ["/root/org", "/root/org/health", "/root/org/preference/email/edit", "/root/org/foo"],
        },
    ] as const;

    for (const suite of cases) {
        describe(`${suite.host}`, () => {
            it("prefixes raw paths", () => {
                suite.rawPaths.forEach((path, i) => {
                    const out = applyRootPrefix(suite.host, path);
                    expect(out).toBe(suite.prefixed[i]);
                });
            });

            it("does not double-prefix already-prefixed paths", () => {
                suite.alreadyPrefixed.forEach((path) => {
                    const out = applyRootPrefix(suite.host, path);
                    expect(out).toBe(path);
                });
            });

            it("does not change paths prefixed for other sections", () => {
                // Ensure we don't create double or cross prefixes
                const others = ["/root/app/abc", "/root/com/abc", "/root/org/abc"];
                others.forEach((path) => {
                    const out = applyRootPrefix(suite.host, path);
                    expect(out).toBe(path);
                });
            });
        });
    }
});
