// Shared helpers for passkey encoding/decoding. Kept DOM-free for testability.

export function csrfToken() {
	return document?.querySelector('meta[name="csrf-token"]')?.content || "";
}

export function toB64url(buf) {
	return btoa(String.fromCharCode(...new Uint8Array(buf)))
		.replace(/\+/g, "-")
		.replace(/\//g, "_")
		.replace(/=+$/, "");
}

export function fromB64url(str) {
	const s = str || "";
	const b64 =
		s.replace(/-/g, "+").replace(/_/g, "/") + "===".slice((s.length + 3) % 4);
	const bin = atob(b64);
	const u8 = new Uint8Array(bin.length);
	for (let i = 0; i < bin.length; i++) u8[i] = bin.charCodeAt(i);
	return u8.buffer;
}

export function decodeCreationOptions(opts) {
	const pk = structuredClone(opts.publicKey);
	pk.challenge = fromB64url(pk.challenge);
	if (pk.user?.id) pk.user.id = fromB64url(pk.user.id);
	if (Array.isArray(pk.excludeCredentials)) {
		pk.excludeCredentials = pk.excludeCredentials.map((c) => ({
			...c,
			id: fromB64url(c.id),
		}));
	}
	return pk;
}
