import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    constructor() {
      this.checkboxTargets = [];
      this.statusTarget = { textContent: "" };
      this.hasStatusTarget = false;
      this.element = { querySelector: vi.fn() };
    }

    connect() {}
  },
}));

const { default: CookieToggleController } =
  await import("../../../app/javascript/controllers/cookie_toggle_controller.js");

describe("CookieToggleController", () => {
  let controller;

  beforeEach(() => {
    controller = new CookieToggleController();
    vi.stubGlobal("fetch", vi.fn());
  });

  test("connect: updateStatus と setupFormListener を呼ぶ", () => {
    const updateSpy = vi.spyOn(controller, "updateStatus");
    const setupSpy = vi.spyOn(controller, "setupFormListener");

    controller.connect();

    expect(updateSpy).toHaveBeenCalledOnce();
    expect(setupSpy).toHaveBeenCalledOnce();
  });

  test("setupFormListener: form がある場合に turbo:submit-end を購読する", async () => {
    const listenerMap = new Map();
    const form = {
      addEventListener: vi.fn((name, handler) => {
        listenerMap.set(name, handler);
      }),
    };
    controller.element.querySelector.mockReturnValue(form);
    const submitSpy = vi.spyOn(controller, "onFormSubmitEnd").mockResolvedValue(undefined);

    controller.setupFormListener();
    await listenerMap.get("turbo:submit-end")({ detail: { success: true } });

    expect(form.addEventListener).toHaveBeenCalledWith("turbo:submit-end", expect.any(Function));
    expect(submitSpy).toHaveBeenCalledWith({ detail: { success: true } });
  });

  test("setupFormListener: form がない場合は何もしない", () => {
    controller.element.querySelector.mockReturnValue(null);

    expect(() => controller.setupFormListener()).not.toThrow();
  });

  test("updateStatus: チェックボックスの数に応じてステータスを更新する", () => {
    const cb1 = { checked: true };
    const cb2 = { checked: false };
    controller.checkboxTargets = [cb1, cb2];
    controller.statusTarget = { textContent: "" };
    controller.hasStatusTarget = true;

    controller.updateStatus();
    expect(controller.statusTarget.textContent).toBe("1 / 2 cookies enabled");
  });

  test("toggle: ステータスを更新する", () => {
    const spy = vi.spyOn(controller, "updateStatus");
    controller.toggle({});
    expect(spy).toHaveBeenCalled();
  });

  test("syncCheckboxesFromAPI: API の結果からチェックボックスを同期する", () => {
    const functionalCb = { checked: false };
    controller.element.querySelector.mockImplementation((selector) => {
      if (selector === 'input[name="preference_cookie[functional]"]') {
        return functionalCb;
      }
      return null;
    });

    controller.syncCheckboxesFromAPI({ functional: true });
    expect(functionalCb.checked).toBe(true);
  });

  test("onFormSubmitEnd: 成功時に API から同期する", async () => {
    const consent = { functional: true };
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve(consent) }),
    );

    const syncSpy = vi.spyOn(controller, "syncCheckboxesFromAPI");
    const updateSpy = vi.spyOn(controller, "updateStatus");

    const event = { detail: { success: true } };
    await controller.onFormSubmitEnd(event);

    expect(syncSpy).toHaveBeenCalledWith(consent);
    expect(updateSpy).toHaveBeenCalled();
  });

  test("onFormSubmitEnd: 失敗時は updateStatus のみ", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));

    const updateSpy = vi.spyOn(controller, "updateStatus");

    const event = { detail: { success: true } };
    await controller.onFormSubmitEnd(event);

    expect(updateSpy).toHaveBeenCalled();
  });

  test("onFormSubmitEnd: API が null を返すと同期しない", async () => {
    const syncSpy = vi.spyOn(controller, "syncCheckboxesFromAPI");
    const updateSpy = vi.spyOn(controller, "updateStatus");
    vi.spyOn(controller, "fetchCookieConsent").mockResolvedValue(null);

    await controller.onFormSubmitEnd({ detail: { success: true } });

    expect(syncSpy).not.toHaveBeenCalled();
    expect(updateSpy).not.toHaveBeenCalled();
  });

  test("onFormSubmitEnd: success=false の場合は何もしない", async () => {
    const fetchSpy = vi.spyOn(controller, "fetchCookieConsent");

    const event = { detail: { success: false } };
    await controller.onFormSubmitEnd(event);

    expect(fetchSpy).not.toHaveBeenCalled();
  });

  test("syncCheckboxesFromAPI: すべてのフィールドを同期する", () => {
    const checkboxMap = {
      functional: { checked: false },
      performant: { checked: false },
      targetable: { checked: false },
      consented: { checked: false },
    };

    controller.element.querySelector.mockImplementation((selector) => {
      if (selector.includes("functional")) {
        return checkboxMap.functional;
      }
      if (selector.includes("performant")) {
        return checkboxMap.performant;
      }
      if (selector.includes("targetable")) {
        return checkboxMap.targetable;
      }
      if (selector.includes("consented")) {
        return checkboxMap.consented;
      }
      return null;
    });

    controller.syncCheckboxesFromAPI({
      functional: true,
      performant: true,
      targetable: false,
      consented: true,
    });

    expect(checkboxMap.functional.checked).toBe(true);
    expect(checkboxMap.performant.checked).toBe(true);
    expect(checkboxMap.targetable.checked).toBe(false);
    expect(checkboxMap.consented.checked).toBe(true);
  });

  test("syncCheckboxesFromAPI: 存在しないチェックボックスは無視", () => {
    controller.element.querySelector.mockReturnValue(null);

    expect(() => {
      controller.syncCheckboxesFromAPI({ functional: true });
    }).not.toThrow();
  });

  test("fetchCookieConsent: 成功时应答を返す", async () => {
    const consent = { consented: true };
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: true, json: () => Promise.resolve(consent) }),
    );

    const result = await controller.fetchCookieConsent();
    expect(result).toEqual(consent);
  });

  test("fetchCookieConsent: 失敗時にエラーを投げる", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, status: 500 }));

    await expect(controller.fetchCookieConsent()).rejects.toThrow();
  });

  test("updateStatus: statusTarget がない場合は何もしない", () => {
    controller.checkboxTargets = [{ checked: true }];
    controller.hasStatusTarget = false;

    expect(() => controller.updateStatus()).not.toThrow();
  });
});
