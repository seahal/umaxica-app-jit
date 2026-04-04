import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

const { default: CookieBannerController } =
  await import("../../../app/javascript/controllers/cookie_banner_controller.js");

describe("CookieBannerController", () => {
  let controller;
  let element;
  let cookieValue = "";

  beforeEach(() => {
    element = { remove: vi.fn() };
    controller = new CookieBannerController();
    controller.element = element;

    cookieValue = "";
    vi.stubGlobal("document", {
      get cookie() {
        return cookieValue;
      },
      set cookie(val) {
        cookieValue = val;
      },
      querySelector: vi.fn(() => ({ content: "test-csrf" })),
    });

    vi.stubGlobal("fetch", vi.fn());
  });

  describe("connect", () => {
    test("同意済みの場合、要素を削除する (API)", async () => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve({ consented: true }) }),
      );

      await controller.checkConsentState();
      expect(element.remove).toHaveBeenCalled();
    });

    test("同意済みの場合、要素を削除する (Cookie フォールバック)", async () => {
      vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));
      cookieValue = "preference_consented=1";

      await controller.checkConsentState();
      expect(element.remove).toHaveBeenCalled();
    });

    test("未同意の場合、要素を削除しない", async () => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve({ consented: false }) }),
      );

      await controller.checkConsentState();
      expect(element.remove).not.toHaveBeenCalled();
    });
  });

  describe("actions", () => {
    let event;
    beforeEach(() => {
      event = { preventDefault: vi.fn() };
    });

    test("invisible: 要素を削除する", () => {
      controller.invisible(event);
      expect(event.preventDefault).toHaveBeenCalled();
      expect(element.remove).toHaveBeenCalled();
    });

    test("accept: Rails endpoint を更新して要素を削除する", async () => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve({ consented: true }) }),
      );

      await controller.accept(event);
      expect(event.preventDefault).toHaveBeenCalled();
      expect(fetch).toHaveBeenCalledWith(
        "/web/v0/cookie",
        expect.objectContaining({
          method: "PATCH",
          body: JSON.stringify({ consented: true }),
        }),
      );
      expect(element.remove).toHaveBeenCalled();
    });

    test("reject: Rails endpoint を更新して要素を削除する", async () => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve({ consented: false }) }),
      );

      await controller.reject(event);
      expect(event.preventDefault).toHaveBeenCalled();
      expect(fetch).toHaveBeenCalledWith(
        "/web/v0/cookie",
        expect.objectContaining({
          method: "PATCH",
          body: JSON.stringify({ consented: false }),
        }),
      );
      expect(element.remove).toHaveBeenCalled();
    });

    test("openSettings: open-settings イベントをディスパッチする", async () => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve({ consented: true }) }),
      );

      controller.openSettings(event);
      expect(event.preventDefault).toHaveBeenCalled();

      await vi.waitFor(() => {
        expect(controller.dispatch).toHaveBeenCalledWith("open-settings", {
          detail: { consent: { consented: true } },
        });
      });
    });
  });
});
