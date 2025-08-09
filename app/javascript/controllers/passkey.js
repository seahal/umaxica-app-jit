const passkey = document.getElementById("add-passkey");

function getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
}

async function challenger() {
    passkey.addEventListener("click", () => {
        const payload = {
            username: "alice@example.com" // ← 任意のデータを送ってみよう（登録対象ユーザーなど）
        };

        fetch('/setting/passkeys/challenge', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': getCsrfToken()
            },
            body: JSON.stringify(payload)
        })
            .then(response => response.json())
            .then(data => {
                console.log("📦 サーバからのレスポンス:", data.challenge);
                passkey.value = data.challenge
            })
            .catch(error => {
                // TODO: how to handle error?
                console.error("❌ エラー:", error);
            });
    });
}

challenger();