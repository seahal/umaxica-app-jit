import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

const { default: ThemeToggleController } =
  await import("../../../app/javascript/controllers/theme_toggle_controller.js");

describe("ThemeToggleController", () => {
  let controller;
  let element;
  let fetchMock;
  let dispatchEventMock;

  beforeEach(() => {
    element = {};
    controller = new ThemeToggleController();
    controller.element = element;
    controller.currentValue = "sy";
    controller.endpointValue = "/web/v0/theme";

    fetchMock = vi.fn();
    dispatchEventMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
    vi.stubGlobal("window", { dispatchEvent: dispatchEventMock });
    vi.stubGlobal("document", {
      querySelector: vi.fn(() => ({ content: "test-csrf" })),
    });
  });

  describe("connect", () => {
    test("currentValue がない場合は system にする", () => {
      controller = new ThemeToggleController();
      controller.element = element;
      controller.currentValue = undefined;
      controller.connect();
      expect(controller.currentTheme).toBe("sy");
    });

    test("currentValue があるはその値にする", () => {
      controller = new ThemeToggleController();
      controller.element = element;
      controller.currentValue = "dr";
      controller.connect();
      expect(controller.currentTheme).toBe("dr");
    });
  });

  describe("toggle", () => {
    test("theme が同じ場合は何もしない", () => {
      controller.currentTheme = "dr";
      const event = { currentTarget: { dataset: { theme: "dr" } } };
      controller.toggle(event);
      expect(fetchMock).not.toHaveBeenCalled();
    });

    test("theme がない場合は何もしない", () => {
      const event = { currentTarget: { dataset: {}, value: "" } };
      controller.toggle(event);
      expect(fetchMock).not.toHaveBeenCalled();
    });

    test("valid theme の場合は updateTheme を呼ぶ", () => {
      controller.currentTheme = "sy";
      const event = { currentTarget: { dataset: { theme: "dr" } } };
      const updateThemeSpy = vi.spyOn(controller, "updateTheme");
      controller.toggle(event);
      expect(updateThemeSpy).toHaveBeenCalledWith("dr");
    });

    test("value から theme を取得する", () => {
      controller.currentTheme = "sy";
      const event = { currentTarget: { dataset: {}, value: "li" } };
      const updateThemeSpy = vi.spyOn(controller, "updateTheme");
      controller.toggle(event);
      expect(updateThemeSpy).toHaveBeenCalledWith("li");
    });
  });

  describe("updateTheme", () => {
    test("成功時: currentTheme を更新しイベントをディスパッチ", async () => {
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({ preference: { ct: "dr" } }),
      });

      await controller.updateTheme("dr");

      expect(controller.currentTheme).toBe("dr");
      expect(dispatchEventMock).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "themeChanged",
          detail: { ct: "dr" },
        }),
      );
    });

    test("成功時: レスポンスに preference がない場合は 引数の theme を使用", async () => {
      fetchMock.mockResolvedValue({
        ok: true,
        json: () => ({}),
      });

      await controller.updateTheme("li");

      expect(controller.currentTheme).toBe("li");
    });

    test("失敗時: dispatchError を呼ぶ", async () => {
      fetchMock.mockResolvedValue({ ok: false, status: 500 });

      await controller.updateTheme("dr");

      expect(controller.dispatch).toHaveBeenCalledWith("error", {
        detail: expect.objectContaining({ message: "Theme update failed" }),
      });
    });

    test("例外発生時: dispatchError を呼ぶ", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));

      await controller.updateTheme("dr");

      expect(controller.dispatch).toHaveBeenCalledWith("error", {
        detail: expect.objectContaining({ message: "Theme update error" }),
      });
    });
  });

  describe("dispatchError", () => {
    test("error イベントをディスパッチする", () => {
      controller.dispatchError("Test error", { status: 400 });
      expect(controller.dispatch).toHaveBeenCalledWith("error", {
        detail: { message: "Test error", status: 400 },
      });
    });
  });
});
