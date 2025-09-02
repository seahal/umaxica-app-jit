export type HostCategory = "app" | "com" | "org";

// Map a host like "app.localhost" to its category
export function hostToCategory(host: string): HostCategory | null {
  const normalized = (host || "").toLowerCase();
  if (normalized.startsWith("app.")) return "app";
  if (normalized.startsWith("com.")) return "com";
  if (normalized.startsWith("org.")) return "org";
  return null;
}

// Given a host and pathname, ensure it has the right /apex/<category> prefix.
// If it's already prefixed correctly, do nothing. Avoid double prefixes.
export function applyApexPrefix(host: string, pathname: string): string {
  const category = hostToCategory(host);
  const path = pathname || "/";

  if (!category) return path; // unknown host: leave unchanged

  const targetPrefix = `/apex/${category}`;

  // Already correctly prefixed
  if (path === targetPrefix || path.startsWith(`${targetPrefix}/`)) {
    return path;
  }

  // Avoid double-prefix if it already starts with any /apex/<known>
  if (path.startsWith("/apex/app/") || path.startsWith("/apex/com/") || path.startsWith("/apex/org/")) {
    return path;
  }

  // Root-only case
  if (path === "/") return `${targetPrefix}`;

  // Normal case
  return `${targetPrefix}${path.startsWith("/") ? "" : "/"}${path}`;
}

