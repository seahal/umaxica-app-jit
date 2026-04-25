import { beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    dispatch = vi.fn();
  },
}));

vi.mock("controllers/webauthn_utils", () => ({
  normalizePublicKeyOptions: vi.fn((options) => options),
}));

const { default: PasskeyAuthenticationController } =
  await import("../../../app/javascript/controllers/passkey_authentication_controller.js");

describe("PasskeyAuthenticationController", () => {
  let controller;
  let errorTarget;
  let statusTarget;
  let identifierTarget;
  let documentMock;
  let fetchMock;
  let getMock;
  let appendChildMock;
  let metaTag;
  let existingScript;
  let reloadMock;

  beforeEach(() => {
    errorTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    statusTarget = { textContent: "", classList: { add: vi.fn(), remove: vi.fn() } };
    identifierTarget = { value: "test@example.com" };
    appendChildMock = vi.fn();
    metaTag = { content: "csrf-token" };
    existingScript = null;

    documentMock = {
      head: { appendChild: appendChildMock },
      createElement: vi.fn((tagName) => {
        if (tagName === "script") {
          return {
            async: false,
            defer: false,
            onerror: null,
            onload: null,
            src: "",
          };
        }
        return { style: {} };
      }),
      querySelector: vi.fn((selector) => {
        if (selector === 'meta[name="csrf-token"]') {
          return metaTag;
        }
        if (selector === "script[src*='challenges.cloudflare.com/turnstile']") {
          return existingScript;
        }
        return null;
      }),
    };

    fetchMock = vi.fn();
    getMock = vi.fn();

    vi.stubGlobal("document", documentMock);
    vi.stubGlobal("fetch", fetchMock);
    vi.stubGlobal("navigator", { credentials: { get: getMock } });
    reloadMock = vi.fn();
    vi.stubGlobal("window", {
      PublicKeyCredential: true,
      location: { href: "", reload: reloadMock },
      turnstile: undefined,
    });

    controller = new PasskeyAuthenticationController();
    controller.element = { appendChild: vi.fn() };
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
    controller.turnstileSiteKeyValue = "turnstile-site-key";
    controller.turnstileErrorMessageValue = "Security verification failed";
  });

  describe("authenticate", () => {
    beforeEach(() => {
      controller.ensureTurnstileToken = vi.fn().mockResolvedValue("turnstile-token");
    });

    test("shows error when PublicKeyCredential is not available", async () => {
      window.PublicKeyCredential = undefined;

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("このブラウザはPasskeyに対応していません");
    });

    test("shows error when identifier is empty", async () => {
      identifierTarget.value = " ";

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("メールアドレスまたはIDを入力してください");
    });

    test("reloads page when options endpoint returns 401 html response", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({}, { ok: false, status: 401, contentType: "text/html" }),
      );

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(reloadMock).toHaveBeenCalledOnce();
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    test("shows json error from options endpoint", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({ error: "Options error" }, { ok: false, status: 422 }),
      );

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("Options error");
    });

    test("uses fallback options error when JSON body has no error key", async () => {
      fetchMock.mockResolvedValueOnce(jsonResponse({}, { ok: false, status: 422 }));

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("オプションの取得に失敗しました");
    });

    test("shows fallback error for non-json options failure", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({}, { ok: false, status: 500, contentType: "text/plain" }),
      );

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("オプションの取得に失敗しました");
    });

    test("treats missing content-type as empty string for options errors", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({}, { ok: false, status: 500, contentType: null }),
      );

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("オプションの取得に失敗しました");
    });

    test("reloads page when verification endpoint returns 302 html response", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({}, { ok: false, status: 302, contentType: "text/html" }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(reloadMock).toHaveBeenCalledOnce();
    });

    test("shows json error from verification endpoint", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({ error: "Verification error" }, { ok: false, status: 422 }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("Verification error");
    });

    test("uses fallback verification error when JSON body has no error key", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(jsonResponse({}, { ok: false, status: 422 }));
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("認証に失敗しました");
    });

    test("shows fallback error for non-json verification failure", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({}, { ok: false, status: 500, contentType: "text/plain" }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("認証に失敗しました");
    });

    test("treats missing content-type as empty string for verification errors", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(jsonResponse({}, { ok: false, status: 500, contentType: null }));
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("認証に失敗しました");
    });

    test("redirects to MFA when verification returns mfa_required", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({
            status: "mfa_required",
            redirect_url: "/sign/app/in/mfa",
          }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(statusTarget.textContent).toBe("二段階認証が必要です...");
      expect(window.location.href).toBe("/sign/app/in/mfa");
    });

    test("redirects to session gate when verification returns session_restricted", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({
            status: "session_restricted",
            redirect_url: "/sign/app/in/session",
            message: "Session verification required",
          }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(statusTarget.textContent).toBe("Session verification required");
      expect(window.location.href).toBe("/sign/app/in/session");
    });

    test("uses fallback session restriction message when none is provided", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({
            status: "session_restricted",
            redirect_url: "/sign/app/in/session",
          }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(statusTarget.textContent).toBe("追加の確認が必要です...");
    });

    test("redirects on successful verification", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(
          jsonResponse({
            status: "ok",
            redirect_url: "/configuration",
          }),
        );
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(statusTarget.textContent).toBe("ログイン成功。リダイレクト中...");
      expect(window.location.href).toBe("/configuration");
    });

    test("shows error when authenticator request is cancelled", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({
          challenge_id: "challenge-1",
          options: { challenge: "test-challenge", allowCredentials: [] },
        }),
      );
      getMock.mockRejectedValue(new DOMException("cancelled", "NotAllowedError"));

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("認証がキャンセルされました");
    });

    test("shows security error on SecurityError", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({
          challenge_id: "challenge-1",
          options: { challenge: "test-challenge", allowCredentials: [] },
        }),
      );
      getMock.mockRejectedValue(new DOMException("blocked", "SecurityError"));

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("セキュリティエラーが発生しました");
    });

    test("shows fallback generic error when thrown object has no message", async () => {
      fetchMock.mockResolvedValueOnce(
        jsonResponse({
          challenge_id: "challenge-1",
          options: { challenge: "test-challenge", allowCredentials: [] },
        }),
      );
      getMock.mockRejectedValue({ name: "UnknownError" });

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("認証中にエラーが発生しました");
    });

    test("shows generic error for unknown verification status", async () => {
      fetchMock
        .mockResolvedValueOnce(
          jsonResponse({
            challenge_id: "challenge-1",
            options: { challenge: "test-challenge", allowCredentials: [] },
          }),
        )
        .mockResolvedValueOnce(jsonResponse({ status: "unknown_status" }));
      getMock.mockResolvedValue(mockCredential());

      await controller.authenticate({ preventDefault: vi.fn() });

      expect(errorTarget.textContent).toBe("予期しない応答です");
    });
  });

  describe("csrfToken", () => {
    test("returns csrf token from meta tag", () => {
      expect(controller.csrfToken).toBe("csrf-token");
    });

    test("returns empty string when meta tag is missing", () => {
      metaTag = null;

      expect(controller.csrfToken).toBe("");
    });
  });

  describe("identifierValue", () => {
    test("returns trimmed identifier value", () => {
      identifierTarget.value = "  user@test.com  ";

      expect(controller.identifierValue).toBe("user@test.com");
    });

    test("returns empty string when target is missing", () => {
      controller.hasIdentifierTarget = false;

      expect(controller.identifierValue).toBe("");
    });
  });

  describe("message helpers", () => {
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
      expect(errorTarget.classList.add).toHaveBeenCalledWith("hidden");
      expect(statusTarget.classList.add).toHaveBeenCalledWith("hidden");
    });

    test("helper methods do not fail when targets are absent", () => {
      controller.hasErrorTarget = false;
      controller.hasStatusTarget = false;

      expect(() => controller.showError("error")).not.toThrow();
      expect(() => controller.showStatus("status")).not.toThrow();
      expect(() => controller.clearMessages()).not.toThrow();
    });
  });

  describe("ensureTurnstileToken", () => {
    test("throws error when turnstileSiteKey is not set", async () => {
      controller.turnstileSiteKeyValue = "";

      await expect(controller.ensureTurnstileToken()).rejects.toThrow(
        "Security verification failed",
      );
    });

    test("returns existing token when turnstileResponseTarget has value", async () => {
      controller.hasTurnstileResponseTarget = true;
      controller.turnstileResponseTarget = { value: "existing-token" };
      controller.ensureTurnstileScriptLoaded = vi.fn();
      controller.requestTurnstileToken = vi.fn();

      await expect(controller.ensureTurnstileToken()).resolves.toBe("existing-token");
      expect(controller.ensureTurnstileScriptLoaded).not.toHaveBeenCalled();
      expect(controller.requestTurnstileToken).not.toHaveBeenCalled();
    });

    test("loads script and requests token when no token is cached", async () => {
      controller.ensureTurnstileScriptLoaded = vi.fn().mockResolvedValue(undefined);
      controller.requestTurnstileToken = vi.fn().mockResolvedValue("new-token");

      await expect(controller.ensureTurnstileToken()).resolves.toBe("new-token");
      expect(controller.ensureTurnstileScriptLoaded).toHaveBeenCalledOnce();
      expect(controller.requestTurnstileToken).toHaveBeenCalledOnce();
    });
  });

  describe("ensureTurnstileScriptLoaded", () => {
    test("resolves immediately when window.turnstile exists", async () => {
      window.turnstile = {};

      await expect(controller.ensureTurnstileScriptLoaded()).resolves.toBeUndefined();
    });

    test("resolves when existing script loads successfully", async () => {
      existingScript = {
        addEventListener: vi.fn((event, handler) => {
          if (event === "load") {
            handler();
          }
        }),
      };

      await expect(controller.ensureTurnstileScriptLoaded()).resolves.toBeUndefined();
      expect(existingScript.addEventListener).toHaveBeenCalledWith("load", expect.any(Function), {
        once: true,
      });
    });

    test("rejects when existing script fails to load", async () => {
      existingScript = {
        addEventListener: vi.fn((event, handler) => {
          if (event === "error") {
            handler();
          }
        }),
      };

      await expect(controller.ensureTurnstileScriptLoaded()).rejects.toThrow(
        "Security verification failed",
      );
    });

    test("appends new script and resolves on load", async () => {
      const promise = controller.ensureTurnstileScriptLoaded();
      const [[script]] = appendChildMock.mock.calls;
      script.onload();

      await expect(promise).resolves.toBeUndefined();
      expect(script.src).toContain("challenges.cloudflare.com/turnstile");
    });

    test("rejects when appended script fails to load", async () => {
      const promise = controller.ensureTurnstileScriptLoaded();
      const [[script]] = appendChildMock.mock.calls;
      script.onerror();

      await expect(promise).rejects.toThrow("Security verification failed");
    });
  });

  describe("requestTurnstileToken", () => {
    test("resolves with token and caches it when target exists", async () => {
      controller.hasTurnstileResponseTarget = true;
      controller.turnstileResponseTarget = { value: "" };
      window.turnstile = {
        render: vi.fn((_container, options) => {
          options.callback("token-1");
        }),
      };

      await expect(controller.requestTurnstileToken()).resolves.toBe("token-1");
      expect(controller.turnstileResponseTarget.value).toBe("token-1");
      expect(controller.element.appendChild).toHaveBeenCalledOnce();
    });

    test("resolves with token when target is not present", async () => {
      window.turnstile = {
        render: vi.fn((_container, options) => {
          options.callback("token-2");
        }),
      };

      await expect(controller.requestTurnstileToken()).resolves.toBe("token-2");
    });

    test("rejects when turnstile render throws", async () => {
      window.turnstile = {
        render: vi.fn(() => {
          throw new Error("Render error");
        }),
      };

      await expect(controller.requestTurnstileToken()).rejects.toThrow(
        "Security verification failed",
      );
    });

    test("rejects when turnstile error-callback is called", async () => {
      window.turnstile = {
        render: vi.fn((_container, options) => {
          options["error-callback"]();
        }),
      };

      await expect(controller.requestTurnstileToken()).rejects.toThrow(
        "Security verification failed",
      );
    });

    test("rejects when turnstile expired-callback is called", async () => {
      window.turnstile = {
        render: vi.fn((_container, options) => {
          options["expired-callback"]();
        }),
      };

      await expect(controller.requestTurnstileToken()).rejects.toThrow(
        "Security verification failed",
      );
    });
  });

  describe("credential encoding", () => {
    test("encodes credential with userHandle", () => {
      const result = controller.encodeCredential(mockCredential());

      expect(result.id).toBe("credential-id");
      expect(result.type).toBe("public-key");
      expect(result.authenticatorAttachment).toBe("platform");
      expect(result.response.userHandle).toBeDefined();
      expect(result.clientExtensionResults).toEqual({});
    });

    test("encodes credential without userHandle", () => {
      const credential = mockCredential();
      credential.authenticatorAttachment = null;
      credential.response.userHandle = null;

      const result = controller.encodeCredential(credential);

      expect(result.authenticatorAttachment).toBeNull();
      expect(result.response.userHandle).toBeNull();
    });

    test("converts buffer to base64url string", () => {
      const buffer = new Uint8Array([72, 101, 108, 108, 111]);

      expect(controller.bufferToBase64url(buffer)).toBe("SGVsbG8");
    });

    test("handles empty buffer", () => {
      expect(controller.bufferToBase64url(new Uint8Array([]))).toBe("");
    });
  });

  describe("redirectWithStatus", () => {
    test("redirects to URL with status message", () => {
      controller.redirectWithStatus("/dashboard", "Redirecting...");

      expect(window.location.href).toBe("/dashboard");
      expect(statusTarget.textContent).toBe("Redirecting...");
    });

    test("throws when URL is missing", () => {
      expect(() => controller.redirectWithStatus(null, "Error")).toThrow(
        "リダイレクト先がありません",
      );
      expect(() => controller.redirectWithStatus("", "Error")).toThrow(
        "リダイレクト先がありません",
      );
    });
  });
});

function jsonResponse(data, { ok = true, status = 200, contentType = "application/json" } = {}) {
  return {
    ok,
    status,
    headers: {
      get: vi.fn((name) => (name === "content-type" ? contentType : null)),
    },
    json: vi.fn().mockResolvedValue(data),
  };
}

function mockCredential() {
  return {
    id: "credential-id",
    rawId: new Uint8Array([1, 2, 3]).buffer,
    type: "public-key",
    authenticatorAttachment: "platform",
    response: {
      clientDataJSON: new Uint8Array([4, 5, 6]).buffer,
      authenticatorData: new Uint8Array([7, 8, 9]).buffer,
      signature: new Uint8Array([10, 11, 12]).buffer,
      userHandle: new Uint8Array([13, 14, 15]).buffer,
    },
    getClientExtensionResults: vi.fn(() => ({})),
  };
}
