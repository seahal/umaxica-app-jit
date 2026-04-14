import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

// ──────────────────────────────────────────────
// DOM グローバルのモック
// ──────────────────────────────────────────────

let cookieReadValue = "";
let themeValueElement = null;
let matchMediaState = false;
let matchMediaListener = null;
const classListMock = {
  _store: new Set(),
  add(...cls) {
    cls.forEach((c) => this._store.add(c));
  },
  remove(...cls) {
    cls.forEach((c) => this._store.delete(c));
  },
  toggle(cls, force) {
    if (force) {
      this._store.add(cls);
    } else {
      this._store.delete(cls);
    }
  },
  has(cls) {
    return this._store.has(cls);
  },
};

const documentMock = {
  get cookie() {
    return cookieReadValue;
  },
  documentElement: { dataset: {}, classList: classListMock },
  getElementById: vi.fn(() => null),
  querySelector: vi.fn((selector) => {
    if (selector === "#js-theme-cookie-value") {
      return themeValueElement;
    }
    return null;
  }),
  addEventListener: vi.fn(),
};

const windowMock = {
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

let applyThemeFromCookie;

beforeEach(async () => {
  vi.resetModules();
  cookieReadValue = "";
  themeValueElement = null;
  matchMediaState = false;
  matchMediaListener = null;
  classListMock._store = new Set();
  windowMock.matchMedia.mockImplementation(() => ({
    addEventListener: vi.fn((name, callback) => {
      if (name === "change") {
        matchMediaListener = callback;
      }
    }),
    get matches() {
      return matchMediaState;
    },
  }));
  documentMock.getElementById.mockReturnValue(null);
  documentMock.querySelector.mockImplementation((selector) => {
    if (selector === "#js-theme-cookie-value") {
      return themeValueElement;
    }
    return null;
  });
  documentMock.addEventListener.mockReset();

  ({ applyThemeFromCookie } = await import("../../app/javascript/theme_cookie.js"));
});

describe("applyThemeFromCookie", () => {
  test("ct=dr のときダークテーマを適用する", () => {
    cookieReadValue = "ct=dr";
    applyThemeFromCookie();
    expect(documentMock.documentElement.dataset.theme).toBe("dark");
    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-dark")).toBe(true);
  });

  test("ct=li のときライトテーマを適用する", () => {
    cookieReadValue = "ct=li";
    applyThemeFromCookie();
    expect(documentMock.documentElement.dataset.theme).toBe("light");
    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-light")).toBe(true);
  });

  test("ct=sy のときシステムテーマを適用する (matches: false)", () => {
    cookieReadValue = "ct=sy";
    windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
    applyThemeFromCookie();
    expect(documentMock.documentElement.dataset.theme).toBe("system");
    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("ct=sy のときシステムテーマを適用する (matches: true)", () => {
    cookieReadValue = "ct=sy";
    windowMock.matchMedia.mockReturnValue({ matches: true, addEventListener: vi.fn() });
    applyThemeFromCookie();
    expect(documentMock.documentElement.dataset.theme).toBe("system");
    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("クッキーがない場合、システムテーマにフォールバックする", () => {
    cookieReadValue = "";
    applyThemeFromCookie();
    expect(documentMock.documentElement.dataset.theme).toBe("system");
  });

  test("js-theme-cookie-value 要素がある場合、テーマ値を設定する", () => {
    cookieReadValue = "ct=li";
    themeValueElement = { textContent: "" };
    applyThemeFromCookie();
    expect(documentMock.querySelector).toHaveBeenCalledWith("#js-theme-cookie-value");
    expect(themeValueElement.textContent).toBe("light");
  });

  test("未知の値はそのまま lower case で適用する", () => {
    cookieReadValue = "ct=CUSTOM";

    applyThemeFromCookie();

    expect(documentMock.documentElement.dataset.theme).toBe("custom");
  });

  test("システムテーマ変更時に dark クラスを更新する", () => {
    cookieReadValue = "ct=sy";

    applyThemeFromCookie();
    matchMediaState = true;
    matchMediaListener();

    expect(classListMock.has("dark")).toBe(true);
  });
});
