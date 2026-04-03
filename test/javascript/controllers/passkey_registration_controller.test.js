import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

vi.mock("controllers/webauthn_utils", () => ({
  normalizePublicKeyOptions: vi.fn((opts) => opts),
}));

const { default: PasskeyRegistrationController } =
  await import("../../../app/javascript/controllers/passkey_registration_controller.js");

describe("PasskeyRegistrationController", () => {
  let controller;
  let errorTarget;
  let statusTarget;
  let descriptionTarget;

  beforeEach(() => {
    errorTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    statusTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    descriptionTarget = { value: "My Passkey" };

    controller = new PasskeyRegistrationController();
    controller.element = { querySelector: vi.fn(() => ({ content: "csrf-token" })) };
    controller.errorTarget = errorTarget;
    controller.statusTarget = statusTarget;
    controller.descriptionTarget = descriptionTarget;
    controller.hasErrorTarget = true;
    controller.hasStatusTarget = true;
    controller.hasDescriptionTarget = true;
    controller.hasBeginUrlValue = false;
    controller.hasFinishUrlValue = false;
    controller.hasSuccessRedirectUrlValue = false;
    controller.optionsUrlValue = "/passkeys/options";
    controller.verificationUrlValue = "/passkeys/verify";
    controller.beginUrlValue = "";
    controller.finishUrlValue = "";
    controller.successRedirectUrlValue = "";

    vi.stubGlobal("document", {
      querySelector: vi.fn(() => ({ content: "csrf-token" })),
      head: { appendChild: vi.fn() },
    });
    vi.stubGlobal("fetch", vi.fn());
    vi.stubGlobal("navigator", { credentials: { create: vi.fn() } });
    vi.stubGlobal("window", { PublicKeyCredential: true, location: { reload: vi.fn(), href: "" } });
  });

  describe("register", () => {
    test("shows error when PublicKeyCredential is not available", async () => {
      window.PublicKeyCredential = undefined;
      const event = { preventDefault: vi.fn() };

      await controller.register(event);

      expect(errorTarget.textContent).toBe("このブラウザはPasskeyに対応していません");
    });

    test("clears messages before starting", async () => {
      errorTarget.textContent = "old error";
      errorTarget.classList.remove("hidden");
      const event = { preventDefault: vi.fn() };
      fetch.mockResolvedValue({
        ok: false,
        status: 500,
        headers: { get: () => "application/json" },
        json: () => Promise.resolve({}),
      });

      await controller.register(event);

      expect(errorTarget.textContent).toBe("オプションの取得に失敗しました");
    });

    test("shows error when options fetch fails", async () => {
      const event = { preventDefault: vi.fn() };
      fetch.mockResolvedValue({
        ok: false,
        status: 500,
        headers: { get: () => "application/json" },
        json: () => Promise.resolve({}),
      });

      await controller.register(event);

      expect(errorTarget.textContent).toBe("オプションの取得に失敗しました");
    });

    test("shows error on NotAllowedError from authenticator", async () => {
      const event = { preventDefault: vi.fn() };
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ challenge_id: "c1", options: {} }),
      });
      const err = new Error("cancelled");
      err.name = "NotAllowedError";
      navigator.credentials.create.mockRejectedValue(err);

      await controller.register(event);

      expect(errorTarget.textContent).toBe("認証がキャンセルされました");
    });

    test("shows error on InvalidStateError from authenticator", async () => {
      const event = { preventDefault: vi.fn() };
      fetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ challenge_id: "c1", options: {} }),
      });
      const err = new Error("exists");
      err.name = "InvalidStateError";
      navigator.credentials.create.mockRejectedValue(err);

      await controller.register(event);

      expect(errorTarget.textContent).toBe("このPasskeyは既に登録されています");
    });
  });

  describe("showError/showStatus/clearMessages", () => {
    test("showError sets error text and hides status", () => {
      controller.showError("Registration failed");
      expect(errorTarget.textContent).toBe("Registration failed");
      expect(errorTarget.classList.remove).toHaveBeenCalledWith("hidden");
      expect(statusTarget.classList.add).toHaveBeenCalledWith("hidden");
    });

    test("showStatus sets status text and shows it", () => {
      controller.showStatus("Creating credential...");
      expect(statusTarget.textContent).toBe("Creating credential...");
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
      const buffer = new Uint8Array([87, 101, 98, 65, 117, 116, 104, 110]);
      const result = controller.bufferToBase64url(buffer);
      expect(result).toBe("V2ViQXV0aG4");
    });

    test("replaces + and / with - and _", () => {
      const buffer = new Uint8Array([251, 255, 191]);
      const result = controller.bufferToBase64url(buffer);
      expect(result).not.toContain("+");
      expect(result).not.toContain("/");
    });
  });

  describe("URL getters", () => {
    test("requestBeginUrl uses optionsUrl when beginUrl not set", () => {
      expect(controller.requestBeginUrl).toBe("/passkeys/options");
    });

    test("requestBeginUrl uses beginUrl when set", () => {
      controller.hasBeginUrlValue = true;
      controller.beginUrlValue = "/custom/begin";
      expect(controller.requestBeginUrl).toBe("/custom/begin");
    });

    test("requestFinishUrl uses verificationUrl when finishUrl not set", () => {
      expect(controller.requestFinishUrl).toBe("/passkeys/verify");
    });

    test("requestFinishUrl uses finishUrl when set", () => {
      controller.hasFinishUrlValue = true;
      controller.finishUrlValue = "/custom/finish";
      expect(controller.requestFinishUrl).toBe("/custom/finish");
    });

    test("redirectUrl returns empty when not set", () => {
      expect(controller.redirectUrl).toBe("");
    });

    test("redirectUrl returns successRedirectUrl when set", () => {
      controller.hasSuccessRedirectUrlValue = true;
      controller.successRedirectUrlValue = "/dashboard";
      expect(controller.redirectUrl).toBe("/dashboard");
    });
  });

  describe("descriptionValue", () => {
    test("returns description target value", () => {
      descriptionTarget.value = "Work Laptop";
      expect(controller.descriptionValue).toBe("Work Laptop");
    });

    test("returns empty string when description target missing", () => {
      controller.hasDescriptionTarget = false;
      expect(controller.descriptionValue).toBe("");
    });
  });

  describe("csrfToken", () => {
    test("returns csrf token from meta tag", () => {
      expect(controller.csrfToken).toBe("csrf-token");
    });
  });
});
