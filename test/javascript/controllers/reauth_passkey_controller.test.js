import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    constructor() {
      this.challengeIdTarget = { value: "" };
      this.credentialJsonTarget = { value: "" };
      this.errorTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
      this.statusTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
      this.hasErrorTarget = true;
      this.hasStatusTarget = true;
      this.element = { closest: vi.fn(() => ({ requestSubmit: vi.fn() })) };
    }

    connect() {}
  },
}));

vi.mock("controllers/webauthn_utils", () => ({ normalizePublicKeyOptions: vi.fn((opt) => opt) }));

const { default: ReauthPasskeyController } =
  await import("../../../app/javascript/controllers/reauth_passkey_controller.js");

describe("ReauthPasskeyController", () => {
  let controller;

  beforeEach(() => {
    controller = new ReauthPasskeyController();
    controller.optionsValue = JSON.stringify({ challenge: "abc" });
    controller.challengeIdValue = "challenge-123";

    vi.stubGlobal("window", { PublicKeyCredential: true });
    vi.stubGlobal("navigator", { credentials: { get: vi.fn() } });
    vi.stubGlobal("btoa", (str) => Buffer.from(str, "binary").toString("base64"));
  });

  test("authenticate: 成功時にフォームを送信する", async () => {
    const mockCredential = {
      id: "cred-id",
      rawId: new Uint8Array([1, 2, 3]).buffer,
      type: "public-key",
      response: {
        clientDataJSON: new Uint8Array([4, 5, 6]).buffer,
        authenticatorData: new Uint8Array([7, 8, 9]).buffer,
        signature: new Uint8Array([10, 11, 12]).buffer,
        userHandle: null,
      },
      getClientExtensionResults: () => ({}),
    };
    navigator.credentials.get.mockResolvedValue(mockCredential);

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.credentialJsonTarget.value).toContain('"id":"cred-id"');
    expect(controller.challengeIdTarget.value).toBe("challenge-123");
    expect(controller.element.closest).toHaveBeenCalledWith("form");
  });

  test("authenticate: NotAllowedError のときに適切なエラーメッセージを表示する", async () => {
    const error = new Error("Cancelled");
    error.name = "NotAllowedError";
    navigator.credentials.get.mockRejectedValue(error);

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("認証がキャンセルされました");
  });

  test("authenticate: WebAuthn 未対応時にエラーを表示する", async () => {
    window.PublicKeyCredential = false;

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("このブラウザはPasskeyに対応していません");
  });

  test("authenticate: optionsValue がない場合エラーを表示", async () => {
    controller.optionsValue = "";

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("認証オプションの取得に失敗しました");
  });

  test("authenticate: challengeIdValue がない場合エラーを表示", async () => {
    controller.challengeIdValue = "";

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("認証オプションの取得に失敗しました");
  });

  test("authenticate: 不正な JSON の場合はエラーを表示", async () => {
    controller.optionsValue = "{";

    await controller.authenticate({ preventDefault: vi.fn() });

    expect(controller.errorTarget.textContent).toContain("Expected property name");
  });

  test("authenticate: SecurityError のときに適切なエラーメッセージを表示", async () => {
    const error = new Error("Security error");
    error.name = "SecurityError";
    navigator.credentials.get.mockRejectedValue(error);

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("セキュリティエラーが発生しました");
  });

  test("authenticate: その他のエラーのときにメッセージを表示", async () => {
    const error = new Error("Some other error");
    navigator.credentials.get.mockRejectedValue(error);

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("Some other error");
  });

  test("authenticate: メッセージがないエラーの場合デフォルトメッセージ", async () => {
    navigator.credentials.get.mockRejectedValue(new Error());

    const event = { preventDefault: vi.fn() };
    await controller.authenticate(event);

    expect(controller.errorTarget.textContent).toBe("認証中にエラーが発生しました");
  });

  test("encodeCredential: credential を正しくエンコード", () => {
    const credential = {
      id: "test-id",
      rawId: new Uint8Array([1, 2, 3]).buffer,
      type: "public-key",
      authenticatorAttachment: "platform",
      response: {
        clientDataJSON: new Uint8Array([4, 5, 6]).buffer,
        authenticatorData: new Uint8Array([7, 8, 9]).buffer,
        signature: new Uint8Array([10, 11, 12]).buffer,
        userHandle: new Uint8Array([13, 14, 15]).buffer,
      },
      getClientExtensionResults: () => ({ largeBlob: true }),
    };

    const result = controller.encodeCredential(credential);

    expect(result.id).toBe("test-id");
    expect(result.type).toBe("public-key");
    expect(result.authenticatorAttachment).toBe("platform");
    expect(result.clientExtensionResults).toEqual({ largeBlob: true });
  });

  test("encodeCredential: userHandle が null の場合", () => {
    const credential = {
      id: "test-id",
      rawId: new Uint8Array([1, 2, 3]).buffer,
      type: "public-key",
      authenticatorAttachment: null,
      response: {
        clientDataJSON: new Uint8Array([4, 5, 6]).buffer,
        authenticatorData: new Uint8Array([7, 8, 9]).buffer,
        signature: new Uint8Array([10, 11, 12]).buffer,
        userHandle: null,
      },
      getClientExtensionResults: () => ({}),
    };

    const result = controller.encodeCredential(credential);

    expect(result.response.userHandle).toBeNull();
    expect(result.authenticatorAttachment).toBeNull();
  });

  test("bufferToBase64url: ArrayBuffer を base64url に変換", () => {
    const { buffer } = new Uint8Array([72, 101, 108, 108, 111]);
    const result = controller.bufferToBase64url(buffer);
    expect(result).toBe("SGVsbG8");
  });

  test("showError: メッセージを設定し status を隠す", () => {
    controller.hasErrorTarget = true;
    controller.hasStatusTarget = true;
    controller.showError("Test error");
    expect(controller.errorTarget.textContent).toBe("Test error");
    expect(controller.errorTarget.classList.remove).toHaveBeenCalledWith("hidden");
    expect(controller.statusTarget.classList.add).toHaveBeenCalledWith("hidden");
  });

  test("showStatus: メッセージを設定し表示する", () => {
    controller.hasStatusTarget = true;
    controller.showStatus("Loading...");
    expect(controller.statusTarget.textContent).toBe("Loading...");
    expect(controller.statusTarget.classList.remove).toHaveBeenCalledWith("hidden");
  });

  test("showError/showStatus/clearMessages: ターゲットがなくても失敗しない", () => {
    controller.hasErrorTarget = false;
    controller.hasStatusTarget = false;

    expect(() => controller.showError("error")).not.toThrow();
    expect(() => controller.showStatus("status")).not.toThrow();
    expect(() => controller.clearMessages()).not.toThrow();
  });

  test("clearMessages: 両方のターゲットをリセット", () => {
    controller.hasErrorTarget = true;
    controller.hasStatusTarget = true;
    controller.clearMessages();
    expect(controller.errorTarget.textContent).toBe("");
    expect(controller.statusTarget.textContent).toBe("");
    expect(controller.errorTarget.classList.add).toHaveBeenCalledWith("hidden");
    expect(controller.statusTarget.classList.add).toHaveBeenCalledWith("hidden");
  });
});
