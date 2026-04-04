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
let fetchMock;

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
  querySelector: vi.fn(() => null),
  addEventListener: vi.fn(),
};

const windowMock = { matchMedia: vi.fn(() => ({ matches: false, addEventListener: vi.fn() })) };

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
  documentMock.querySelector.mockReturnValue(null);
  documentMock.addEventListener.mockReset();
  fetchMock = vi.fn();

  vi.stubGlobal("document", documentMock);
  vi.stubGlobal("window", windowMock);
  vi.stubGlobal("location", { protocol: "https:" });
  vi.stubGlobal("fetch", fetchMock);
});

// ──────────────────────────────────────────────
// connect
// ──────────────────────────────────────────────

describe("connect", () => {
  test("syncRadio を呼ぶ", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Failed")));
    const controller = makeController();
    const spy = vi.spyOn(controller, "syncRadio");
    controller.connect();
    await vi.waitFor(() => {
      expect(spy).toHaveBeenCalledOnce();
    });
  });
});

// ──────────────────────────────────────────────
// select
// ──────────────────────────────────────────────

describe("select", () => {
  test('"dark" を PATCH /web/v0/theme に送る', async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "dr" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "dark" } });

    expect(fetchMock).toHaveBeenCalledWith(
      "/web/v0/theme",
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ theme: "dr" }),
      }),
    );
  });

  test('"light" を PATCH /web/v0/theme に送る', async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "li" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "light" } });
    expect(fetchMock).toHaveBeenCalledWith(
      "/web/v0/theme",
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ theme: "li" }),
      }),
    );
  });

  test('"system" を PATCH /web/v0/theme に送る', async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "system" } });
    expect(fetchMock).toHaveBeenCalledWith(
      "/web/v0/theme",
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ theme: "sy" }),
      }),
    );
  });

  test("未知の値はデフォルトで theme=sy を送る", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "unknown" } });
    expect(fetchMock).toHaveBeenCalledWith(
      "/web/v0/theme",
      expect.objectContaining({
        body: JSON.stringify({ theme: "sy" }),
      }),
    );
  });

  test("select は JS から ct クッキーを書かない", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "dr" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "dark" } });
    expect(cookieWritten).toEqual([]);
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
  test("theme=dr 応答でダークテーマを適用する", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "dr" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "dark" } });

    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-dark")).toBe(true);
  });

  test("theme=li 応答でライトテーマを適用する", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "li" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "light" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-light")).toBe(true);
  });

  test("theme=sy 応答でシステムテーマを適用する (matches: false)", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
    const controller = makeController();
    await controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("theme=sy 応答でシステムテーマを適用する (matches: true)", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    windowMock.matchMedia.mockReturnValue({ matches: true, addEventListener: vi.fn() });
    const controller = makeController();
    await controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(true);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("theme=sy 応答でシステムデフォルトを適用する", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    windowMock.matchMedia.mockReturnValue({ matches: false, addEventListener: vi.fn() });
    const controller = makeController();
    await controller.select({ target: { value: "system" } });

    expect(classListMock.has("dark")).toBe(false);
    expect(classListMock.has("theme-system")).toBe(true);
  });

  test("html.dataset.theme に正しい値が設定される", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "dr" }),
    });
    const controller = makeController();
    await controller.select({ target: { value: "dark" } });

    expect(documentMock.documentElement.dataset.theme).toBe("dark");
  });

  test("js-theme-cookie-value 要素がある場合、テーマ値を設定する", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "li" }),
    });
    const valueEl = { textContent: "" };
    documentMock.querySelector.mockReturnValue(valueEl);
    const controller = makeController();
    await controller.select({ target: { value: "light" } });

    expect(documentMock.querySelector).toHaveBeenCalledWith("#js-theme-cookie-value");
    expect(valueEl.textContent).toBe("light");
  });

  test("js-theme-cookie-value 要素がない場合、エラーにならない", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "dr" }),
    });
    documentMock.querySelector.mockReturnValue(null);
    const controller = makeController();

    await expect(controller.select({ target: { value: "dark" } })).resolves.toBeUndefined();
  });

  test("システムテーマが選択されると matchMedia が呼ばれる", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ theme: "sy" }),
    });
    const matchMediaMock = vi.fn(() => ({ matches: false, addEventListener: vi.fn() }));
    windowMock.matchMedia = matchMediaMock;
    const controller = makeController();

    await controller.select({ target: { value: "system" } });
    expect(matchMediaMock).toHaveBeenCalledWith("(prefers-color-scheme: dark)");
  });
});
