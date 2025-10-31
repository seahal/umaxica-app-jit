export const NEWS_APP_DEFAULT_ORIGIN = "http://news.app.localhost";

/**
 * Resolves fully-qualified URLs for the news app surface.
 */
export function resolveNewsAppUrl(path = "/"): URL {
	return new URL(path, NEWS_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the news app container dataset.
 */
export function readNewsAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
	};
}
