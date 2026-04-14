import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    connect() {}
  },
}));

let ThemeController;
let cookieReadValue;
let fetchMock;
let documentMock;
let windowMock;
let radioLookup;
let themeValueElement;
let matchMediaState;
let matchMediaListener;

const classListMock = {
  _store: new Set(),
  add(...classes) {
    classes.forEach((name) => this._store.add(name));
  },
  remove(...classes) {
    classes.forEach((name) => this._store.delete(name));
  },
  toggle(name, force) {
    if (force) {
      this._store.add(name);
    } else {
      this._store.delete(name);
    }
  },
  has(name) {
    return this._store.has(name);
  },
};

function makeController() {
  const controller = new ThemeController();
  controller.element = {
    querySelector: vi.fn((selector) => radioLookup[selector] ?? null),
  };
  return controller;
}

beforeEach(async () => {
  vi.resetModules();

  cookieReadValue = "";
  fetchMock = vi.fn();
  radioLookup = {};
  themeValueElement = null;
  matchMediaState = false;
  matchMediaListener = null;
  classListMock._store = new Set();

  documentMock = {
    get cookie() {
      return cookieReadValue;
    },
    documentElement: { dataset: {}, classList: classListMock },
    querySelector: vi.fn((selector) => {
      if (selector === "#js-theme-cookie-value") {
        return themeValueElement;
      }
      if (selector === 'meta[name="csrf-token"]') {
        return { content: "csrf-token" };
      }
      return null;
    }),
  };

  windowMock = {
    matchMedia: vi.fn(() => ({
      addEventListener: vi.fn((name, callback) => {
        if (name === "change") {
          matchMediaListener = callback;
        }
      }),
      get matches() {
        return matchMediaState;
      },
    })),
  };

  vi.stubGlobal("document", documentMock);
  vi.stubGlobal("window", windowMock);
  vi.stubGlobal("fetch", fetchMock);

  ({ default: ThemeController } =
    await import("../../../app/javascript/controllers/theme_controller.js"));
});

