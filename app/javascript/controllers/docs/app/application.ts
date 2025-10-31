export const DOCS_APP_DEFAULT_ORIGIN = "http://docs.app.localhost";

/**
 * Resolves fully-qualified URLs for the docs app surface.
 */
export function resolveDocsAppUrl(path = "/"): URL {
	return new URL(path, DOCS_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the docs app container dataset.
 */
const docsAppHostname = new URL(DOCS_APP_DEFAULT_ORIGIN).hostname;

export function readDocsAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}

if (
	typeof window !== "undefined" &&
	window.location.hostname === docsAppHostname
) {
	window.addEventListener("DOMContentLoaded", () => {
		alert("docs");
	});
}
