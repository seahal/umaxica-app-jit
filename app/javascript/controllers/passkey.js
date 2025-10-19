import {csrfToken} from "./passkey_helpers.js";

const btn =
    typeof document !== "undefined"
        ? document.getElementById("add-passkey")
        : null;

btn?.addEventListener("click", async () => {
    // 1) サーバから options を取得
    const res = await fetch("/setting/passkeys/challenge", {
        method: "POST",
        headers: {
            "X-CSRF-Token": csrfToken(),
            "Content-Type": "application/json",
        },
        body: JSON.stringify({}),
    });

    if (!res.ok) {
        console.error("server error", res.status, await res.text()); // ← HTML返ってないか確認
        return;
    }

    const options = await res.json();

    const createCredentialDefaultArgs = {
        publicKey: {
            // Relying Party (a.k.a. - Service):
            rp: {
                name: "Acme",
            },
            // User:
            user: {
                id: new Uint8Array(16),
                name: "carina.p.anand@example.com",
                displayName: "Carina P. Anand",
            },
            pubKeyCredParams: [
                {type: "public-key", alg: -7},
                {type: "public-key", alg: -257},
                {type: "public-key", alg: -8},
            ],
            attestation: "direct",
            timeout: 60000,
            challenge: new Uint8Array([
                // must be a cryptographically random number sent from a server
                0x8c, 0x0a, 0x26, 0xff, 0x22, 0x91, 0xc1, 0xe9, 0xb9, 0x4e, 0x2e, 0x17,
                0x1a, 0x98, 0x6a, 0x73, 0x71, 0x9d, 0x43, 0x48, 0xd5, 0xa7, 0x6a, 0x15,
                0x7e, 0x38, 0x94, 0x52, 0x77, 0x97, 0x0f, 0xef,
            ]).buffer,
        },
    };

    // challenge
    console.log("server options:", createCredentialDefaultArgs);
    console.log("server options:", options); // ← { publicKey: { challenge: "...", user: { id: "..." }, ... } }
    console.log("challenge", options.challenge);
    console.log("user name", options.user.name);
    console.log("user id", options.user.id);
    console.log("user display name", options.user.displayName);

    // 3) 認証器で作成
    await navigator.credentials
        .create(createCredentialDefaultArgs)
        .then((cred) => {
            console.log("credential created", cred);
            const payload = {
                credential: {
                    id: cred.id,
                    rawId: cred.rawId, // 既にbase64urlならOK（そうでなければ toB64url() して）
                    type: cred.type,
                    response: {
                        clientDataJSON: cred.response.clientDataJSON,
                        attestationObject: cred.response.attestationObject,
                    },
                },
                description: "My Passkey",
            };
            console.log("payload", payload);

            // 4) サーバに保存依頼
            return fetch("/setting/passkeys/verify", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": csrfToken(),
                },
                credentials: "same-origin",
                body: JSON.stringify(payload),
            });
        })
        .catch((err) => {
            console.error("credential creation failed", err);
            alert(`❌ パスキー登録に失敗しました: ${err.message}`);
        });
});
