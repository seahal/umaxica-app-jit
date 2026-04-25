export function parseConsentCookie(cookieString) {
  if (!cookieString) {
    return { consented: false, functional: false, performant: false, targetable: false };
  }

  const pairs = cookieString.split(";").map((entry) => entry.trim().split("="));
  const values = Object.fromEntries(pairs.filter(([key]) => key && key.length > 0));
  const consented = values.preference_consented === "1";

  return {
    consented,
    functional: consented,
    performant: consented,
    targetable: false,
  };
}

export function consentAllowsAnalytics(consentState) {
  return Boolean(consentState?.performant);
}

export function consentAllowsTargeting(consentState) {
  return Boolean(consentState?.targetable);
}

export function currentConsentState() {
  return parseConsentCookie(globalThis.document?.cookie);
}

export function canLoadProductAnalytics() {
  return consentAllowsAnalytics(currentConsentState());
}

export function canLoadTargetingAnalytics() {
  return consentAllowsTargeting(currentConsentState());
}

export function installAnalyticsConsentGate({ onConsentChange } = {}) {
  const emit = () => {
    if (typeof onConsentChange === "function") {
      onConsentChange(currentConsentState());
    }
  };

  emit();
  globalThis.addEventListener?.("consentChanged", emit);

  return {
    canLoadProductAnalytics,
    canLoadTargetingAnalytics,
    currentConsentState,
  };
}
