import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

const {
  parseConsentCookie,
  consentAllowsAnalytics,
  consentAllowsTargeting,
  currentConsentState,
  canLoadProductAnalytics,
  canLoadTargetingAnalytics,
  installAnalyticsConsentGate,
} = await import("../../app/javascript/analytics_consent_gate.js");

describe("analytics_consent_gate", () => {
  beforeEach(() => {
    vi.stubGlobal("document", { cookie: "" });
  });

  test("parseConsentCookie returns safe defaults when cookie is blank", () => {
    expect(parseConsentCookie("")).toEqual({
      consented: false,
      functional: false,
      performant: false,
      targetable: false,
    });
  });

  test("parseConsentCookie treats consent cookie as performant consent", () => {
    expect(parseConsentCookie("foo=bar; preference_consented=1")).toEqual({
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
    });
  });

  test("consent helpers read performant and targetable flags", () => {
    expect(consentAllowsAnalytics({ performant: true })).toBe(true);
    expect(consentAllowsAnalytics({ performant: false })).toBe(false);
    expect(consentAllowsTargeting({ targetable: true })).toBe(true);
    expect(consentAllowsTargeting({ targetable: false })).toBe(false);
  });

  test("currentConsentState reads from document cookie", () => {
    document.cookie = "preference_consented=1";

    expect(currentConsentState()).toEqual({
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
    });
  });

  test("load helpers reflect cookie state", () => {
    document.cookie = "preference_consented=1";

    expect(canLoadProductAnalytics()).toBe(true);
    expect(canLoadTargetingAnalytics()).toBe(false);
  });

  test("installAnalyticsConsentGate invokes callback with current consent state", () => {
    document.cookie = "preference_consented=1";
    const onConsentChange = vi.fn();

    installAnalyticsConsentGate({ onConsentChange });

    expect(onConsentChange).toHaveBeenCalledWith({
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
    });
  });
});
