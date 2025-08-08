// WebAuthn Passkey Implementation
class PasskeyManager {
    constructor() {
        this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
        this.baseUrl = '/auth/setting/passkeys';
        this.initEventListeners();
    }

    initEventListeners() {
        const addButton = document.getElementById('add-passkey');
        if (addButton) {
            addButton.addEventListener('click', () => this.registerPasskey());
        }

        const authenticateButton = document.getElementById('authenticate-passkey');
        if (authenticateButton) {
            authenticateButton.addEventListener('click', () => this.authenticatePasskey());
        }
    }

    async registerPasskey() {
        try {
            // Get challenge from server
            const challengeResponse = await fetch(`${this.baseUrl}/challenge`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                }
            });

            if (!challengeResponse.ok) {
                throw new Error('Failed to get challenge from server');
            }

            const options = await challengeResponse.json();
            
            // Convert base64url strings to ArrayBuffers
            options.challenge = this.base64urlToArrayBuffer(options.challenge);
            options.user.id = this.base64urlToArrayBuffer(options.user.id);
            
            if (options.excludeCredentials) {
                options.excludeCredentials = options.excludeCredentials.map(cred => ({
                    ...cred,
                    id: this.base64urlToArrayBuffer(cred.id)
                }));
            }

            // Create credential
            const credential = await navigator.credentials.create({
                publicKey: options
            });

            if (!credential) {
                throw new Error('Credential creation was cancelled');
            }

            // Prepare credential for server
            const credentialForServer = {
                id: credential.id,
                type: credential.type,
                rawId: this.arrayBufferToBase64url(credential.rawId),
                response: {
                    clientDataJSON: this.arrayBufferToBase64url(credential.response.clientDataJSON),
                    attestationObject: this.arrayBufferToBase64url(credential.response.attestationObject)
                }
            };

            // Send to server for verification
            const verifyResponse = await fetch(`${this.baseUrl}/verify`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify({
                    credential: credentialForServer,
                    description: this.getDescription()
                })
            });

            const result = await verifyResponse.json();

            if (result.success) {
                this.showSuccess('Passkey registered successfully!');
                setTimeout(() => window.location.reload(), 1500);
            } else {
                throw new Error(result.error || 'Registration failed');
            }

        } catch (error) {
            console.error('Passkey registration error:', error);
            this.showError(error.message);
        }
    }

    async authenticatePasskey() {
        try {
            // Get authentication challenge
            const challengeResponse = await fetch(`${this.baseUrl}/auth_challenge`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                }
            });

            if (!challengeResponse.ok) {
                throw new Error('Failed to get authentication challenge');
            }

            const options = await challengeResponse.json();
            
            // Convert base64url to ArrayBuffers
            options.challenge = this.base64urlToArrayBuffer(options.challenge);
            
            if (options.allowCredentials) {
                options.allowCredentials = options.allowCredentials.map(cred => ({
                    ...cred,
                    id: this.base64urlToArrayBuffer(cred.id)
                }));
            }

            // Get credential
            const credential = await navigator.credentials.get({
                publicKey: options
            });

            if (!credential) {
                throw new Error('Authentication was cancelled');
            }

            // Prepare credential for server
            const credentialForServer = {
                id: credential.id,
                type: credential.type,
                rawId: this.arrayBufferToBase64url(credential.rawId),
                response: {
                    clientDataJSON: this.arrayBufferToBase64url(credential.response.clientDataJSON),
                    authenticatorData: this.arrayBufferToBase64url(credential.response.authenticatorData),
                    signature: this.arrayBufferToBase64url(credential.response.signature),
                    userHandle: credential.response.userHandle ? this.arrayBufferToBase64url(credential.response.userHandle) : null
                }
            };

            // Send to server for verification
            const verifyResponse = await fetch(`${this.baseUrl}/auth_verify`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify({
                    credential: credentialForServer
                })
            });

            const result = await verifyResponse.json();

            if (result.success) {
                this.showSuccess('Authentication successful!');
                if (result.redirect_url) {
                    window.location.href = result.redirect_url;
                }
            } else {
                throw new Error(result.error || 'Authentication failed');
            }

        } catch (error) {
            console.error('Passkey authentication error:', error);
            this.showError(error.message);
        }
    }

    getDescription() {
        const input = document.getElementById('passkey-description');
        return input ? input.value.trim() || 'My Passkey' : 'My Passkey';
    }

    // Utility functions for base64url encoding/decoding
    base64urlToArrayBuffer(base64url) {
        const padding = '='.repeat((4 - base64url.length % 4) % 4);
        const base64 = (base64url + padding).replace(/-/g, '+').replace(/_/g, '/');
        const rawData = window.atob(base64);
        const outputArray = new Uint8Array(rawData.length);
        for (let i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray.buffer;
    }

    arrayBufferToBase64url(buffer) {
        const bytes = new Uint8Array(buffer);
        let str = '';
        for (let i = 0; i < bytes.byteLength; i++) {
            str += String.fromCharCode(bytes[i]);
        }
        return window.btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
    }

    showSuccess(message) {
        this.showMessage(message, 'success');
    }

    showError(message) {
        this.showMessage(message, 'error');
    }

    showMessage(message, type) {
        // Remove existing messages
        const existing = document.querySelector('.passkey-message');
        if (existing) {
            existing.remove();
        }

        // Create message element
        const messageEl = document.createElement('div');
        messageEl.className = `passkey-message passkey-message--${type}`;
        messageEl.textContent = message;
        messageEl.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 24px;
            border-radius: 6px;
            color: white;
            font-weight: bold;
            z-index: 10000;
            background: ${type === 'success' ? '#10b981' : '#ef4444'};
        `;

        document.body.appendChild(messageEl);

        // Auto remove after 5 seconds
        setTimeout(() => {
            if (messageEl.parentNode) {
                messageEl.remove();
            }
        }, 5000);
    }

    // Check WebAuthn support
    static isSupported() {
        return window.PublicKeyCredential && 
               navigator.credentials && 
               navigator.credentials.create && 
               navigator.credentials.get;
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    if (!PasskeyManager.isSupported()) {
        console.warn('WebAuthn is not supported in this browser');
        const unsupportedEl = document.getElementById('webauthn-unsupported');
        if (unsupportedEl) {
            unsupportedEl.style.display = 'block';
        }
        return;
    }

    new PasskeyManager();
});