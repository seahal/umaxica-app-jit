import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  // eslint-disable-next-line @typescript-eslint/no-extraneous-class
  Controller: class {
    connect() {}
  },
}));

const { default: ThemeController } =
  await import("../../../app/javascript/controllers/theme_controller.js");

// ──────────────────────────────────────────────
// DOM グローバルのモック
// ──────────────────────────────────────────────

let cookieReadValue = "";
let cookieWritten = [];

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
  set cookie(val) {
    cookieWritten.push(val);
  },
  documentElement: { dataset: {}, classList: classListMock },
  getElementById: vi.fn(() => null),
  addEventListener: vi.fn(),
};

const windowMock = {
  matchMedia: vi.fn(() => ({
    matches: false,
    addEventListener: vi.fn(),
  })),
};

function makeController() {
  const controller = new ThemeController();
  controller.element = { querySelector: vi.fn() };
  return controller;
}

beforeEach(() => {
  cookieReadValue = "";
  cookieWritten = [];
  classListMock._store = new Set();
  windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
  documentMock.getElementById.mockReturnValue(null);
  documentMock.addEventListener.mockReset();

  vi.stubGlobal("document", documentMock);
  vi.stubGlobal("window", windowMock);
  vi.stubGlobal("location", { protocol: "https:" });
});

// ──────────────────────────────────────────────
// connect
// ──────────────────────────────────────────────

describe("connect", () => {
  test("syncRadio を呼ぶ", () => {
    const controller = makeController();
    const spy = vi.spyOn(controller, "syncRadio");
    controller.connect();
    expect(spy).toHaveBeenCalledOnce();
  });
});

// ──────────────────────────────────────────────
// select
// ──────────────────────────────────────────────

describe("select", () => {
  test('"dark" → ct=dr クッキーを設定する', () => {
    const controller = makeController();
    controller.select({ target: { value: "dark" } });
    expect(cookieWritten).toContain("ct=dr; path=/; max-age=31536000; samesite=lax; secure");
  });

  test('"light" → ct=li クッキーを設定する', () => {
    const controller = makeController();
    controller.select({ target: { value: "light" } });
    expect(cookieWritten).toContain("ct=li; path=/; max-age=31536000; samesite=lax; secure");
  });

  test('"system" → ct=sy クッキーを設定する', () => {
    const controller = makeController();
    controller.select({ target: { value: "system" } });
    expect(cookieWritten).toContain("ct=sy; path=/; max-age=31536000; samesite=lax; secure");
  });

  test("未知の値はデフォルトで ct=sy になる", () => {
    const controller = makeController();
    controller.select({ target: { value: "unknown" } });
    expect(cookieWritten).toContain("ct=sy; path=/; max-age=31536000; samesite=lax; secure");
  });

  test("https のとき secure フラグが付く", () => {
    const controller = makeController();
    controller.select({ target: { value: "dark" } });
    expect(cookieWritten[0]).toMatch(/; secure$/);
  });

  test("http のとき secure フラグが付かない", () => {
    vi.stubGlobal("location", { protocol: "http:" });
    const controller = makeController();
    controller.select({ target: { value: "dark" } });
    expect(cookieWritten[0]).not.toMatch(/; secure$/);
  });
});

// ──────────────────────────────────────────────
// syncRadio
// ──────────────────────────────────────────────

describe("syncRadio", () => {
  test('ct=dr のとき radio[value="dark"] をチェックする', () => {
    cookieReadValue = "ct=dr";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="dark"]');
    expect(radio.checked).toBe(true);
  });

  test('ct=li のとき radio[value="light"] をチェックする', () => {
    cookieReadValue = "ct=li";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="light"]');
    expect(radio.checked).toBe(true);
  });

  test('ct=sy のとき radio[value="system"] をチェックする', () => {
    cookieReadValue = "ct=sy";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="system"]');
    expect(radio.checked).toBe(true);
  });

  test("ct クッキーがない場合は system にフォールバックする", () => {
    cookieReadValue = "other=value";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="system"]');
    expect(radio.checked).toBe(true);
  });

  test("クッキーが空の場合は system にフォールバックする", () => {
    cookieReadValue = "";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="system"]');
  });

  test("対応する radio がない場合はエラーにならない", () => {
    cookieReadValue = "ct=dr";
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(null);
    expect(() => controller.syncRadio()).not.toThrow();
  });

  test("複数クッキーがある場合も ct を正しく読む", () => {
    cookieReadValue = "foo=bar; ct=li; baz=qux";
    const radio = { checked: false };
    const controller = makeController();
    controller.element.querySelector.mockReturnValue(radio);
    controller.syncRadio();
    expect(controller.element.querySelector).toHaveBeenCalledWith('input[value="light"]');
  });
});

// ──────────────────────────────────────────────
// applyThemeFromCookie (統合テスト)
// ──────────────────────────────────────────────

describe("applyThemeFromCookie (統合テスト)", () => {
  test("ct=dr クッキーでダークテーマを適用する", () => {
    cookieReadValue = "ct=dr";
    const controller = makeController();
    controller.select({ target: { value: "dark" } });

    // select した時点でクッキーが書き込まれ、applyThemeFromCookie が呼ばれる
    // classListMock に dark クラスが追加されているか確認
    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-dark")).toBe(true);
  });

  test("ct=li クッキーでライトテーマを適用する", () => {
    cookieReadValue = "ct=li";
    const controller = makeController();
    controller.select({ target: { value: "light" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-light")).toBe(true);
  });

  test("ct=sy クッキーでシステムテーマを適用する (matches: false)", () => {
    cookieReadValue = "ct=sy";
    windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
    const controller = makeController();
    controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("ct=sy クッキーでシステムテーマを適用する (matches: true)", () => {
    cookieReadValue = "ct=sy";
    windowMock.matchMedia.mockReturnValue({ matches: true, addEventListener: vi.fn() });
    const controller = makeController();
    controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("クッキーがない場合のテーマはシステムデフォルト", () => {
    cookieReadValue = "";
    windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
    const controller = makeController();
    controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("html.dataset.theme に正しい値が設定される", () => {
    cookieReadValue = "ct=dr";
    const controller = makeController();
    controller.select({ target: { value: "dark" } });

    expect(documentMock.documentElement.dataset.theme).toBe("dark");
  });

  test("js-theme-cookie-value 要素がある場合、テーマ値を設定する", () => {
    cookieReadValue = "ct=li";
    const valueEl = { textContent: "" };
    documentMock.getElementById.mockReturnValue(valueEl);
    const controller = makeController();
    controller.select({ target: { value: "light" } });

    expect(documentMock.getElementById).toHaveBeenCalledWith("js-theme-cookie-value");
    expect(valueEl.textContent).toBe("light");
  });

  test("js-theme-cookie-value 要素がない場合、エラーにならない", () => {
    cookieReadValue = "ct=dr";
    documentMock.getElementById.mockReturnValue(null);
    const controller = makeController();

    expect(() => controller.select({ target: { value: "dark" } })).not.toThrow();
  });

  test("システムテーマが選択されると matchMedia が呼ばれる", () => {
    cookieReadValue = "ct=sy";
    const matchMediaMock = vi.fn(() => ({
      matches: false,
      addEventListener: vi.fn(),
    }));
    windowMock.matchMedia = matchMediaMock;
    const controller = makeController();

    controller.select({ target: { value: "system" } });
    expect(matchMediaMock).toHaveBeenCalledWith("(prefers-color-scheme: dark)");
  });
});
