import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        optionsUrl: String,
        verificationUrl: String,
        updateUrl: String,
        destroyUrl: String
    }
    static targets = ["status", "error", "description"]

    get csrfToken() {
        return document.querySelector('meta[name="csrf-token"]')?.content
    }

    async register(event) {
        await this.performRegistration(event, this.verificationUrlValue, "POST")
    }

    async update(event) {
        if (!confirm("This will replace your existing passkey. Continue?")) return
        await this.performRegistration(event, this.updateUrlValue, "PATCH")
    }

    async destroy(event) {
        event.preventDefault()
        if (!confirm("Are you sure you want to remove your passkey?")) return

        this.statusTarget.textContent = "Removing..."
        this.statusTarget.classList.remove("hidden")

        try {
            const resp = await fetch(this.destroyUrlValue, {
                method: "DELETE",
                headers: {
                    "X-CSRF-Token": this.csrfToken,
                    "Content-Type": "application/json"
                }
            })

            if (!resp.ok) throw new Error("Failed to remove passkey")

            this.statusTarget.textContent = "Removed!"
            window.location.reload()
        } catch (e) {
            this.showError(e.message)
        }
    }

    async performRegistration(event, url, method) {
        event.preventDefault()
        this.clearMessages()
        this.statusTarget.textContent = "Prepare your authenticator..."
        this.statusTarget.classList.remove("hidden")

        try {
            const optionsResp = await fetch(this.optionsUrlValue, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": this.csrfToken
                }
            })

            if (!optionsResp.ok) throw new Error("Failed to get options")
            const responseJson = await optionsResp.json()
            const { challenge_id, options } = responseJson

            options.challenge = this.base64urlToBuffer(options.challenge)

            // WebAuthn requires user.id to be a Buffer.
            // We assume server sends string (e.g. UUID), so we convert it.
            if (options.user && options.user.id) {
                options.user.id = this.stringToBuffer(options.user.id)
            }

            if (options.excludeCredentials) {
                options.excludeCredentials = options.excludeCredentials.map(c => ({
                    ...c,
                    id: this.base64urlToBuffer(c.id)
                }))
            }

            const credential = await navigator.credentials.create({ publicKey: options })

            // Flatten structure for server
            const body = {
                challenge_id: challenge_id,
                credential: {
                    id: credential.id,
                    rawId: this.bufferToBase64url(credential.rawId),
                    type: credential.type,
                    response: {
                        clientDataJSON: this.bufferToBase64url(credential.response.clientDataJSON),
                        attestationObject: this.bufferToBase64url(credential.response.attestationObject)
                    }
                },
                description: this.descriptionTarget ? this.descriptionTarget.value : ""
            }

            const resp = await fetch(url, {
                method: method,
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": this.csrfToken
                },
                body: JSON.stringify(body)
            })

            const respJson = await resp.json()
            if (!resp.ok) {
                throw new Error(respJson.error || "Registration failed")
            }

            this.statusTarget.textContent = "Success!"
            if (respJson.redirect_url) {
                window.location.href = respJson.redirect_url
            } else {
                window.location.reload()
            }

        } catch (e) {
            console.error(e)
            this.showError(e.message)
        }
    }

    showError(msg) {
        this.errorTarget.textContent = msg
        this.errorTarget.classList.remove("hidden")
        this.statusTarget.classList.add("hidden")
    }

    clearMessages() {
        this.errorTarget.classList.add("hidden")
        this.statusTarget.classList.add("hidden")
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

    stringToBuffer(str) {
        return new TextEncoder().encode(str)
    }
}
