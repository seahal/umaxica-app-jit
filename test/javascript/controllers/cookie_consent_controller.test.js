import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

const { default: CookieConsentController } =
  await import("../../../app/javascript/controllers/cookie_consent_controller.js");

describe("CookieConsentController", () => {
  let controller;
  let bannerElement;

  beforeEach(() => {
    bannerElement = { classList: { add: vi.fn(), remove: vi.fn() } };
    controller = new CookieConsentController();
    controller.element = { querySelector: vi.fn(() => ({ content: "test-csrf" })) };
    controller.bannerTarget = bannerElement;
    controller.hasBannerTarget = true;
    controller.endpointValue = "/consent";

    vi.stubGlobal("document", {
      querySelector: vi.fn(() => ({ content: "test-csrf" })),
    });
    vi.stubGlobal("fetch", vi.fn());
    vi.stubGlobal("window", { dispatchEvent: vi.fn() });
  });

  describe("connect", () => {
    test("shows banner when not consented", () => {
      controller.consentedValue = false;
      controller.connect();
      expect(bannerElement.classList.remove).toHaveBeenCalledWith("hidden");
    });

    test("does not show banner when already consented", () => {
      controller.consentedValue = true;
      controller.connect();
      expect(bannerElement.classList.remove).not.toHaveBeenCalled();
    });

    test("does not show banner when target is missing", () => {
      controller.consentedValue = false;
      controller.hasBannerTarget = false;

      controller.connect();

      expect(bannerElement.classList.remove).not.toHaveBeenCalled();
    });
  });

  describe("showBanner/hideBanner", () => {
    test("showBanner removes hidden class", () => {
      controller.showBanner();
      expect(bannerElement.classList.remove).toHaveBeenCalledWith("hidden");
    });

    test("hideBanner adds hidden class", () => {
      controller.hideBanner();
      expect(bannerElement.classList.add).toHaveBeenCalledWith("hidden");
    });
  });

  describe("submitConsent", () => {
    test("accept prevents default and submits true", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ consented: true }),
      });
      const event = { preventDefault: vi.fn() };

      await controller.accept(event);

      expect(event.preventDefault).toHaveBeenCalledOnce();
      expect(fetch).toHaveBeenCalledWith(
        "/consent",
        expect.objectContaining({
          body: expect.stringContaining('"consented":true'),
        }),
      );
    });

    test("reject prevents default and submits false", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ consented: false }),
      });
      const event = { preventDefault: vi.fn() };

      await controller.reject(event);

      expect(event.preventDefault).toHaveBeenCalledOnce();
      expect(fetch).toHaveBeenCalledWith(
        "/consent",
        expect.objectContaining({
          body: expect.stringContaining('"consented":false'),
        }),
      );
    });

    test("accept sends true and hides banner on success", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ consented: true }),
      });

      await controller.submitConsent(true);

      expect(fetch).toHaveBeenCalledWith(
        "/consent",
        expect.objectContaining({
          method: "PATCH",
          body: expect.stringContaining('"consented":true'),
        }),
      );
      expect(bannerElement.classList.add).toHaveBeenCalledWith("hidden");
    });

    test("reject sends false and hides banner on success", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ consented: false }),
      });

      await controller.submitConsent(false);

      expect(fetch).toHaveBeenCalledWith(
        "/consent",
        expect.objectContaining({
          method: "PATCH",
          body: expect.stringContaining('"consented":false'),
        }),
      );
      expect(bannerElement.classList.add).toHaveBeenCalledWith("hidden");
    });

    test("dispatches consentChanged event on success", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ consented: true }),
      });

      await controller.submitConsent(true);

      expect(window.dispatchEvent).toHaveBeenCalledWith(
        expect.objectContaining({ type: "consentChanged" }),
      );
    });

    test("uses accepted value when response omits consented", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({}),
      });

      await controller.submitConsent(false);

      expect(window.dispatchEvent).toHaveBeenCalledWith(
        expect.objectContaining({
          detail: {},
          type: "consentChanged",
        }),
      );
    });

    test("uses fallback detail when response body is falsy", async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(""),
      });

      await controller.submitConsent(true);

      expect(window.dispatchEvent).toHaveBeenCalledWith(
        expect.objectContaining({
          detail: { consented: true },
          type: "consentChanged",
        }),
      );
    });

    test("handles error response", async () => {
      fetch.mockResolvedValue({ ok: false, status: 500 });
      const spy = vi.spyOn(controller, "dispatchError");

      await controller.submitConsent(true);

      expect(spy).toHaveBeenCalledWith("Consent update failed", { status: 500 });
    });

    test("handles network error", async () => {
      fetch.mockRejectedValue(new Error("Network error"));
      const spy = vi.spyOn(controller, "dispatchError");

      await controller.submitConsent(true);

      expect(spy).toHaveBeenCalledWith("Consent update error", expect.any(Object));
    });
  });

  describe("dispatchError", () => {
    test("dispatches error event with merged detail", () => {
      controller.dispatchError("Consent update failed", { status: 500 });

      expect(controller.dispatch).toHaveBeenCalledWith("error", {
        detail: { message: "Consent update failed", status: 500 },
      });
    });
  });
});
