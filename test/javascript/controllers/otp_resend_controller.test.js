import { afterEach, beforeEach, describe, expect, test, vi } from "vite-plus/test";

vi.mock("@hotwired/stimulus", () => ({
  Controller: class {
    constructor() {
      this.statusTarget = { textContent: "" };
      this.buttonTarget = { disabled: false, textContent: "" };
      this.inputTarget = { value: "", focus: vi.fn() };
      this.hasInputTarget = true;
    }

    connect() {}
  },
}));

const { default: OtpResendController } =
  await import("../../../app/javascript/controllers/otp_resend_controller.js");

describe("OtpResendController", () => {
  let controller;

  beforeEach(() => {
    vi.useFakeTimers();
    controller = new OtpResendController();
    controller.endpointValue = "/otp/resend";
    controller.stateValue = "some-state";
    controller.buttonLabelValue = "Resend OTP";
    controller.sentMessageValue = "OTP Sent!";
    controller.tooSoonMessageValue = "Too soon";
    controller.failedMessageValue = "Failed to send";

    vi.stubGlobal("fetch", vi.fn());
    vi.stubGlobal("document", {
      querySelector: vi.fn((selector) => {
        if (selector === "meta[name='csrf-token']") {
          return { getAttribute: () => "csrf-token-value" };
        }
        return null;
      }),
    });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  test("connect: 初期状態を設定する", () => {
    controller.remainingSeconds = 99;
    controller.countdownTimer = 123;

    controller.connect();

    expect(controller.remainingSeconds).toBe(0);
    expect(controller.countdownTimer).toBeNull();
  });

  test("disconnect: カウントダウンを停止する", () => {
    const stopSpy = vi.spyOn(controller, "stopCountdown");

    controller.disconnect();

    expect(stopSpy).toHaveBeenCalledOnce();
  });

  test("resend: 成功時にステータスを更新し、入力をクリアする", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ status: 200, json: () => Promise.resolve({ resendable: true }) }),
    );

    const event = { preventDefault: vi.fn() };
    await controller.resend(event);

    expect(controller.statusTarget.textContent).toBe("OTP Sent!");
    expect(controller.inputTarget.value).toBe("");
    expect(controller.inputTarget.focus).toHaveBeenCalled();
  });

  test("resend: 429 (Too Many Requests) のときにカウントダウンを開始する", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ status: 429, json: () => Promise.resolve({ retry_after: 10 }) }),
    );

    const event = { preventDefault: vi.fn() };
    await controller.resend(event);

    expect(controller.statusTarget.textContent).toBe("Too soon");
    expect(controller.buttonTarget.disabled).toBe(true);
    expect(controller.buttonTarget.textContent).toContain("(10s)");

    vi.advanceTimersByTime(1000);
    expect(controller.buttonTarget.textContent).toContain("(9s)");

    vi.advanceTimersByTime(9000);
    expect(controller.buttonTarget.disabled).toBe(false);
    expect(controller.buttonTarget.textContent).toBe("Resend OTP");
  });

  test("resend: retry_after がない 429 では 0 秒として扱う", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ status: 429, json: () => Promise.resolve({}) }),
    );

    await controller.resend({ preventDefault: vi.fn() });

    expect(controller.remainingSeconds).toBe(0);
    expect(controller.buttonTarget.disabled).toBe(false);
  });

  test("resend: 失敗時にエラーメッセージを表示する", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ status: 500, json: () => Promise.resolve({}) }),
    );

    const event = { preventDefault: vi.fn() };
    await controller.resend(event);

    expect(controller.statusTarget.textContent).toBe("Failed to send");
  });

  test("resend: network error 时显示错误信息", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("Network error")));

    const event = { preventDefault: vi.fn() };
    await controller.resend(event);

    expect(controller.statusTarget.textContent).toBe("Failed to send");
  });

  test("resend: remainingSeconds > 0 时返回", async () => {
    vi.stubGlobal("fetch", vi.fn());

    controller.remainingSeconds = 5;
    const event = { preventDefault: vi.fn() };
    await controller.resend(event);

    expect(fetch).not.toHaveBeenCalled();
  });

  test("clearOtpInput: inputTarget がない场合不报错", () => {
    controller.hasInputTarget = false;
    expect(() => controller.clearOtpInput()).not.toThrow();
  });

  test("startCountdown: remainingSeconds <= 0 时立即 resetButton", () => {
    const resetSpy = vi.spyOn(controller, "resetButton");
    controller.startCountdown(0);
    expect(resetSpy).toHaveBeenCalled();
  });

  test("stopCountdown: 清除定时器", () => {
    controller.countdownTimer = setInterval(() => {}, 1000);
    controller.stopCountdown();
    expect(controller.countdownTimer).toBeNull();
  });

  test("renderButton: 剩余秒数为0时显示按钮标签", () => {
    controller.remainingSeconds = 0;
    controller.renderButton();
    expect(controller.buttonTarget.textContent).toBe("Resend OTP");
  });

  test("renderButton: 剩余秒数大于0时显示倒计时", () => {
    controller.remainingSeconds = 5;
    controller.renderButton();
    expect(controller.buttonTarget.disabled).toBe(true);
    expect(controller.buttonTarget.textContent).toContain("5s");
  });

  test("csrfToken: メタタグがない場合は空文字を返す", () => {
    document.querySelector.mockReturnValue(null);

    expect(controller.csrfToken()).toBe("");
  });

  test("startCountdown: 小数は切り上げる", () => {
    controller.startCountdown(1.2);

    expect(controller.remainingSeconds).toBe(2);
    expect(controller.buttonTarget.textContent).toContain("2s");
  });

  test("resetButton: 重置所有状态", () => {
    controller.remainingSeconds = 10;
    controller.countdownTimer = setInterval(() => {}, 1000);
    controller.resetButton();
    expect(controller.remainingSeconds).toBe(0);
    expect(controller.countdownTimer).toBeNull();
    expect(controller.buttonTarget.disabled).toBe(false);
    expect(controller.buttonTarget.textContent).toBe("Resend OTP");
  });
});