describe("ThemeController", () => {
  describe("connect", () => {
    test("delegates to fetchAndSyncTheme", () => {
      const controller = makeController();
      const spy = vi.spyOn(controller, "fetchAndSyncTheme").mockResolvedValue(undefined);

      controller.connect();

      expect(spy).toHaveBeenCalledOnce();
    });
  });

  describe("select", () => {
    test("maps dark, light, system, and unknown values to theme codes", async () => {
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({ theme: "dr" }),
      });
      const controller = makeController();

      await controller.select({ target: { value: "dark" } });
      await controller.select({ target: { value: "light" } });
      await controller.select({ target: { value: "system" } });
      await controller.select({ target: { value: "unknown" } });

      expect(fetchMock).toHaveBeenNthCalledWith(
        1,
        "/web/v0/theme",
        expect.objectContaining({ body: JSON.stringify({ theme: "dr" }) }),
      );
      expect(fetchMock).toHaveBeenNthCalledWith(
        2,
        "/web/v0/theme",
        expect.objectContaining({ body: JSON.stringify({ theme: "li" }) }),
      );
      expect(fetchMock).toHaveBeenNthCalledWith(
        3,
        "/web/v0/theme",
        expect.objectContaining({ body: JSON.stringify({ theme: "sy" }) }),
      );
      expect(fetchMock).toHaveBeenNthCalledWith(
        4,
        "/web/v0/theme",
        expect.objectContaining({ body: JSON.stringify({ theme: "sy" }) }),
      );
    });
  });

  describe("fetchAndSyncTheme", () => {
    test("syncs theme from API response", async () => {
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({ theme: "dr" }),
      });
      const controller = makeController();
      const syncSpy = vi.spyOn(controller, "syncRadioFromThemeCode");
      const applySpy = vi.spyOn(controller, "applyThemeFromCode");

      await controller.fetchAndSyncTheme();

      expect(syncSpy).toHaveBeenCalledWith("dr");
      expect(applySpy).toHaveBeenCalledWith("dr");
    });

    test("uses system fallback when API omits theme", async () => {
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({}),
      });
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="system"]');
      expect(documentMock.documentElement.dataset.theme).toBe("system");
    });

    test("falls back to cookie when request rejects", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));
      cookieReadValue = "ct=dr";
      const radio = { checked: false };
      radioLookup['input[value="dark"]'] = radio;
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(radio.checked).toBe(true);
      expect(documentMock.documentElement.dataset.theme).toBe("dark");
    });

    test("falls back to cookie when response is not ok", async () => {
      fetchMock.mockResolvedValue({ ok: false, status: 500 });
      cookieReadValue = "ct=li";
      const radio = { checked: false };
      radioLookup['input[value="light"]'] = radio;
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(radio.checked).toBe(true);
      expect(documentMock.documentElement.dataset.theme).toBe("light");
    });

    test("falls back to system theme when cookie value is blank", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));
      cookieReadValue = "ct=";
      themeValueElement = { textContent: "" };
      const radio = { checked: false };
      radioLookup['input[value="system"]'] = radio;
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(radio.checked).toBe(true);
      expect(documentMock.documentElement.dataset.theme).toBe("system");
      expect(themeValueElement.textContent).toBe("system");
    });

    test("falls back to custom lower-case theme when cookie is unknown", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));
      cookieReadValue = "ct=CUSTOM";
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(documentMock.documentElement.dataset.theme).toBe("custom");
      expect(classListMock.has("theme-custom")).toBe(true);
    });

    test("falls back to system theme when ct cookie is missing", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));
      cookieReadValue = "";
      const controller = makeController();

      await controller.fetchAndSyncTheme();

      expect(documentMock.documentElement.dataset.theme).toBe("system");
    });
  });

  describe("syncRadio", () => {
    test("checks dark, light, system, and fallback radios from cookie", () => {
      const dark = { checked: false };
      const light = { checked: false };
      const system = { checked: false };
      radioLookup['input[value="dark"]'] = dark;
      radioLookup['input[value="light"]'] = light;
      radioLookup['input[value="system"]'] = system;
      const controller = makeController();

      cookieReadValue = "ct=dr";
      controller.syncRadio();
      cookieReadValue = "ct=li";
      controller.syncRadio();
      cookieReadValue = "ct=sy";
      controller.syncRadio();
      cookieReadValue = "other=value";
      controller.syncRadio();

      expect(dark.checked).toBe(true);
      expect(light.checked).toBe(true);
      expect(system.checked).toBe(true);
    });

    test("does nothing when matching radio is missing", () => {
      cookieReadValue = "ct=dr";
      const controller = makeController();

      expect(() => controller.syncRadio()).not.toThrow();
    });
  });

  describe("syncRadioFromThemeCode", () => {
    test("checks radio for explicit and fallback theme codes", () => {
      const dark = { checked: false };
      const light = { checked: false };
      const system = { checked: false };
      radioLookup['input[value="dark"]'] = dark;
      radioLookup['input[value="light"]'] = light;
      radioLookup['input[value="system"]'] = system;
      const controller = makeController();

      controller.syncRadioFromThemeCode("dr");
      controller.syncRadioFromThemeCode("li");
      controller.syncRadioFromThemeCode("unknown");

      expect(dark.checked).toBe(true);
      expect(light.checked).toBe(true);
      expect(system.checked).toBe(true);
    });

    test("does nothing when matching radio is missing", () => {
      const controller = makeController();

      expect(() => controller.syncRadioFromThemeCode("dr")).not.toThrow();
    });
  });

  describe("applyThemeFromCode", () => {
    test("applies explicit theme and updates visible value", () => {
      themeValueElement = { textContent: "" };
      const controller = makeController();

      controller.applyThemeFromCode("dr");

      expect(documentMock.documentElement.dataset.theme).toBe("dark");
      expect(classListMock.has("dark")).toBe(true);
      expect(classListMock.has("theme-dark")).toBe(true);
      expect(themeValueElement.textContent).toBe("dark");
    });

    test("applies fallback system theme when code is unknown", () => {
      const controller = makeController();

      controller.applyThemeFromCode("unknown");

      expect(documentMock.documentElement.dataset.theme).toBe("system");
      expect(classListMock.has("theme-system")).toBe(true);
    });

    test("does not fail when visible value element is missing", () => {
      const controller = makeController();

      expect(() => controller.applyThemeFromCode("li")).not.toThrow();
      expect(classListMock.has("theme-light")).toBe(true);
    });

    test("registers one system theme listener and reacts to changes", () => {
      const controller = makeController();

      controller.applyThemeFromCode("sy");
      matchMediaState = true;
      matchMediaListener();

      expect(windowMock.matchMedia).toHaveBeenCalledWith("(prefers-color-scheme: dark)");
      expect(classListMock.has("dark")).toBe(true);
    });
  });

  describe("updateTheme", () => {
    test("patches theme, syncs radio, and applies returned theme", async () => {
      const radio = { checked: false };
      radioLookup['input[value="dark"]'] = radio;
      themeValueElement = { textContent: "" };
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({ theme: "dr" }),
      });
      const controller = makeController();

      await controller.updateTheme("dr");

      expect(fetchMock).toHaveBeenCalledWith(
        "/web/v0/theme",
        expect.objectContaining({
          method: "PATCH",
          headers: expect.objectContaining({ "X-CSRF-Token": "csrf-token" }),
          body: JSON.stringify({ theme: "dr" }),
        }),
      );
      expect(radio.checked).toBe(true);
      expect(themeValueElement.textContent).toBe("dark");
    });

    test("uses requested theme code when response omits it", async () => {
      const radio = { checked: false };
      radioLookup['input[value="light"]'] = radio;
      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => ({}),
      });
      const controller = makeController();

      await controller.updateTheme("li");

      expect(radio.checked).toBe(true);
      expect(classListMock.has("theme-light")).toBe(true);
    });

    test("throws when patch response is not ok", async () => {
      fetchMock.mockResolvedValue({ ok: false, status: 422 });
      const controller = makeController();

      await expect(controller.updateTheme("dr")).rejects.toThrow("HTTP error! status: 422");
    });
  });
});
