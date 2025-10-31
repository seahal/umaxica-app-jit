export const WWW_APP_DEFAULT_ORIGIN = "http://www.app.localhost";

/**
 * Resolves fully-qualified URLs for the www app surface.
 */
export function resolveWwwAppUrl(path = "/"): URL {
	return new URL(path, WWW_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the www app container dataset.
 */
export function readWwwAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		wwwServiceUrl: dataset.wwwServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}
