import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.applyTheme();
  }

  toggle() {
    const currentTheme = this.getCurrentTheme();
    const newTheme = currentTheme === "dark" ? "light" : "dark";
    this.setTheme(newTheme);
  }

  getCurrentTheme() {
    // Checking localStorage first allows user override
    const stored = localStorage.getItem("theme");
    if (stored) {
      return stored;
    }

    // Fallback to system preference
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  setTheme(theme) {
    localStorage.setItem("theme", theme);
    // Sync with server-side cookie helper (ct)
    const secure = location.protocol === "https:" ? "; secure" : "";
    document.cookie = `ct=${theme}; path=/; max-age=31536000; samesite=lax${secure}`;
    this.applyTheme();
  }

  applyTheme() {
    const theme = this.getCurrentTheme();
    const html = document.documentElement;

    if (theme === "dark") {
      html.classList.add("dark");
      html.classList.remove("theme-light");
      html.classList.add("theme-dark");
    } else {
      html.classList.remove("dark");
      html.classList.remove("theme-dark");
      html.classList.add("theme-light");
    }
  }
}
