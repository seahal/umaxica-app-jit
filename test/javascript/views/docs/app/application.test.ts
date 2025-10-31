import {describe, expect, test} from "bun:test";
import {
    DOCS_APP_DEFAULT_ORIGIN,
    installDocsAppHostAlert,
    isDocsAppHost,
    readDocsAppProps,
    resolveDocsAppUrl,
} from "../../../../../app/javascript/views/docs/app/application.ts";

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

    test("detects when running on the docs host", () => {
        const hostname = new URL(DOCS_APP_DEFAULT_ORIGIN).hostname;
        const windowLike = {
            location: {hostname} as unknown as Location,
        };

        expect(isDocsAppHost(windowLike)).toBe(true);
    });

    test("bails when hostname lookup throws", () => {
        const windowLike = {
            location: Object.defineProperty(
                {},
                "hostname",
                {
                    get() {
                        throw new Error("unreachable");
                    },
                },
            ) as Location,
        };

        expect(isDocsAppHost(windowLike)).toBe(false);
    });

    test("returns false when window context missing", () => {
        expect(isDocsAppHost(undefined)).toBe(false);
    });

    test("returns false when window lacks location", () => {
        expect(isDocsAppHost({})).toBe(false);
    });

    test("installs DOMContentLoaded alert when host matches", () => {
        const alertCalls: string[] = [];
        const eventListeners: Record<string, Array<EventListenerOrEventListenerObject>> = {};
        const addEventListener: Window["addEventListener"] = (type, listener) => {
            if (!listener) {
                return;
            }

            eventListeners[type] = eventListeners[type] ?? [];
            eventListeners[type].push(listener);
        };
        const windowLike = {
            location: {
                hostname: new URL(DOCS_APP_DEFAULT_ORIGIN).hostname,
            } as unknown as Location,
            addEventListener,
            alert: (message: string) => {
                alertCalls.push(message);
            },
        };

        installDocsAppHostAlert(windowLike);

        expect(eventListeners.DOMContentLoaded?.length ?? 0).toBe(1);

        const [listener] = eventListeners.DOMContentLoaded ?? [];

        if (typeof listener === "function") {
            listener(new Event("DOMContentLoaded"));
        } else if (listener) {
            listener.handleEvent(new Event("DOMContentLoaded"));
        }

        expect(alertCalls).toEqual(["docs"]);
    });
});
