import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

vi.mock("controllers/webauthn_utils", () => ({
  normalizePublicKeyOptions: vi.fn((opts) => opts),
}));

const { default: PasskeyAuthenticationController } =
  await import("../../../app/javascript/controllers/passkey_authentication_controller.js");

describe("PasskeyAuthenticationController", () => {
  let controller;
  let errorTarget;
  let statusTarget;
  let identifierTarget;

  beforeEach(() => {
    errorTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    statusTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    identifierTarget = { value: "test@example.com" };

    controller = new PasskeyAuthenticationController();
    controller.element = {
      appendChild: vi.fn(),
      querySelector: vi.fn(() => ({ content: "csrf-token" })),
    };
    controller.errorTarget = errorTarget;
    controller.statusTarget = statusTarget;
    controller.identifierTarget = identifierTarget;
    controller.hasErrorTarget = true;
    controller.hasStatusTarget = true;
    controller.hasIdentifierTarget = true;
    controller.hasTurnstileResponseTarget = false;
    controller.optionsUrlValue = "/passkeys/options";
    controller.verificationUrlValue = "/passkeys/verify";
    controller.identifierParamValue = "email";
    controller.turnstileSiteKeyValue = "";
    controller.turnstileErrorMessageValue = "Security verification failed";

    vi.stubGlobal("document", {
      querySelector: vi.fn(() => ({ content: "csrf-token" })),
      head: { appendChild: vi.fn() },
    });
    vi.stubGlobal("fetch", vi.fn());
    vi.stubGlobal("navigator", { credentials: { get: vi.fn() } });
    vi.stubGlobal("window", { PublicKeyCredential: true, location: { reload: vi.fn(), href: "" } });
  });

  describe("authenticate", () => {
    test("shows error when PublicKeyCredential is not available", async () => {
      window.PublicKeyCredential = undefined;
      const event = { preventDefault: vi.fn() };

      await controller.authenticate(event);

      expect(errorTarget.textContent).toBe("このブラウザはPasskeyに対応していません");
    });

    test("shows error when identifier is empty", async () => {
      identifierTarget.value = "";
      const event = { preventDefault: vi.fn() };

      await controller.authenticate(event);

      expect(errorTarget.textContent).toBe("メールアドレスまたはIDを入力してください");
    });
  });

  describe("showError/showStatus/clearMessages", () => {
    test("showError sets error text and hides status", () => {
      controller.showError("Test error");
      expect(errorTarget.textContent).toBe("Test error");
      expect(errorTarget.classList.remove).toHaveBeenCalledWith("hidden");
      expect(statusTarget.classList.add).toHaveBeenCalledWith("hidden");
    });

    test("showStatus sets status text and shows it", () => {
      controller.showStatus("Loading...");
      expect(statusTarget.textContent).toBe("Loading...");
      expect(statusTarget.classList.remove).toHaveBeenCalledWith("hidden");
    });

    test("clearMessages resets both targets", () => {
      errorTarget.textContent = "error";
      statusTarget.textContent = "status";
      controller.clearMessages();
      expect(errorTarget.textContent).toBe("");
      expect(statusTarget.textContent).toBe("");
    });
  });

  describe("bufferToBase64url", () => {
    test("converts buffer to base64url string", () => {
      const buffer = new Uint8Array([72, 101, 108, 108, 111]);
      const result = controller.bufferToBase64url(buffer);
      expect(result).toBe("SGVsbG8");
    });

    test("replaces + and / with - and _", () => {
      const buffer = new Uint8Array([251, 255, 191]);
      const result = controller.bufferToBase64url(buffer);
      expect(result).not.toContain("+");
      expect(result).not.toContain("/");
    });
  });

  describe("csrfToken", () => {
    test("returns csrf token from meta tag", () => {
      expect(controller.csrfToken).toBe("csrf-token");
    });
  });

  describe("identifierValue", () => {
    test("returns trimmed identifier value", () => {
      identifierTarget.value = "  user@test.com  ";
      expect(controller.identifierValue).toBe("user@test.com");
    });
  });
});
