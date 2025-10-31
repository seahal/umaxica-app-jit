// Application entrypoint (bundled by Bun -> app/assets/builds/application.js)
// Import page-level controllers here so views/layouts only include `application.js`.
import "@hotwired/turbo-rails";

// Passkeys (Auth App)
import "./controllers/passkey.js";

// Help Center (React Aria experience)
import "./help/com/landing";
import "./help/app/landing";
