import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // Connects to data-controller="cookie-banner"
  connect() {
    if (this.hasCookieConsent()) {
      this.element.remove();
    }
  }

  // Handle invisible/close action
  invisible(event) {
    event.preventDefault();
    this.element.remove();
  }

  // Handle accept action
  accept(event) {
    event.preventDefault();
    this.setCookieConsent("accepted");
    this.element.remove();
  }

  // Handle reject action
  reject(event) {
    event.preventDefault();
    this.setCookieConsent("rejected");
    this.element.remove();
  }

  // Handle open settings action
  openSettings(event) {
    event.preventDefault();
    // Dispatch a custom event that can be handled by a settings modal controller
    this.dispatch("open-settings", { detail: { consent: this.getCookieConsent() } });
  }

  // Helper: Set cookie consent preference
  setCookieConsent(value) {
    const expires = new Date();
    expires.setFullYear(expires.getFullYear() + 1);
    document.cookie = `cookie_consent=${value}; expires=${expires.toUTCString()}; path=/`;
  }

  // Helper: Get current cookie consent value
  getCookieConsent() {
    const name = "cookie_consent=";
    const decodedCookie = decodeURIComponent(document.cookie);
    const cookies = decodedCookie.split(";");
    for (let cookie of cookies) {
      cookie = cookie.trim();
      if (cookie.indexOf(name) === 0) {
        return cookie.substring(name.length);
      }
    }
    return null;
  }

  // Helper: Check if user has already provided consent
  hasCookieConsent() {
    return this.getCookieConsent() !== null;
  }
}
