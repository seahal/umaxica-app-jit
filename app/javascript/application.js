// Application entrypoint (bundled by Bun -> app/assets/builds/application.js)
// Import page-level views here so views/layouts only include `application.js`.
import "@hotwired/turbo-rails";

// Views
import "./views/root/app/application.ts";
import "./views/root/com/application.ts";
import "./views/root/org/application.ts";
import "./views/docs/app/application.ts";
import "./views/docs/com/application.ts";
import "./views/docs/org/application.ts";
import "./views/help/app/application.ts";
import "./views/help/com/application.ts";
import "./views/help/org/application.ts";
import "./views/news/app/application.ts";
import "./views/news/com/application.ts";
import "./views/news/org/application.ts";
import "./views/sign/app/application.ts";
import "./views/sign/org/application.ts";
import "./views/www/app/application.ts";
import "./views/www/com/application.ts";
import "./views/www/org/application.ts";
import "./views/passkey.js";
import "./views/passkey_helpers.js";
import "./views/www/app/inquiry/before_submit.js";
