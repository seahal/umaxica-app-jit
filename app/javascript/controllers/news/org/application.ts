export const NEWS_ORG_DEFAULT_ORIGIN = "http://news.org.localhost";

/**
 * Resolves fully-qualified URLs for the news staff surface.
 */
export function resolveNewsOrgUrl(path = "/"): URL {
	return new URL(path, NEWS_ORG_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the news staff container dataset.
 */
export function readNewsOrgProps(
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
