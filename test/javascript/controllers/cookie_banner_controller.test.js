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
    vi.stubGlobal("window", { dispatchEvent: vi.fn() });
  });

  describe("connect", () => {
    test("delegates to checkConsentState", () => {
      const spy = vi.spyOn(controller, "checkConsentState").mockResolvedValue(undefined);

      controller.connect();

      expect(spy).toHaveBeenCalledOnce();
    });
  });

  describe("checkConsentState", () => {
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

    test("Cookie fallback では拒否済みでも要素を削除する", async () => {
      vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));
      cookieValue = "preference_consented=0";

      await controller.checkConsentState();

      expect(element.remove).toHaveBeenCalled();
    });

    test("Cookie fallback で consent cookie がない場合は要素を残す", async () => {
      vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));
      cookieValue = "foo=bar";

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

    test("openSettings: API 失敗時は cookie の値を使う", async () => {
      vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));
      cookieValue = "preference_consented=0";

      controller.openSettings(event);

      await vi.waitFor(() => {
        expect(controller.dispatch).toHaveBeenCalledWith("open-settings", {
          detail: { consent: { consented: false } },
        });
      });
    });
  });

  describe("helpers", () => {
    test("normalizeConsentValue: 値がない場合は null を返す", () => {
      expect(controller.normalizeConsentValue("")).toBeNull();
      expect(controller.normalizeConsentValue(null)).toBeNull();
    });

    test("normalizeConsentValue: 小文字化する", () => {
      expect(controller.normalizeConsentValue("TRUE")).toBe("true");
    });

    test("fetchCookieConsent: 非正常応答でエラーを投げる", async () => {
      vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, status: 500 }));

      await expect(controller.fetchCookieConsent()).rejects.toThrow("HTTP error! status: 500");
    });

    test("submitConsent: 非正常応答でエラーを投げる", async () => {
      vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, status: 422 }));

      await expect(controller.submitConsent(true)).rejects.toThrow("HTTP error! status: 422");
      expect(element.remove).not.toHaveBeenCalled();
    });

    test("getCookieConsent: false を返す", () => {
      cookieValue = "preference_consented=0";

      expect(controller.getCookieConsent()).toEqual({ consented: false });
    });

    test("getCookieConsent: 複数 cookie から対象値を見つける", () => {
      cookieValue = "foo=bar; preference_consented=1; baz=qux";

      expect(controller.getCookieConsent()).toEqual({ consented: true });
    });

    test("getCookieConsent: 不正な値では null を返す", () => {
      cookieValue = "preference_consented=maybe";

      expect(controller.getCookieConsent()).toBeNull();
      expect(controller.hasCookieConsent()).toBe(false);
    });
  });
});
