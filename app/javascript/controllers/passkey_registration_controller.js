import { Controller } from "@hotwired/stimulus"

// Passkey Registration Controller
// Handles WebAuthn credential creation for passkey registration.
//
// Usage:
//   <div data-controller="passkey-registration"
//        data-passkey-registration-options-url-value="/configuration/passkeys/options"
//        data-passkey-registration-verification-url-value="/configuration/passkeys/verification">
//     <input type="text" data-passkey-registration-target="description" placeholder="Passkey name">
//     <button data-action="click->passkey-registration#register">Register Passkey</button>
//     <p data-passkey-registration-target="error" class="hidden text-red-600"></p>
//     <p data-passkey-registration-target="status" class="hidden text-gray-600"></p>
//   </div>
export default class extends Controller {
  static targets = ["description", "error", "status"]
  static values = {
    optionsUrl: String,
    verificationUrl: String
  }

  async register(event) {
    event.preventDefault()
    this.clearMessages()

    // Check WebAuthn support
    if (!window.PublicKeyCredential) {
      this.showError("このブラウザはPasskeyに対応していません")
      return
    }

    try {
      this.showStatus("認証オプションを取得中...")

      // Step 1: Get registration options from server
      const optionsResponse = await fetch(this.optionsUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })

      if (!optionsResponse.ok) {
        const data = await optionsResponse.json()
        throw new Error(data.error || "オプションの取得に失敗しました")
      }

      const { challenge_id, options } = await optionsResponse.json()

      this.showStatus("認証器でPasskeyを作成中...")

      // Step 2: Create credential with authenticator
      const publicKeyOptions = this.decodeOptions(options)
      const credential = await navigator.credentials.create({ publicKey: publicKeyOptions })

      this.showStatus("サーバーで検証中...")

      // Step 3: Send credential to server for verification
      const verificationResponse = await fetch(this.verificationUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({
          challenge_id: challenge_id,
          credential: this.encodeCredential(credential),
          description: this.descriptionValue
        })
      })

      const result = await verificationResponse.json()

      if (!verificationResponse.ok) {
        throw new Error(result.error || "登録に失敗しました")
      }

      // Step 4: Success - redirect
      this.showStatus("登録完了！リダイレクト中...")
      if (result.redirect_url) {
        window.location.href = result.redirect_url
      } else {
        window.location.reload()
      }

    } catch (error) {
      console.error("Passkey registration error:", error)
      if (error.name === "NotAllowedError") {
        this.showError("認証がキャンセルされました")
      } else if (error.name === "InvalidStateError") {
        this.showError("このPasskeyは既に登録されています")
      } else {
        this.showError(error.message || "登録中にエラーが発生しました")
      }
    }
  }

  get csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }

  get descriptionValue() {
    if (this.hasDescriptionTarget) {
      return this.descriptionTarget.value || ""
    }
    return ""
  }

  decodeOptions(options) {
    // Decode Base64URL-encoded fields
    const decoded = { ...options }

    if (options.challenge) {
      decoded.challenge = this.base64urlToBuffer(options.challenge)
    }

    if (options.user && options.user.id) {
      decoded.user = {
        ...options.user,
        id: this.base64urlToBuffer(options.user.id)
      }
    }

    if (options.excludeCredentials) {
      decoded.excludeCredentials = options.excludeCredentials.map(cred => ({
        ...cred,
        id: this.base64urlToBuffer(cred.id)
      }))
    }

    return decoded
  }

  encodeCredential(credential) {
    const response = credential.response

    return {
      id: credential.id,
      rawId: this.bufferToBase64url(credential.rawId),
      type: credential.type,
      authenticatorAttachment: credential.authenticatorAttachment || null,
      response: {
        clientDataJSON: this.bufferToBase64url(response.clientDataJSON),
        attestationObject: this.bufferToBase64url(response.attestationObject)
      },
      clientExtensionResults: credential.getClientExtensionResults()
    }
  }

  base64urlToBuffer(base64url) {
    const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/')
    const padding = '='.repeat((4 - base64.length % 4) % 4)
    const binary = atob(base64 + padding)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i)
    }
    return bytes.buffer
  }

  bufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ''
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove("hidden")
    }
    if (this.hasStatusTarget) {
      this.statusTarget.classList.add("hidden")
    }
  }

  showStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove("hidden")
    }
  }

  clearMessages() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add("hidden")
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
      this.statusTarget.classList.add("hidden")
    }
  }
}
