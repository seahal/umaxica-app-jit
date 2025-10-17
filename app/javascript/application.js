// Application entrypoint (bundled by Bun -> app/assets/builds/application.js)
// Import page-level controllers here so views/layouts only include `application.js`.
import "@hotwired/turbo-rails";

// Passkeys (Auth App)
import "./controllers/passkey.js";
