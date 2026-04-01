import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

// ──────────────────────────────────────────────
// DOM グローバルのモック
// ──────────────────────────────────────────────

let cookieReadValue = "";
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
  querySelector: vi.fn(() => null),
  addEventListener: vi.fn(),
};

const windowMock = { matchMedia: vi.fn(() => ({ matches: false, addEventListener: vi.fn() })) };

vi.stubGlobal("document", documentMock);
vi.stubGlobal("window", windowMock);

const { applyThemeFromCookie } = await import("../../app/javascript/theme_cookie.js");

beforeEach(() => {
  cookieReadValue = "";
  classListMock._store = new Set();
  windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
  documentMock.getElementById.mockReturnValue(null);
  documentMock.querySelector.mockReturnValue(null);
  documentMock.addEventListener.mockReset();
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
    const valueEl = { textContent: "" };
    documentMock.querySelector.mockReturnValue(valueEl);
    applyThemeFromCookie();
    expect(documentMock.querySelector).toHaveBeenCalledWith("#js-theme-cookie-value");
    expect(valueEl.textContent).toBe("light");
  });
});
