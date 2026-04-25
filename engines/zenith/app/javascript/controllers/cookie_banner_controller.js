import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // Connects to data-controller="cookie-banner"
  connect() {
    void this.checkConsentState();
  }

  async checkConsentState() {
    try {
      const consentState = await this.fetchCookieConsent();
      if (consentState && consentState.consented) {
        this.element.remove();
      }
    } catch {
      if (this.hasCookieConsent()) {
        this.element.remove();
      }
    }
  }

  normalizeConsentValue(value) {
    if (!value) {
      return null;
    }

    return value.toLowerCase();
  }

  // Handle invisible/close action
  invisible(event) {
    event.preventDefault();
    this.element.remove();
  }

  // Handle accept action
  async accept(event) {
    event.preventDefault();
    await this.submitConsent(true);
  }

  // Handle reject action
  async reject(event) {
    event.preventDefault();
    await this.submitConsent(false);
  }

  // Handle open settings action
  openSettings(event) {
    event.preventDefault();
    void this.dispatchSettingsEvent();
  }

  async dispatchSettingsEvent() {
    try {
      const consent = await this.fetchCookieConsent();
      this.dispatch("open-settings", { detail: { consent } });
    } catch {
      this.dispatch("open-settings", { detail: { consent: this.getCookieConsent() } });
    }
  }

  // Fetch cookie consent from API endpoint
  async fetchCookieConsent() {
    const response = await fetch("/web/v0/cookie");
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  }

  async submitConsent(consented) {
    const response = await fetch("/web/v0/cookie", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
      },
      body: JSON.stringify({ consented }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    this.element.remove();
  }

  // Helper: Get current cookie consent value
  getCookieConsent() {
    const name = "preference_consented=";
    const decodedCookie = decodeURIComponent(document.cookie);
    const cookies = decodedCookie.split(";");
    for (let cookie of cookies) {
      cookie = cookie.trim();
      if (cookie.indexOf(name) === 0) {
        const value = cookie.substring(name.length).trim();
        if (value === "1") {
          return { consented: true };
        }
        if (value === "0") {
          return { consented: false };
        }
      }
    }
    return null;
  }

  // Helper: Check if user has already provided consent
  hasCookieConsent() {
    return this.getCookieConsent() !== null;
  }
}
