import { Controller } from "@hotwired/stimulus";

const THEME_CODE_MAP = {
  dr: "dark",
  dark: "dark",
  li: "light",
  light: "light",
  sy: "system",
  system: "system",
};

function readCookie(name) {
  const cookie = document.cookie
    .split(";")
    .map((part) => part.trim().split("="))
    .find(([key]) => key === name);
  return cookie ? decodeURIComponent(cookie[1]) : null;
}

function resolveTheme(value) {
  if (!value) {
    return "system";
  }
  return THEME_CODE_MAP[value.toLowerCase()] || value.toLowerCase();
}

let systemListenerRegistered = false;

function applyTheme(theme) {
  const html = document.documentElement;
  const systemMatch = window.matchMedia("(prefers-color-scheme: dark)");
  const resolveSystem = () => (systemMatch.matches ? "dark" : "light");
  const appliedTheme = theme === "system" ? resolveSystem() : theme;
  html.dataset.theme = theme;
  html.classList.remove("theme-dark", "theme-light", "theme-system");
  html.classList.add(`theme-${theme}`);
  html.classList.toggle("dark", appliedTheme === "dark");

  if (theme === "system" && !systemListenerRegistered) {
    systemListenerRegistered = true;
    systemMatch.addEventListener("change", () => {
      html.classList.toggle("dark", resolveSystem() === "dark");
    });
  }
}

function applyThemeFromCookie() {
  const raw = readCookie("ct");
  const theme = resolveTheme(raw);
  applyTheme(theme);

  const valueEl = document.querySelector("#js-theme-cookie-value");
  if (valueEl) {
    valueEl.textContent = theme;
  }
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content;
}

export default class extends Controller {
  connect() {
    void this.fetchAndSyncTheme();
  }

  async select(event) {
    const { value } = event.target;
    const code = { system: "sy", dark: "dr", light: "li" }[value] ?? "sy";
    await this.updateTheme(code);
  }

  async fetchAndSyncTheme() {
    try {
      const response = await fetch("/web/v0/theme");
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      const themeCode = data.theme || "sy";
      this.syncRadioFromThemeCode(themeCode);
      this.applyThemeFromCode(themeCode);
    } catch {
      this.syncRadio();
      applyThemeFromCookie();
    }
  }

  syncRadio() {
    const raw = document.cookie
      .split(";")
      .map((p) => p.trim().split("="))
      .find(([k]) => k === "ct")?.[1];
    const map = { sy: "system", dr: "dark", li: "light" };
    const value = map[raw] ?? "system";
    const radio = this.element.querySelector(`input[value="${value}"]`);
    if (radio) {
      radio.checked = true;
    }
  }

  syncRadioFromThemeCode(themeCode) {
    const map = { sy: "system", dr: "dark", li: "light" };
    const value = map[themeCode] ?? "system";
    const radio = this.element.querySelector(`input[value="${value}"]`);
    if (radio) {
      radio.checked = true;
    }
  }

  applyThemeFromCode(themeCode) {
    const map = { sy: "system", dr: "dark", li: "light" };
    const theme = map[themeCode] ?? "system";
    applyTheme(theme);

    const valueEl = document.querySelector("#js-theme-cookie-value");
    if (valueEl) {
      valueEl.textContent = theme;
    }
  }

  async updateTheme(themeCode) {
    const response = await fetch("/web/v0/theme", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ theme: themeCode }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    const appliedThemeCode = data.theme || themeCode;
    this.syncRadioFromThemeCode(appliedThemeCode);
    this.applyThemeFromCode(appliedThemeCode);
  }
}
