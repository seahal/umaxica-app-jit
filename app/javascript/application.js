// Application entrypoint (bundled by Bun -> app/assets/builds/application.js)
// Import page-level controllers here so views/layouts only include `application.js`.

// Passkeys (Auth App)
import "./controllers/passkey.js";

// Help > Inquiries page helpers (client-side validation)
import "./controllers/www/app/inquiry/before_submit.js";
