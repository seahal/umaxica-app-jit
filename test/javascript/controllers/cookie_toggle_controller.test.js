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
});
