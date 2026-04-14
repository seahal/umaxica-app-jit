import { describe, expect, test } from "vite-plus/test";

import {
  normalizePublicKeyOptions,
  toArrayBuffer,
} from "../../../app/javascript/controllers/webauthn_utils.js";

// Mock atob if not available (Node.js environment)
if (typeof atob === "undefined") {
  global.atob = (str) => Buffer.from(str, "base64").toString("binary");
}

describe("webauthn_utils", () => {
  describe("toArrayBuffer", () => {
    test("Base64URL 文字列を ArrayBuffer に変換する", () => {
      const input = "SGVsbG8td29ybGQ_"; // Hello-world? (Base64URL)
      const buffer = toArrayBuffer(input);
      expect(buffer).toBeInstanceOf(ArrayBuffer);
      const bytes = new Uint8Array(buffer);
      expect(bytes[0]).toBe(72); // 'H'
    });

    test("ArrayBuffer をそのまま返す", () => {
      const buffer = new ArrayBuffer(8);
      expect(toArrayBuffer(buffer)).toBe(buffer);
    });

    test("バイト配列を ArrayBuffer に変換する", () => {
      const input = [72, 101, 108, 108, 111];
      const buffer = toArrayBuffer(input);
      expect(new Uint8Array(buffer)[0]).toBe(72);
    });

    test("不正な入力に対して TypeError を投げる", () => {
      expect(() => toArrayBuffer(123)).toThrow(TypeError);
      expect(() => toArrayBuffer(null)).toThrow(TypeError);
    });

    test("エラーメッセージに入力の型情報を含める", () => {
      expect(() => toArrayBuffer(undefined, "challenge")).toThrow(
        "Expected challenge to be a base64url string, ArrayBuffer, or byte array, got undefined",
      );
      expect(() => toArrayBuffer({ id: 1 }, "credential")).toThrow(
        "Expected credential to be a base64url string, ArrayBuffer, or byte array, got object(Object)",
      );
    });
  });

  describe("normalizePublicKeyOptions", () => {
    test("challenge と user.id を Base64URL から ArrayBuffer に変換する", () => {
      const options = { challenge: "Y2hhbGxlbmdl", user: { id: "dXNlcmlk" } };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.challenge).toBeInstanceOf(ArrayBuffer);
      expect(normalized.user.id).toBeInstanceOf(ArrayBuffer);
    });

    test("publicKey プロパティがある場合、その中身を正規化する", () => {
      const options = { publicKey: { challenge: "Y2hhbGxlbmdl" } };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.challenge).toBeInstanceOf(ArrayBuffer);
    });

    test("excludeCredentials の id を正規化する", () => {
      const options = { excludeCredentials: [{ id: "Y3JlZGlk" }] };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.excludeCredentials[0].id).toBeInstanceOf(ArrayBuffer);
    });

    test("allowCredentials の id を正規化する", () => {
      const options = { allowCredentials: [{ id: "Y3JlZGlk" }] };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.allowCredentials[0].id).toBeInstanceOf(ArrayBuffer);
    });

    test("ArrayBuffer と配列の id をそのまま正規化する", () => {
      const options = {
        excludeCredentials: [{ id: new ArrayBuffer(2) }],
        allowCredentials: [{ id: [1, 2, 3] }],
      };

      const normalized = normalizePublicKeyOptions(options);

      expect(normalized.excludeCredentials[0].id).toBeInstanceOf(ArrayBuffer);
      expect(normalized.allowCredentials[0].id).toBeInstanceOf(ArrayBuffer);
    });

    test("optionsがnullの場合はTypeErrorを投げる", () => {
      expect(() => normalizePublicKeyOptions(null)).toThrow(TypeError);
    });

    test("optionsがundefinedの場合はTypeErrorを投げる", () => {
      expect(() => normalizePublicKeyOptions(undefined)).toThrow(TypeError);
    });

    test("optionsがオブジェクトでない場合はTypeErrorを投げる", () => {
      expect(() => normalizePublicKeyOptions("string")).toThrow(TypeError);
      expect(() => normalizePublicKeyOptions(123)).toThrow(TypeError);
      expect(() => normalizePublicKeyOptions(false)).toThrow(
        "Expected options to be an object, got boolean",
      );
      expect(normalizePublicKeyOptions([])).toEqual({});
    });

    test("challengeがない場合は変換しない", () => {
      const options = { user: { id: "dXNlcmlk" } };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.challenge).toBeUndefined();
      expect(normalized.user.id).toBeInstanceOf(ArrayBuffer);
    });

    test("userがない場合は変換しない", () => {
      const options = { challenge: "Y2hhbGxlbmdl" };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.challenge).toBeInstanceOf(ArrayBuffer);
      expect(normalized.user).toBeUndefined();
    });

    test("user.idがない場合は変換しない", () => {
      const options = { challenge: "Y2hhbGxlbmdl", user: { name: "test" } };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.challenge).toBeInstanceOf(ArrayBuffer);
      expect(normalized.user.id).toBeUndefined();
    });

    test("excludeCredentialsがnullの場合はそのまま", () => {
      const options = { excludeCredentials: null };
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.excludeCredentials).toBeNull();
    });

    test("excludeCredentialsがundefinedの場合はそのまま", () => {
      const options = {};
      const normalized = normalizePublicKeyOptions(options);
      expect(normalized.excludeCredentials).toBeUndefined();
    });

    test("excludeCredentials が配列でない場合は TypeError を投げる", () => {
      expect(() => normalizePublicKeyOptions({ excludeCredentials: "bad" })).toThrow(
        "excludeCredentials must be an array",
      );
    });

    test("allowCredentials が配列でない場合は TypeError を投げる", () => {
      expect(() => normalizePublicKeyOptions({ allowCredentials: "bad" })).toThrow(
        "allowCredentials must be an array",
      );
    });

    test("toArrayBufferにnullを渡すとTypeError", () => {
      expect(() => toArrayBuffer(null)).toThrow(TypeError);
    });

    test("toArrayBufferにundefinedを渡すとTypeError", () => {
      expect(() => toArrayBuffer(undefined)).toThrow(TypeError);
    });

    test("toArrayBufferにnumberを渡すとTypeError", () => {
      expect(() => toArrayBuffer(123)).toThrow(TypeError);
    });
  });
});
