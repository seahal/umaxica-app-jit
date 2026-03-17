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

function initThemeFromCookie() {
  const raw = readCookie("ct");
  const theme = resolveTheme(raw);
  applyTheme(theme);

  const valueEl = document.getElementById("js-theme-cookie-value");
  if (valueEl) {
    valueEl.textContent = theme;
  }
}

document.addEventListener("DOMContentLoaded", initThemeFromCookie);
document.addEventListener("turbo:load", initThemeFromCookie);
